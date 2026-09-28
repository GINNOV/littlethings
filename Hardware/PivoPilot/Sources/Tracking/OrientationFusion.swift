import Combine
import Foundation
import simd

@MainActor
final class OrientationFusion: ObservableObject {
    @Published private(set) var rawYawRadians: Double = 0
    @Published private(set) var smoothedYawRadians: Double = 0
    @Published private(set) var referenceCaptured = false

    private var referenceQuaternion: simd_quatd?
    private var referenceYawRadians: Double?
    private let filter = SmoothingFilter(alpha: 0.18)

    var rawYawDegrees: Double {
        QuaternionMath.radiansToDegrees(rawYawRadians)
    }

    var smoothedYawDegrees: Double {
        QuaternionMath.radiansToDegrees(smoothedYawRadians)
    }

    func recenter() {
        referenceQuaternion = nil
        referenceYawRadians = nil
        referenceCaptured = false
        rawYawRadians = 0
        smoothedYawRadians = 0
        filter.reset()
    }

    func update(current quaternion: simd_quatd) {
        if referenceQuaternion == nil {
            referenceQuaternion = quaternion
            referenceCaptured = true
        }

        guard let referenceQuaternion else { return }
        let delta = QuaternionMath.delta(reference: referenceQuaternion, current: quaternion)
        let yaw = QuaternionMath.normalize(QuaternionMath.yaw(from: delta))
        apply(yawRadians: yaw)
    }

    func update(yawRadians: Double) {
        if referenceYawRadians == nil {
            referenceYawRadians = yawRadians
            referenceCaptured = true
        }

        guard let referenceYawRadians else { return }
        let normalized = QuaternionMath.normalize(yawRadians - referenceYawRadians)
        apply(yawRadians: normalized)
    }

    private func apply(yawRadians: Double) {
        rawYawRadians = yawRadians
        smoothedYawRadians = QuaternionMath.normalize(filter.update(yawRadians))
    }
}
