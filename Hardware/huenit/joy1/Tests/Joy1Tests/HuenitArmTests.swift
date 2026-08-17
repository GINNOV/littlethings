import Testing
@testable import Joy1

struct FakeSerialTests {
    @Test func writeLineRecordsAndReadUntilOk() async throws {
        let serial = FakeSerial()
        await serial.setReplies(["FIRMWARE_NAME:Marlin MACHINE_TYPE:FYSETC_E4\nok\n"])
        try await serial.open()
        try await serial.writeLine("M115")
        let reply = try await serial.readUntilOk(timeout: .seconds(1))
        #expect(await serial.written == ["M115"])
        #expect(reply.contains("FYSETC_E4"))
        await serial.close()
    }

    @Test func timeoutWhenNoOk() async {
        let serial = FakeSerial()
        await serial.setReplies(["nope\n"])
        try? await serial.open()
        try? await serial.writeLine("M115")
        await #expect(throws: ArmError.timeout) {
            _ = try await serial.readUntilOk(timeout: .milliseconds(50))
        }
    }

    @Test func timeoutClearsPendingSoLaterWriteTimesOutWithoutNewReply() async {
        let serial = FakeSerial()
        await serial.setReplies(["nope\n"])
        try? await serial.open()
        try? await serial.writeLine("M115")
        await #expect(throws: ArmError.timeout) {
            _ = try await serial.readUntilOk(timeout: .milliseconds(50))
        }
        try? await serial.writeLine("M114")
        await #expect(throws: ArmError.timeout) {
            _ = try await serial.readUntilOk(timeout: .milliseconds(50))
        }
    }

    @Test func afterTimeoutNextReplyIsOnlyTheNewEnqueue() async throws {
        let serial = FakeSerial()
        await serial.setReplies(["nope\n"])
        try await serial.open()
        try await serial.writeLine("M115")
        await #expect(throws: ArmError.timeout) {
            _ = try await serial.readUntilOk(timeout: .milliseconds(50))
        }
        await serial.setReplies(["new-ok\nok\n"])
        try await serial.writeLine("M114")
        let reply = try await serial.readUntilOk(timeout: .seconds(1))
        #expect(reply == "new-ok\nok\n")
        #expect(!reply.contains("nope"))
    }

    @Test func closeClearsPending() async throws {
        let serial = FakeSerial()
        await serial.setReplies(["late ok\n"])
        try await serial.open()
        try await serial.writeLine("M115")
        await serial.close()
        await serial.setReplies(["fresh\nok\n"])
        try await serial.writeLine("M114")
        let reply = try await serial.readUntilOk(timeout: .seconds(1))
        #expect(reply == "fresh\nok\n")
        #expect(!reply.contains("late"))
    }
}

struct HuenitArmTests {
    @Test func connectAcceptsMarlinE4() async throws {
        let serial = FakeSerial()
        await serial.setReplies([
            "FIRMWARE_NAME:Marlin bugfix-2.0.x MACHINE_TYPE:FYSETC_E4\nok\n",
            "ok\n",
            "ok\n",
        ])
        let arm = HuenitArm(transport: serial)
        try await arm.connect()
        #expect(await arm.isConnected)
        #expect(await serial.isOpen)
        let written = await serial.written
        #expect(written == ["M115", "G21", "G91"])
    }

    @Test func connectRejectsNonMarlin() async {
        let serial = FakeSerial()
        await serial.setReplies(["hello\nok\n"])
        let arm = HuenitArm(transport: serial)
        let thrown = await #expect(throws: ArmError.self) {
            try await arm.connect()
        }
        if case .connectFailed = thrown {
            // expected
        } else {
            Issue.record("expected connectFailed, got \(String(describing: thrown))")
        }
        #expect(await arm.isConnected == false)
        #expect(await serial.isOpen == false)
        let written = await serial.written
        #expect(written == ["M115"])
        #expect(!written.contains("G21"))
        #expect(!written.contains("G91"))
    }

    @Test func rejectsG28() async {
        let serial = FakeSerial()
        let arm = HuenitArm(transport: serial)
        await #expect(throws: ArmError.forbiddenCommand("G28")) {
            try await arm.send("G28")
        }
        let written = await serial.written
        #expect(!written.contains(where: { $0.contains("G28") }))
    }

    @Test func sendRejectsAnyLineContainingG28() async {
        let serial = FakeSerial()
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        await #expect(throws: ArmError.forbiddenCommand("G28")) {
            try await arm.send("g28")
        }
        await #expect(throws: ArmError.forbiddenCommand("G28")) {
            try await arm.send("G1 X10 ; then G28")
        }
        let written = await serial.written
        #expect(!written.contains(where: { $0.uppercased().contains("G28") }))
    }

    @Test func sendG21WhileDisconnectedThrowsDisconnected() async {
        let serial = FakeSerial()
        let arm = HuenitArm(transport: serial)
        await #expect(throws: ArmError.disconnected) {
            try await arm.send("G21")
        }
        await #expect(throws: ArmError.disconnected) {
            try await arm.send("M115")
        }
        #expect(await serial.written.isEmpty)
        #expect(await arm.isConnected == false)
    }

    @Test func stopThrowsWhenM410AndM84Fail() async {
        let serial = FakeSerial()
        await serial.setReplies(["ok\n"])
        let arm = HuenitArm(transport: serial, commandTimeout: .milliseconds(40))
        await arm.forceConnectedForTests()
        await #expect(throws: ArmError.timeout) {
            try await arm.stop()
        }
        #expect(await serial.written == ["M1400 A0", "M410", "M84"])
    }

    @Test func disconnectedErrorClearsIsConnected() async {
        let serial = FakeSerial()
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        #expect(await arm.isConnected)
        await serial.enqueueWriteError(.disconnected)
        await #expect(throws: ArmError.disconnected) {
            try await arm.send("M400")
        }
        #expect(await arm.isConnected == false)
    }

    @Test func forceConnectedForTestsSetsFlag() async {
        let serial = FakeSerial()
        let arm = HuenitArm(transport: serial)
        #expect(await arm.isConnected == false)
        await arm.forceConnectedForTests()
        #expect(await arm.isConnected)
    }

    @Test func queryPoseParsesBothSpaces() async throws {
        let serial = FakeSerial()
        await serial.setReplies([
            "X:-0.12 Y:233.81 Z:3.15\nok\n",
            "A:164.97 B:60.73 C:31.64\nok\n",
        ])
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        let pose = try await arm.queryPose()
        #expect(abs(pose.cartesian.y - 233.81) < 0.001)
        #expect(abs(pose.joints.a - 164.97) < 0.001)
        #expect(pose.isStale == false)
        let written = await serial.written
        #expect(written == ["M1008 A3", "M1008 A2"])
    }

    @Test func vacuumCommands() async throws {
        let serial = FakeSerial()
        await serial.setReplies(["ok\n", "ok\n"])
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        try await arm.setVacuum(true)
        try await arm.setVacuum(false)
        let written = await serial.written
        #expect(written == ["M1400 A1023", "M1400 A0"])
    }

    @Test func jogStepSendsRelativeG1() async throws {
        let serial = FakeSerial()
        await serial.setReplies(["ok\n"])
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        try await arm.jogCartesian(axis: .x, deltaMm: 3, feedMmPerMin: 1200)
        let written = await serial.written
        #expect(written.count == 1)
        #expect(written[0].hasPrefix("G1 X"))
        #expect(written[0].contains("F1200"))
    }

    @Test func jogJointUsesDefaultFormat() async throws {
        let serial = FakeSerial()
        await serial.setReplies(["ok\n"])
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        try await arm.jogJoint(axis: .a, deltaDeg: 2.5, feedMmPerMin: 800)
        let written = await serial.written
        #expect(written.count == 1)
        #expect(written[0] == "G1 A2.5000 F800.0")
    }

    @Test func setJointCommandFormatChangesWrittenLine() async throws {
        let serial = FakeSerial()
        await serial.setReplies(["ok\n"])
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        await arm.setJointCommandFormat("M1007 {A}{delta}")
        try await arm.jogJoint(axis: .b, deltaDeg: -2, feedMmPerMin: 300)
        #expect(await serial.written == ["M1007 B-2.0000"])
        #expect(await arm.jointCommandFormat == "M1007 {A}{delta}")
    }

    @Test func flushSendsM400() async throws {
        let serial = FakeSerial()
        await serial.setReplies(["ok\n"])
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        try await arm.flush()
        #expect(await serial.written == ["M400"])
    }

    @Test func stopSendsVacuumOffThenM410() async throws {
        let serial = FakeSerial()
        await serial.setReplies(["ok\n", "ok\n"])
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        try await arm.stop()
        #expect(await serial.written == ["M1400 A0", "M410"])
    }

    @Test func disconnectClosesTransport() async {
        let serial = FakeSerial()
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        try? await serial.open()
        await arm.disconnect()
        #expect(await arm.isConnected == false)
        #expect(await serial.isOpen == false)
    }
}
