import Foundation

protocol LocalAIHTTPClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: LocalAIHTTPClient {}

struct LocalAIService {
    private let client: any LocalAIHTTPClient

    init(client: any LocalAIHTTPClient = URLSession.shared) {
        self.client = client
    }

    func generatePlaylist(
        request: String,
        items: [PlaylistItem],
        configuration: LocalAIConfiguration
    ) async throws -> AIPlaylistDraft {
        guard items.isEmpty == false else { throw AIPlaylistError.emptyLibrary }
        let cleanRequest = request.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanRequest.isEmpty == false else { throw AIPlaylistError.emptyRequest }

        let prompt = AIPlaylistPrompt.make(request: cleanRequest, items: items)
        let urlRequest = try LocalAIRequest.make(configuration: configuration, prompt: prompt)
        let (data, response) = try await client.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw AIPlaylistError.server(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        let content = try LocalAIResponse.content(from: data, provider: configuration.provider)
        let criteria = try AIPlaylistCriteria.decodeModelResponse(content)
        let matches = AIPlaylistMatcher.matches(in: items, criteria: criteria)
        guard matches.isEmpty == false else { throw AIPlaylistError.noMatches }
        return AIPlaylistDraft(criteria: criteria, items: matches)
    }
}
