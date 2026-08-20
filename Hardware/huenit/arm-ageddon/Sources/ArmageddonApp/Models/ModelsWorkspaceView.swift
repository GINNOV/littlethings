import AppKit
import ArmageddonCore
import SwiftUI

struct ModelsWorkspaceView: View {
    @Environment(AppModel.self) private var appModel
    @State private var searchText = ""

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
                    TextField("Search models", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 170)
                        .accessibilityLabel("Search models")
                        .accessibilityIdentifier("models.search")
                    Button {
                        importModel()
                    } label: {
                        Label("Import model", systemImage: "arrow.down.doc")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("models.import")
                }

                if let error = appModel.modelImportError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.orange)
                        .padding(DesignTokens.Spacing.standard)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("models.error")
                }

                HStack(alignment: .top, spacing: DesignTokens.Spacing.standard) {
                    Image(systemName: "cable.connector")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HUENIT K210 camera")
                            .font(DesignTokens.Typography.sectionTitle)
                        Text("Detection telemetry only · preview and in-app upload unsupported")
                            .font(DesignTokens.Typography.supporting)
                            .foregroundStyle(.secondary)
                        Text("Copy a verified .kmodel bundle through the documented HUENIT workflow. The app never sends guessed serial writes.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Text("Unsupported")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.orange)
                }
                .padding(DesignTokens.Spacing.roomy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignTokens.Colors.canvas, in: RoundedRectangle(cornerRadius: 12))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("HUENIT K210 camera. Detection telemetry only. Preview and upload unsupported.")
                .accessibilityIdentifier("models.huenit-unsupported")

                if appModel.modelRegistrySnapshot.models.isEmpty {
                    EmptyStateView(
                        title: "No verified models",
                        symbol: "cube.transparent",
                        description: "Import an .armmodel.json manifest beside its model artifact. Validation happens before activation."
                    )
                    .frame(maxWidth: .infinity, minHeight: 280)
                } else {
                    LazyVStack(spacing: DesignTokens.Spacing.standard) {
                        ForEach(filteredModels) { model in
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
            VStack(alignment: .trailing, spacing: 4) {
                Text(model.availability.rawValue.capitalized)
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(model.availability == .ready ? .green : .orange)
                if let reason = model.availabilityReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
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

    private var filteredModels: [ModelRecord] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return appModel.modelRegistrySnapshot.models }
        return appModel.modelRegistrySnapshot.models.filter {
            $0.id.localizedStandardContains(query) || $0.displayName.localizedStandardContains(query)
        }
    }
}
