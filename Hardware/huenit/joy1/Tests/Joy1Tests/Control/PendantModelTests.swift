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
            "X:-0.12 Y:233.81 Z:3.15 E:240.00 motor_status:1\nok\n",
            "ok\n",
        ])
        let arm = HuenitArm(transport: serial)
        let model = PendantModel(arm: arm, detector: { [] })
        model.makeTransport = { _ in serial }
        model.settleAfterOpen = .zero
        await model.connect(path: "/dev/cu.usbserial-test")
        #expect(model.isConnected)
        #expect(abs((model.pose?.cartesian.y ?? 0) - 233.81) < 0.001)
        #expect(abs((model.pose?.joints.a ?? 0) - 164.97) < 0.001)
        #expect(model.pose?.isStale == false)

        model.setHeld(.x, .pos, down: true)
        await model.tickJog(dt: 0.1)

        let written = await serial.written
        #expect(written.prefix(6).elementsEqual(["M115", "G21", "G91", "M1008 A3", "M1008 A2", "M114"]))
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
            "X:1.00 Y:2.00 Z:3.00 E:0.00 motor_status:1\nok\n",
            "ok\n",
            "ok\n",
        ])
        let arm = HuenitArm(transport: serial)
        let model = PendantModel(arm: arm, detector: { [] })
        model.makeTransport = { _ in serial }
        model.settleAfterOpen = .zero
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
            "X:1.00 Y:2.00 Z:3.00 E:0.00 motor_status:1\nok\n",
        ] + Array(repeating: "ok\n", count: 24))
        let arm = HuenitArm(transport: serial)
        let model = PendantModel(arm: arm, detector: { [] })
        model.makeTransport = { _ in serial }
        model.settleAfterOpen = .zero

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
            "X:1.00 Y:2.00 Z:3.00 E:0.00 motor_status:1\nok\n",
        ])
        let model = PendantModel(arm: HuenitArm(transport: FakeSerial()), detector: { [] })
        let requested = PathBox()
        model.makeTransport = { path in
            requested.value = path
            return serial
        }
        model.settleAfterOpen = .zero

        await model.connect(path: "/dev/cu.usbserial-selected")

        #expect(requested.value == "/dev/cu.usbserial-selected")
        #expect(model.portPath == "/dev/cu.usbserial-selected")
        #expect(model.isConnected)
    }

    @Test @MainActor func connectPrefersRescanOverStalePath() async throws {
        let serial = FakeSerial()
        await serial.setReplies([
            marlinIdentity(),
            "ok\n",
            "ok\n",
            "X:1.00 Y:2.00 Z:3.00\nok\n",
            "A:10.00 B:20.00 C:30.00\nok\n",
            "X:1.00 Y:2.00 Z:3.00 E:0.00 motor_status:1\nok\n",
        ])
        let live = SerialCandidate(
            path: "/dev/cu.usbserial-834430",
            product: "HUENIT_HUEARM",
            serial: "D30GQRUV_HUEARM",
            vid: 0x0403,
            pid: 0x6015
        )
        let requested = PathBox()
        let model = PendantModel(arm: HuenitArm(transport: FakeSerial()), detector: { [live] })
        model.makeTransport = { path in
            requested.value = path
            return serial
        }
        model.settleAfterOpen = .zero

        await model.connect(path: "/dev/cu.usbserial-3120")

        #expect(requested.value == "/dev/cu.usbserial-834430")
        #expect(model.portPath == "/dev/cu.usbserial-834430")
        #expect(model.isConnected)
    }

    @Test @MainActor func connectWithoutPortReportsMissingArm() async {
        let model = PendantModel(arm: HuenitArm(transport: FakeSerial()), detector: { [] })
        await model.connect()
        #expect(!model.isConnected)
        #expect(model.lastError?.contains("No HUEARM") == true)
    }

    @Test @MainActor func stepAndHomeSendLabCommands() async throws {
        let serial = FakeSerial()
        await serial.setReplies([
            marlinIdentity(),
            "ok\n",
            "ok\n",
            "X:0.00 Y:180.00 Z:0.00\nok\n",
            "A:0.00 B:0.00 C:0.00\nok\n",
            "X:0.00 Y:180.00 Z:0.00 E:0.00 motor_status:1\nok\n",
        ] + Array(repeating: "ok\n", count: 12))
        let model = PendantModel(arm: HuenitArm(transport: FakeSerial()), detector: { [] })
        model.makeTransport = { _ in serial }
        model.settleAfterOpen = .zero
        await model.connect(path: "/dev/cu.test")
        model.setControlMode(.step)
        model.setStepWidth(10)
        await model.step(dx: 1, dy: 1, dz: 0)
        await model.home()
        let written = await serial.written
        #expect(written.contains("G1 X10.0000 Y10.0000 F600.0"))
        #expect(written.contains("G1 X0.0000 Y180.0000 Z0.0000 F600.0"))
    }
}

private final class PathBox: @unchecked Sendable {
    var value: String?
}
