actor EmergencyStopController {
    static let deadlineNanoseconds: UInt64 = 100_000_000

    private let transport: any PriorityStopTransport
    private let clock: any MonotonicStopClock
    private let generation: MotionCommandGeneration
    private var stopInProgress = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(
        transport: any PriorityStopTransport,
        clock: any MonotonicStopClock = ContinuousStopClock(),
        generation: MotionCommandGeneration = MotionCommandGeneration()
    ) {
        self.transport = transport
        self.clock = clock
        self.generation = generation
    }

    func issueMotionGeneration() async -> MotionGenerationToken {
        await generation.issue()
    }

    func isCurrent(_ token: MotionGenerationToken) async -> Bool {
        await generation.isCurrent(token)
    }

    func stop() async -> EmergencyStopReceipt {
        while stopInProgress {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                waiters.append(continuation)
            }
        }
        stopInProgress = true
        let receipt = await performStop()
        stopInProgress = false
        let waitingCallers = waiters
        waiters.removeAll()
        waitingCallers.forEach { $0.resume() }
        return receipt
    }

    private func performStop() async -> EmergencyStopReceipt {
        let start = clock.nowNanoseconds()
        let deadline = start &+ Self.deadlineNanoseconds
        await generation.invalidate()
        var events: [EmergencyStopEvent] = [.requested]

        events.append(.vacuumOffAttempted)
        let vacuum = await transport.urgentWrite(.vacuumOff, deadlineNanoseconds: deadline)
        append(vacuum, to: &events, writeConfirmed: .vacuumOffWriteConfirmed)
        let vacuumSafetyFailure: StopUnconfirmedReason? = switch vacuum {
        case .explicitlyRejected: .vacuumOffRejected
        case .partialWrite: .partialWrite
        case .deadlineExceeded: .urgentWriteDeadlineExceeded
        case .transportUnavailable: .urgentWriteDeadlineExceeded
        case .writeConfirmed, .firmwareConfirmed: nil
        }

        events.append(.motionStopAttempted)
        let motionStop = await transport.urgentWrite(.motionStop, deadlineNanoseconds: deadline)
        append(motionStop, to: &events, writeConfirmed: .motionStopWriteConfirmed)

        var result: EmergencyStopResult = .unconfirmed(.urgentWriteDeadlineExceeded)
        switch motionStop {
        case .firmwareConfirmed:
            events.append(.firmwareConfirmed)
            result = .confirmed
        case .writeConfirmed:
            result = .confirmed
        case .explicitlyRejected:
            events.append(.motorDisableAttempted)
            let motorDisable = await transport.urgentWrite(.motorDisable, deadlineNanoseconds: deadline)
            switch motorDisable {
            case .writeConfirmed, .firmwareConfirmed:
                result = .confirmed
                if case .firmwareConfirmed = motorDisable { events.append(.firmwareConfirmed) }
            case .explicitlyRejected:
                events.append(.unconfirmed(.motorDisableFailed))
                result = .unconfirmed(.motorDisableFailed)
            case .transportUnavailable:
                events.append(.unconfirmed(.urgentWriteDeadlineExceeded))
                result = .unconfirmed(.urgentWriteDeadlineExceeded)
            case .partialWrite:
                events.append(.partialWrite)
                events.append(.unconfirmed(.partialWrite))
                result = .unconfirmed(.partialWrite)
            case .deadlineExceeded:
                events.append(.deadlineExceeded)
                events.append(.unconfirmed(.urgentWriteDeadlineExceeded))
                result = .unconfirmed(.urgentWriteDeadlineExceeded)
            }
        case .partialWrite:
            events.append(.partialWrite)
            events.append(.unconfirmed(.partialWrite))
            result = .unconfirmed(.partialWrite)
        case .deadlineExceeded:
            events.append(.deadlineExceeded)
            events.append(.unconfirmed(.urgentWriteDeadlineExceeded))
            result = .unconfirmed(.urgentWriteDeadlineExceeded)
        case .transportUnavailable:
            events.append(.unconfirmed(.urgentWriteDeadlineExceeded))
            result = .unconfirmed(.urgentWriteDeadlineExceeded)
        }

        if clock.nowNanoseconds() > deadline {
            events.append(.deadlineExceeded)
            events.append(.unconfirmed(.urgentWriteDeadlineExceeded))
            result = .unconfirmed(.urgentWriteDeadlineExceeded)
        } else if let vacuumSafetyFailure, result == .confirmed {
            events.append(.unconfirmed(vacuumSafetyFailure))
            result = .unconfirmed(vacuumSafetyFailure)
        }
        return EmergencyStopReceipt(result: result, events: events, elapsedNanoseconds: clock.nowNanoseconds() &- start)
    }

    private func append(
        _ outcome: UrgentWriteOutcome,
        to events: inout [EmergencyStopEvent],
        writeConfirmed: EmergencyStopEvent
    ) {
        switch outcome {
        case .writeConfirmed: events.append(writeConfirmed)
        case .firmwareConfirmed:
            events.append(writeConfirmed)
            events.append(.firmwareConfirmed)
        case .partialWrite: events.append(.partialWrite)
        case .deadlineExceeded: events.append(.deadlineExceeded)
        case .explicitlyRejected: break
        case .transportUnavailable: events.append(.deadlineExceeded)
        }
    }
}
