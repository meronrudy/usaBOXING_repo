#if os(macOS)
import Foundation

@MainActor
final class PeakmodoroMacAppModel: ObservableObject {
    @Published private(set) var payload: WatchSyncPayload?
    @Published private(set) var dashboardState: DashboardState = .blocked("No local readiness snapshot.")
    @Published private(set) var gate: FocusGateDecision = FocusGateDecision(
        canStart: false,
        staleReason: .missingRequiredSignal,
        detail: "No readiness snapshot is available."
    )

    private let store: OperationalStateStore
    private let calendar: Calendar

    init(
        store: OperationalStateStore = OperationalStateStore(),
        calendar: Calendar = .current
    ) {
        self.store = store
        self.calendar = calendar
    }

    func bootstrap() {
        reload()
    }

    func reload() {
        guard let snapshot = store.snapshot(), let recommendation = store.recommendation() else {
            update(payload: nil)
            return
        }
        update(payload: WatchSyncPayload(snapshot: snapshot, recommendation: recommendation))
    }

    func useSamplePayload() {
        update(payload: Self.samplePayload(generatedAt: Date()))
    }

    private func update(payload: WatchSyncPayload?) {
        self.payload = payload
        dashboardState = SnapshotPolicy.dashboardState(snapshot: payload?.snapshot)
        gate = SnapshotPolicy.activeFocusGate(
            payload: payload,
            now: Date(),
            calendar: calendar,
            permissionChangedAt: store.date(for: .permissionChangedAt),
            watchHeartRateAvailable: true
        )
    }

    private static func samplePayload(generatedAt: Date) -> WatchSyncPayload {
        let snapshot = ReadinessSnapshot(
            readiness: 72,
            fatigue: 28,
            volatility: 18,
            confidence: 84,
            band: .green,
            missingSignals: [],
            generatedAt: generatedAt
        )
        let recommendation = FocusRecommendation(
            focusMinutes: 40,
            breakMinutes: 8,
            staleReasonCode: .none,
            generatedAt: generatedAt
        )
        return WatchSyncPayload(snapshot: snapshot, recommendation: recommendation)
    }
}
#endif
