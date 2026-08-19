import ArmageddonCore
import Observation

@MainActor
@Observable
final class AppModel {
    private let coordinator: AppStateCoordinator

    private(set) var destination: String
    private(set) var selectedDevice: DeviceIdentity?
    private(set) var selectedModelID: String?
    private(set) var armed: Bool
    private(set) var moving: Bool
    private(set) var restorationNotice: AppStateRestorationNotice?

    init(coordinator: AppStateCoordinator, restoredState: RestoredAppState) {
        self.coordinator = coordinator
        destination = restoredState.destination
        selectedDevice = restoredState.selectedDevice
        selectedModelID = restoredState.selectedModelID
        armed = restoredState.armed
        moving = restoredState.moving
        restorationNotice = restoredState.notice
    }

    func restore() async {
        guard let restored = try? await coordinator.restore() else { return }
        destination = restored.destination
        selectedDevice = restored.selectedDevice
        selectedModelID = restored.selectedModelID
        armed = restored.armed
        moving = restored.moving
        restorationNotice = restored.notice
    }

    func persistSelections() async {
        let snapshot = AppStateSnapshot(
            destination: destination,
            selectedDevice: selectedDevice,
            selectedModelID: selectedModelID,
            armed: false,
            moving: false
        )
        try? await coordinator.save(snapshot)
    }
}
