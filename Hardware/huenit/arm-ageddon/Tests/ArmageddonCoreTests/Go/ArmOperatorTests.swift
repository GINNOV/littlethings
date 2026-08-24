import Testing
@testable import ArmageddonCore

struct ArmOperatorTests {
    @Test("Null operator connects and reports a zero pose")
    func nullConnects() async throws {
        let arm = NullArmOperator()
        try await arm.connect()
        let pose = try await arm.pose()
        #expect(pose == ArmCartesianPose(x: 0, y: 0, z: 0))
        await arm.disconnect()
    }

    @Test("Null operator rejects step and vacuum")
    func nullRejectsMotion() async {
        let arm = NullArmOperator()
        await #expect(throws: ArmOperatorError.rejected("not attached")) {
            try await arm.step(dx: 1, dy: 0, dz: 0, feedMmPerMin: 300)
        }
        await #expect(throws: ArmOperatorError.rejected("not attached")) {
            try await arm.setVacuum(true)
        }
        await #expect(throws: ArmOperatorError.rejected("not attached")) {
            try await arm.placeStone(
                bowl: ArmCartesianPose(x: 0, y: 0, z: 80),
                targetX: 10,
                targetY: 10,
                safeZ: 80,
                pickZ: 18,
                placeZ: 18,
                feedMmPerMin: 300
            )
        }
    }
}
