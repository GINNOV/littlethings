import ArmageddonCore
import Testing
@testable import ArmageddonMotionBoundary

struct PickPlaceRecipeTests {
    @Test("recipe uses vacuum and G1, never G28")
    func writesPickPlaceWithoutHoming() async throws {
        let serial = FakeSerial()
        await serial.setReplies(
            ["FIRMWARE_NAME:Marlin MACHINE_TYPE:FYSETC_E4\nok\n"]
                + Array(repeating: "ok\n", count: 80)
        )
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)
        try await arm.connect()
        let recipe = PickPlaceRecipe(
            bowlX: 20,
            bowlY: -90,
            bowlZ: 80,
            targetX: 40,
            targetY: -70,
            safeZ: 80,
            pickZ: 18,
            placeZ: 18,
            feedMmPerMin: 300
        )
        try await recipe.run(on: arm)
        let written = await serial.written
        #expect(written.contains("M1400 A1023"))
        #expect(written.contains("M1400 A0"))
        #expect(written.contains { $0.hasPrefix("G1 ") })
        #expect(written.contains("G90"))
        #expect(!written.contains { $0.uppercased().contains("G28") })
    }

    @Test("HuenitArmOperator placeStone uses the same recipe")
    func operatorPlaceStone() async throws {
        let serial = FakeSerial()
        await serial.setReplies(
            ["FIRMWARE_NAME:Marlin MACHINE_TYPE:FYSETC_E4\nok\n"]
                + Array(repeating: "ok\n", count: 80)
        )
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)
        let operator_ = HuenitArmOperator(arm: arm)
        try await operator_.connect()
        try await operator_.placeStone(
            bowl: ArmCartesianPose(x: 20, y: -90, z: 80),
            targetX: 40,
            targetY: -70,
            safeZ: 80,
            pickZ: 18,
            placeZ: 18,
            feedMmPerMin: 300
        )
        let written = await serial.written
        #expect(written.contains("M1400 A1023"))
        #expect(written.contains("M1400 A0"))
        #expect(!written.contains { $0.uppercased().contains("G28") })
    }
}
