import Foundation

enum RobotCommand: Equatable {
    case forward
    case back
    case left
    case right
    case stop
    case sit
    case greet
    /// Official grid after Greetings. Inferred: next unused `2A 00` stride (`13 + 3`).
    case getDown
    /// Official grid after Get Down. Inferred: `16 + 3`.
    case actCute
    /// Official grid after Act Cute. Inferred: `19 + 3`.
    case handshake
    /// Official grid after Handshake. Inferred: `1C + 3`.
    case attack
    /// Official grid after Attack. Inferred: `1F + 3`.
    case surrender
    /// Official grid after Surrender. Inferred: `22 + 3`.
    case urinate
    /// Official grid after Urinate, before Patrol. Inferred: `25 + 3`.
    case handstand
    case patrol
    case kungFu
    case pushUp
    /// Official D-pad bottom. Inferred: next unused `2A 00` stride after Push-up (`31 + 3`).
    case swimming
    case dance
    /// Framed heartbeat. Mapped actions start at `2A 00 01`; `00` is unused.
    case keepAlive

    var packet: Data {
        let payload: (UInt8, UInt8, UInt8) = switch self {
        case .forward: (0x2A, 0x00, 0x01)
        case .back: (0x2A, 0x00, 0x0D)
        case .left: (0x2A, 0x00, 0x04)
        case .right: (0x2A, 0x00, 0x07)
        case .stop: (0x2A, 0x00, 0x0A)
        case .sit: (0x2A, 0x00, 0x10)
        case .greet: (0x2A, 0x00, 0x13)
        case .getDown: (0x2A, 0x00, 0x16)
        case .actCute: (0x2A, 0x00, 0x19)
        case .handshake: (0x2A, 0x00, 0x1C)
        case .attack: (0x2A, 0x00, 0x1F)
        case .surrender: (0x2A, 0x00, 0x22)
        case .urinate: (0x2A, 0x00, 0x25)
        case .handstand: (0x2A, 0x00, 0x28)
        case .patrol: (0x2A, 0x00, 0x2B)
        case .kungFu: (0x2A, 0x00, 0x2E)
        case .pushUp: (0x2A, 0x00, 0x31)
        case .swimming: (0x2A, 0x00, 0x34)
        case .dance: (0x12, 0x00, 0x01)
        case .keepAlive: (0x2A, 0x00, 0x00)
        }

        return Data([
            0xF0,
            payload.0, payload.1, payload.2,
            ~payload.0, ~payload.1, ~payload.2,
        ])
    }

    var displayName: String {
        switch self {
        case .forward: "Forward"
        case .back: "Back"
        case .left: "Left"
        case .right: "Right"
        case .stop: "Stop"
        case .sit: "Sit Down"
        case .greet: "Greetings"
        case .getDown: "Get Down"
        case .actCute: "Act Cute"
        case .handshake: "Handshake"
        case .attack: "Attack"
        case .surrender: "Surrender"
        case .urinate: "Urinate"
        case .handstand: "Handstand"
        case .patrol: "Patrol"
        case .kungFu: "Kung Fu"
        case .pushUp: "Push-up"
        case .swimming: "Swimming"
        case .dance: "Dance"
        case .keepAlive: "Stay awake"
        }
    }
}
