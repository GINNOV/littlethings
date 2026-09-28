import Foundation

enum MotorCommand: Equatable {
    case rotateLeft(speed: Int)
    case rotateRight(speed: Int)
    case stop

    var description: String {
        switch self {
        case .rotateLeft(let speed):
            return "Rotate left @ \(speed)"
        case .rotateRight(let speed):
            return "Rotate right @ \(speed)"
        case .stop:
            return "Stop"
        }
    }
}
