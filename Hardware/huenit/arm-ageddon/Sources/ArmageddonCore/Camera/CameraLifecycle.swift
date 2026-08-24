import Foundation

public enum NativeCameraConnectionState: String, Codable, Equatable, Sendable {
    case unavailable
    case available
    case connecting
    case connected
    case disconnected
    case interrupted
    case failed
}

public enum CameraLifecycleError: Error, Equatable, Sendable {
    case notNativeCamera
    case unavailable
}

public struct NativeCameraLifecycleSnapshot: Equatable, Sendable {
    public let authorization: CameraAuthorizationStatus
    public let selection: DeviceSelection
    public let connection: NativeCameraConnectionState
    public let canRequestPermission: Bool
    public let canOpenSystemSettings: Bool
    public let canRescan: Bool

    public init(
        authorization: CameraAuthorizationStatus,
        selection: DeviceSelection = .none,
        connection: NativeCameraConnectionState = .unavailable
    ) {
        self.authorization = authorization
        self.selection = selection
        self.connection = connection
        canRequestPermission = authorization == .notDetermined
        canOpenSystemSettings = authorization == .denied || authorization == .restricted
        canRescan = (authorization == .authorized || authorization == .unavailable || authorization == .failed)
            && connection != .connected
    }
}

public actor NativeCameraLifecycleController {
    private let authorizationClient: any CameraAuthorizationClient
    private let catalog: DeviceCatalog
    private var currentState: NativeCameraLifecycleSnapshot

    public init(
        authorizationClient: any CameraAuthorizationClient,
        catalog: DeviceCatalog
    ) {
        self.authorizationClient = authorizationClient
        self.catalog = catalog
        currentState = NativeCameraLifecycleSnapshot(authorization: .notDetermined)
    }

    public func snapshot() -> NativeCameraLifecycleSnapshot {
        currentState
    }

    public func availableNativeCameras() async -> [NativeCameraDevice] {
        await catalog.devices().compactMap { record in
            guard case .nativeCamera(let identifier) = record.identity else { return nil }
            return NativeCameraDevice(
                stableIdentifier: identifier,
                permission: record.permission,
                displayName: record.displayName
            )
        }
        .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }

    @discardableResult
    public func requestAuthorization() async -> NativeCameraLifecycleSnapshot {
        _ = await authorizationClient.requestAccess()
        _ = await refresh()
        return currentState
    }

    @discardableResult
    public func refresh() async -> [DeviceEvent] {
        let authorization = await authorizationClient.status()
        guard authorization == .authorized else {
            currentState = NativeCameraLifecycleSnapshot(
                authorization: authorization,
                selection: currentState.selection,
                connection: .unavailable
            )
            return []
        }

        let events = await catalog.refresh()
        let selection = await catalog.selection()
        let connection: NativeCameraConnectionState = switch selection {
        case .stale:
            .disconnected
        case .none:
            currentState.connection == .connected ? .connected : .available
        case .selected:
            switch currentState.connection {
            case .unavailable, .disconnected, .interrupted, .failed:
                .available
            case .available, .connecting, .connected:
                currentState.connection
            }
        }
        currentState = NativeCameraLifecycleSnapshot(
            authorization: authorization,
            selection: selection,
            connection: connection
        )
        return events
    }

    public func select(_ identity: DeviceIdentity) async throws {
        guard case .nativeCamera = identity else {
            throw CameraLifecycleError.notNativeCamera
        }
        guard currentState.authorization == .authorized else {
            throw CameraLifecycleError.unavailable
        }
        try await catalog.select(identity)
        currentState = NativeCameraLifecycleSnapshot(
            authorization: currentState.authorization,
            selection: .selected(identity),
            connection: .available
        )
    }

    public func markConnecting() {
        guard currentState.authorization == .authorized else { return }
        currentState = NativeCameraLifecycleSnapshot(
            authorization: currentState.authorization,
            selection: currentState.selection,
            connection: .connecting
        )
    }

    public func markConnected() {
        guard currentState.authorization == .authorized else { return }
        currentState = NativeCameraLifecycleSnapshot(
            authorization: currentState.authorization,
            selection: currentState.selection,
            connection: .connected
        )
    }

    public func markDisconnected() {
        guard currentState.authorization == .authorized else { return }
        currentState = NativeCameraLifecycleSnapshot(
            authorization: currentState.authorization,
            selection: currentState.selection,
            connection: .disconnected
        )
    }

    public func markInterrupted() {
        guard currentState.authorization == .authorized else { return }
        currentState = NativeCameraLifecycleSnapshot(
            authorization: currentState.authorization,
            selection: currentState.selection,
            connection: .interrupted
        )
    }

    public func markFailed() {
        guard currentState.authorization == .authorized else { return }
        currentState = NativeCameraLifecycleSnapshot(
            authorization: currentState.authorization,
            selection: currentState.selection,
            connection: .failed
        )
    }
}
