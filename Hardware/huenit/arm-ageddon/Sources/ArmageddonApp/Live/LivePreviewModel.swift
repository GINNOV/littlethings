import ArmageddonCore
import AVFoundation
import Observation

@MainActor
@Observable
final class LivePreviewModel {
    private let capture: AVFoundationNativeCaptureSession
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?
    private(set) var snapshot: NativeCaptureSessionSnapshot
    private(set) var negotiatedFormat: CaptureFormat?

    var isRunning: Bool {
        capture.isRunning
    }

    init(capture: AVFoundationNativeCaptureSession = AVFoundationNativeCaptureSession()) {
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

    func start(device: AVCaptureDevice, requestedFormat: CaptureFormat = CaptureFormat(width: 1_280, height: 720, frameRate: 30)) async throws {
        negotiatedFormat = try await capture.start(device: device, requestedFormat: requestedFormat)
        await refreshSnapshot()
    }

    func switchSource(to device: AVCaptureDevice, requestedFormat: CaptureFormat = CaptureFormat(width: 1_280, height: 720, frameRate: 30)) async throws {
        await stop()
        try await start(device: device, requestedFormat: requestedFormat)
    }

    func refreshSnapshot() async {
        snapshot = await capture.snapshot()
    }

    func stop() async {
        await capture.stop()
        negotiatedFormat = nil
        await refreshSnapshot()
    }
}
