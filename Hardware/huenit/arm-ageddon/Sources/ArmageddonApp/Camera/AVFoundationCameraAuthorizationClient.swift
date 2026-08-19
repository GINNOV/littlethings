@preconcurrency import AVFoundation
import ArmageddonCore

struct AVFoundationCameraAuthorizationClient: CameraAuthorizationClient {
    func status() async -> CameraAuthorizationStatus {
        Self.map(AVCaptureDevice.authorizationStatus(for: .video))
    }

    func requestAccess() async -> CameraAuthorizationStatus {
        let current = await status()
        guard current == .notDetermined else { return current }
        let granted = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
        return granted ? .authorized : .denied
    }

    private static func map(_ status: AVAuthorizationStatus) -> CameraAuthorizationStatus {
        switch status {
        case .notDetermined:
            .notDetermined
        case .restricted:
            .restricted
        case .denied:
            .denied
        case .authorized:
            .authorized
        @unknown default:
            .failed
        }
    }
}
