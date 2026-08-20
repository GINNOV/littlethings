import ArmageddonCore
import SwiftUI

struct ContextualInspectorView: View {
    let destination: AppDestination
    let selectedObservation: DetectionObservation?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.roomy) {
            Label("\(destination.title) inspector", systemImage: destination.symbol)
                .font(DesignTokens.Typography.sectionTitle)
            Divider()
            LabeledContent("Target") {
                if let selectedObservation {
                    Text("\(selectedObservation.label) · \(selectedObservation.confidence, format: .percent.precision(.fractionLength(0)))")
                        .accessibilityIdentifier("inspector.target")
                } else {
                    Text("None selected")
                        .accessibilityIdentifier("inspector.target")
                }
            }
            LabeledContent("Target state") {
                Label(
                    selectedObservation == nil ? "Detected only" : "Selected",
                    systemImage: selectedObservation == nil ? "viewfinder" : "scope"
                )
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
