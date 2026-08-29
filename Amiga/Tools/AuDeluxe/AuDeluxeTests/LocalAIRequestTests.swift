import Foundation
import Testing
@testable import AuDeluxe

struct LocalAIRequestTests {
    @Test("Provider request uses its compatible chat endpoint", arguments: [
        (LocalAIProvider.lmStudio, "http://localhost:1234/v1", "/v1/chat/completions"),
        (LocalAIProvider.ollama, "http://localhost:11434", "/api/chat"),
        (LocalAIProvider.openAICompatible, "http://localhost:8080/v1", "/v1/chat/completions")
    ])
    func providerUsesChatEndpoint(provider: LocalAIProvider, endpoint: String, expectedPath: String) throws {
        // Given
        let configuration = LocalAIConfiguration(provider: provider, modelName: "local-model", endpoint: endpoint)

        // When
        let request = try LocalAIRequest.make(configuration: configuration, prompt: "{}")

        // Then
        #expect(request.url?.path == expectedPath)
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test("Provider response exposes the assistant JSON", arguments: [
        (LocalAIProvider.lmStudio, "{\"choices\":[{\"message\":{\"content\":\"{\\\"name\\\":\\\"Mix\\\"}\"}}]}"),
        (LocalAIProvider.ollama, "{\"message\":{\"content\":\"{\\\"name\\\":\\\"Mix\\\"}\"}}")
    ])
    func providerResponseExposesContent(provider: LocalAIProvider, payload: String) throws {
        // Given
        let data = Data(payload.utf8)

        // When
        let content = try LocalAIResponse.content(from: data, provider: provider)

        // Then
        #expect(content == "{\"name\":\"Mix\"}")
    }
}
