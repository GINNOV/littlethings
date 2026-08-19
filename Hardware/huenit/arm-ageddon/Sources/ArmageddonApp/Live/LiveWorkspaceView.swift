import SwiftUI

struct LiveWorkspaceView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            Text("Live workspace")
                .font(DesignTokens.Typography.workspaceTitle)
                .bold()
                .accessibilityIdentifier("workspace.live")
            ZStack {
                DesignTokens.Colors.canvas
                VStack(spacing: DesignTokens.Spacing.standard) {
                    Image(systemName: "viewfinder")
                        .font(.largeTitle)
                        .foregroundStyle(DesignTokens.Colors.canvasPrimary)
                        .accessibilityHidden(true)
                    Text("Camera preview will appear here")
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(DesignTokens.Colors.canvasPrimary)
                    Text("Connect a supported source to begin local inspection.")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(DesignTokens.Colors.canvasSecondary)
                }
                .multilineTextAlignment(.center)
                .padding(DesignTokens.Spacing.roomy)
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Spacing.standard))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Live camera canvas, no source connected")
            .accessibilityIdentifier("live.canvas")
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.Colors.workspace)
    }
}
