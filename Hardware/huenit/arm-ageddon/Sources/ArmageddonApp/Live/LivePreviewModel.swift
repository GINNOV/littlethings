import ArmageddonCore
import AVFoundation
import Observation

@MainActor
@Observable
final class LivePreviewModel {
    private let capture: AVFoundationNativeCaptureSession
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?
    private(set) var snapshot: NativeCaptureSessionSnapshot

    init(capture: AVFoundationNativeCaptureSession = AVFoundationNativeCaptureSession()) {
        self.capture = capture
        snapshot = NativeCaptureSessionSnapshot(
            state: .idle,
            configuration: nil,
            source: nil,
            metrics: NativeCaptureSessionMetrics()
        )
        previewLayer = capture.previewLayer()
    }

    func refreshSnapshot() async {
        snapshot = await capture.snapshot()
    }

    func stop() async {
        await capture.stop()
        await refreshSnapshot()
    }
}
