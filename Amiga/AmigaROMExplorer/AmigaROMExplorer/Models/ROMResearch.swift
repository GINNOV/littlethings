import Foundation

enum ResearchState: Equatable, Sendable {
    case idle
    case queued
    case researching(progress: String)
    case completed(ROMResearch)
    case failed(String)
}

struct ROMResearch: Identifiable, Hashable, Codable, Sendable {
    let romID: String
    let title: String
    let summary: String
    let contentsDescription: String
    let purpose: String
    let hardwareIDs: [String]
    let history: String
    let technicalInsights: [String]
    let notableLibraries: [String]
    let compatibilityNotes: String
    let researchSource: ResearchSource
    let researchedAt: Date

    var id: String { romID }

    enum ResearchSource: String, Codable, Sendable {
        case knowledgeBase
        case subAgent
        case hybrid
    }

    var hardwareModels: [HardwareModel] {
        HardwareModel.resolve(from: hardwareIDs)
    }
}