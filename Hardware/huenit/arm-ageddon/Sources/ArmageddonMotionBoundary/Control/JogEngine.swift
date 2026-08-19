struct JogStep: Equatable, Sendable {
    let axis: Axis
    let delta: Double
    let feedMmPerMin: Double
}

enum Sign: Int, Sendable {
    case neg = -1
    case pos = 1
}

struct JogEngine: Sendable {
    var speedMmPerSec: Double
    var speedDegPerSec: Double
    private(set) var wantsFlush = false

    private var holds: [Axis: Sign] = [:]
    private var idleFor: Double = 0
    private var hadMotion = false

    init(speedMmPerSec: Double, speedDegPerSec: Double) {
        self.speedMmPerSec = speedMmPerSec
        self.speedDegPerSec = speedDegPerSec
    }

    mutating func setHeld(_ axis: Axis, _ sign: Sign, down: Bool) {
        if down {
            holds[axis] = sign
            idleFor = 0
            wantsFlush = false
        } else if holds[axis] == sign {
            holds[axis] = nil
        }
    }

    mutating func clearAll() {
        holds.removeAll()
    }

    mutating func didFlush() {
        wantsFlush = false
        hadMotion = false
        idleFor = 0
    }

    mutating func tick(dt: Double) -> [JogStep] {
        if holds.isEmpty {
            if hadMotion {
                idleFor += dt
                if idleFor >= 0.6 { wantsFlush = true }
            }
            return []
        }
        hadMotion = true
        idleFor = 0
        wantsFlush = false
        return holds.map { axis, sign in
            let speed = axis.isCartesian ? speedMmPerSec : speedDegPerSec
            return JogStep(axis: axis, delta: speed * dt * Double(sign.rawValue), feedMmPerMin: speedMmPerSec * 60)
        }
    }
}
