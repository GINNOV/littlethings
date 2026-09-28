import CoreMotion
import Foundation
import simd

@MainActor
final class AirPodsHeadTracker: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var lastError: String?

    var onQuaternion: ((simd_quatd) -> Void)?

    private let manager = CMHeadphoneMotionManager()

    var isAvailable: Bool {
        manager.isDeviceMotionAvailable
    }

    func start() {
        guard isAvailable else {
            lastError = "Headphone motion is unavailable. Connect supported AirPods and enable motion access."
            return
        }

        guard !isRunning else { return }

        lastError = nil
        isRunning = true

        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
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
        manager.stopDeviceMotionUpdates()
        isRunning = false
    }
}
