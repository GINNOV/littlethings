enum StopFrame: Equatable, Sendable {
    case vacuumOff
    case motionStop
    case motorDisable
}

enum UrgentWriteOutcome: Equatable, Sendable {
    case writeConfirmed
    case firmwareConfirmed
    case explicitlyRejected
    case transportUnavailable
    case partialWrite(bytes: Int)
    case deadlineExceeded
}

enum StopUnconfirmedReason: Equatable, Sendable {
    case urgentWriteDeadlineExceeded
    case partialWrite
    case vacuumOffRejected
    case motionStopRejected
    case motorDisableFailed
}

enum EmergencyStopEvent: Equatable, Sendable {
    case requested
    case vacuumOffAttempted
    case vacuumOffWriteConfirmed
    case motionStopAttempted
    case motionStopWriteConfirmed
    case firmwareConfirmed
    case motorDisableAttempted
    case partialWrite
    case deadlineExceeded
    case unconfirmed(StopUnconfirmedReason)
}

enum EmergencyStopResult: Equatable, Sendable {
    case confirmed
    case unconfirmed(StopUnconfirmedReason)
}

struct EmergencyStopReceipt: Equatable, Sendable {
    let result: EmergencyStopResult
    let events: [EmergencyStopEvent]
    let elapsedNanoseconds: UInt64
}
