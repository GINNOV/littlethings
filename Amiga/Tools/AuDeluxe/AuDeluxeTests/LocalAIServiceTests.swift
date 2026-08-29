import Foundation
import Testing
@testable import AuDeluxe

struct LocalAIServiceTests {
    private struct StubHTTPClient: LocalAIHTTPClient {
        let data: Data
        let response: URLResponse

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            (data, response)
        }
    }

    @Test("Generated criteria are applied to indexed songs")
    func generatedCriteriaApplyToIndexedSongs() async throws {
        // Given
        let endpoint = try #require(URL(string: "http://localhost:1234/v1/chat/completions"))
        let response = try #require(HTTPURLResponse(url: endpoint, statusCode: 200, httpVersion: nil, headerFields: nil))
        let modelContent = "{\"name\":\"Jazz Pair\",\"folderTerms\":[\"Jazz\"],\"limit\":2}"
        let envelope = ["choices": [["message": ["content": modelContent]]]]
        let data = try JSONSerialization.data(withJSONObject: envelope)
        let service = LocalAIService(client: StubHTTPClient(data: data, response: response))
        let jazz = PlaylistItem(fileURL: URL(fileURLWithPath: "/Music/Jazz/one.mod"), metadata: [:])
        let rock = PlaylistItem(fileURL: URL(fileURLWithPath: "/Music/Rock/two.mod"), metadata: [:])
        let configuration = LocalAIConfiguration(provider: .lmStudio, modelName: "local", endpoint: "http://localhost:1234/v1")

        // When
        let draft = try await service.generatePlaylist(request: "Jazz", items: [jazz, rock], configuration: configuration)

        // Then
        #expect(draft.criteria.name == "Jazz Pair")
        #expect(draft.items == [jazz])
    }
}
