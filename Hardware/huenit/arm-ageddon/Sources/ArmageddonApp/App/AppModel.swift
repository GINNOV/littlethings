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
    private let k210Inventory: K210ArtifactInventory
    private let captureStore: CaptureSessionStore?
    private let diagnosticLog: DiagnosticEventLog?
    let livePreview: LivePreviewModel
    let calibrationWizard: CalibrationWizardModel
    let runs: RunsWorkspaceModel

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
    private(set) var k210Artifacts: [K210ArtifactRecord]
    private(set) var k210InventoryError: String?
    private(set) var captures: [CaptureRecord] = []
    private(set) var captureImageData: [String: Data] = [:]
    private(set) var captureError: String?
    private(set) var diagnosticEvents: [DiagnosticEvent] = []
    private(set) var supportBundleURL: URL?
    private(set) var availableNativeCameras: [NativeCameraDevice] = []

    init(
        coordinator: AppStateCoordinator,
        restoredState: RestoredAppState,
        cameraLifecycle: NativeCameraLifecycleController,
        cameraLifecycleObserver: AVFoundationCameraLifecycleObserver = AVFoundationCameraLifecycleObserver(),
        modelRegistry: ModelRegistry? = nil,
        livePreview: LivePreviewModel = LivePreviewModel(),
        calibrationWizard: CalibrationWizardModel? = nil,
        calibrationProfileURL: URL? = nil,
        captureRoot: URL? = nil,
        runMode: RunWorkspaceExecutionMode = .unavailable,
        runJournalRoot: URL? = nil
    ) {
        self.coordinator = coordinator
        self.cameraLifecycle = cameraLifecycle
        self.cameraLifecycleObserver = cameraLifecycleObserver
        self.modelRegistry = modelRegistry ?? ModelRegistry(root: Self.defaultModelRegistryRoot())
        self.k210Inventory = K210ArtifactInventory(
            root: Self.defaultK210InventoryRoot(),
            decision: Self.defaultK210CapabilityDecision()
        )
        self.captureStore = Self.makeCaptureStore(root: captureRoot ?? Self.defaultCaptureRoot())
        self.diagnosticLog = try? DiagnosticEventLog()
        self.livePreview = livePreview
        self.calibrationWizard = calibrationWizard ?? CalibrationWizardModel(profileURL: calibrationProfileURL)
        runs = RunsWorkspaceModel(
            mode: runMode,
            journalRoot: runJournalRoot ?? Self.defaultRunJournalRoot(),
            clock: livePreview.hostClock
        )
        destination = restoredState.destination
        selectedDevice = restoredState.selectedDevice
        selectedModelID = restoredState.selectedModelID
        armed = restoredState.armed
        moving = restoredState.moving
        cameraWorkCancelled = false
        restorationNotice = restoredState.notice
        cameraLifecycleSnapshot = NativeCameraLifecycleSnapshot(authorization: .notDetermined)
        availableNativeCameras = []
        modelRegistrySnapshot = .empty
        modelImportError = nil
        k210Artifacts = []
        k210InventoryError = nil
        captureError = nil
        supportBundleURL = nil
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
        await reconcileNativeCameraSelection()
        await startCameraPreviewIfAvailable()
    }

    var selectedNativeCameraID: String {
        if case .nativeCamera(let identifier) = selectedDevice {
            return identifier
        }
        if case .selected(.nativeCamera(let identifier)) = cameraLifecycleSnapshot.selection {
            return identifier
        }
        return ""
    }

    func selectLiveSource(_ source: LivePreviewSource) async {
        await livePreview.selectSource(source)
        if source == .nativeCamera {
            await startCameraPreviewIfAvailable()
        }
    }

    func selectNativeCamera(id: String) async {
        guard !id.isEmpty, id != "changed-camera" else { return }
        do {
            try await cameraLifecycle.select(.nativeCamera(id))
            selectedDevice = .nativeCamera(id)
            calibrationWizard.selectedCameraID = id
            await persistSelections()
            cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
            if livePreview.selectedSource == .nativeCamera {
                await livePreview.stop()
                await startCameraPreviewIfAvailable()
            }
        } catch {
            captureError = "The selected camera is unavailable."
        }
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
        if let format = livePreview.negotiatedFormat {
            calibrationWizard.updateCurrentFormat(format)
        }
    }

    func configureCalibratedRunFixture() {
        calibrationWizard.installDeterministicFixtureProfile()
    }

    func prepareRunProposal() async {
        if runs.isDeterministicFixture {
            await livePreview.reloadDeterministicFixtureOverlayPreservingSelection()
        }
        await runs.prepare(
            observation: livePreview.selectedObservation,
            selectedObservationID: livePreview.selectedObservationID,
            format: livePreview.negotiatedFormat,
            modelHash: livePreview.activeModelHash,
            profile: calibrationWizard.activeProfile
        )
    }

    func executePreparedRun() async {
        await runs.execute()
    }

    func retryLiveDetection() async {
        await livePreview.reloadDeterministicFixtureOverlay()
        if let format = livePreview.negotiatedFormat {
            calibrationWizard.updateCurrentFormat(format)
        }
    }

    func simulateModelFailureFixture() async {
        await livePreview.simulateModelFailureFixture()
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

    func refreshK210Artifacts() async {
        k210Artifacts = await k210Inventory.all()
    }

    func openCaptures() async {
        guard let captureStore else {
            captureError = "Capture storage is unavailable for this launch."
            await recordDiagnostic(category: .storage, severity: .error, code: "storage-unavailable", message: captureError ?? "")
            return
        }
        do {
            try await captureStore.open()
            await refreshCaptures()
            captureError = nil
            await recordDiagnostic(category: .storage, severity: .info, code: "storage-ready", message: "Capture storage is ready.")
        } catch {
            captureError = "Capture storage could not be opened."
            await recordDiagnostic(category: .storage, severity: .error, code: "storage-open-failed", message: captureError ?? "")
        }
    }

    func refreshDiagnostics() async {
        diagnosticEvents = await diagnosticLog?.snapshot() ?? []
    }

    func exportSupportBundle(to outputURL: URL) async {
        let events = await diagnosticLog?.snapshot() ?? []
        let snapshot = DiagnosticSnapshot(
            generatedAt: ContinuousCaptureHostClock().now(),
            states: [
                "camera": cameraLifecycleSnapshot.connection.rawValue,
                "capture": captureStore == nil ? "unavailable" : "ready",
                "motion": armed ? "armed" : "disarmed"
            ],
            metrics: ["captureCount": Double(captures.count)],
            modelHashes: modelRegistrySnapshot.models.map(\.artifactHash)
        )
        do {
            supportBundleURL = try SupportBundleExporter.export(
                to: outputURL,
                appVersion: "0.1",
                toolVersion: "Armageddon",
                events: events,
                snapshot: snapshot
            )
            await recordDiagnostic(category: .storage, severity: .info, code: "support-exported", message: "Support bundle exported.")
            diagnosticEvents = await diagnosticLog?.snapshot() ?? []
        } catch {
            captureError = "Support export was refused because the destination already exists or is invalid."
        }
    }

    func refreshCaptures(search: String = "") async {
        guard let captureStore else { return }
        do {
            captures = try await captureStore.query(search: search)
            var images: [String: Data] = [:]
            for record in captures {
                if let data = try? await captureStore.imageData(for: record),
                   RecordedFixtureFrameImage.isDisplayableFrame(data) {
                    images[record.id] = data
                } else {
                    let width = Int(record.provenance.imageSize.width)
                    let height = Int(record.provenance.imageSize.height)
                    images[record.id] = RecordedFixtureFrameImage.jpeg(
                        width: width,
                        height: height,
                        observations: record.provenance.observations
                    )
                }
            }
            captureImageData = images
            captureError = nil
        } catch {
            captureError = "Captures could not be loaded."
        }
    }

    func captureCurrentFrame(name: String = "Captured frame") async {
        guard let captureStore else {
            captureError = "Capture storage is unavailable for this launch."
            return
        }
        guard !livePreview.isPaused else {
            livePreview.captureCurrentFrame()
            return
        }
        guard let frame = await livePreview.currentCaptureFrame(),
              let format = livePreview.negotiatedFormat else {
            captureError = "No camera frame is ready to capture."
            return
        }
        guard let image = livePreview.currentCaptureImageData(),
              RecordedFixtureFrameImage.isDisplayableFrame(image) else {
            captureError = "No valid JPEG image is ready to capture."
            return
        }
        let imageSize = PixelSize(width: Double(format.width), height: Double(format.height))
        let provenance = CaptureProvenance(
            sourceID: livePreview.selectedSource.rawValue,
            frameID: frame.id,
            modelID: livePreview.activeModelID,
            modelHash: livePreview.activeModelHash,
            observations: livePreview.observations,
            selectedObservationID: livePreview.selectedObservationID,
            calibrationID: nil,
            armPose: nil,
            runID: nil,
            captureInstant: frame.captureInstant,
            imageSize: imageSize,
            imageFormat: .jpeg
        )
        do {
            _ = try await captureStore.capture(image: image, thumbnail: nil, provenance: provenance, name: name)
            livePreview.captureCurrentFrame()
            await refreshCaptures()
            captureError = nil
            await recordDiagnostic(
                category: .capture,
                severity: .info,
                code: "capture-persisted",
                message: "Explicit capture persisted.",
                metadata: ["source": livePreview.selectedSource.rawValue, "count": "1"]
            )
        } catch {
            captureError = "The frame could not be persisted atomically."
            await recordDiagnostic(category: .capture, severity: .error, code: "capture-failed", message: captureError ?? "")
        }
    }

    func reviewCapture(id: String, as review: CaptureReview) async {
        guard let captureStore else { return }
        do {
            try await captureStore.review(id: id, as: review)
            await refreshCaptures()
        } catch {
            captureError = "The capture review could not be saved."
        }
    }

    func trashCapture(id: String) async {
        guard let captureStore else { return }
        do {
            try await captureStore.trash(id: id)
            await refreshCaptures()
        } catch {
            captureError = "The capture could not be moved to Trash."
        }
    }

    func restoreCapture(id: String) async {
        guard let captureStore else { return }
        do {
            try await captureStore.restore(id: id)
            await refreshCaptures()
        } catch {
            captureError = "The capture could not be restored."
        }
    }

    func exportCapture(id: String, to directory: URL) async -> URL? {
        guard let captureStore else { return nil }
        do {
            let manifestURL = try await captureStore.export(id: id, to: directory)
            captureError = nil
            return manifestURL
        } catch {
            captureError = "Export refused because its destination already exists or is invalid."
            return nil
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

    func importK210Bundle(manifestURL: URL, modelURL: URL, scriptURL: URL) async {
        do {
            _ = try await k210Inventory.importBundle(
                manifestURL: manifestURL,
                modelURL: modelURL,
                scriptURL: scriptURL
            )
            k210Artifacts = await k210Inventory.all()
            k210InventoryError = nil
        } catch {
            k210InventoryError = k210ErrorMessage(error)
        }
    }

    func importK210Bundle(urls: [URL]) async {
        do {
            guard let manifestURL = urls.first(where: { $0.lastPathComponent.hasSuffix(".armk210.json") }) else {
                throw K210InventoryError.missingArtifact("manifest.armk210.json")
            }
            let manifest = try JSONDecoder().decode(
                K210ArtifactManifest.self,
                from: Data(contentsOf: manifestURL)
            )
            guard let modelURL = urls.first(where: { $0.lastPathComponent == manifest.modelFilename }) else {
                throw K210InventoryError.missingArtifact(manifest.modelFilename)
            }
            guard let scriptURL = urls.first(where: { $0.lastPathComponent == manifest.scriptFilename }) else {
                throw K210InventoryError.missingArtifact(manifest.scriptFilename)
            }
            await importK210Bundle(manifestURL: manifestURL, modelURL: modelURL, scriptURL: scriptURL)
        } catch {
            k210InventoryError = k210ErrorMessage(error)
        }
    }

    func importK210Bundle(directoryURL: URL) async {
        let isAccessingSecurityScopedResource = directoryURL.startAccessingSecurityScopedResource()
        defer {
            if isAccessingSecurityScopedResource {
                directoryURL.stopAccessingSecurityScopedResource()
            }
        }
        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            await importK210Bundle(urls: urls)
        } catch {
            k210InventoryError = k210ErrorMessage(error)
        }
    }

    func exportK210Artifact(id: String, to directory: URL) async {
        do {
            _ = try await k210Inventory.exportBundle(identifier: id, to: directory)
            k210InventoryError = nil
        } catch {
            k210InventoryError = k210ErrorMessage(error)
        }
    }

    func activateModel(id: String) async {
        do {
            _ = try await modelRegistry.activate(identifier: id)
            modelRegistrySnapshot = try await modelRegistry.snapshot()
            modelImportError = nil
            selectedModelID = id
            if let model = modelRegistrySnapshot.models.first(where: { $0.id == id }) {
                livePreview.setActiveModel(id: model.id, label: model.displayName, hash: model.artifactHash)
            }
            await persistSelections()
        } catch {
            modelImportError = modelErrorMessage(error)
        }
    }

    func rollbackModel(id: String) async {
        do {
            _ = try await modelRegistry.rollback(to: id)
            modelRegistrySnapshot = try await modelRegistry.snapshot()
            modelImportError = nil
            selectedModelID = id
            if let model = modelRegistrySnapshot.models.first(where: { $0.id == id }) {
                livePreview.setActiveModel(id: model.id, label: model.displayName, hash: model.artifactHash)
            }
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

    func configureConnectedCameraFixture() async {
        guard cameraLifecycleSnapshot.authorization == .authorized else { return }
        try? await cameraLifecycle.select(.nativeCamera("fixture-camera"))
        await cameraLifecycle.markConnected()
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

    private func reconcileNativeCameraSelection() async {
        let cameras = await cameraLifecycle.availableNativeCameras()
        availableNativeCameras = cameras
        let snapshot = await cameraLifecycle.snapshot()
        if case .selected(.nativeCamera(let identifier)) = snapshot.selection {
            selectedDevice = .nativeCamera(identifier)
            if calibrationWizard.selectedCameraID != "changed-camera" {
                calibrationWizard.selectedCameraID = identifier
            }
            cameraLifecycleSnapshot = snapshot
            return
        }
        guard snapshot.authorization == .authorized,
              let preferred = NativeCameraSelectionPolicy.preferredUniqueID(
                discovered: cameras,
                restored: selectedDevice,
                current: snapshot.selection
              ) else {
            cameraLifecycleSnapshot = snapshot
            return
        }
        try? await cameraLifecycle.select(.nativeCamera(preferred))
        selectedDevice = .nativeCamera(preferred)
        if calibrationWizard.selectedCameraID != "changed-camera" {
            calibrationWizard.selectedCameraID = preferred
        }
        await persistSelections()
        cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
    }

    private func startCameraPreviewIfAvailable() async {
        guard livePreview.selectedSource == .nativeCamera,
              cameraLifecycleSnapshot.authorization == .authorized,
              cameraLifecycleSnapshot.connection == .available,
              case let .selected(.nativeCamera(uniqueID)) = cameraLifecycleSnapshot.selection,
              let device = AVCaptureDevice(uniqueID: uniqueID),
              !livePreview.isRunning else { return }

        await cameraLifecycle.markConnecting()
        cameraLifecycleSnapshot = await cameraLifecycle.snapshot()
        do {
            try await livePreview.start(device: device)
            if let format = livePreview.negotiatedFormat {
                calibrationWizard.updateCurrentFormat(format)
            }
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

    private static func defaultK210InventoryRoot() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Armageddon", isDirectory: true)
            .appendingPathComponent("K210", isDirectory: true)
    }

    private static func defaultK210CapabilityDecision() -> HuenitCameraCapabilityDecision {
        HuenitCameraCapabilityDecision(
            status: .notMeasured,
            supported: [],
            unsupportedReasons: [
                .preview: "HUENIT preview has not been measured.",
                .artifactUpload: "HUENIT artifact upload has not been measured."
            ],
            profile: nil
        )
    }

    private static func defaultCaptureRoot() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Armageddon", isDirectory: true)
            .appendingPathComponent("Captures", isDirectory: true)
    }

    private static func defaultRunJournalRoot() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Armageddon", isDirectory: true)
            .appendingPathComponent("Runs", isDirectory: true)
    }

    private static func makeCaptureStore(root: URL) -> CaptureSessionStore? {
        guard let metadata = try? SwiftDataArtifactMetadataStore(
            storeURL: root.appendingPathComponent("Metadata", isDirectory: true)
                .appendingPathComponent("metadata.store")
        ) else { return nil }
        let fileSystem = POSIXDurableFileSystem(
            root: root.appendingPathComponent("Artifacts", isDirectory: true)
        )
        let artifacts = LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata)
        let index = FileCaptureIndexStore(
            fileURL: root.appendingPathComponent("Index", isDirectory: true)
                .appendingPathComponent("captures.json")
        )
        return CaptureSessionStore(artifacts: artifacts, index: index)
    }

    private func modelErrorMessage(_ error: Error) -> String {
        if let registryError = error as? ModelRegistryError {
            return registryError.reason
        }
        return "The model could not be activated."
    }

    private func k210ErrorMessage(_ error: Error) -> String {
        guard let error = error as? K210InventoryError else {
            return "The K210 bundle could not be imported."
        }
        return switch error {
        case .invalidFilename: "The K210 bundle contains an unsafe filename or identifier."
        case .missingLabels: "The K210 manifest must contain unique labels."
        case .invalidAnchors: "The K210 manifest contains invalid anchors."
        case let .missingArtifact(name): "The K210 bundle is missing \(name)."
        case let .hashMismatch(name): "The K210 \(name) hash does not match its manifest."
        case .destinationExists: "That K210 destination already exists."
        case .uploadUnsupported: "In-app K210 upload is unsupported; copy the verified bundle manually."
        }
    }

    private func recordDiagnostic(
        category: DiagnosticCategory,
        severity: DiagnosticSeverity,
        code: String,
        message: String,
        metadata: [String: String] = [:]
    ) async {
        guard let diagnosticLog else { return }
        _ = await diagnosticLog.append(
            occurredAt: ContinuousCaptureHostClock().now(),
            generation: livePreview.latestFrame?.id ?? 0,
            category: category,
            severity: severity,
            code: code,
            message: message,
            metadata: metadata
        )
        diagnosticEvents = await diagnosticLog.snapshot()
    }

}
