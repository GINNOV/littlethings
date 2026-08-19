import Foundation

enum AppDestination: String, CaseIterable, Identifiable, Sendable {
    case live = "live.workspace"
    case capture = "capture.library"
    case models = "models.library"
    case runs = "runs.history"
    case diagnostics = "diagnostics.workspace"

    var id: String { rawValue }

    var accessibilityName: String {
        switch self {
        case .live: "live"
        case .capture: "capture"
        case .models: "models"
        case .runs: "runs"
        case .diagnostics: "diagnostics"
        }
    }

    var title: String {
        switch self {
        case .live: "Live"
        case .capture: "Capture"
        case .models: "Models"
        case .runs: "Runs"
        case .diagnostics: "Diagnostics"
        }
    }

    var symbol: String {
        switch self {
        case .live: "viewfinder"
        case .capture: "photo.on.rectangle.angled"
        case .models: "cube"
        case .runs: "clock.arrow.circlepath"
        case .diagnostics: "stethoscope"
        }
    }
}
