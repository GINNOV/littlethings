import AppKit
import ArmageddonCore
import Observation

@MainActor
@Observable
final class AppModel {
    private let coordinator: AppStateCoordinator
    private let cameraLifecycle: NativeCameraLifecycleController
    private let cameraLifecycleObserver: AVFoundationCameraLifecycleObserver

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
        cameraLifecycle: NativeCameraLifecycleController,
        cameraLifecycleObserver: AVFoundationCameraLifecycleObserver = AVFoundationCameraLifecycleObserver()
    ) {
        self.coordinator = coordinator
        self.cameraLifecycle = cameraLifecycle
        self.cameraLifecycleObserver = cameraLifecycleObserver
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

    func startCameraLifecycleMonitoring() {
        cameraLifecycleObserver.start { [weak self] event in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if case .interrupted = event {
                    await cameraLifecycle.markInterrupted()
                    cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
                } else {
                    await refreshCameraLifecycle()
                }
            }
        }
    }

    func openCameraSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") else { return }
        NSWorkspace.shared.open(url)
    }
}
