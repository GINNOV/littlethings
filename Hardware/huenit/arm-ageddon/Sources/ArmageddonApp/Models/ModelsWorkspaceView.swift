import AppKit
import ArmageddonCore
import SwiftUI
import UniformTypeIdentifiers

struct ModelsWorkspaceView: View {
    @Environment(AppModel.self) private var appModel
    @State private var searchText = ""
    @State private var selectedDetails: ModelDetailSelection?

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
                    Button {
                        importK210Bundle()
                    } label: {
                        Label("Import K210 folder", systemImage: "shippingbox")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("models.k210-import")
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
                        .foregroundStyle(DesignTokens.Colors.canvasSecondary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HUENIT K210 camera")
                            .font(DesignTokens.Typography.sectionTitle)
                            .foregroundStyle(DesignTokens.Colors.canvasPrimary)
                        Text("Detection telemetry only · preview and in-app upload unsupported")
                            .font(DesignTokens.Typography.supporting)
                            .foregroundStyle(DesignTokens.Colors.canvasSecondary)
                        Text("Choose a bundle folder containing the manifest, .kmodel, and generated script. The app never sends guessed serial writes.")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.Colors.canvasTertiary)
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

                k210InventorySection

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
        .sheet(item: $selectedDetails) { selection in
            if let model = appModel.modelRegistrySnapshot.models.first(where: { $0.id == selection.id }) {
                ModelDetailView(
                    model: model,
                    isActive: appModel.modelRegistrySnapshot.activeModelID == model.id,
                    onActivate: { Task { await appModel.activateModel(id: model.id) } },
                    onRollback: { Task { await appModel.rollbackModel(id: model.id) } }
                )
            }
        }
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
                    .foregroundStyle(DesignTokens.Colors.canvasPrimary)
                Text("\(model.id) · \(model.artifactKind.rawValue)")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(DesignTokens.Colors.canvasSecondary)
                Text(String(model.artifactHash.prefix(16)) + "…")
                    .font(.caption.monospaced())
                    .foregroundStyle(DesignTokens.Colors.canvasTertiary)
            }
            Spacer()
            Button("Details") {
                selectedDetails = ModelDetailSelection(id: model.id)
            }
            .buttonStyle(.bordered)
            .foregroundStyle(DesignTokens.Colors.canvasPrimary)
            .tint(DesignTokens.Colors.canvasPrimary)
            .accessibilityLabel("View provenance for \(model.displayName)")
            .accessibilityIdentifier("model.\(model.id).details")
            if isActive {
                Text("Active")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.green)
            } else {
                Button("Activate") {
                    Task { await appModel.activateModel(id: model.id) }
                }
                .buttonStyle(.bordered)
                .foregroundStyle(DesignTokens.Colors.canvasPrimary)
                .tint(DesignTokens.Colors.canvasPrimary)
                .accessibilityIdentifier("model.\(model.id).activate")
            }
            VStack(alignment: .trailing, spacing: 4) {
                Text(model.availability.rawValue.capitalized)
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(model.availability == .ready ? .green : .orange)
                if let reason = model.availabilityReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(DesignTokens.Colors.canvasSecondary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(DesignTokens.Spacing.roomy)
        .background(DesignTokens.Colors.canvas, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityIdentifier("model.\(model.id)")
    }

    private struct ModelDetailSelection: Identifiable {
        let id: String
    }

    @ViewBuilder
    private var k210InventorySection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    Text("K210 artifact inventory")
                        .font(DesignTokens.Typography.sectionTitle)
                    Text("Verified model, script, labels, anchors, and provenance for the documented external copy workflow.")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("Upload unsupported")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.orange)
            }
            if let error = appModel.k210InventoryError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.orange)
                    .accessibilityIdentifier("models.k210-error")
            }
            if appModel.k210Artifacts.isEmpty {
                Text("No verified K210 bundles. Import a manifest, .kmodel, and generated script together to quarantine and hash them.")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("models.k210-empty")
            } else {
                ForEach(appModel.k210Artifacts) { record in
                    k210ArtifactCard(record)
                }
            }
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Colors.status, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityIdentifier("models.k210-inventory")
    }

    private func k210ArtifactCard(_ record: K210ArtifactRecord) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.standard) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                Text(record.manifest.identifier)
                    .font(DesignTokens.Typography.sectionTitle)
                    .foregroundStyle(DesignTokens.Colors.canvasPrimary)
                Text(record.manifest.labels.joined(separator: ", "))
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(DesignTokens.Colors.canvasSecondary)
                Text("Model \(record.modelSHA256.prefix(16))… · Script \(record.scriptSHA256.prefix(16))…")
                    .font(.caption.monospaced())
                    .foregroundStyle(DesignTokens.Colors.canvasTertiary)
                Text(record.uploadAvailable ? "Measured upload available" : "Copy verified bundle manually")
                    .font(.caption)
                    .foregroundStyle(record.uploadAvailable ? .green : .orange)
            }
            Spacer()
            Button("Export bundle", systemImage: "square.and.arrow.up") {
                exportK210Bundle(record)
            }
            .buttonStyle(.bordered)
            .foregroundStyle(DesignTokens.Colors.canvasPrimary)
            .tint(DesignTokens.Colors.canvasPrimary)
            .accessibilityIdentifier("k210.\(record.id).export")
                }
                .padding(DesignTokens.Spacing.standard)
                .background(DesignTokens.Colors.canvas, in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .contain)
    }

    private func importModel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        Task { await appModel.importModel(manifestURL: url) }
    }

    private func importK210Bundle() {
        let panel = NSOpenPanel()
        panel.message = "Choose a folder containing the manifest, .kmodel, and generated script."
        panel.prompt = "Choose Bundle Folder"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let directoryURL = panel.url else { return }
        Task { await appModel.importK210Bundle(directoryURL: directoryURL) }
    }

    private func exportK210Bundle(_ record: K210ArtifactRecord) {
        let panel = NSOpenPanel()
        panel.message = "Choose a destination folder for the verified K210 bundle."
        panel.prompt = "Choose Export Folder"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let directory = panel.url else { return }
        Task { await appModel.exportK210Artifact(id: record.id, to: directory) }
    }

    private var filteredModels: [ModelRecord] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return appModel.modelRegistrySnapshot.models }
        return appModel.modelRegistrySnapshot.models.filter {
            $0.id.localizedStandardContains(query) || $0.displayName.localizedStandardContains(query)
        }
    }
}
