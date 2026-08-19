import ArmageddonCore

public actor MotionBoundaryFacade {
    public init() {}

    public func requestMotion(_ intent: MotionIntent) -> MotionBoundaryDecision {
        guard let permit = MotionPermit.issue() else {
            return .denied(.permitUnavailable)
        }

        return RawMotionTransport().send(intent, authorizedBy: permit)
    }
}

private struct MotionPermit: Sendable {
    private init() {}

    fileprivate static func issue() -> MotionPermit? {
        nil
    }
}

private struct RawMotionTransport: Sendable {
    func send(
        _ intent: MotionIntent,
        authorizedBy permit: MotionPermit
    ) -> MotionBoundaryDecision {
        _ = intent
        _ = permit
        return .accepted
    }
}
