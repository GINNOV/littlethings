import ArmageddonCore
import AVFoundation
import Foundation
import Observation

public enum LivePreviewSource: String, CaseIterable, Codable, Sendable {
    case nativeCamera
    case recordedFixture
    case huenitTelemetry

    public var label: String {
        switch self {
        case .nativeCamera: "Native camera"
        case .recordedFixture: "Recorded fixture"
        case .huenitTelemetry: "HUENIT telemetry · detection only"
        }
    }
}

@MainActor
@Observable
public final class LivePreviewModel {
    private let capture: AVFoundationNativeCaptureSession
    private let telemetry: PerformanceTelemetry?
    private let telemetryClock: any CaptureHostClock
    public private(set) var previewLayer: AVCaptureVideoPreviewLayer?
    public private(set) var snapshot: NativeCaptureSessionSnapshot
    public private(set) var negotiatedFormat: CaptureFormat?
    public private(set) var observations: [DetectionObservation] = []
    public private(set) var detectorInputSize = PixelSize(width: 224, height: 224)
    public private(set) var performanceSnapshot = PerformanceTelemetrySnapshot()
    public private(set) var isPaused = false
    public private(set) var capturedFrameCount = 0
    public private(set) var lastCaptureMessage: String?
    public private(set) var selectedObservationID: String?
    public private(set) var selectedSource: LivePreviewSource = .nativeCamera
    public private(set) var activeModelID = "fixture.constant.detector"
    public private(set) var activeModelLabel = "Fixture detector"
    public private(set) var latestFrame: CameraFrameMetadata?

    public var isRunning: Bool {
        capture.isRunning
    }

    public var attachedResourceCount: Int {
        capture.attachedResourceCount
    }

    public var targetingAvailable: Bool {
        performanceSnapshot.targetingAvailable
    }

    public var selectedObservation: DetectionObservation? {
        guard let selectedObservationID else { return nil }
        return observations.first { $0.id == selectedObservationID }
    }

    public init(
        capture: AVFoundationNativeCaptureSession = AVFoundationNativeCaptureSession(),
        telemetry: PerformanceTelemetry? = nil
    ) {
        self.capture = capture
        self.telemetry = telemetry ?? Self.makeTelemetry()
        telemetryClock = ContinuousCaptureHostClock()
        snapshot = NativeCaptureSessionSnapshot(
            state: .idle,
            configuration: nil,
            source: nil,
            metrics: NativeCaptureSessionMetrics()
        )
        negotiatedFormat = nil
        previewLayer = capture.previewLayer()
        latestFrame = nil
    }

    public func start(device: AVCaptureDevice, requestedFormat: CaptureFormat = CaptureFormat(width: 1_280, height: 720, frameRate: 30)) async throws {
        await resetPerformanceTelemetry()
        negotiatedFormat = try await capture.start(device: device, requestedFormat: requestedFormat)
        isPaused = false
        lastCaptureMessage = nil
        await refreshSnapshot()
    }

    public func switchSource(to device: AVCaptureDevice, requestedFormat: CaptureFormat = CaptureFormat(width: 1_280, height: 720, frameRate: 30)) async throws {
        await stop()
        try await start(device: device, requestedFormat: requestedFormat)
    }

    public func refreshSnapshot() async {
        snapshot = await capture.snapshot()
    }

    public func updateObservations(_ observations: [DetectionObservation]) {
        self.observations = observations
        if let selectedObservationID,
           !observations.contains(where: { $0.id == selectedObservationID }) {
            self.selectedObservationID = nil
        }
    }

    public func selectObservation(id: String?) {
        guard let id else {
            selectedObservationID = nil
            return
        }
        guard observations.contains(where: { $0.id == id }) else { return }
        selectedObservationID = id
    }

    public func setPaused(_ paused: Bool) {
        isPaused = paused
        lastCaptureMessage = paused
            ? "Preview paused. Resume to capture a fresh frame."
            : "Preview resumed."
    }

    public func selectSource(_ source: LivePreviewSource) async {
        guard source != .huenitTelemetry else {
            lastCaptureMessage = "HUENIT telemetry is detection-only until its protocol is measured."
            return
        }
        selectedSource = source
        if source == .recordedFixture {
            await reloadDeterministicFixtureOverlay()
        } else {
            lastCaptureMessage = "Source switched to Native camera."
        }
    }

    public func selectFixtureModel(id: String, label: String) async {
        activeModelID = id
        activeModelLabel = label
        await reloadDeterministicFixtureOverlay()
    }

    public func setActiveModel(id: String, label: String) {
        activeModelID = id
        activeModelLabel = label
    }

    public func reloadDeterministicFixtureOverlay() async {
        await resetPerformanceTelemetry()
        try? await loadDeterministicFixtureOverlay()
        lastCaptureMessage = "Detection model ready: \(activeModelLabel)."
    }

    public func simulateModelFailureFixture() async {
        guard let telemetry else { return }
        await telemetry.recordModelFailure()
        await telemetry.recordModelFailure()
        await telemetry.recordModelFailure()
        performanceSnapshot = await telemetry.snapshot(now: MonotonicInstant(nanoseconds: 1_100_000_000))
    }

    public func captureCurrentFrame() {
        guard !isPaused else {
            lastCaptureMessage = "Resume the preview before capturing a frame."
            return
        }
        guard !observations.isEmpty else {
            lastCaptureMessage = "No detection frame is ready to capture."
            return
        }
        capturedFrameCount += 1
        lastCaptureMessage = "Frame \(capturedFrameCount) staged for capture review."
    }

    public func currentCaptureFrame() async -> CameraFrameMetadata? {
        if let frame = await capture.consumeLatestFrame() {
            latestFrame = frame
        }
        return latestFrame
    }

    public func currentCaptureImageData() -> Data? {
        capture.consumeLatestImageData()
    }

    public func loadDeterministicFixtureOverlay() async throws {
        let manifest = try DetectorManifest(
            identifier: "fixture.constant.detector",
            sha256: String(repeating: "0", count: 64),
            input: DetectorInputContract(width: 224, height: 224),
            output: DetectorOutputContract(kind: .visionObjects),
            labels: ["target", "other"]
        )
        detectorInputSize = PixelSize(
            width: Double(manifest.input.width),
            height: Double(manifest.input.height)
        )
        let engine = DeterministicFakeInferenceEngine(detections: [
            FakeDetection(
                label: "target",
                confidence: 0.9,
                boundingBox: NormalizedRect(x: 0.25, y: 0.25, width: 0.2, height: 0.2)
            ),
            FakeDetection(
                label: "other",
                confidence: 0.82,
                boundingBox: NormalizedRect(x: 0.30, y: 0.28, width: 0.22, height: 0.2)
            ),
        ])
        let pipeline = try DetectorPipeline(manifest: manifest, engine: engine)
        let frame = CameraFrameMetadata(
            id: 1,
            rawPresentationTimestamp: 1,
            captureInstant: MonotonicInstant(nanoseconds: 1_000_000_000),
            format: CaptureFormat(width: 1_920, height: 1_080, frameRate: 30)
        )
        negotiatedFormat = frame.format
        latestFrame = frame
        observations = try await pipeline.process(
            frame: frame,
            now: MonotonicInstant(nanoseconds: 2_000_000_000),
            generation: 1
        )
        selectedObservationID = nil
        if let telemetry {
            try? await telemetry.recordFrame(
                captureInstant: frame.captureInstant,
                receivedAt: MonotonicInstant(nanoseconds: 1_020_000_000),
                negotiatedFPS: frame.format.frameRate,
                droppedFramesSinceLastSample: 0,
                queueDepth: 1
            )
            try? await telemetry.recordInference(
                captureInstant: frame.captureInstant,
                startedAt: MonotonicInstant(nanoseconds: 1_020_000_000),
                finishedAt: MonotonicInstant(nanoseconds: 1_040_000_000),
                overlayAt: MonotonicInstant(nanoseconds: 1_055_000_000),
                queueDepth: 1
            )
            performanceSnapshot = await telemetry.snapshot(now: MonotonicInstant(nanoseconds: 1_055_000_000))
            await persistPerformanceSummary()
        }
    }

    public func recordFrameTelemetry(
        captureInstant: MonotonicInstant,
        receivedAt: MonotonicInstant,
        negotiatedFPS: Double,
        droppedFramesSinceLastSample: UInt64,
        queueDepth: Int,
        now: MonotonicInstant
    ) async {
        guard let telemetry else { return }
        try? await telemetry.recordFrame(
            captureInstant: captureInstant,
            receivedAt: receivedAt,
            negotiatedFPS: negotiatedFPS,
            droppedFramesSinceLastSample: droppedFramesSinceLastSample,
            queueDepth: queueDepth
        )
        performanceSnapshot = await telemetry.snapshot(now: now)
    }

    public func recordInferenceTelemetry(
        captureInstant: MonotonicInstant,
        startedAt: MonotonicInstant,
        finishedAt: MonotonicInstant,
        overlayAt: MonotonicInstant,
        queueDepth: Int,
        now: MonotonicInstant
    ) async {
        guard let telemetry else { return }
        try? await telemetry.recordInference(
            captureInstant: captureInstant,
            startedAt: startedAt,
            finishedAt: finishedAt,
            overlayAt: overlayAt,
            queueDepth: queueDepth
        )
        performanceSnapshot = await telemetry.snapshot(now: now)
    }

    public func recordModelFailure(now: MonotonicInstant) async {
        guard let telemetry else { return }
        await telemetry.recordModelFailure()
        performanceSnapshot = await telemetry.snapshot(now: now)
    }

    private func resetPerformanceTelemetry() async {
        await telemetry?.reset()
        performanceSnapshot = PerformanceTelemetrySnapshot()
    }

    private func persistPerformanceSummary() async {
        guard let telemetry,
              let summary = try? await telemetry.persistSummary(now: telemetryClock.now()) else { return }
        performanceSnapshot = summary
    }

    public func stop() async {
        await capture.stop()
        await persistPerformanceSummary()
        await resetPerformanceTelemetry()
        negotiatedFormat = nil
        observations = []
        selectedObservationID = nil
        isPaused = false
        capturedFrameCount = 0
        lastCaptureMessage = nil
        latestFrame = nil
        await refreshSnapshot()
    }

    private static func makeTelemetry() -> PerformanceTelemetry? {
        let summaryURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Armageddon", isDirectory: true)
            .appendingPathComponent("performance-summary.json")
        let store = PerformanceTelemetrySummaryStore(fileURL: summaryURL)
        return try? PerformanceTelemetry(summaryStore: store)
    }
}
