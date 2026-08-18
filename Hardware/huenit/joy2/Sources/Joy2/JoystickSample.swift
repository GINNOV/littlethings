public enum StickDirection: Equatable, Sendable {
    case center, n, ne, e, se, s, sw, w, nw

    /// `x`/`y` in 0...1, 0.5 is center. `y` is already north-positive.
    public static func fromAxes(x: Double, y: Double, deadzone: Double = 0.28) -> StickDirection {
        let dx = x - 0.5
        let dy = y - 0.5
        let hx: Int
        if dx > deadzone { hx = 1 }
        else if dx < -deadzone { hx = -1 }
        else { hx = 0 }
        let hy: Int
        if dy > deadzone { hy = 1 }
        else if dy < -deadzone { hy = -1 }
        else { hy = 0 }
        switch (hx, hy) {
        case (0, 0): return .center
        case (0, 1): return .n
        case (1, 1): return .ne
        case (1, 0): return .e
        case (1, -1): return .se
        case (0, -1): return .s
        case (-1, -1): return .sw
        case (-1, 0): return .w
        case (-1, 1): return .nw
        default: return .center
        }
    }
}

public struct JoystickSample: Equatable, Sendable {
    public var connected: Bool
    public var direction: StickDirection
    public var leftFire: Bool
    public var rightFire: Bool

    public init(connected: Bool, direction: StickDirection, leftFire: Bool, rightFire: Bool) {
        self.connected = connected
        self.direction = direction
        self.leftFire = leftFire
        self.rightFire = rightFire
    }

    public static var idle: JoystickSample {
        JoystickSample(connected: true, direction: .center, leftFire: false, rightFire: false)
    }

    public static func deflected(_ direction: StickDirection, leftFire: Bool, rightFire: Bool) -> JoystickSample {
        JoystickSample(connected: true, direction: direction, leftFire: leftFire, rightFire: rightFire)
    }
}
