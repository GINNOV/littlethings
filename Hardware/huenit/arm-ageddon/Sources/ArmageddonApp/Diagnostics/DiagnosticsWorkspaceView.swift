import AppKit
import SwiftUI

struct DiagnosticsWorkspaceView: View {
    @Environment(AppModel.self) private var appModel
    let recoveryAction: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    Text("Diagnostics")
                        .font(DesignTokens.Typography.workspaceTitle)
                        .bold()
                    Text("A bounded, explainable record of what happened and what to do next.")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Refresh", systemImage: "arrow.clockwise") {
                    Task { await appModel.refreshDiagnostics() }
                }
                .buttonStyle(.bordered)
                Button("Export support bundle", systemImage: "square.and.arrow.up") {
                    exportBundle()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("diagnostics.export")
            }

            HStack(spacing: DesignTokens.Spacing.standard) {
                statusCard("Camera", value: appModel.cameraLifecycleSnapshot.connection.rawValue, symbol: "camera")
                statusCard("Captures", value: "\(appModel.captures.count)", symbol: "photo.on.rectangle")
                statusCard("Model", value: appModel.modelRegistrySnapshot.activeModelID ?? "Fixture detector", symbol: "cube")
                statusCard("Motion", value: appModel.armed ? "Armed" : "Disarmed", symbol: "shield")
            }

            if appModel.diagnosticEvents.isEmpty {
                ErrorStateView(
                    title: "No diagnostic events yet",
                    description: "Refresh after using Live, Capture, or Models to see bounded local events.",
                    recoveryAction: recoveryAction
                )
            } else {
                List(appModel.diagnosticEvents) { event in
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.standard) {
                        Image(systemName: event.severity == .error ? "xmark.octagon.fill" : "info.circle.fill")
                            .foregroundStyle(event.severity == .error ? .orange : .secondary)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(event.message)
                                .font(DesignTokens.Typography.supporting)
                            Text("\(event.category.rawValue.capitalized) · \(event.code) · generation \(event.generation)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("t+\(event.occurredAt.nanoseconds / 1_000_000) ms")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.tertiary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(event.severity.rawValue): \(event.message)")
                }
                .listStyle(.inset)
            }
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.workspace)
        .accessibilityIdentifier("workspace.diagnostics")
        .task { await appModel.refreshDiagnostics() }
    }

    private func statusCard(_ title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value.capitalized)
                .font(DesignTokens.Typography.sectionTitle)
        }
        .padding(DesignTokens.Spacing.standard)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Colors.canvas, in: RoundedRectangle(cornerRadius: 10))
    }

    private func exportBundle() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let directory = panel.url else { return }
        let destination = directory.appendingPathComponent("armageddon-support-\(UUID().uuidString.prefix(8)).zip")
        Task { await appModel.exportSupportBundle(to: destination) }
    }
}
