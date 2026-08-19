import Testing
@testable import ArmageddonMotionBoundary

actor RecordingPriorityStopTransport: PriorityStopTransport {
    private(set) var frames: [StopFrame] = []

    func urgentWrite(_ frame: StopFrame, deadlineNanoseconds: UInt64) async -> UrgentWriteOutcome {
        frames.append(frame)
        return .writeConfirmed
    }
}

actor BlockingPriorityStopTransport: PriorityStopTransport {
    private(set) var frames: [StopFrame] = []
    private var firstWriteStarted = false
    private var released = false

    func urgentWrite(_ frame: StopFrame, deadlineNanoseconds: UInt64) async -> UrgentWriteOutcome {
        if !firstWriteStarted {
            firstWriteStarted = true
            while !released {
                try? await Task.sleep(for: .milliseconds(1))
            }
        }
        frames.append(frame)
        return .writeConfirmed
    }

    func waitForFirstWrite() async {
        while !firstWriteStarted {
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    func release() {
        released = true
    }
}

struct ManualArmControlTests {
    private func makeGateway(replies: Int = 20) async -> (ArmCommandGateway, FakeSerial, RecordingPriorityStopTransport) {
        let serial = FakeSerial()
        await serial.setReplies(
            ["FIRMWARE_NAME:Marlin MACHINE_TYPE:FYSETC_E4\nok\n"]
                + Array(repeating: "ok\n", count: max(0, replies - 1))
        )
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)
        let stopTransport = RecordingPriorityStopTransport()
        let stop = EmergencyStopController(transport: stopTransport, clock: FixedStopClock(value: 10))
        return (ArmCommandGateway(arm: arm, emergencyStop: stop), serial, stopTransport)
    }

    @Test("Hold and release emit bounded jog and flush after idle")
    func holdRelease() async throws {
        let (gateway, serial, _) = await makeGateway()
        try await gateway.connect()
        await gateway.setHeld(.x, .pos, down: true)
        await gateway.tickJog(dt: 0.1)
        await gateway.setHeld(.x, .pos, down: false)
        await gateway.tickJog(dt: 0.6)

        let written = await serial.written
        #expect(written.contains("G1 X2.0000 F1200.0"))
        #expect(written.last == "M400")
        #expect(await gateway.heldAxes().isEmpty)
    }

    @Test("Simultaneous held axes serialize as separate bounded commands")
    func simultaneousAxesPolicy() async throws {
        let (gateway, serial, _) = await makeGateway()
        try await gateway.connect()
        await gateway.setHeld(.x, .pos, down: true)
        await gateway.setHeld(.y, .neg, down: true)
        await gateway.tickJog(dt: 0.1)

        let written = await serial.written
        #expect(written.filter { $0.hasPrefix("G1 ") }.count == 2)
        #expect(written.contains("G1 X2.0000 F1200.0"))
        #expect(written.contains("G1 Y-2.0000 F1200.0"))
    }

    @Test("Module hold routes through the module command")
    func moduleAxisRouting() async throws {
        let (gateway, serial, _) = await makeGateway()
        await gateway.markConnectedForTests()
        await gateway.setHeld(.e, .pos, down: true)
        await gateway.tickJog(dt: 0.1)

        #expect((await serial.written).contains("G1 E2.0000 F1200.0"))
    }

    @Test("Step controls require explicit step mode")
    func stepModeBoundary() async throws {
        let (gateway, serial, _) = await makeGateway()
        await gateway.markConnectedForTests()

        await #expect(throws: ArmError.invalidControlMode) {
            try await gateway.step(dx: 1, dy: 0, dz: 0)
        }

        await gateway.setControlMode(.step)
        try await gateway.step(dx: 1, dy: 0, dz: 0)
        #expect((await serial.written).contains("G1 X1.0000 F1200.0"))
    }

    @Test("Pose monitoring cancels cleanly")
    func posePollingCancellation() async throws {
        let (gateway, _, _) = await makeGateway()
        await gateway.markConnectedForTests()
        await gateway.startPoseMonitoring()
        #expect(await gateway.isPoseMonitoring())
        await gateway.stopPoseMonitoring()
        #expect(await gateway.isPoseMonitoring() == false)
    }

    @Test("Focus loss stops motion and leaves no queued jog")
    func focusLossStop() async throws {
        let (gateway, serial, stopTransport) = await makeGateway()
        await gateway.markConnectedForTests()
        await gateway.setHeld(.x, .pos, down: true)
        _ = await gateway.focusLost()
        let commandCount = await serial.written.count

        await gateway.tickJog(dt: 0.1)

        #expect(await gateway.heldAxes().isEmpty)
        #expect(await gateway.isMoving == false)
        #expect(await serial.written.count == commandCount)
        #expect(await stopTransport.frames == [.vacuumOff, .motionStop])
    }

    @Test("Focus loss blocks new holds until the stop sequence completes")
    func focusLossBlocksConcurrentHold() async {
        let serial = FakeSerial()
        let arm = HuenitArm(transport: serial, settleAfterOpen: .zero)
        let stopTransport = BlockingPriorityStopTransport()
        let stop = EmergencyStopController(transport: stopTransport, clock: FixedStopClock(value: 10))
        let gateway = ArmCommandGateway(arm: arm, emergencyStop: stop)
        await gateway.markConnectedForTests()

        let stopTask = Task { await gateway.focusLost() }
        await stopTransport.waitForFirstWrite()
        await gateway.setHeld(.x, .pos, down: true)
        await stopTransport.release()
        _ = await stopTask.value

        #expect(await gateway.heldAxes().isEmpty)
        #expect(await gateway.isMoving == false)
    }

    @Test("Disconnect stops, cancels pose work, and disables commands")
    func disconnectCleanup() async throws {
        let (gateway, _, stopTransport) = await makeGateway()
        await gateway.markConnectedForTests()
        await gateway.startPoseMonitoring()

        _ = await gateway.disconnect()

        #expect(await gateway.isConnected == false)
        #expect(await gateway.isPoseMonitoring() == false)
        #expect(await gateway.heldAxes().isEmpty)
        #expect(await stopTransport.frames == [.vacuumOff, .motionStop])
    }

    @Test("Manual gateway never exposes armed or vision-guided motion")
    func disarmedOnly() async {
        let (gateway, _, _) = await makeGateway()
        #expect(await gateway.isArmed == false)
        #expect(await gateway.visionMotionEnabled == false)
    }

    @Test("Concurrent ticks remain serialized by the arm actor")
    func commandSerialization() async throws {
        let (gateway, serial, _) = await makeGateway()
        await gateway.markConnectedForTests()
        await gateway.setHeld(.x, .pos, down: true)

        async let first: Void = gateway.tickJog(dt: 0.1)
        async let second: Void = gateway.tickJog(dt: 0.1)
        _ = await (first, second)

        #expect((await serial.written).filter { $0.hasPrefix("G1 ") }.count == 2)
    }
}
