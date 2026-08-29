import Foundation

enum LocalAIProvider: String, CaseIterable, Identifiable {
    case lmStudio = "LM Studio"
    case ollama = "Ollama"
    case openAICompatible = "OpenAI Compatible"

    var id: String { rawValue }

    var defaultEndpoint: String {
        switch self {
        case .lmStudio: "http://localhost:1234/v1"
        case .ollama: "http://localhost:11434"
        case .openAICompatible: "http://localhost:8080/v1"
        }
    }
}
