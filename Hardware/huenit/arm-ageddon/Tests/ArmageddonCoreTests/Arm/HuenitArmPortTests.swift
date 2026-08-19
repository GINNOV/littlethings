import Testing
@testable import ArmageddonMotionBoundary

struct HuenitArmPortTests {
    actor PermitSequence {
        private var checks = 0

        func next() -> Bool {
            checks += 1
            return checks == 1
        }
    }

    @Test("Recorded handshake uses the HUENIT serial profile")
    func recordedHandshakeAndJog() async throws {
        let serial = FakeSerial()
        await serial.setReplies([
            "FIRMWARE_NAME:Marlin bugfix MACHINE_TYPE:FYSETC_E4\nok\n",
            "ok\n",
            "ok\n",
            "ok\n",
        ])
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)

        try await arm.connect()
        try await arm.jogCartesian(axis: .x, deltaMm: 3, feedMmPerMin: 1200)

        #expect(await serial.written == ["M115", "G21", "G91", "G1 X3.0000 F1200.0"])
        #expect(await arm.isConnected)
    }

    @Test("Non-HUENIT firmware fails closed and closes the port")
    func rejectsUnexpectedFirmware() async {
        let serial = FakeSerial()
        await serial.setReplies(["hello\nok\n"])
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)

        let thrown = await #expect(throws: ArmError.self) { try await arm.connect() }

        if case .connectFailed = thrown {} else { Issue.record("expected connectFailed") }
        #expect(await serial.isOpen == false)
        #expect(await serial.written == ["M115"])
    }

    @Test("Serial timeout clears pending input")
    func timeoutClearsPending() async {
        let serial = FakeSerial()
        await serial.setReplies(["not-ok\n"])
        try? await serial.open()
        try? await serial.writeLine("M115")

        await #expect(throws: ArmError.timeout) {
            _ = try await serial.readUntilOk(timeout: .milliseconds(20))
        }
        try? await serial.writeLine("M114")
        await #expect(throws: ArmError.timeout) {
            _ = try await serial.readUntilOk(timeout: .milliseconds(20))
        }
    }

    @Test("Pose parsing rejects malformed responses and preserves labeled values")
    func poseParsing() throws {
        let cartesian = try CartesianPose.parseM1008("MAX:1 X:-0.12 Y:233.81 Z:3.15")
        #expect(abs(cartesian.x - (-0.12)) < 0.001)
        #expect(abs(cartesian.y - 233.81) < 0.001)
        #expect(throws: ArmError.self) { _ = try CartesianPose.parseM1008("garbage\nok\n") }

        let joints = try JointPose.parseM1008("A:164.97 B:60.73 C:31.64\nok\n")
        #expect(abs(joints.a - 164.97) < 0.001)
        let extras = ArmPose.parseM114Extras("E:240.00 motor_status:1\nok\n")
        #expect(abs(extras.e - 240) < 0.001)
        #expect(extras.motorStatus == 1)
    }

    @Test("Pose query uses the recorded M1008 and M114 sequence")
    func queryPose() async throws {
        let serial = FakeSerial()
        await serial.setReplies([
            "X:-0.12 Y:233.81 Z:3.15\nok\n",
            "A:164.97 B:60.73 C:31.64\nok\n",
            "X:-0.12 Y:233.81 Z:3.15 E:240.00 motor_status:1\nok\n",
        ])
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)
        await arm.forceConnectedForTests()

        let pose = try await arm.queryPose()

        #expect(abs(pose.cartesian.y - 233.81) < 0.001)
        #expect(abs(pose.joints.a - 164.97) < 0.001)
        #expect(pose.motorStatus == 1)
        #expect(await serial.written == ["M1008 A3", "M1008 A2", "M114"])
    }

    @Test("Vacuum, motors, and flush preserve exact command profiles")
    func commandProfiles() async throws {
        let serial = FakeSerial()
        await serial.setReplies(Array(repeating: "ok\n", count: 5))
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)
        await arm.forceConnectedForTests()

        try await arm.setVacuum(true)
        try await arm.setVacuum(false)
        try await arm.setMotors(true)
        try await arm.setMotors(false)
        try await arm.flush()

        #expect(await serial.written == ["M1400 A1023", "M1400 A0", "M17", "M84", "M400"])
    }

    @Test("Absolute moves restore relative mode and flush")
    func absoluteMoveRestoresRelativeMode() async throws {
        let serial = FakeSerial()
        await serial.setReplies(Array(repeating: "ok\n", count: 4))
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)
        await arm.forceConnectedForTests()

        try await arm.home(feedMmPerMin: 600)

        #expect(await serial.written == [
            "G90",
            "G1 X0.0000 Y180.0000 Z0.0000 F600.0",
            "M400",
            "G91",
        ])
    }

    @Test("Aborted absolute moves restore relative mode before later jogs")
    func abortedAbsoluteMoveRestoresRelativeMode() async throws {
        let serial = FakeSerial()
        await serial.setReplies(Array(repeating: "ok\n", count: 10))
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)
        await arm.forceConnectedForTests()
        let sequence = PermitSequence()
        let permit: ArmMotionPermit = { await sequence.next() }

        await #expect(throws: ArmError.motionInvalidated) {
            try await arm.moveAbsolute(x: 1, y: 2, z: 3, feedMmPerMin: 600, motionPermit: permit)
        }
        try await arm.step(dx: 1, dy: 0, dz: 0, feedMmPerMin: 1200)

        #expect(await serial.written == ["G90", "G91", "G1 X1.0000 F1200.0"])
    }

    @Test("Stop attempts vacuum off, M410, and explicit M84 fallback")
    func stopProfile() async throws {
        let serial = FakeSerial()
        await serial.setReplies(["ok\n"])
        let arm = HuenitArm(transport: serial, commandTimeout: .milliseconds(20), settleAfterOpen: .zero)
        await arm.forceConnectedForTests()

        await #expect(throws: ArmError.timeout) { try await arm.stop() }

        #expect(await serial.written == ["M1400 A0", "M410", "M84"])
    }

    @Test("Every G28 casing and embedding is rejected before any write")
    func forbiddenG28WritesNothing() async {
        let serial = FakeSerial()
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)
        await arm.forceConnectedForTests()

        for command in ["G28", "g28", "G1 X10 ; then G28", "G0 g28"] {
            await #expect(throws: ArmError.forbiddenCommand("G28")) {
                try await arm.send(command)
            }
        }

        #expect(await serial.written.isEmpty)
    }

    @Test("Disconnect closes transport and clears connection state")
    func disconnectCleanup() async {
        let serial = FakeSerial()
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)
        await arm.forceConnectedForTests()
        try? await serial.open()

        await arm.disconnect()

        #expect(await arm.isConnected == false)
        #expect(await serial.isOpen == false)
    }

    @Test("Port selection never treats HUENIT_CAM as an arm")
    func cameraCannotWinArmSelection() {
        let camera = SerialCandidate(path: "/dev/cu.usbserial-cam", product: "HUENIT_CAM", serial: "cam", vid: 0x0403, pid: 0x6015)
        let arm = SerialCandidate(path: "/dev/cu.usbserial-arm", product: "HUENIT_HUEARM", serial: "arm", vid: 0x0403, pid: 0x6015)

        #expect(PortDetector.pickArm(from: [camera]) == nil)
        #expect(PortDetector.pickArm(from: [camera, arm]) == arm)
    }
}
