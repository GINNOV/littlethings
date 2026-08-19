import SwiftUI

struct ContextualInspectorView: View {
    let destination: AppDestination

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.roomy) {
            Label("\(destination.title) inspector", systemImage: destination.symbol)
                .font(DesignTokens.Typography.sectionTitle)
            Divider()
            LabeledContent("Target") {
                Text("None selected")
                    .foregroundStyle(.secondary)
            }
            LabeledContent("Calibration") {
                Label("Not configured", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("Contextual controls will appear when this workspace has an active selection.")
                .font(DesignTokens.Typography.supporting)
                .foregroundStyle(.secondary)
        }
        .padding(DesignTokens.Spacing.roomy)
        .accessibilityIdentifier("inspector.\(destination.accessibilityName)")
    }
}
