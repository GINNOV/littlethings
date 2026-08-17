import Testing
@testable import Joy1

struct PendantModelTests {
    private func marlinIdentity() -> String {
        "FIRMWARE_NAME:Marlin bugfix-2.0.x MACHINE_TYPE:FYSETC_E4\nok\n"
    }

    @Test @MainActor func connectUpdatesPoseAndTickJogWritesG1X() async throws {
        let serial = FakeSerial()
        await serial.setReplies([
            marlinIdentity(),
            "ok\n",
            "ok\n",
            "X:-0.12 Y:233.81 Z:3.15\nok\n",
            "A:164.97 B:60.73 C:31.64\nok\n",
            "ok\n",
        ])
        let arm = HuenitArm(transport: serial)
        let model = PendantModel(arm: arm, detector: { [] })
        model.makeTransport = { _ in serial }
        await model.connect(path: "/dev/cu.usbserial-test")
        #expect(model.isConnected)
        #expect(abs((model.pose?.cartesian.y ?? 0) - 233.81) < 0.001)
        #expect(abs((model.pose?.joints.a ?? 0) - 164.97) < 0.001)
        #expect(model.pose?.isStale == false)

        model.setHeld(.x, .pos, down: true)
        await model.tickJog(dt: 0.1)

        let written = await serial.written
        #expect(written.prefix(5).elementsEqual(["M115", "G21", "G91", "M1008 A3", "M1008 A2"]))
        #expect(written.contains(where: { $0.hasPrefix("G1 X") }))
    }

    @Test @MainActor func stopClearsHeldAndWritesVacuumOff() async throws {
        let serial = FakeSerial()
        await serial.setReplies([
            marlinIdentity(),
            "ok\n",
            "ok\n",
            "X:1.00 Y:2.00 Z:3.00\nok\n",
            "A:10.00 B:20.00 C:30.00\nok\n",
            "ok\n",
            "ok\n",
        ])
        let arm = HuenitArm(transport: serial)
        let model = PendantModel(arm: arm, detector: { [] })
        model.makeTransport = { _ in serial }
        await model.connect(path: "/dev/cu.usbserial-test")
        model.setHeld(.x, .pos, down: true)
        #expect(model.held[.x] == .pos)

        await model.stop()

        #expect(model.held.isEmpty)
        let written = await serial.written
        #expect(written.contains("M1400 A0"))
    }

    @Test @MainActor func startJogLoopIdlesWhileDisconnectedAndSurvivesConnect() async throws {
        let serial = FakeSerial()
        await serial.setReplies([
            marlinIdentity(),
            "ok\n",
            "ok\n",
            "X:1.00 Y:2.00 Z:3.00\nok\n",
            "A:10.00 B:20.00 C:30.00\nok\n",
        ] + Array(repeating: "ok\n", count: 16))
        let arm = HuenitArm(transport: serial)
        let model = PendantModel(arm: arm, detector: { [] })
        model.makeTransport = { _ in serial }

        model.startJogLoop()
        model.startJogLoop()
        try await Task.sleep(for: .milliseconds(80))
        #expect(!model.isConnected)

        await model.connect(path: "/dev/cu.usbserial-test")
        #expect(model.isConnected)

        model.setHeld(.x, .pos, down: true)
        try await Task.sleep(for: .milliseconds(80))

        let written = await serial.written
        #expect(written.contains(where: { $0.hasPrefix("G1 X") }))

        await model.disconnect()
        #expect(!model.isConnected)
        try await Task.sleep(for: .milliseconds(80))
        #expect(!model.isConnected)
    }

    @Test @MainActor func connectCallsMakeTransportWithSelectedPath() async throws {
        let serial = FakeSerial()
        await serial.setReplies([
            marlinIdentity(),
            "ok\n",
            "ok\n",
            "X:1.00 Y:2.00 Z:3.00\nok\n",
            "A:10.00 B:20.00 C:30.00\nok\n",
        ])
        let model = PendantModel(arm: HuenitArm(transport: FakeSerial()), detector: { [] })
        let requested = PathBox()
        model.makeTransport = { path in
            requested.value = path
            return serial
        }

        await model.connect(path: "/dev/cu.usbserial-selected")

        #expect(requested.value == "/dev/cu.usbserial-selected")
        #expect(model.portPath == "/dev/cu.usbserial-selected")
        #expect(model.isConnected)
    }
}

private final class PathBox: @unchecked Sendable {
    var value: String?
}
