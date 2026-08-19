import Foundation

public enum CameraAuthorizationStatus: String, Codable, CaseIterable, Equatable, Sendable {
    case notDetermined
    case requesting
    case authorized
    case denied
    case restricted
    case unavailable
    case failed

    public var recoveryAction: CameraAuthorizationRecoveryAction? {
        switch self {
        case .notDetermined:
            .requestPermission
        case .denied, .restricted:
            .openSystemSettings
        case .authorized, .unavailable, .failed:
            .rescan
        case .requesting:
            nil
        }
    }
}

public enum CameraAuthorizationRecoveryAction: String, Codable, Equatable, Sendable {
    case requestPermission
    case openSystemSettings
    case rescan
}

public protocol CameraAuthorizationClient: Sendable {
    func status() async -> CameraAuthorizationStatus
    func requestAccess() async -> CameraAuthorizationStatus
}

public actor DeterministicCameraAuthorizationClient: CameraAuthorizationClient {
    private var currentStatus: CameraAuthorizationStatus
    private var requestResult: CameraAuthorizationStatus
    private(set) var requestCount = 0

    public init(
        status: CameraAuthorizationStatus = .notDetermined,
        requestResult: CameraAuthorizationStatus = .authorized
    ) {
        self.currentStatus = status
        self.requestResult = requestResult
    }

    public func status() async -> CameraAuthorizationStatus {
        currentStatus
    }

    public func requestAccess() async -> CameraAuthorizationStatus {
        requestCount += 1
        currentStatus = .requesting
        currentStatus = requestResult
        return currentStatus
    }

    public func setStatus(_ status: CameraAuthorizationStatus) {
        currentStatus = status
    }

    public func setRequestResult(_ status: CameraAuthorizationStatus) {
        requestResult = status
    }
}
