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
}
