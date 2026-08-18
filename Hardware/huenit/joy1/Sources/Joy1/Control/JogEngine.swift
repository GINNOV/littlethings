public struct JogStep: Equatable, Sendable {
    public var axis: Axis
    public var delta: Double
    public var feedMmPerMin: Double
}

public struct JogEngine: Sendable {
    public var speedMmPerSec: Double
    public var speedDegPerSec: Double
    public private(set) var wantsFlush = false

    private var holds: [Axis: Sign] = [:]
    private var idleFor: Double = 0
    private var hadMotion = false

    public init(speedMmPerSec: Double, speedDegPerSec: Double) {
        self.speedMmPerSec = speedMmPerSec
        self.speedDegPerSec = speedDegPerSec
    }

    public mutating func setHeld(_ axis: Axis, _ sign: Sign, down: Bool) {
        if down {
            holds[axis] = sign
            idleFor = 0
            wantsFlush = false
        } else if holds[axis] == sign {
            holds[axis] = nil
        }
    }

    public mutating func clearAll() {
        holds.removeAll()
    }

    public mutating func didFlush() {
        wantsFlush = false
        hadMotion = false
        idleFor = 0
    }

    public mutating func tick(dt: Double) -> [JogStep] {
        if holds.isEmpty {
            if hadMotion {
                idleFor += dt
                if idleFor >= 0.6 {
                    wantsFlush = true
                }
            }
            return []
        }
        hadMotion = true
        idleFor = 0
        wantsFlush = false
        return holds.map { axis, sign in
            let speed = axis.isCartesian ? speedMmPerSec : speedDegPerSec
            let delta = speed * dt * Double(sign.rawValue)
            return JogStep(axis: axis, delta: delta, feedMmPerMin: speedMmPerSec * 60)
        }
    }
}
