import XCTest
@testable import DogBotProtocol

final class StayAwakeTests: XCTestCase {
    func testKeepAliveUsesVendorStandPacket() {
        // Vendor map: Stand / Handstand is F0 2A 00 28 D5 FF D7. Unused 2A 00 00
        // is ignored by firmware, so a guessed heartbeat cannot keep the dog awake.
        let expected = Data([0xF0, 0x2A, 0x00, 0x28, 0xD5, 0xFF, 0xD7])
        XCTAssertEqual(RobotCommand.keepAlive.packet, expected)
        XCTAssertEqual(RobotCommand.keepAlive.packet, RobotCommand.handstand.packet)
    }

    func testStayAwakeReplacesStopWithKeepAlive() {
        XCTAssertEqual(RobotCommand.outbound(.stop, stayAwake: true), .keepAlive)
    }

    func testStayAwakeLeavesMotionCommandsAlone() {
        XCTAssertEqual(RobotCommand.outbound(.forward, stayAwake: true), .forward)
        XCTAssertEqual(RobotCommand.outbound(.sit, stayAwake: true), .sit)
    }

    func testStayAwakeOffSendsStop() {
        XCTAssertEqual(RobotCommand.outbound(.stop, stayAwake: false), .stop)
    }
}
