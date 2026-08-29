import SwiftUI

struct AIPlaylistBuilderView: View {
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var engine: OpenMPTEngine
    @StateObject private var model = AIPlaylistBuilderModel()

    var body: some View {
        Section("Create a Playlist") {
            TextField(
                "For example: 20 highly rated MODs from Jazz folders under four minutes",
                text: $model.request,
                axis: .vertical
            )
            .lineLimit(2...4)

            HStack {
                Button("Generate Playlist", systemImage: "sparkles", action: generate)
                    .disabled(canGenerate == false)
                if model.isGenerating {
                    ProgressView()
                        .controlSize(.small)
                    Text("Asking \(settings.localAIProvider.rawValue)…")
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage = model.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            }
            if let statusMessage = model.statusMessage {
                Label(statusMessage, systemImage: "checkmark.circle")
                    .foregroundStyle(.green)
            }
            if let draft = model.draft {
                AIPlaylistDraftView(draft: draft, playlistName: $model.playlistName, save: save)
            }
        }
    }

    private var canGenerate: Bool {
        settings.localAIEnabled
            && settings.localAIModelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && settings.localAIEndpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && model.request.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && engine.allPlaylistItems.isEmpty == false
            && model.isGenerating == false
    }

    private func generate() {
        let configuration = LocalAIConfiguration(
            provider: settings.localAIProvider,
            modelName: settings.localAIModelName,
            endpoint: settings.localAIEndpoint
        )
        Task {
            await model.generate(items: engine.allPlaylistItems, configuration: configuration)
        }
    }

    private func save() {
        model.save(using: settings)
    }
}
