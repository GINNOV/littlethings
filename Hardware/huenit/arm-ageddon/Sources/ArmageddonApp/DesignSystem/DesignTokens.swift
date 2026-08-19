import SwiftUI

enum DesignTokens {
    enum Colors {
        static let workspace = Color("WorkspaceBackground")
        static let canvas = Color("CanvasSurface")
        static let selected = Color("SelectionSurface")
        static let status = Color("StatusSurface")
        static let danger = Color("DangerAction")
        static let canvasPrimary = Color.white
        static let canvasSecondary = Color.white.opacity(0.82)
    }

    enum Spacing {
        static let compact: CGFloat = 6
        static let standard: CGFloat = 12
        static let roomy: CGFloat = 20
        static let section: CGFloat = 28
    }

    enum Typography {
        static let workspaceTitle: Font = .title2
        static let sectionTitle: Font = .headline
        static let body: Font = .body
        static let supporting: Font = .subheadline
    }

    enum Layout {
        static let minimumWindowWidth: CGFloat = 1_100
        static let minimumWindowHeight: CGFloat = 720
        static let defaultWindowWidth: CGFloat = 1_280
        static let defaultWindowHeight: CGFloat = 800
        static let sidebarWidth: CGFloat = 210
        static let inspectorWidth: CGFloat = 216
    }
}
