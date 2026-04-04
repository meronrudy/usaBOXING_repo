#if os(iOS)
import Foundation
import HealthKit

struct HealthFeatureSnapshot {
    var sleepDurationMinutes: UInt16
    var sleepRecencyMinutes: UInt16
    var hrvLatestMs: UInt16
    var hrvMedian7dMs: UInt16
    var restingHRLatestBpm: UInt16
    var restingHRMedian7dBpm: UInt16
    var respiratoryLatestTenths: UInt16
    var respiratoryMedian7dTenths: UInt16
    var hrvAgeHours: UInt16
    var restingHRAgeHours: UInt16
    var respiratoryAgeHours: UInt16
    var sleepAgeHours: UInt16
    var availabilityFlags: UInt32
    var missingSignals: SignalFlags
}

@MainActor
final class HealthSyncCoordinator: NSObject, ObservableObject {
    @Published private(set) var payload: WatchSyncPayload?
    @Published private(set) var authorizationState: AuthorizationState = .unknown

    private let authorizationService: HealthAuthorizationService
    private let store: OperationalStateStore
    private let estimator = PeakcoreEstimator()

    init(
        authorizationService: HealthAuthorizationService = HealthAuthorizationService(),
        store: OperationalStateStore = OperationalStateStore()
    ) {
        self.authorizationService = authorizationService
        self.store = store
        self.payload = {
            guard let snapshot = store.snapshot(), let recommendation = store.recommendation() else {
                return nil
            }
            return WatchSyncPayload(snapshot: snapshot, recommendation: recommendation)
        }()
        super.init()
    }

    func bootstrap() async {
        authorizationState = authorizationService.authorizationState()
        if authorizationState == .authorized {
            installObservers()
            await refresh()
        }
    }

    func requestAuthorization() async {
        do {
            try await authorizationService.requestAuthorization()
            authorizationState = .authorized
            store.setDate(Date(), for: .permissionChangedAt)
            installObservers()
            await refresh()
        } catch {
            authorizationState = authorizationService.authorizationState()
        }
    }

    func refresh() async {
        do {
            try await refreshAnchors()
            let features = try await collectFeatures(referenceDate: Date())
            let generatedAt = Date()
            let payload = try estimator.computePayload(
                from: PeakEstimatorInput(
                    sleepDurationMinutes: features.sleepDurationMinutes,
                    sleepRecencyMinutes: features.sleepRecencyMinutes,
                    hrvLatestMs: features.hrvLatestMs,
                    hrvMedian7dMs: features.hrvMedian7dMs,
                    restingHRLatestBpm: features.restingHRLatestBpm,
                    restingHRMedian7dBpm: features.restingHRMedian7dBpm,
                    respiratoryLatestTenths: features.respiratoryLatestTenths,
                    respiratoryMedian7dTenths: features.respiratoryMedian7dTenths,
                    liveHRDeltaBpm: 0,
                    hrvAgeHours: features.hrvAgeHours,
                    restingHRAgeHours: features.restingHRAgeHours,
                    respiratoryAgeHours: features.respiratoryAgeHours,
                    sleepAgeHours: features.sleepAgeHours,
                    availabilityFlags: features.availabilityFlags,
                    missingSignals: features.missingSignals
                ),
                generatedAt: generatedAt
            )
            self.payload = payload
            store.setSnapshot(payload.snapshot)
            store.setRecommendation(payload.recommendation)
            store.setDate(generatedAt, for: .latestSyncAt)
        } catch {
            self.payload = nil
        }
    }

    private func installObservers() {
        observedSampleTypes.forEach { type in
            let query = HKObserverQuery(sampleType: type.hkSampleType, predicate: nil) { [weak self] _, _, completion, _ in
                defer { completion() }
                Task { @MainActor in
                    await self?.refresh()
                }
            }
            authorizationService.healthStore.execute(query)
            authorizationService.healthStore.enableBackgroundDelivery(for: type.hkSampleType, frequency: .immediate) { _, _ in }
        }
    }

    private func refreshAnchors() async throws {
        for sample in observedSampleTypes {
            try await consumeAnchoredUpdates(for: sample)
        }
    }

    private func consumeAnchoredUpdates(for sample: ObservedSample) async throws {
        let currentAnchor = anchor(for: sample)
        try await withCheckedThrowingContinuation { continuation in
            let query = HKAnchoredObjectQuery(
                type: sample.hkSampleType,
                predicate: nil,
                anchor: currentAnchor,
                limit: HKObjectQueryNoLimit
            ) { [weak self] _, _, _, newAnchor, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                if let newAnchor {
                    self?.storeAnchor(newAnchor, for: sample)
                }
                continuation.resume(returning: ())
            }
            authorizationService.healthStore.execute(query)
        }
    }

    private func collectFeatures(referenceDate: Date) async throws -> HealthFeatureSnapshot {
        async let sleep = fetchSleep(referenceDate: referenceDate)
        async let hrvLatest = fetchLatestQuantity(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli), referenceDate: referenceDate)
        async let hrvMedian = fetchMedianQuantity(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli), daysBack: 7, referenceDate: referenceDate)
        async let restingLatest = fetchLatestQuantity(.restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()), referenceDate: referenceDate)
        async let restingMedian = fetchMedianQuantity(.restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()), daysBack: 7, referenceDate: referenceDate)
        async let respiratoryLatest = fetchLatestQuantity(.respiratoryRate, unit: HKUnit.count().unitDivided(by: .minute()), referenceDate: referenceDate)
        async let respiratoryMedian = fetchMedianQuantity(.respiratoryRate, unit: HKUnit.count().unitDivided(by: .minute()), daysBack: 7, referenceDate: referenceDate)

        let sleepResult = try await sleep
        let hrvLatestResult = try await hrvLatest
        let hrvMedianResult = try await hrvMedian
        let restingLatestResult = try await restingLatest
        let restingMedianResult = try await restingMedian
        let respiratoryLatestResult = try await respiratoryLatest
        let respiratoryMedianResult = try await respiratoryMedian

        var availability: UInt32 = SignalFlags.heartRate.rawValue
        var missing: SignalFlags = []

        if hrvLatestResult.value > 0 && hrvMedianResult.value > 0 {
            availability |= SignalFlags.hrv.rawValue
        } else {
            missing.insert(.hrv)
        }
        if restingLatestResult.value > 0 && restingMedianResult.value > 0 {
            availability |= SignalFlags.restingHeartRate.rawValue
        } else {
            missing.insert(.restingHeartRate)
        }
        if respiratoryLatestResult.value > 0 && respiratoryMedianResult.value > 0 {
            availability |= SignalFlags.respiratoryRate.rawValue
        } else {
            missing.insert(.respiratoryRate)
        }
        if sleepResult.durationMinutes > 0 {
            availability |= SignalFlags.sleep.rawValue
        } else {
            missing.insert(.sleep)
        }

        return HealthFeatureSnapshot(
            sleepDurationMinutes: sleepResult.durationMinutes,
            sleepRecencyMinutes: sleepResult.recencyMinutes,
            hrvLatestMs: hrvLatestResult.value,
            hrvMedian7dMs: hrvMedianResult.value,
            restingHRLatestBpm: restingLatestResult.value,
            restingHRMedian7dBpm: restingMedianResult.value,
            respiratoryLatestTenths: respiratoryLatestResult.value,
            respiratoryMedian7dTenths: respiratoryMedianResult.value,
            hrvAgeHours: hrvLatestResult.ageHours,
            restingHRAgeHours: restingLatestResult.ageHours,
            respiratoryAgeHours: respiratoryLatestResult.ageHours,
            sleepAgeHours: sleepResult.ageHours,
            availabilityFlags: availability,
            missingSignals: missing
        )
    }

    private func fetchLatestQuantity(
        _ identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        referenceDate: Date
    ) async throws -> (value: UInt16, ageHours: UInt16) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return (0, UInt16.max)
        }
        return try await withCheckedThrowingContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: (0, UInt16.max))
                    return
                }
                let value = sample.quantity.doubleValue(for: unit)
                let scaled = identifier == .respiratoryRate ? value * 10.0 : value
                let age = max(0, Int(referenceDate.timeIntervalSince(sample.endDate) / 3600.0))
                continuation.resume(returning: (UInt16(clamping: Int(scaled.rounded())), UInt16(clamping: age)))
            }
            authorizationService.healthStore.execute(query)
        }
    }

    private func fetchMedianQuantity(
        _ identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        daysBack: Int,
        referenceDate: Date
    ) async throws -> (value: UInt16, ageHours: UInt16) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return (0, UInt16.max)
        }
        let startDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: referenceDate) ?? referenceDate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: referenceDate)
        return try await withCheckedThrowingContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let quantitySamples = (samples as? [HKQuantitySample]) ?? []
                guard !quantitySamples.isEmpty else {
                    continuation.resume(returning: (0, UInt16.max))
                    return
                }
                let values = quantitySamples.map { sample -> Int in
                    let raw = sample.quantity.doubleValue(for: unit)
                    let scaled = identifier == .respiratoryRate ? raw * 10.0 : raw
                    return Int(scaled.rounded())
                }.sorted()
                let median = values[values.count / 2]
                let latestDate = quantitySamples.first?.endDate ?? referenceDate
                let age = max(0, Int(referenceDate.timeIntervalSince(latestDate) / 3600.0))
                continuation.resume(returning: (UInt16(clamping: median), UInt16(clamping: age)))
            }
            authorizationService.healthStore.execute(query)
        }
    }

    private func fetchSleep(referenceDate: Date) async throws -> (durationMinutes: UInt16, recencyMinutes: UInt16, ageHours: UInt16) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return (0, UInt16.max, UInt16.max)
        }
        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: referenceDate) ?? referenceDate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: referenceDate)
        return try await withCheckedThrowingContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let categorySamples = (samples as? [HKCategorySample]) ?? []
                let asleepSamples = categorySamples.filter { $0.value != HKCategoryValueSleepAnalysis.inBed.rawValue }
                guard let latest = asleepSamples.first else {
                    continuation.resume(returning: (0, UInt16.max, UInt16.max))
                    return
                }
                let totalMinutes = asleepSamples.reduce(0.0) { partial, sample in
                    partial + sample.endDate.timeIntervalSince(sample.startDate) / 60.0
                }
                let recency = max(0, Int(referenceDate.timeIntervalSince(latest.endDate) / 60.0))
                let age = max(0, Int(referenceDate.timeIntervalSince(latest.endDate) / 3600.0))
                continuation.resume(returning: (UInt16(clamping: Int(totalMinutes.rounded())), UInt16(clamping: recency), UInt16(clamping: age)))
            }
            authorizationService.healthStore.execute(query)
        }
    }

    private var observedSampleTypes: [ObservedSample] {
        [.heartRate, .hrv, .restingHeartRate, .respiratoryRate, .sleep]
    }

    private func anchor(for sample: ObservedSample) -> HKQueryAnchor? {
        guard let data = store.anchorData(for: sample.storeKey) else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
    }

    private func storeAnchor(_ anchor: HKQueryAnchor, for sample: ObservedSample) {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
        store.setAnchorData(data, for: sample.storeKey)
    }
}

private enum ObservedSample {
    case heartRate
    case hrv
    case restingHeartRate
    case respiratoryRate
    case sleep

    var hkSampleType: HKSampleType {
        switch self {
        case .heartRate:
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        case .hrv:
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        case .restingHeartRate:
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        case .respiratoryRate:
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
        case .sleep:
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        }
    }

    var storeKey: OperationalStateKey {
        switch self {
        case .heartRate:
            .heartRateAnchor
        case .hrv:
            .hrvAnchor
        case .restingHeartRate:
            .restingHeartRateAnchor
        case .respiratoryRate:
            .respiratoryRateAnchor
        case .sleep:
            .sleepAnchor
        }
    }
}
#endif
