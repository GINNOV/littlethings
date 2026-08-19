import SwiftUI

struct RunsWorkspaceView: View {
    var body: some View {
        EmptyStateView(
            title: "No runs",
            symbol: "clock.arrow.circlepath",
            description: "Dry-run and executed timelines will remain available here."
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.workspace)
        .accessibilityIdentifier("workspace.runs")
    }
}
