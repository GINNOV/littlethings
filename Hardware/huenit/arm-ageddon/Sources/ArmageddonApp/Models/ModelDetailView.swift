import ArmageddonCore
import Foundation
import SwiftUI

struct ModelDetailView: View {
    let model: ModelRecord
    let isActive: Bool
    let onActivate: () -> Void
    let onRollback: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    Text(model.displayName)
                        .font(DesignTokens.Typography.workspaceTitle)
                        .bold()
                    Text(model.id)
                        .font(DesignTokens.Typography.supporting.monospaced())
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Label(isActive ? "Active" : "Last-known-good candidate", systemImage: isActive ? "checkmark.seal.fill" : "arrow.uturn.backward.circle")
                    .foregroundStyle(isActive ? .green : .secondary)
            }

            GroupBox("Provenance") {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    provenanceRow("Artifact", model.artifactKind.rawValue)
                    provenanceRow("Artifact hash", String(model.artifactHash.prefix(24)) + "…")
                    provenanceRow("Compiled hash", String(model.compiledHash.prefix(24)) + "…")
                    provenanceRow("Smoke p95", String(format: "%.1f ms", model.benchmarkP95Milliseconds))
                    provenanceRow("Availability", model.availability.rawValue.capitalized)
                    if let reason = model.availabilityReason {
                        Text(reason)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .accessibilityIdentifier("model.detail.provenance")

            GroupBox("Detector contract") {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    provenanceRow("Labels", model.detector.labels.joined(separator: ", "))
                    provenanceRow("Input", "\(model.detector.input.width) × \(model.detector.input.height)")
                    provenanceRow("Output", model.detector.output.kind.rawValue)
                }
            }

            HStack {
                if !isActive {
                    Button("Activate", systemImage: "checkmark.circle", action: onActivate)
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("model.detail.activate")
                    Button("Rollback to this model", systemImage: "arrow.uturn.backward", action: onRollback)
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("model.detail.rollback")
                } else {
                    Label("Motion remains separately interlocked", systemImage: "shield.checkered")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .accessibilityIdentifier("model.detail.actions")
        }
        .padding(DesignTokens.Spacing.section)
        .frame(minWidth: 560, minHeight: 460)
        .background(DesignTokens.Colors.workspace)
    }

    private func provenanceRow(_ title: String, _ value: String) -> some View {
        LabeledContent(title, value: value)
            .font(DesignTokens.Typography.supporting)
    }
}
