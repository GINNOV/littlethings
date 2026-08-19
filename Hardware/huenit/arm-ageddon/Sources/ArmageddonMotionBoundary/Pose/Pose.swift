import Foundation

func parseLabeledNumber(_ text: String, key: String) throws -> Double {
    let pattern = "(?<![A-Za-z0-9_])\(NSRegularExpression.escapedPattern(for: key))\\s*[:=]\\s*(-?\\d+(?:\\.\\d+)?)"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
          let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
          let range = Range(match.range(at: 1), in: text),
          let value = Double(text[range]) else {
        throw ArmError.parseFailed("missing \(key) in \(text)")
    }
    return value
}

struct CartesianPose: Equatable, Sendable {
    var x: Double
    var y: Double
    var z: Double

    static let officialHome = CartesianPose(x: 0, y: 180, z: 0)

    static func parseM1008(_ text: String) throws -> CartesianPose {
        CartesianPose(
            x: try parseLabeledNumber(text, key: "X"),
            y: try parseLabeledNumber(text, key: "Y"),
            z: try parseLabeledNumber(text, key: "Z")
        )
    }

    func value(for axis: Axis) -> Double? {
        switch axis { case .x: x; case .y: y; case .z: z; default: nil }
    }
}

struct JointPose: Equatable, Sendable {
    var a: Double
    var b: Double
    var c: Double

    static func parseM1008(_ text: String) throws -> JointPose {
        JointPose(
            a: try parseLabeledNumber(text, key: "A"),
            b: try parseLabeledNumber(text, key: "B"),
            c: try parseLabeledNumber(text, key: "C")
        )
    }
}

struct ArmPose: Equatable, Sendable {
    var cartesian: CartesianPose
    var joints: JointPose
    var e: Double
    var motorStatus: Int?
    var isStale: Bool

    static func parseM114Extras(_ text: String) -> (e: Double, motorStatus: Int?) {
        let e = (try? parseLabeledNumber(text, key: "E")) ?? 0
        let motor = try? parseLabeledNumber(text, key: "motor_status")
        return (e, motor.map { Int($0) })
    }
}

struct FirmwareIdentity: Equatable, Sendable {
    var raw: String
    var isHuenitMarlin: Bool

    static func parse(_ text: String) -> FirmwareIdentity {
        FirmwareIdentity(
            raw: text,
            isHuenitMarlin: text.localizedCaseInsensitiveContains("Marlin")
                && text.localizedCaseInsensitiveContains("FYSETC_E4")
        )
    }
}

enum Axis: String, Sendable, CaseIterable {
    case x, y, z, a, b, c, e

    var isCartesian: Bool { [.x, .y, .z].contains(self) }
    var isModule: Bool { self == .e }
    var gcodeLetter: String { rawValue.uppercased() }
}
