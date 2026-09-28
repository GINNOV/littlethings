import CoreMotion
import Foundation
import simd

@MainActor
final class PhoneMotionTracker: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var lastError: String?

    var onQuaternion: ((simd_quatd) -> Void)?

    private let motionManager = CMMotionManager()

    var isAvailable: Bool {
        motionManager.isDeviceMotionAvailable
    }

    func start() {
        guard isAvailable else {
            lastError = "Device motion is unavailable on this device."
            return
        }

        guard !isRunning else { return }

        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        lastError = nil
        isRunning = true

        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motion, error in
            guard let self else { return }

            if let error {
                self.lastError = error.localizedDescription
                return
            }

            guard let motion else { return }

            let quaternion = simd_quatd(
                ix: motion.attitude.quaternion.x,
                iy: motion.attitude.quaternion.y,
                iz: motion.attitude.quaternion.z,
                r: motion.attitude.quaternion.w
            )

            self.onQuaternion?(quaternion)
        }
    }

    func stop() {
        guard isRunning else { return }
        motionManager.stopDeviceMotionUpdates()
        isRunning = false
    }
}
