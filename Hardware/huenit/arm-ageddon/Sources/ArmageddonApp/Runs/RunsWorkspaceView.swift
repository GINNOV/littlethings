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
                    Text("Prepare and confirm one auditable XY move through the supervised boundary.")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.secondary)
                }

                executionCard
                prerequisites
                timelineCard
            }
            .padding(DesignTokens.Spacing.section)
        }
        .background(DesignTokens.Colors.workspace)
        .accessibilityIdentifier("workspace.runs")
    }

    private var executionCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            Label("Supervised execution", systemImage: "checkmark.shield")
                .font(DesignTokens.Typography.sectionTitle)
            if let target = targetWorkspacePoint {
                LabeledContent("Selected target") {
                    Text(String(format: "X %.2f mm · Y %.2f mm", target.x, target.y))
                        .font(.body.monospacedDigit())
                        .accessibilityIdentifier("runs.target-xy")
                }
                LabeledContent("Path") {
                    if let delta = appModel.runs.proposal?.deltaXY {
                        Text("ΔX \(delta.x, specifier: "%.2f") mm · ΔY \(delta.y, specifier: "%.2f") mm")
                            .font(.body.monospacedDigit())
                    } else {
                        Text("Prepare a proposal to bind the final pose")
                            .foregroundStyle(.orange)
                    }
                }
                Text(appModel.runs.statusMessage)
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("runs.status-message")
            } else {
                Text(appModel.runs.statusMessage)
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(.secondary)
            }
            Text(appModel.runs.executionModeDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Button("Prepare proposal", systemImage: "scope") {
                    Task { await appModel.prepareRunProposal() }
                }
                .buttonStyle(.bordered)
                .disabled(!canPrepare)
                .accessibilityIdentifier("runs.prepare")
                Button("Confirm and execute one XY move", systemImage: "arrow.right.circle.fill") {
                    Task { await appModel.executePreparedRun() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!appModel.runs.canExecute)
                .accessibilityIdentifier("runs.execute")
            }
            Text("Status: \(appModel.runs.status.label)")
                .font(.caption.monospaced())
                .accessibilityIdentifier("runs.status")
            Label("No motion is written until the typed boundary validates every prerequisite.", systemImage: "checkmark.shield")
                .foregroundStyle(.green)
                .accessibilityIdentifier("runs.no-write-guarantee")
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, alignment: .leading)
        .canvasCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("runs.dry-run")
    }

    private var prerequisites: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            Text("Prerequisites")
                .font(DesignTokens.Typography.sectionTitle)
            prerequisite("Calibration", ready: appModel.calibrationWizard.activeProfile != nil)
            prerequisite("Selected detection", ready: appModel.livePreview.selectedObservation != nil)
            prerequisite("Fresh arm pose", ready: appModel.runs.hasPreparedProposal)
            prerequisite("Explicit confirmation", ready: appModel.runs.canExecute)
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, alignment: .leading)
        .canvasCard()
        .accessibilityIdentifier("runs.prerequisites")
    }

    private var timelineCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
            Text("Run timeline")
                .font(DesignTokens.Typography.sectionTitle)
            if appModel.runs.timeline.isEmpty {
                Text("No supervised run has been submitted.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(appModel.runs.timeline.enumerated()), id: \.offset) { _, event in
                    LabeledContent(event.kind.rawValue) {
                        Text(event.detail)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, alignment: .leading)
        .canvasCard()
        .accessibilityIdentifier("runs.timeline")
    }

    private var canPrepare: Bool {
        appModel.calibrationWizard.activeProfile != nil
            && appModel.livePreview.selectedObservation != nil
            && appModel.runs.isDeterministicFixture
    }

    private func prerequisite(_ title: String, ready: Bool) -> some View {
        Label(title, systemImage: ready ? "checkmark.circle.fill" : "circle.dashed")
            .foregroundStyle(ready ? Color.green : Color.secondary)
    }

    private var targetWorkspacePoint: CalibrationPoint? {
        if let proposed = appModel.runs.targetWorkspacePoint { return proposed }
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
