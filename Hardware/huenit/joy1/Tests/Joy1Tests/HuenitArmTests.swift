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
