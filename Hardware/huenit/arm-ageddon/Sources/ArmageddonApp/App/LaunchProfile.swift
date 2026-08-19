import Foundation

enum LaunchProfile: String, CaseIterable, Sendable {
    case noDevices = "no-devices"
    case permissionDenied = "permission-denied"
    case allConnected = "all-connected"
    case modelFailed = "model-failed"
    case calibratedDryRun = "calibrated-dry-run"
    case stopUnconfirmed = "stop-unconfirmed"

    var title: String {
        switch self {
        case .noDevices: "No devices"
        case .permissionDenied: "Permission denied"
        case .allConnected: "All connected"
        case .modelFailed: "Model failed"
        case .calibratedDryRun: "Calibrated dry run"
        case .stopUnconfirmed: "Stop unconfirmed"
        }
    }
}
