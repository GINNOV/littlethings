import SwiftUI

struct CaptureWorkspaceView: View {
    var body: some View {
        EmptyStateView(
            title: "No captures",
            symbol: "photo.on.rectangle.angled",
            description: "Explicitly captured frames will appear here."
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.workspace)
        .accessibilityIdentifier("workspace.capture")
    }
}
