import SwiftUI

struct CalibrationWizardView: View {
    @Bindable var model: CalibrationWizardModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            header
            stepBar
            ScrollView {
                stepContent
            }
            footer
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("calibration.wizard")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
            HStack {
                Label("Guided calibration", systemImage: "scope")
                    .font(DesignTokens.Typography.sectionTitle)
                Spacer()
                Text(model.calibrationStatus)
                    .font(DesignTokens.Typography.supporting.weight(.semibold))
                    .foregroundStyle(model.calibrationStatus == "Active" ? Color.green : Color.secondary)
                    .accessibilityIdentifier("calibration.status")
            }
            Text("Position the arm manually. This workflow never issues motion commands.")
                .font(DesignTokens.Typography.supporting)
                .foregroundStyle(.secondary)
        }
    }

    private var stepBar: some View {
        HStack(spacing: DesignTokens.Spacing.compact) {
            ForEach(CalibrationWizardStep.allCases, id: \.self) { step in
                VStack(spacing: 3) {
                    Circle()
                        .fill(step.rawValue <= model.step.rawValue ? Color.accentColor : Color.secondary.opacity(0.25))
                        .frame(width: 10, height: 10)
                    Text(step.title)
                        .font(.caption2)
                        .foregroundStyle(step == model.step ? .primary : .secondary)
                }
                if step != CalibrationWizardStep.allCases.last { Spacer(minLength: 0) }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Calibration step \(model.step.title) of five")
    }

    @ViewBuilder
    private var stepContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            switch model.step {
            case .hardware:
                instruction(title: "Confirm the camera", detail: "Use the connected camera and keep the negotiated format unchanged.")
                Picker("Camera", selection: $model.selectedCameraID) {
                    Text("Fixture camera").tag("fixture-camera")
                    Text("Changed camera").tag("changed-camera")
                }
                .accessibilityIdentifier("calibration.camera")
                statusRow("Camera", value: model.selectedCameraID)
                statusRow(
                    "Format",
                    value: "\(model.currentFormat.width) × \(model.currentFormat.height) at \(Int(model.currentFormat.frameRate)) fps"
                )
            case .mount:
                instruction(title: "Lock the camera mount", detail: "Tighten the mount and confirm the camera cannot shift during the point sequence.")
                Label("A loose mount invalidates every point.", systemImage: "lock.shield")
                    .foregroundStyle(.orange)
            case .tool:
                instruction(title: "Select the tool", detail: "The active profile is bound to this tool identity and safe-Z band.")
                Picker("Tool", selection: $model.selectedToolID) {
                    Text("Standard tool").tag("standard-tool")
                    Text("Camera tool").tag("camera-tool")
                }
                .accessibilityIdentifier("calibration.tool")
                statusRow("Safe Z", value: "20–80 mm")
            case .points:
                instruction(title: "Record workspace points", detail: "Manually position the tool over each visible fixture point, then record it. Keep the emergency stop available.")
                ProgressView(value: Double(model.capturedPointCount), total: 8)
                    .accessibilityIdentifier("calibration.point-progress")
                Text("\(model.capturedPointCount) of 8 points recorded · 6 fit + 2 validation")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.secondary)
                Button("Record next fixture point", systemImage: "scope") {
                    model.recordFixturePoint()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!model.canRecordPoint)
                .accessibilityIdentifier("calibration.record-point")
                Picker("Fixture quality", selection: $model.fixtureQuality) {
                    ForEach(CalibrationFixtureQuality.allCases) { quality in
                        Text(quality.title).tag(quality)
                    }
                }
                .accessibilityIdentifier("calibration.fixture-quality")
            case .review:
                instruction(title: "Review before activation", detail: "Activation only changes the selected calibration profile. It does not move the arm.")
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    Text("Current binding")
                        .font(DesignTokens.Typography.supporting.weight(.semibold))
                    Picker("Camera", selection: $model.selectedCameraID) {
                        Text("Fixture camera").tag("fixture-camera")
                        Text("Changed camera").tag("changed-camera")
                    }
                    .accessibilityIdentifier("calibration.review-camera")
                    Picker("Tool", selection: $model.selectedToolID) {
                        Text("Standard tool").tag("standard-tool")
                        Text("Camera tool").tag("camera-tool")
                    }
                    .accessibilityIdentifier("calibration.review-tool")
                }
                if let residualSummary = model.residualSummary {
                    Label(residualSummary, systemImage: "checkmark.seal")
                        .foregroundStyle(.green)
                        .accessibilityIdentifier("calibration.residuals")
                }
                if let errorMessage = model.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("calibration.error")
                }
                if let resultMessage = model.resultMessage {
                    Text(resultMessage)
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("calibration.result")
                }
            }
        }
        .padding(.vertical, DesignTokens.Spacing.compact)
    }

    private var footer: some View {
        HStack {
            Button("Start over", systemImage: "arrow.counterclockwise") {
                model.reset()
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("calibration.reset")
            Spacer()
            if model.step == .review {
                Button("Activate profile", systemImage: "checkmark.shield") {
                    model.activate()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!model.canActivate)
                .accessibilityIdentifier("calibration.activate")
                if model.previousProfile != nil {
                    Button("Restore previous") {
                        model.restorePrevious()
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("calibration.restore")
                }
            } else {
                Button(model.step == .points ? "Solve calibration" : "Continue", systemImage: "arrow.right") {
                    model.advance()
                }
                .buttonStyle(.borderedProminent)
                .disabled(model.step == .points && !model.canSolve)
                .accessibilityIdentifier("calibration.continue")
            }
        }
    }

    private func instruction(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
            Text(title)
                .font(DesignTokens.Typography.sectionTitle)
            Text(detail)
                .font(DesignTokens.Typography.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func statusRow(_ title: String, value: String) -> some View {
        LabeledContent(title) {
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
