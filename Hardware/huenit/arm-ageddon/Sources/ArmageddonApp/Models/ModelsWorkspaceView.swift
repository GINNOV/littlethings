import AppKit
import ArmageddonCore
import SwiftUI

struct ModelsWorkspaceView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.section) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                        Text("Models")
                            .font(DesignTokens.Typography.workspaceTitle)
                        Text("Quarantined, verified, and ready for local inference.")
                            .font(DesignTokens.Typography.supporting)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        importModel()
                    } label: {
                        Label("Import model", systemImage: "arrow.down.doc")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("models.import")
                }

                if appModel.modelRegistrySnapshot.models.isEmpty {
                    EmptyStateView(
                        title: "No verified models",
                        symbol: "cube.transparent",
                        description: "Import an .armmodel.json manifest beside its model artifact. Validation happens before activation."
                    )
                    .frame(maxWidth: .infinity, minHeight: 280)
                } else {
                    LazyVStack(spacing: DesignTokens.Spacing.standard) {
                        ForEach(appModel.modelRegistrySnapshot.models) { model in
                            modelCard(model)
                        }
                    }
                }
            }
            .padding(DesignTokens.Spacing.section)
        }
        .background(DesignTokens.Colors.workspace)
        .accessibilityIdentifier("workspace.models")
    }

    private func modelCard(_ model: ModelRecord) -> some View {
        let isActive = appModel.modelRegistrySnapshot.activeModelID == model.id
        return HStack(spacing: DesignTokens.Spacing.standard) {
            Image(systemName: isActive ? "checkmark.seal.fill" : "cube.fill")
                .font(.title2)
                .foregroundStyle(isActive ? .green : .secondary)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(model.displayName)
                    .font(DesignTokens.Typography.sectionTitle)
                Text("\(model.id) · \(model.artifactKind.rawValue)")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.secondary)
                Text(String(model.artifactHash.prefix(16)) + "…")
                    .font(.caption.monospaced())
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            if isActive {
                Text("Active")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.green)
            } else {
                Button("Activate") {
                    Task { await appModel.activateModel(id: model.id) }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(DesignTokens.Spacing.roomy)
        .background(DesignTokens.Colors.canvas, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("model.\(model.id)")
    }

    private func importModel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        Task { await appModel.importModel(manifestURL: url) }
    }
}
