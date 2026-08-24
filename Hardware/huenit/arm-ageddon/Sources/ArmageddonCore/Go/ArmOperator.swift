public struct ArmCartesianPose: Sendable, Equatable {
    public var x: Double
    public var y: Double
    public var z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public enum ArmOperatorError: Error, Equatable, Sendable {
    case disconnected
    case rejected(String)
}

public protocol ArmOperatorControlling: Sendable {
    func connect() async throws
    func disconnect() async
    func pose() async throws -> ArmCartesianPose
    func step(dx: Double, dy: Double, dz: Double, feedMmPerMin: Double) async throws
    func setVacuum(_ on: Bool) async throws
    func placeStone(
        bowl: ArmCartesianPose,
        targetX: Double,
        targetY: Double,
        safeZ: Double,
        pickZ: Double,
        placeZ: Double,
        feedMmPerMin: Double
    ) async throws
    func emergencyStop() async
}

public struct NullArmOperator: ArmOperatorControlling {
    public init() {}

    public func connect() async throws {}

    public func disconnect() async {}

    public func pose() async throws -> ArmCartesianPose {
        ArmCartesianPose(x: 0, y: 0, z: 0)
    }

    public func step(dx: Double, dy: Double, dz: Double, feedMmPerMin: Double) async throws {
        _ = dx
        _ = dy
        _ = dz
        _ = feedMmPerMin
        throw ArmOperatorError.rejected("not attached")
    }

    public func setVacuum(_ on: Bool) async throws {
        _ = on
        throw ArmOperatorError.rejected("not attached")
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
        _ = bowl
        _ = targetX
        _ = targetY
        _ = safeZ
        _ = pickZ
        _ = placeZ
        _ = feedMmPerMin
        throw ArmOperatorError.rejected("not attached")
    }

    public func emergencyStop() async {}
}
