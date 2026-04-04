#if os(watchOS)
import Foundation

@MainActor
final class WatchAppModel: ObservableObject {
    enum Phase {
        case idle
        case focus
        case breakTime
    }

    @Published private(set) var payload: WatchSyncPayload?
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var remainingSeconds = 0

    let bridge = WatchConnectivityBridge()
    let workout = WatchWorkoutController()

    private var timer: Timer?

    func activate() {
        bridge.activate()
        payload = bridge.payload
    }

    func refreshPayload() {
        payload = bridge.payload
    }

    func startSession() {
        refreshPayload()
        guard gate.canStart, let payload else { return }
        do {
            try workout.start()
        } catch {
            return
        }
        phase = .focus
        remainingSeconds = payload.recommendation.focusMinutes * 60
        installTimer()
    }

    func stopSession() {
        timer?.invalidate()
        timer = nil
        phase = .idle
        remainingSeconds = 0
        workout.stop()
    }

    var gate: FocusGateDecision {
        SnapshotPolicy.activeFocusGate(
            payload: payload,
            now: Date(),
            calendar: .current,
            permissionChangedAt: nil,
            watchHeartRateAvailable: workout.heartRateAvailable || phase == .idle
        )
    }

    private func installTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            transitionPhase()
            return
        }
        remainingSeconds -= 1
    }

    private func transitionPhase() {
        guard let payload else {
            stopSession()
            return
        }

        switch phase {
        case .idle:
            break
        case .focus:
            phase = .breakTime
            remainingSeconds = payload.recommendation.breakMinutes * 60
        case .breakTime:
            stopSession()
        }
    }
}
#endif
