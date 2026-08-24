import ArmageddonCore
import ArmageddonMotionBoundary
import Foundation

public struct DiscoveredArmPort: Sendable, Equatable, Identifiable {
    public var id: String { path }
    public let path: String
    public let label: String

    public init(path: String, label: String) {
        self.path = path
        self.label = label
    }
}

public enum LiveArm {
    public static func scanPorts() -> [DiscoveredArmPort] {
        ArmPortPicker.scan().map { DiscoveredArmPort(path: $0.path, label: $0.label) }
    }

    public static func preferredPath() -> String? {
        ProcessInfo.processInfo.environment["ARMAGEDDON_ARM_SERIAL"]
            ?? ArmPortPicker.preferredPath()
    }

    public static func makeOperator(path: String? = nil) throws -> any ArmOperatorControlling {
        guard let resolved = path ?? preferredPath(), !resolved.isEmpty else {
            throw ArmOperatorError.rejected("No HUEARM serial port. Plug the arm USB-C into the Mac and Rescan.")
        }
        return HuenitArmOperator(serialPath: resolved)
    }
}
