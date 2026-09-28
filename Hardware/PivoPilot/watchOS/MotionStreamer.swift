import CoreMotion
import Foundation
import WatchConnectivity

final class MotionStreamer: NSObject, WCSessionDelegate {
    private let motionManager = CMMotionManager()

    override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion else { return }
            guard WCSession.default.activationState == .activated else { return }

            let payload: [String: Double] = [
                "yaw": motion.attitude.yaw,
                "pitch": motion.attitude.pitch,
                "roll": motion.attitude.roll
            ]

            WCSession.default.sendMessage(payload, replyHandler: nil)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
}
