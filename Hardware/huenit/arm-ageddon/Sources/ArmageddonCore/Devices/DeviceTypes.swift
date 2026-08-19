import Foundation

public enum DeviceKind: String, Codable, Hashable, Sendable {
    case camera
    case arm
}

public enum DeviceIdentity: Codable, Hashable, Sendable {
    case nativeCamera(String)
    case serialCamera(String)
    case arm(String)
}

public enum DeviceCapability: String, Codable, Hashable, Sendable {
    case videoFrames
    case serialTelemetry
    case artifactInventory
    case armMotion
}

public enum DevicePermissionState: String, Codable, Hashable, Sendable {
    case unknown
    case authorized
    case denied
    case restricted
}

public enum SerialDeviceRole: String, Codable, Hashable, Sendable {
    case camera
    case arm
}

public struct NativeCameraDevice: Codable, Hashable, Sendable {
    public let stableIdentifier: String
    public let permission: DevicePermissionState

    public init(stableIdentifier: String, permission: DevicePermissionState) {
        self.stableIdentifier = stableIdentifier
        self.permission = permission
    }
}

public struct SerialDevice: Codable, Hashable, Sendable {
    public let registryPath: String
    public let serialNumber: String
    public let role: SerialDeviceRole
    public let productName: String?

    public init(registryPath: String, serialNumber: String, role: SerialDeviceRole, productName: String? = nil) {
        self.registryPath = registryPath
        self.serialNumber = serialNumber
        self.role = role
        self.productName = productName
    }
}

public struct DeviceRecord: Hashable, Sendable {
    public let identity: DeviceIdentity
    public let kind: DeviceKind
    public let capabilities: [DeviceCapability]
    public let permission: DevicePermissionState

    private let serialNumber: String?
    private let registryPath: String?

    public init(
        identity: DeviceIdentity,
        kind: DeviceKind,
        capabilities: [DeviceCapability],
        permission: DevicePermissionState = .unknown,
        serialNumber: String? = nil,
        registryPath: String? = nil
    ) {
        self.identity = identity
        self.kind = kind
        self.capabilities = capabilities
        self.permission = permission
        self.serialNumber = serialNumber
        self.registryPath = registryPath
    }

    public static func nativeCamera(stableIdentifier: String, permission: DevicePermissionState) -> Self {
        DeviceRecord(
            identity: .nativeCamera(stableIdentifier),
            kind: .camera,
            capabilities: permission == .authorized ? [.videoFrames] : [],
            permission: permission
        )
    }

    public static func serialCamera(serialNumber: String, registryPath: String) -> Self {
        DeviceRecord(
            identity: .serialCamera(serialNumber),
            kind: .camera,
            capabilities: [.serialTelemetry, .artifactInventory],
            serialNumber: serialNumber,
            registryPath: registryPath
        )
    }

    public static func arm(serialNumber: String, registryPath: String) -> Self {
        DeviceRecord(
            identity: .arm(serialNumber),
            kind: .arm,
            capabilities: [.serialTelemetry, .artifactInventory, .armMotion],
            serialNumber: serialNumber,
            registryPath: registryPath
        )
    }

    public var redactedDisplay: String {
        kind == .arm ? "HUENIT arm" : "Camera"
    }

    public var redactedDiagnostics: String {
        "kind=\(kind.rawValue); capabilities=\(capabilities.map(\.rawValue).joined(separator: ",")); permission=\(permission.rawValue)"
    }
}

public enum DeviceSelection: Codable, Equatable, Sendable {
    case none
    case selected(DeviceIdentity)
    case stale(DeviceIdentity)
}

public enum DeviceEvent: Equatable, Sendable {
    case added(DeviceRecord)
    case removed(DeviceIdentity)
    case selectionBecameStale(DeviceIdentity)
    case selectionRecovered(DeviceIdentity)
}

public enum DeviceSelectionError: Error, Equatable, Sendable {
    case unavailable(DeviceIdentity)
}

public enum DeviceLifecycleTransitionError: Error, Equatable, Sendable {
    case impossible(from: DeviceConnectionLifecycle, to: DeviceConnectionLifecycle)
}

public enum DeviceConnectionLifecycle: String, Codable, Equatable, Sendable {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case failed

    public func transitioning(to next: Self) throws -> Self {
        let allowed: Set<Self> = switch self {
        case .disconnected: [.connecting]
        case .connecting: [.connected, .disconnected, .failed]
        case .connected: [.disconnecting, .failed]
        case .disconnecting: [.disconnected, .failed]
        case .failed: [.connecting, .disconnected]
        }
        guard allowed.contains(next) else {
            throw DeviceLifecycleTransitionError.impossible(from: self, to: next)
        }
        return next
    }
}
