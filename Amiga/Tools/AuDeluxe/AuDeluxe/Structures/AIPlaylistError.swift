import Foundation

enum AIPlaylistError: LocalizedError, Equatable {
    case invalidEndpoint
    case missingModel
    case emptyLibrary
    case emptyRequest
    case invalidResponse
    case server(statusCode: Int)
    case noMatches

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            "Enter a valid local AI endpoint in Settings."
        case .missingModel:
            "Enter the model name loaded by your local AI server."
        case .emptyLibrary:
            "Choose and index a music folder before creating an AI playlist."
        case .emptyRequest:
            "Describe the playlist you want to create."
        case .invalidResponse:
            "The local model returned a response AuDeluxe could not understand. Try a more specific request."
        case .server(let statusCode):
            "The local AI server returned HTTP \(statusCode)."
        case .noMatches:
            "No indexed songs matched the generated criteria. Try a broader request."
        }
    }
}
