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

    private struct UnavailableHTTPClient: LocalAIHTTPClient {
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            throw URLError(.cannotConnectToHost)
        }
    }

    private struct UnhealthyHTTPClient: LocalAIHTTPClient {
        let endpoint: URL

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            let response = try #require(HTTPURLResponse(url: endpoint, statusCode: 404, httpVersion: nil, headerFields: nil))
            return (Data(), response)
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

    @Test("Generation stops before posting when the local server is offline")
    func generationStopsWhenServerIsUnavailable() async throws {
        // Given
        let service = LocalAIService(client: UnavailableHTTPClient())
        let item = PlaylistItem(fileURL: URL(fileURLWithPath: "/Music/Jazz/one.mod"), metadata: [:])
        let configuration = LocalAIConfiguration(provider: .lmStudio, modelName: "local", endpoint: "http://localhost:1234/v1")

        // When
        let error = await #expect(throws: AIPlaylistError.self) {
            try await service.generatePlaylist(request: "Jazz", items: [item], configuration: configuration)
        }

        // Then
        #expect(error == .serverUnavailable)
    }

    @Test("Generation stops when the local server health endpoint is unsuccessful")
    func generationStopsWhenServerIsUnhealthy() async throws {
        // Given
        let endpoint = try #require(URL(string: "http://localhost:1234/v1/models"))
        let service = LocalAIService(client: UnhealthyHTTPClient(endpoint: endpoint))
        let item = PlaylistItem(fileURL: URL(fileURLWithPath: "/Music/Jazz/one.mod"), metadata: [:])
        let configuration = LocalAIConfiguration(provider: .lmStudio, modelName: "local", endpoint: "http://localhost:1234/v1")

        // When
        let error = await #expect(throws: AIPlaylistError.self) {
            try await service.generatePlaylist(request: "Jazz", items: [item], configuration: configuration)
        }

        // Then
        #expect(error == .serverUnavailable)
    }
}
