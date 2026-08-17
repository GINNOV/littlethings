import Foundation

public struct CartesianPose: Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static func parseM1008(_ text: String) throws -> CartesianPose {
        func num(_ key: String) throws -> Double {
            let pattern = "\(key)\\s*[:=]\\s*(-?\\d+(?:\\.\\d+)?)"
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text),
                  let value = Double(text[range])
            else {
                throw ArmError.parseFailed("missing \(key) in \(text)")
            }
            return value
        }
        return try CartesianPose(x: num("X"), y: num("Y"), z: num("Z"))
    }

    public func value(for axis: Axis) -> Double {
        switch axis {
        case .x: x
        case .y: y
        case .z: z
        default: 0
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
        func num(_ key: String) throws -> Double {
            let pattern = "\(key)\\s*[:=]\\s*(-?\\d+(?:\\.\\d+)?)"
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text),
                  let value = Double(text[range])
            else {
                throw ArmError.parseFailed("missing \(key) in \(text)")
            }
            return value
        }
        return try JointPose(a: num("A"), b: num("B"), c: num("C"))
    }

    public func value(for axis: Axis) -> Double {
        switch axis {
        case .a: a
        case .b: b
        case .c: c
        default: 0
        }
    }
}

public struct ArmPose: Equatable, Sendable {
    public var cartesian: CartesianPose
    public var joints: JointPose
    public var isStale: Bool

    public init(cartesian: CartesianPose, joints: JointPose, isStale: Bool = false) {
        self.cartesian = cartesian
        self.joints = joints
        self.isStale = isStale
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
    case x, y, z, a, b, c

    public var isCartesian: Bool {
        self == .x || self == .y || self == .z
    }

    public var gcodeLetter: String {
        rawValue.uppercased()
    }
}

public enum Sign: Int, Sendable {
    case neg = -1
    case pos = 1
}
