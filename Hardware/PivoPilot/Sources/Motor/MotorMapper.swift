import Foundation

final class MotorMapper {
    private let deadbandDegrees: Double
    private let maxSpeed: Int
    private let maxAngleForFullSpeed: Double

    init(deadbandDegrees: Double = 4, maxSpeed: Int = 60, maxAngleForFullSpeed: Double = 40) {
        self.deadbandDegrees = deadbandDegrees
        self.maxSpeed = maxSpeed
        self.maxAngleForFullSpeed = maxAngleForFullSpeed
    }

    func command(forYawRadians yaw: Double) -> MotorCommand {
        let degrees = QuaternionMath.radiansToDegrees(yaw)
        let magnitude = abs(degrees)

        guard magnitude >= deadbandDegrees else {
            return .stop
        }

        let normalized = min(magnitude / maxAngleForFullSpeed, 1)
        let speed = max(8, Int((normalized * Double(maxSpeed)).rounded()))

        if degrees > 0 {
            return .rotateRight(speed: speed)
        }

        return .rotateLeft(speed: speed)
    }
}
