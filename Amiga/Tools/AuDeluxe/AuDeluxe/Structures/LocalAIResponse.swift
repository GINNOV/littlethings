import Foundation

enum LocalAIResponse {
    private struct Message: Decodable {
        let content: String
    }

    private struct Choice: Decodable {
        let message: Message
    }

    private struct OpenAIEnvelope: Decodable {
        let choices: [Choice]
    }

    private struct OllamaEnvelope: Decodable {
        let message: Message
    }

    static func content(from data: Data, provider: LocalAIProvider) throws -> String {
        do {
            switch provider {
            case .ollama:
                return try JSONDecoder().decode(OllamaEnvelope.self, from: data).message.content
            case .lmStudio, .openAICompatible:
                guard let choice = try JSONDecoder().decode(OpenAIEnvelope.self, from: data).choices.first else {
                    throw AIPlaylistError.invalidResponse
                }
                return choice.message.content
            }
        } catch let error as AIPlaylistError {
            throw error
        } catch {
            throw AIPlaylistError.invalidResponse
        }
    }
}
