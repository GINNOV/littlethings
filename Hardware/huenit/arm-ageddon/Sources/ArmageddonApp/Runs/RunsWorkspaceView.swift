import ArmageddonCore
import SwiftUI

struct RunsWorkspaceView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.section) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    Text("Runs")
                        .font(DesignTokens.Typography.workspaceTitle)
                        .bold()
                    Text("Inspect a proposed XY path before any supervised execution is possible.")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.secondary)
                }

                dryRunCard
                prerequisites
            }
            .padding(DesignTokens.Spacing.section)
        }
        .background(DesignTokens.Colors.workspace)
        .accessibilityIdentifier("workspace.runs")
    }

    private var dryRunCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            Label("Read-only dry run", systemImage: "point.3.connected.trianglepath.dotted")
                .font(DesignTokens.Typography.sectionTitle)
            if let target = targetWorkspacePoint {
                LabeledContent("Selected target") {
                    Text(String(format: "X %.2f mm · Y %.2f mm", target.x, target.y))
                        .font(.body.monospacedDigit())
                        .accessibilityIdentifier("runs.target-xy")
                }
                LabeledContent("Path") {
                    Text("Awaiting a fresh arm pose")
                        .foregroundStyle(.orange)
                }
                Text("No proposal can be armed until a fresh pose is revalidated inside the workspace. This view never opens a serial transport.")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.secondary)
            } else {
                Text("Select a detection in Live and activate a matching calibration profile to preview a target path.")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Colors.canvas, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityIdentifier("runs.dry-run")
    }

    private var prerequisites: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            Text("Prerequisites")
                .font(DesignTokens.Typography.sectionTitle)
            prerequisite("Calibration", ready: appModel.calibrationWizard.activeProfile != nil)
            prerequisite("Selected detection", ready: appModel.livePreview.selectedObservation != nil)
            prerequisite("Fresh arm pose", ready: false)
            prerequisite("Explicit confirmation", ready: false)
            Label("Motion is disarmed in this workspace.", systemImage: "checkmark.shield")
                .foregroundStyle(.green)
                .accessibilityIdentifier("runs.no-write-guarantee")
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Colors.canvas, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityIdentifier("runs.prerequisites")
    }

    private func prerequisite(_ title: String, ready: Bool) -> some View {
        Label(title, systemImage: ready ? "checkmark.circle.fill" : "circle.dashed")
            .foregroundStyle(ready ? Color.green : Color.secondary)
    }

    private var targetWorkspacePoint: CalibrationPoint? {
        guard let profile = appModel.calibrationWizard.activeProfile,
              let observation = appModel.livePreview.selectedObservation,
              let format = appModel.livePreview.negotiatedFormat else { return nil }
        let source = CalibrationPoint(
            x: (observation.boundingBox.x + observation.boundingBox.width / 2) * Double(format.width),
            y: (observation.boundingBox.y + observation.boundingBox.height / 2) * Double(format.height)
        )
        return try? profile.transform(source)
    }
}
