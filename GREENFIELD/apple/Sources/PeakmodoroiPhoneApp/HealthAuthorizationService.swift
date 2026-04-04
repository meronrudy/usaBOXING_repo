#if os(iOS)
import Foundation
import HealthKit

final class HealthAuthorizationService {
    let healthStore: HKHealthStore

    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }

    var requiredTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = []
        let identifiers: [HKQuantityTypeIdentifier] = [
            .heartRate,
            .heartRateVariabilitySDNN,
            .restingHeartRate,
            .respiratoryRate
        ]

        identifiers.compactMap { HKObjectType.quantityType(forIdentifier: $0) }.forEach { types.insert($0) }
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleep)
        }
        return types
    }

    func requestAuthorization() async throws {
        try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: requiredTypes) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                if success {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: CocoaError(.userCancelled))
                }
            }
        }
    }

    func authorizationState() -> AuthorizationState {
        let allAuthorized = requiredTypes.allSatisfy { type in
            healthStore.authorizationStatus(for: type) == .sharingAuthorized
        }
        if allAuthorized {
            return .authorized
        }

        let anyDenied = requiredTypes.contains { type in
            healthStore.authorizationStatus(for: type) == .sharingDenied
        }
        return anyDenied ? .denied : .unknown
    }
}
#endif
