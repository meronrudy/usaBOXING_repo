#if os(watchOS)
import Foundation
import HealthKit

@MainActor
final class WatchWorkoutController: NSObject, ObservableObject {
    @Published private(set) var currentHeartRate: Double?
    @Published private(set) var heartRateAvailable = false

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func start() throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .mindAndBody
        configuration.locationType = .indoor

        let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        let builder = session.associatedWorkoutBuilder()
        session.delegate = self
        builder.delegate = self
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        let startDate = Date()
        session.startActivity(with: startDate)
        builder.beginCollection(withStart: startDate) { _, _ in }

        self.session = session
        self.builder = builder
    }

    func stop() {
        let endDate = Date()
        builder?.endCollection(withEnd: endDate) { [weak self] _, _ in
            self?.builder?.finishWorkout { _, _ in }
        }
        session?.end()
        currentHeartRate = nil
        heartRateAvailable = false
    }
}

extension WatchWorkoutController: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}
}

extension WatchWorkoutController: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        guard collectedTypes.contains(heartRateType) else {
            return
        }
        guard let statistics = workoutBuilder.statistics(for: heartRateType) else {
            return
        }
        let unit = HKUnit.count().unitDivided(by: .minute())
        let value = statistics.mostRecentQuantity()?.doubleValue(for: unit)
        Task { @MainActor in
            self.currentHeartRate = value
            self.heartRateAvailable = value != nil
        }
    }
}
#endif
