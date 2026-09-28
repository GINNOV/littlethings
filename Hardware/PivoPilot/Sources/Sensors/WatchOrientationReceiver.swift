import Foundation
import WatchConnectivity

@MainActor
final class WatchOrientationReceiver: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var isRunning = false
    @Published private(set) var lastError: String?

    var onYawRadians: ((Double) -> Void)?

    private(set) var latestYawRadians: Double = 0

    override init() {
        super.init()
        guard WCSession.isSupported() else {
            lastError = "Watch Connectivity is unavailable on this device."
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func start() {
        isRunning = true
        lastError = nil
    }

    func stop() {
        isRunning = false
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error {
            Task { @MainActor in
                self.lastError = error.localizedDescription
            }
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let yaw = message["yaw"] as? Double else { return }

        Task { @MainActor in
            self.latestYawRadians = yaw
            if self.isRunning {
                self.onYawRadians?(yaw)
            }
        }
    }
}
