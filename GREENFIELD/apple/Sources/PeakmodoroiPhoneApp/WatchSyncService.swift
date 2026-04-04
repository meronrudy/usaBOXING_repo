#if os(iOS)
import Foundation
import WatchConnectivity

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    @Published private(set) var activationStateDescription = "Inactive"
    @Published private(set) var isReachable = false

    private let encoder = JSONEncoder()
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    override init() {
        super.init()
        encoder.dateEncodingStrategy = .iso8601
        session?.delegate = self
        session?.activate()
    }

    func push(payload: WatchSyncPayload) {
        guard let session, let data = try? encoder.encode(payload) else {
            return
        }
        try? session.updateApplicationContext(["payload": data])
        if session.isReachable {
            session.sendMessageData(data, replyHandler: nil, errorHandler: nil)
        }
    }
}

extension WatchSyncService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            self.activationStateDescription = error == nil ? String(describing: activationState) : "Error"
            self.isReachable = session.isReachable
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
#endif
