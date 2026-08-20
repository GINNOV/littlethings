import AppKit
import ArmageddonCore
import Observation
@preconcurrency import AVFoundation

@MainActor
@Observable
final class AppModel {
    private let coordinator: AppStateCoordinator
    private let cameraLifecycle: NativeCameraLifecycleController
    private let cameraLifecycleObserver: AVFoundationCameraLifecycleObserver
    private let modelRegistry: ModelRegistry
    let livePreview: LivePreviewModel

    private(set) var destination: String
    private(set) var selectedDevice: DeviceIdentity?
    private(set) var selectedModelID: String?
    private(set) var armed: Bool
    private(set) var moving: Bool
    private(set) var cameraWorkCancelled: Bool
    private(set) var restorationNotice: AppStateRestorationNotice?
    private(set) var cameraLifecycleSnapshot: NativeCameraLifecycleSnapshot
    private(set) var modelRegistrySnapshot: ModelRegistrySnapshot
    private(set) var modelImportError: String?

    init(
        coordinator: AppStateCoordinator,
        restoredState: RestoredAppState,
        cameraLifecycle: NativeCameraLifecycleController,
        cameraLifecycleObserver: AVFoundationCameraLifecycleObserver = AVFoundationCameraLifecycleObserver(),
        modelRegistry: ModelRegistry? = nil,
        livePreview: LivePreviewModel = LivePreviewModel()
    ) {
        self.coordinator = coordinator
        self.cameraLifecycle = cameraLifecycle
        self.cameraLifecycleObserver = cameraLifecycleObserver
        self.modelRegistry = modelRegistry ?? ModelRegistry(root: Self.defaultModelRegistryRoot())
        self.livePreview = livePreview
        destination = restoredState.destination
        selectedDevice = restoredState.selectedDevice
        selectedModelID = restoredState.selectedModelID
        armed = restoredState.armed
        moving = restoredState.moving
        cameraWorkCancelled = false
        restorationNotice = restoredState.notice
        cameraLifecycleSnapshot = NativeCameraLifecycleSnapshot(authorization: .notDetermined)
        modelRegistrySnapshot = .empty
        modelImportError = nil
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
        let events = await cameraLifecycle.refresh()
        if events.contains(where: {
            if case .selectionBecameStale = $0 { true } else { false }
        }) {
            await cancelCameraWork()
        }
        cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
        await startCameraPreviewIfAvailable()
    }

    func requestCameraPermission() async {
        _ = await cameraLifecycle.requestAuthorization()
        await refreshCameraLifecycle()
    }

    func rescanCameras() async {
        await refreshCameraLifecycle()
        if cameraLifecycleSnapshot.connection == .available || cameraLifecycleSnapshot.connection == .connected {
            cameraWorkCancelled = false
        }
    }

    func loadFixtureOverlay() async {
        try? await livePreview.loadDeterministicFixtureOverlay()
    }

    func refreshModels() async {
        do {
            try await modelRegistry.open()
            modelRegistrySnapshot = try await modelRegistry.snapshot()
            modelImportError = nil
        } catch {
            modelImportError = modelErrorMessage(error)
        }
    }

    func importModel(manifestURL: URL) async {
        do {
            try await modelRegistry.open()
            _ = try await modelRegistry.importAndActivate(manifestURL: manifestURL)
            modelRegistrySnapshot = try await modelRegistry.snapshot()
            modelImportError = nil
        } catch {
            modelImportError = modelErrorMessage(error)
        }
    }

    func activateModel(id: String) async {
        do {
            _ = try await modelRegistry.activate(identifier: id)
            modelRegistrySnapshot = try await modelRegistry.snapshot()
            modelImportError = nil
            selectedModelID = id
            await persistSelections()
        } catch {
            modelImportError = modelErrorMessage(error)
        }
    }

    func configureDisconnectedCameraFixture() async {
        guard cameraLifecycleSnapshot.authorization == .authorized else { return }
        try? await cameraLifecycle.select(.nativeCamera("fixture-camera"))
        await cameraLifecycle.markConnected()
        await cameraLifecycle.markDisconnected()
        await cancelCameraWork()
        cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
    }

    func startCameraLifecycleMonitoring() {
        cameraLifecycleObserver.start { [weak self] event in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch event {
                case .deviceDisconnected:
                    await cameraLifecycle.markDisconnected()
                    await cancelCameraWork()
                    cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
                case .interrupted:
                    await cameraLifecycle.markInterrupted()
                    await cancelCameraWork()
                    cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
                case .deviceConnected, .interruptionEnded:
                    await refreshCameraLifecycle()
                }
            }
        }
    }

    private func startCameraPreviewIfAvailable() async {
        guard cameraLifecycleSnapshot.authorization == .authorized,
              cameraLifecycleSnapshot.connection == .available,
              case let .selected(.nativeCamera(uniqueID)) = cameraLifecycleSnapshot.selection,
              let device = AVCaptureDevice(uniqueID: uniqueID),
              !livePreview.isRunning else { return }

        await cameraLifecycle.markConnecting()
        cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
        do {
            try await livePreview.start(device: device)
            await cameraLifecycle.markConnected()
        } catch {
            await livePreview.stop()
            await cameraLifecycle.markFailed()
        }
        cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
    }

    func openCameraSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") else { return }
        NSWorkspace.shared.open(url)
    }

    private func cancelCameraWork() async {
        armed = false
        moving = false
        cameraWorkCancelled = true
        await livePreview.stop()
    }

    private static func defaultModelRegistryRoot() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Armageddon", isDirectory: true)
            .appendingPathComponent("Models", isDirectory: true)
    }

    private func modelErrorMessage(_ error: Error) -> String {
        if let registryError = error as? ModelRegistryError {
            return registryError.reason
        }
        return "The model could not be activated."
    }
}
