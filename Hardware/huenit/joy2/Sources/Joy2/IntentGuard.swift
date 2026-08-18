public struct GuardState: Equatable, Sendable {
    public var armConnected: Bool
    public var motorsOn: Bool
    public var busy: Bool

    public init(armConnected: Bool, motorsOn: Bool, busy: Bool) {
        self.armConnected = armConnected
        self.motorsOn = motorsOn
        self.busy = busy
    }
}

public enum GuardReject: String, Equatable, Sendable {
    case notConnected
    case motorsOff
    case busy

    public var message: String {
        switch self {
        case .notConnected: "not connected"
        case .motorsOff: "motors off"
        case .busy: "still moving"
        }
    }
}

public struct GuardDecision: Equatable, Sendable {
    public var accepted: PilotIntent?
    public var reject: GuardReject?

    public init(accepted: PilotIntent?, reject: GuardReject?) {
        self.accepted = accepted
        self.reject = reject
    }
}

public enum IntentGuard: Sendable {
    public static func decide(_ intent: PilotIntent, state: GuardState) -> GuardDecision {
        switch intent {
        case .none, .stop:
            return GuardDecision(accepted: intent, reject: nil)
        case .toggleVacuum:
            if !state.armConnected { return GuardDecision(accepted: nil, reject: .notConnected) }
            if state.busy { return GuardDecision(accepted: nil, reject: .busy) }
            return GuardDecision(accepted: intent, reject: nil)
        case .jog:
            if !state.armConnected { return GuardDecision(accepted: nil, reject: .notConnected) }
            if !state.motorsOn { return GuardDecision(accepted: nil, reject: .motorsOff) }
            if state.busy { return GuardDecision(accepted: nil, reject: .busy) }
            return GuardDecision(accepted: intent, reject: nil)
        }
    }
}
