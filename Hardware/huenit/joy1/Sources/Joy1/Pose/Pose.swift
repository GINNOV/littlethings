import Foundation

/// Labeled number with a leading token boundary so key `A` does not match inside `MAX:` or `AX:`.
func parseLabeledNumber(_ text: String, key: String) throws -> Double {
    let pattern = "(?<![A-Za-z0-9_])\(NSRegularExpression.escapedPattern(for: key))\\s*[:=]\\s*(-?\\d+(?:\\.\\d+)?)"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
          let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
          let range = Range(match.range(at: 1), in: text),
          let value = Double(text[range])
    else {
        throw ArmError.parseFailed("missing \(key) in \(text)")
    }
    return value
}

public struct CartesianPose: Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static let officialHome = CartesianPose(x: 0, y: 180, z: 0)

    public static func parseM1008(_ text: String) throws -> CartesianPose {
        try CartesianPose(
            x: parseLabeledNumber(text, key: "X"),
            y: parseLabeledNumber(text, key: "Y"),
            z: parseLabeledNumber(text, key: "Z")
        )
    }

    public func value(for axis: Axis) -> Double? {
        switch axis {
        case .x: x
        case .y: y
        case .z: z
        case .a, .b, .c, .e: nil
        }
    }
}

public struct JointPose: Equatable, Sendable {
    public var a: Double
    public var b: Double
    public var c: Double

    public init(a: Double, b: Double, c: Double) {
        self.a = a
        self.b = b
        self.c = c
    }

    public static func parseM1008(_ text: String) throws -> JointPose {
        try JointPose(
            a: parseLabeledNumber(text, key: "A"),
            b: parseLabeledNumber(text, key: "B"),
            c: parseLabeledNumber(text, key: "C")
        )
    }

    public func value(for axis: Axis) -> Double? {
        switch axis {
        case .a: a
        case .b: b
        case .c: c
        case .x, .y, .z, .e: nil
        }
    }
}

public struct ArmPose: Equatable, Sendable {
    public var cartesian: CartesianPose
    public var joints: JointPose
    /// End-effector / suction rotation from `M114` `E`.
    public var e: Double
    public var motorStatus: Int?
    public var isStale: Bool

    public init(
        cartesian: CartesianPose,
        joints: JointPose,
        e: Double = 0,
        motorStatus: Int? = nil,
        isStale: Bool = false
    ) {
        self.cartesian = cartesian
        self.joints = joints
        self.e = e
        self.motorStatus = motorStatus
        self.isStale = isStale
    }

    public static func parseM114Extras(_ text: String) -> (e: Double, motorStatus: Int?) {
        let e = (try? parseLabeledNumber(text, key: "E")) ?? 0
        let motor = try? parseLabeledNumber(text, key: "motor_status")
        return (e, motor.map { Int($0) })
    }
}

public struct FirmwareIdentity: Equatable, Sendable {
    public var raw: String
    public var isHuenitMarlin: Bool

    public static func parse(_ text: String) -> FirmwareIdentity {
        let ok = text.localizedCaseInsensitiveContains("Marlin")
            && text.localizedCaseInsensitiveContains("FYSETC_E4")
        return FirmwareIdentity(raw: text, isHuenitMarlin: ok)
    }
}

public enum Axis: String, Sendable, CaseIterable {
    case x, y, z, a, b, c, e

    public var isCartesian: Bool {
        self == .x || self == .y || self == .z
    }

    public var isModule: Bool {
        self == .e
    }

    public var gcodeLetter: String {
        rawValue.uppercased()
    }
}

public enum Sign: Int, Sendable {
    case neg = -1
    case pos = 1
}

public enum ControlMode: String, Sendable, CaseIterable {
    case hold
    case step
}
