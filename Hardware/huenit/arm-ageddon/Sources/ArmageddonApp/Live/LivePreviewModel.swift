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

    public func stop() async {
        await capture.stop()
        negotiatedFormat = nil
        await refreshSnapshot()
    }
}
