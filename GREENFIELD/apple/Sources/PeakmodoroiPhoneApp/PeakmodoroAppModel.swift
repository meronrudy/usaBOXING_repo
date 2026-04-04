#if os(iOS)
import Foundation

@MainActor
final class PeakmodoroAppModel: ObservableObject {
    @Published private(set) var payload: WatchSyncPayload?
    @Published private(set) var dashboardState: DashboardState = .blocked("Authorizing Health data…")
    @Published private(set) var authorizationState: AuthorizationState = .unknown

    let watchSync = WatchSyncService()
    private let coordinator = HealthSyncCoordinator()

    func bootstrap() async {
        await coordinator.bootstrap()
        await syncFromCoordinator()
    }

    func requestAuthorization() async {
        await coordinator.requestAuthorization()
        await syncFromCoordinator()
    }

    func refresh() async {
        await coordinator.refresh()
        await syncFromCoordinator()
    }

    private func syncFromCoordinator() async {
        payload = coordinator.payload
        authorizationState = coordinator.authorizationState
        dashboardState = SnapshotPolicy.dashboardState(snapshot: payload?.snapshot)
        if let payload {
            watchSync.push(payload: payload)
        }
    }
}
#endif
