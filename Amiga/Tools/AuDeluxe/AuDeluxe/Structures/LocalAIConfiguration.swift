import Foundation

struct LocalAIConfiguration: Equatable {
    let provider: LocalAIProvider
    let modelName: String
    let endpoint: String
}
