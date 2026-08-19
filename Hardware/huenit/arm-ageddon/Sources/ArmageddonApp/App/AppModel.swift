import ArmageddonCore
import Observation

@MainActor
@Observable
final class AppModel {
    private let coordinator: AppStateCoordinator
    private let cameraLifecycle: NativeCameraLifecycleController

    private(set) var destination: String
    private(set) var selectedDevice: DeviceIdentity?
    private(set) var selectedModelID: String?
    private(set) var armed: Bool
    private(set) var moving: Bool
    private(set) var restorationNotice: AppStateRestorationNotice?
    private(set) var cameraLifecycleSnapshot: NativeCameraLifecycleSnapshot

    init(
        coordinator: AppStateCoordinator,
        restoredState: RestoredAppState,
        cameraLifecycle: NativeCameraLifecycleController
    ) {
        self.coordinator = coordinator
        self.cameraLifecycle = cameraLifecycle
        destination = restoredState.destination
        selectedDevice = restoredState.selectedDevice
        selectedModelID = restoredState.selectedModelID
        armed = restoredState.armed
        moving = restoredState.moving
        restorationNotice = restoredState.notice
        cameraLifecycleSnapshot = NativeCameraLifecycleSnapshot(authorization: .notDetermined)
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
            selectedModelID: selectedModelID
        )
        try? await coordinator.save(snapshot)
    }

    func refreshCameraLifecycle() async {
        _ = await cameraLifecycle.refresh()
        cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
    }

    func requestCameraPermission() async {
        cameraLifecycleSnapshot = await cameraLifecycle.requestAuthorization()
    }

    func rescanCameras() async {
        _ = await cameraLifecycle.refresh()
        cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
    }
}
