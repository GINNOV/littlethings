@preconcurrency import AVFoundation
import ArmageddonCore

struct AVFoundationCameraDiscovery: NativeCameraDiscovery {
    private let authorizationClient: any CameraAuthorizationClient

    init(authorizationClient: any CameraAuthorizationClient) {
        self.authorizationClient = authorizationClient
    }

    func discover() async -> [NativeCameraDevice] {
        guard await authorizationClient.status() == .authorized else { return [] }
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.external, .builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return session.devices.map {
            NativeCameraDevice(stableIdentifier: $0.uniqueID, permission: .authorized)
        }
    }
}
