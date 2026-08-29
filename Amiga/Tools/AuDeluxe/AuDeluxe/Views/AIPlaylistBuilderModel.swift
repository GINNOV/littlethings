import Foundation

@MainActor
final class AIPlaylistBuilderModel: ObservableObject {
    @Published var request = ""
    @Published var playlistName = ""
    @Published private(set) var draft: AIPlaylistDraft?
    @Published private(set) var isGenerating = false
    @Published private(set) var statusMessage: String?
    @Published private(set) var errorMessage: String?

    private let service: LocalAIService

    init(service: LocalAIService = LocalAIService()) {
        self.service = service
    }

    func generate(items: [PlaylistItem], configuration: LocalAIConfiguration) async {
        isGenerating = true
        draft = nil
        statusMessage = nil
        errorMessage = nil
        defer { isGenerating = false }

        do {
            let result = try await service.generatePlaylist(
                request: request,
                items: items,
                configuration: configuration
            )
            draft = result
            playlistName = result.criteria.name
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func save(using settings: SettingsStore) {
        guard let draft else { return }
        let cleanName = playlistName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanName.isEmpty == false else { return }
        settings.savePlaylist(Playlist(name: cleanName, fileURLs: draft.items.map(\.fileURL)))
        statusMessage = "Saved “\(cleanName)” with \(draft.items.count) songs."
    }
}
