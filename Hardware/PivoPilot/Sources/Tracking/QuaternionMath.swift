import Foundation
import simd

enum QuaternionMath {
    static func delta(reference: simd_quatd, current: simd_quatd) -> simd_quatd {
        simd_inverse(reference) * current
    }

    static func yaw(from q: simd_quatd) -> Double {
        let w = q.real
        let x = q.imag.x
        let y = q.imag.y
        let z = q.imag.z

        return atan2(
            2 * (w * z + x * y),
            1 - 2 * (y * y + z * z)
        )
    }

    static func normalize(_ angle: Double) -> Double {
        var normalized = angle

        while normalized > .pi {
            normalized -= 2 * .pi
        }

        while normalized < -.pi {
            normalized += 2 * .pi
        }

        return normalized
    }

    static func radiansToDegrees(_ angle: Double) -> Double {
        angle * 180 / .pi
    }
}
