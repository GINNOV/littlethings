enum ArmError: Error, Equatable, Sendable {
    case forbiddenCommand(String)
    case connectFailed(String)
    case timeout
    case parseFailed(String)
    case disconnected
    case portBusy(String)
    case invalidControlMode
    case motionInvalidated
}
