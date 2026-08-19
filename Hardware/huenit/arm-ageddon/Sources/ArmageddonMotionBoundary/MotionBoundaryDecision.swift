public enum MotionBoundaryDecision: Equatable, Sendable {
    case accepted
    case denied(MotionDenialReason)
}
