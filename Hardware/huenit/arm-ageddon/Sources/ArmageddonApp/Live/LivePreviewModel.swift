import ArmageddonCore
import AVFoundation
import Observation

@MainActor
@Observable
public final class LivePreviewModel {
    private let capture: AVFoundationNativeCaptureSession
    public private(set) var previewLayer: AVCaptureVideoPreviewLayer?
    public private(set) var snapshot: NativeCaptureSessionSnapshot
    public private(set) var negotiatedFormat: CaptureFormat?
    public private(set) var observations: [DetectionObservation] = []

    public var isRunning: Bool {
        capture.isRunning
    }

    public var attachedResourceCount: Int {
        capture.attachedResourceCount
    }

    public init(capture: AVFoundationNativeCaptureSession = AVFoundationNativeCaptureSession()) {
        self.capture = capture
        snapshot = NativeCaptureSessionSnapshot(
            state: .idle,
            configuration: nil,
            source: nil,
            metrics: NativeCaptureSessionMetrics()
        )
        negotiatedFormat = nil
        previewLayer = capture.previewLayer()
    }

    public func start(device: AVCaptureDevice, requestedFormat: CaptureFormat = CaptureFormat(width: 1_280, height: 720, frameRate: 30)) async throws {
        negotiatedFormat = try await capture.start(device: device, requestedFormat: requestedFormat)
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
    }

    public func loadDeterministicFixtureOverlay() async throws {
        let manifest = try DetectorManifest(
            identifier: "fixture.constant.detector",
            sha256: String(repeating: "0", count: 64),
            input: DetectorInputContract(width: 224, height: 224),
            output: DetectorOutputContract(kind: .visionObjects),
            labels: ["target", "other"]
        )
        let engine = DeterministicFakeInferenceEngine(detections: [
            FakeDetection(
                label: "target",
                confidence: 0.9,
                boundingBox: NormalizedRect(x: 0.25, y: 0.25, width: 0.2, height: 0.2)
            ),
        ])
        let pipeline = try DetectorPipeline(manifest: manifest, engine: engine)
        let frame = CameraFrameMetadata(
            id: 1,
            rawPresentationTimestamp: 1,
            captureInstant: MonotonicInstant(nanoseconds: 1_000_000_000),
            format: CaptureFormat(width: 1_920, height: 1_080, frameRate: 30)
        )
        observations = try await pipeline.process(
            frame: frame,
            now: MonotonicInstant(nanoseconds: 2_000_000_000),
            generation: 1
        )
    }

    public func stop() async {
        await capture.stop()
        negotiatedFormat = nil
        observations = []
        await refreshSnapshot()
    }
}
