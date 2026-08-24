import ArmageddonCore
import Foundation

public actor HuenitArmOperator: ArmOperatorControlling {
    private let arm: HuenitArm

    public init(serialPath: String) {
        arm = HuenitArm(transport: SerialPort(path: serialPath))
    }

    init(arm: HuenitArm) {
        self.arm = arm
    }

    public func connect() async throws {
        try await arm.connect()
    }

    public func disconnect() async {
        await arm.disconnect()
    }

    public func pose() async throws -> ArmCartesianPose {
        let pose = try await arm.queryPose()
        return ArmCartesianPose(x: pose.cartesian.x, y: pose.cartesian.y, z: pose.cartesian.z)
    }

    public func step(dx: Double, dy: Double, dz: Double, feedMmPerMin: Double) async throws {
        try await arm.step(dx: dx, dy: dy, dz: dz, feedMmPerMin: feedMmPerMin)
    }

    public func setVacuum(_ on: Bool) async throws {
        try await arm.setVacuum(on)
    }

    public func placeStone(
        bowl: ArmCartesianPose,
        targetX: Double,
        targetY: Double,
        safeZ: Double,
        pickZ: Double,
        placeZ: Double,
        feedMmPerMin: Double
    ) async throws {
        let recipe = PickPlaceRecipe(
            bowlX: bowl.x,
            bowlY: bowl.y,
            bowlZ: bowl.z,
            targetX: targetX,
            targetY: targetY,
            safeZ: safeZ,
            pickZ: pickZ,
            placeZ: placeZ,
            feedMmPerMin: feedMmPerMin
        )
        try await recipe.run(on: arm)
    }

    public func emergencyStop() async {
        try? await arm.stop()
    }
}

public struct ArmSerialPort: Sendable, Equatable, Identifiable {
    public var id: String { path }
    public let path: String
    public let label: String
}

public enum ArmPortPicker {
    public static func scan() -> [ArmSerialPort] {
        PortDetector.scan().map { candidate in
            let extra = [candidate.product, candidate.serial].compactMap { $0 }.joined(separator: " · ")
            return ArmSerialPort(
                path: candidate.path,
                label: extra.isEmpty ? candidate.path : "\(candidate.path) (\(extra))"
            )
        }
    }

    public static func preferredPath(in ports: [ArmSerialPort]? = nil) -> String? {
        if let ports {
            let candidates = PortDetector.scan().filter { port in
                ports.contains(where: { $0.path == port.path })
            }
            return PortDetector.pickArm(from: candidates.isEmpty ? PortDetector.scan() : candidates)?.path
        }
        return PortDetector.pickArm(from: PortDetector.scan())?.path
    }
}
