import Foundation

enum RobotCommand: Equatable {
    case forward
    case back
    case left
    case right
    case stop
    case sit
    case greet
    case patrol
    case kungFu
    case pushUp
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
        case .patrol: (0x2A, 0x00, 0x2B)
        case .kungFu: (0x2A, 0x00, 0x2E)
        case .pushUp: (0x2A, 0x00, 0x31)
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
        case .sit: "Sit"
        case .greet: "Greet"
        case .patrol: "Patrol"
        case .kungFu: "Kung Fu"
        case .pushUp: "Push-up"
        case .dance: "Dance"
        case .keepAlive: "Stay awake"
        }
    }
}
