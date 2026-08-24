import ArmageddonCore
import SwiftUI

struct ContextualInspectorView: View {
    @Environment(AppModel.self) private var appModel
    let destination: AppDestination
    let selectedObservation: DetectionObservation?

    var body: some View {
        ScrollView {
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
                if destination == .go {
                    Text("Teach bowl and board poses on the Go workspace. The inspector is unused.")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.secondary)
                } else {
                    LabeledContent("Calibration") {
                        Label(appModel.calibrationWizard.calibrationStatus, systemImage: "scope")
                            .foregroundStyle(appModel.calibrationWizard.activeProfile == nil ? Color.secondary : Color.green)
                    }
                    Text("Open Live to configure the camera workspace.")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(DesignTokens.Spacing.roomy)
        }
        .accessibilityIdentifier("inspector.\(destination.accessibilityName)")
    }
}
