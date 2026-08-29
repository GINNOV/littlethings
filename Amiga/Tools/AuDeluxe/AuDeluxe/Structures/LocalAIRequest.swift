import Foundation

enum LocalAIRequest {
    private struct Message: Encodable {
        let role: String
        let content: String
    }

    private struct OpenAIBody: Encodable {
        let model: String
        let messages: [Message]
        let temperature: Double
    }

    private struct OllamaBody: Encodable {
        let model: String
        let messages: [Message]
        let stream: Bool
        let format: String
    }

    static func make(configuration: LocalAIConfiguration, prompt: String) throws -> URLRequest {
        let modelName = configuration.modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard modelName.isEmpty == false else { throw AIPlaylistError.missingModel }
        guard let baseURL = URL(string: configuration.endpoint), baseURL.host != nil else {
            throw AIPlaylistError.invalidEndpoint
        }

        let message = Message(role: "user", content: prompt)
        let url: URL
        let body: Data
        switch configuration.provider {
        case .ollama:
            url = baseURL.path.hasSuffix("/api/chat") ? baseURL : baseURL.appending(path: "api/chat")
            body = try JSONEncoder().encode(OllamaBody(model: modelName, messages: [message], stream: false, format: "json"))
        case .lmStudio, .openAICompatible:
            url = baseURL.path.hasSuffix("/chat/completions") ? baseURL : baseURL.appending(path: "chat/completions")
            body = try JSONEncoder().encode(OpenAIBody(model: modelName, messages: [message], temperature: 0.1))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.timeoutInterval = 120
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
