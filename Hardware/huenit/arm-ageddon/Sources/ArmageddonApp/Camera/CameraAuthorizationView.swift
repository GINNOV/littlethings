import ArmageddonCore
import SwiftUI

struct CameraAuthorizationView: View {
    let snapshot: NativeCameraLifecycleSnapshot
    let requestPermission: () -> Void
    let openSystemSettings: () -> Void
    let rescan: () -> Void

    private var title: String {
        switch snapshot.authorization {
        case .notDetermined:
            "Camera access is ready"
        case .requesting:
            "Waiting for camera permission"
        case .authorized:
            switch snapshot.connection {
            case .available:
                "Choose a camera to begin"
            case .connecting:
                "Connecting to camera"
            case .connected:
                "Camera connected"
            case .disconnected:
                "Camera disconnected"
            case .interrupted:
                "Camera interrupted"
            case .failed:
                "Camera needs attention"
            case .unavailable:
                "Camera unavailable"
            }
        case .denied, .restricted:
            "Camera access is blocked"
        case .unavailable:
            "Camera service unavailable"
        case .failed:
            "Camera access failed"
        }
    }

    private var message: String {
        switch snapshot.authorization {
        case .notDetermined:
            "Allow access only when you are ready to inspect a native camera locally."
        case .requesting:
            "Complete the camera permission request to continue."
        case .authorized:
            "The camera source can be rescanned without opening a permission prompt."
        case .denied, .restricted:
            "Enable Camera for Armageddon in System Settings, then rescan."
        case .unavailable:
            "Reconnect the camera service and try a rescan."
        case .failed:
            "The camera service reported a failure. A rescan is safe to retry."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            Label(title, systemImage: "camera.fill")
                .font(DesignTokens.Typography.sectionTitle)
            Text(message)
                .font(DesignTokens.Typography.supporting)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                if snapshot.canRequestPermission {
                    Button("Allow Camera Access", action: requestPermission)
                        .buttonStyle(.borderedProminent)
                }
                if snapshot.canOpenSystemSettings {
                    Button("Open Camera Settings", action: openSystemSettings)
                        .buttonStyle(.borderedProminent)
                }
                if snapshot.canRescan {
                    Button("Rescan Cameras", action: rescan)
                        .buttonStyle(.bordered)
                }
            }
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: 560, alignment: .leading)
        .background(DesignTokens.Colors.status, in: RoundedRectangle(cornerRadius: DesignTokens.Spacing.standard))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("camera.authorization-card")
    }
}
