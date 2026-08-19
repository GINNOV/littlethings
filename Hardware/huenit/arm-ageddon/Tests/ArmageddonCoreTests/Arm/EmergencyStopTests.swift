import Testing
@testable import ArmageddonMotionBoundary

actor ScriptedPriorityStopTransport: PriorityStopTransport {
    private var scripts: [StopFrame: [UrgentWriteOutcome]] = [:]
    private(set) var frames: [StopFrame] = []

    func set(_ outcomes: [UrgentWriteOutcome], for frame: StopFrame) {
        scripts[frame] = outcomes
    }

    func urgentWrite(_ frame: StopFrame, deadlineNanoseconds: UInt64) async -> UrgentWriteOutcome {
        frames.append(frame)
        return scripts[frame]?.isEmpty == false ? scripts[frame]!.removeFirst() : .writeConfirmed
    }
}

struct FixedStopClock: MonotonicStopClock {
    let value: UInt64

    func nowNanoseconds() -> UInt64 { value }
}

struct EmergencyStopTests {
    @Test("STOP is independent of normal command generation")
    func invalidatesNormalGeneration() async {
        let transport = ScriptedPriorityStopTransport()
        let controller = EmergencyStopController(transport: transport, clock: FixedStopClock(value: 10))
        let token = await controller.issueMotionGeneration()
        #expect(await controller.isCurrent(token))

        _ = await controller.stop()

        #expect(await controller.isCurrent(token) == false)
        #expect(await transport.frames == [.vacuumOff, .motionStop])
    }

    @Test("STOP attempts M410 even when vacuum off is partial")
    func partialVacuumDoesNotSuppressMotionStop() async {
        let transport = ScriptedPriorityStopTransport()
        await transport.set([.partialWrite(bytes: 1)], for: .vacuumOff)
        let controller = EmergencyStopController(transport: transport, clock: FixedStopClock(value: 10))

        let receipt = await controller.stop()

        #expect(receipt.result == .unconfirmed(.partialWrite))
        #expect(await transport.frames == [.vacuumOff, .motionStop])
        #expect(receipt.events.contains(.partialWrite))
    }

    @Test("Rejected vacuum off is truthful while M410 is still attempted")
    func rejectedVacuumIsUnconfirmed() async {
        let transport = ScriptedPriorityStopTransport()
        await transport.set([.explicitlyRejected], for: .vacuumOff)
        let controller = EmergencyStopController(transport: transport, clock: FixedStopClock(value: 10))

        let receipt = await controller.stop()

        #expect(receipt.result == .unconfirmed(.vacuumOffRejected))
        #expect(await transport.frames == [.vacuumOff, .motionStop])
    }

    @Test("STOP reports unconfirmed when M410 misses its deadline")
    func deadlineIsTruthful() async {
        let transport = ScriptedPriorityStopTransport()
        await transport.set([.deadlineExceeded], for: .motionStop)
        let controller = EmergencyStopController(transport: transport, clock: FixedStopClock(value: 10))

        let receipt = await controller.stop()

        #expect(receipt.result == .unconfirmed(.urgentWriteDeadlineExceeded))
        #expect(receipt.events.contains(.motionStopAttempted))
        #expect(receipt.events.contains(.deadlineExceeded))
        #expect(!receipt.events.contains(.motorDisableAttempted))
    }

    @Test("M84 fallback is used only after explicit M410 rejection")
    func explicitRejectionAllowsFallback() async {
        let transport = ScriptedPriorityStopTransport()
        await transport.set([.explicitlyRejected], for: .motionStop)
        let controller = EmergencyStopController(transport: transport, clock: FixedStopClock(value: 10))

        let receipt = await controller.stop()

        #expect(receipt.result == .confirmed)
        #expect(await transport.frames == [.vacuumOff, .motionStop, .motorDisable])
        #expect(receipt.events.contains(.motorDisableAttempted))
    }

    @Test("Concurrent STOP requests serialize complete urgent frame sequences")
    func concurrentStopsDoNotInterleave() async {
        let transport = ScriptedPriorityStopTransport()
        let controller = EmergencyStopController(transport: transport, clock: FixedStopClock(value: 10))

        async let first = controller.stop()
        async let second = controller.stop()
        let firstReceipt = await first
        let secondReceipt = await second

        let frames = await transport.frames
        #expect(frames == [.vacuumOff, .motionStop, .vacuumOff, .motionStop])
        #expect(firstReceipt.result == .confirmed)
        #expect(secondReceipt.result == .confirmed)
    }

    @Test("One thousand STOP requests stay inside the 100ms budget")
    func stopStress() async {
        let transport = ScriptedPriorityStopTransport()
        let controller = EmergencyStopController(transport: transport, clock: FixedStopClock(value: 10))
        var maximum: UInt64 = 0

        for _ in 0..<1_000 {
            let receipt = await controller.stop()
            maximum = max(maximum, receipt.elapsedNanoseconds)
            #expect(receipt.result == .confirmed)
        }

        #expect(maximum <= EmergencyStopController.deadlineNanoseconds)
        #expect((await transport.frames).count == 2_000)
    }
}
