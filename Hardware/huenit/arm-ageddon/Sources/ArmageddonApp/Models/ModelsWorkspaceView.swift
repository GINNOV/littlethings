import SwiftUI

struct ModelsWorkspaceView: View {
    var body: some View {
        EmptyStateView(
            title: "No models",
            symbol: "cube",
            description: "Imported detector models will be validated before activation."
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.workspace)
        .accessibilityIdentifier("workspace.models")
    }
}
