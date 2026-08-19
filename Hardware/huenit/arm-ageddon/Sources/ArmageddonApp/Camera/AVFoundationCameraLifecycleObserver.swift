@preconcurrency import AVFoundation
import Foundation

enum AVFoundationCameraLifecycleEvent: Sendable {
    case deviceConnected
    case deviceDisconnected
    case interrupted
    case interruptionEnded
}

@MainActor
final class AVFoundationCameraLifecycleObserver {
    private var observations: [NSObjectProtocol] = []
    private var onChange: (@MainActor (AVFoundationCameraLifecycleEvent) -> Void)?

    func start(onChange: @escaping @MainActor (AVFoundationCameraLifecycleEvent) -> Void) {
        stop()
        self.onChange = onChange
        let center = NotificationCenter.default
        let names: [Notification.Name] = [
            AVCaptureDevice.wasConnectedNotification,
            AVCaptureDevice.wasDisconnectedNotification,
            AVCaptureSession.wasInterruptedNotification,
            AVCaptureSession.interruptionEndedNotification,
        ]
        observations = names.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in
                    let event: AVFoundationCameraLifecycleEvent = switch name {
                    case AVCaptureDevice.wasConnectedNotification:
                        .deviceConnected
                    case AVCaptureDevice.wasDisconnectedNotification:
                        .deviceDisconnected
                    case AVCaptureSession.wasInterruptedNotification:
                        .interrupted
                    default:
                        .interruptionEnded
                    }
                    self?.onChange?(event)
                }
            }
        }
    }

    func stop() {
        let center = NotificationCenter.default
        observations.forEach(center.removeObserver)
        observations.removeAll()
        onChange = nil
    }
}
