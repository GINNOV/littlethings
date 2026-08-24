import Foundation

enum AppDestination: String, CaseIterable, Identifiable, Sendable {
    case go = "go.workspace"

    var id: String { rawValue }
    var accessibilityName: String { "go" }
    var title: String { "Go" }
    var symbol: String { "circle.grid.3x3" }
}
