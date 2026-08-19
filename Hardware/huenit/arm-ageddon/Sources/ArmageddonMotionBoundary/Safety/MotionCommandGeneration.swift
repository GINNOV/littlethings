struct MotionGenerationToken: Equatable, Sendable {
    let rawValue: UInt64
}

actor MotionCommandGeneration {
    private var generation: UInt64 = 0

    func issue() -> MotionGenerationToken {
        MotionGenerationToken(rawValue: generation)
    }

    func invalidate() {
        generation &+= 1
    }

    func isCurrent(_ token: MotionGenerationToken) -> Bool {
        token.rawValue == generation
    }
}
