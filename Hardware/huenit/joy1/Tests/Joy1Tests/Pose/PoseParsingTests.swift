import Testing
@testable import Joy1

struct PoseParsingTests {
    @Test func parseCartesianM1008A3() throws {
        let text = "X:-0.12 Y:233.81 Z:3.15\nok\n"
        let pose = try CartesianPose.parseM1008(text)
        #expect(abs(pose.x - (-0.12)) < 0.001)
        #expect(abs(pose.y - 233.81) < 0.001)
        #expect(abs(pose.z - 3.15) < 0.001)
    }

    @Test func parseJointsM1008A2() throws {
        let text = "A:164.97 B:60.73 C:31.64\nok\n"
        let pose = try JointPose.parseM1008(text)
        #expect(abs(pose.a - 164.97) < 0.001)
        #expect(abs(pose.b - 60.73) < 0.001)
        #expect(abs(pose.c - 31.64) < 0.001)
    }

    @Test func parseCartesianIgnoresExtraTokens() throws {
        let text = "MAX:1 X:-0.12 Y:233.81 Z:3.15"
        let pose = try CartesianPose.parseM1008(text)
        #expect(abs(pose.x - (-0.12)) < 0.001)
        #expect(abs(pose.y - 233.81) < 0.001)
        #expect(abs(pose.z - 3.15) < 0.001)
    }

    @Test func cartesianValueForJointAxisIsNil() {
        let pose = CartesianPose(x: 1, y: 2, z: 3)
        #expect(pose.value(for: .a) == nil)
        #expect(pose.value(for: .b) == nil)
        #expect(pose.value(for: .c) == nil)
        #expect(pose.value(for: .x) == 1)
    }

    @Test func parseBrokenLineThrows() {
        #expect(throws: ArmError.self) {
            _ = try CartesianPose.parseM1008("garbage\nok\n")
        }
    }

    @Test func identityLooksLikeHuenit() {
        let text = "FIRMWARE_NAME:Marlin bugfix-2.0.x (Jun 28 2025 14:44:59) MACHINE_TYPE:FYSETC_E4\nok\n"
        #expect(FirmwareIdentity.parse(text).isHuenitMarlin)
    }

    @Test func identityRejectsRandom() {
        #expect(!FirmwareIdentity.parse("hello").isHuenitMarlin)
    }

    @Test func parseM114ExtrasReadsEAndMotorStatus() {
        let text = "X:0.22 Y:216.26 Z:-61.97 E:240.00 current_module:0 module_status:0 motor_status:1\nok\n"
        let extras = ArmPose.parseM114Extras(text)
        #expect(abs(extras.e - 240) < 0.001)
        #expect(extras.motorStatus == 1)
    }

    @Test func officialHomeIsLabHome() {
        #expect(CartesianPose.officialHome.x == 0)
        #expect(CartesianPose.officialHome.y == 180)
        #expect(CartesianPose.officialHome.z == 0)
    }
}
