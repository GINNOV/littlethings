import Foundation

public struct AppStateSnapshot: Codable, Equatable, Sendable {
    public let destination: String?
    public let selectedDevice: DeviceIdentity?
    public let selectedModelID: String?
    public let armed: Bool
    public let moving: Bool

    public init(
        destination: String?,
        selectedDevice: DeviceIdentity?,
        selectedModelID: String?,
        armed: Bool,
        moving: Bool
    ) {
        self.destination = destination
        self.selectedDevice = selectedDevice
        self.selectedModelID = selectedModelID
        self.armed = armed
        self.moving = moving
    }
}

public struct RestoredAppState: Equatable, Sendable {
    public let destination: String
    public let selectedDevice: DeviceIdentity?
    public let selectedModelID: String?
    public let armed: Bool
    public let moving: Bool
    public let notice: AppStateRestorationNotice?

    public init(
        destination: String,
        selectedDevice: DeviceIdentity?,
        selectedModelID: String?,
        armed: Bool,
        moving: Bool,
        notice: AppStateRestorationNotice?
    ) {
        self.destination = destination
        self.selectedDevice = selectedDevice
        self.selectedModelID = selectedModelID
        self.armed = armed
        self.moving = moving
        self.notice = notice
    }
}

public enum AppStateRestorationNotice: String, Codable, Equatable, Sendable {
    case navigationRecovered
    case unsafeStateDiscarded
}

public enum AppStateRestorer {
    public static let validDestinations: Set<String> = [
        "live.workspace",
        "capture.library",
        "models.library",
        "runs.history",
        "diagnostics.workspace",
    ]

    public static func restore(
        _ snapshot: AppStateSnapshot,
        validDestinations: Set<String> = Self.validDestinations
    ) -> RestoredAppState {
        let destination = snapshot.destination.flatMap { validDestinations.contains($0) ? $0 : nil } ?? "live.workspace"
        let navigationNotice = snapshot.destination == destination ? nil : AppStateRestorationNotice.navigationRecovered
        let unsafeNotice = snapshot.armed || snapshot.moving ? AppStateRestorationNotice.unsafeStateDiscarded : nil
        let notice = unsafeNotice ?? navigationNotice
        return RestoredAppState(
            destination: destination,
            selectedDevice: snapshot.selectedDevice,
            selectedModelID: snapshot.selectedModelID,
            armed: false,
            moving: false,
            notice: notice
        )
    }
}

public protocol AppStateRepository: Sendable {
    func load() async throws -> AppStateSnapshot?
    func save(_ snapshot: AppStateSnapshot) async throws
}

public actor InMemoryAppStateRepository: AppStateRepository {
    private var snapshot: AppStateSnapshot?

    public init(snapshot: AppStateSnapshot? = nil) {
        self.snapshot = snapshot
    }

    public func load() async throws -> AppStateSnapshot? {
        snapshot
    }

    public func save(_ snapshot: AppStateSnapshot) async throws {
        self.snapshot = snapshot
    }
}

public actor AppStateCoordinator {
    private let repository: any AppStateRepository

    public init(repository: any AppStateRepository) {
        self.repository = repository
    }

    public func restore() async throws -> RestoredAppState {
        AppStateRestorer.restore(try await repository.load() ?? AppStateSnapshot(
            destination: "live.workspace",
            selectedDevice: nil,
            selectedModelID: nil,
            armed: false,
            moving: false
        ))
    }

    public func save(_ snapshot: AppStateSnapshot) async throws {
        try await repository.save(snapshot)
    }
}
