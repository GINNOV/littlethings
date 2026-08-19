import SwiftUI

struct DiagnosticsWorkspaceView: View {
    let recoveryAction: @MainActor () -> Void

    var body: some View {
        ErrorStateView(
            title: "Diagnostics unavailable",
            description: "Runtime diagnostics will appear when device services are connected.",
            recoveryAction: recoveryAction
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.workspace)
        .accessibilityIdentifier("workspace.diagnostics")
    }
}
