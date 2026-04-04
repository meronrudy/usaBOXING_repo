#if os(watchOS)
import Foundation
import WatchConnectivity

@MainActor
final class WatchConnectivityBridge: NSObject, ObservableObject {
    @Published private(set) var payload: WatchSyncPayload?
    private let decoder = JSONDecoder()
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    override init() {
        super.init()
        decoder.dateDecodingStrategy = .iso8601
        session?.delegate = self
    }

    func activate() {
        session?.activate()
        if let data = session?.receivedApplicationContext["payload"] as? Data {
            payload = try? decoder.decode(WatchSyncPayload.self, from: data)
        }
    }
}

extension WatchConnectivityBridge: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext["payload"] as? Data else { return }
        Task { @MainActor in
            self.payload = try? self.decoder.decode(WatchSyncPayload.self, from: data)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        Task { @MainActor in
            self.payload = try? self.decoder.decode(WatchSyncPayload.self, from: messageData)
        }
    }
}
#endif
