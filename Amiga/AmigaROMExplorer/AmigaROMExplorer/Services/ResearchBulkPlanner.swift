import Foundation

enum ResearchBulkPlanner {
    static func shouldQueue(state: ResearchState?, forceRefresh: Bool) -> Bool {
        switch state ?? .idle {
        case .queued, .researching:
            return false
        case .idle, .failed:
            return true
        case .completed:
            return forceRefresh
        }
    }

    static func queuedCount(in states: [String: ResearchState]) -> Int {
        states.values.filter { if case .queued = $0 { true } else { false } }.count
    }

    static func bulkMessage(
        queued: Int,
        total: Int,
        forceRefresh: Bool,
        useSubAgents: Bool,
        activeAgentCount: Int,
        queuedResearchCount: Int
    ) -> String {
        if queued > 0 {
            if forceRefresh && useSubAgents {
                return "Queued \(queued) ROMs for Ollama deep research…"
            }
            return "Queued \(queued) ROMs for research…"
        }

        let inFlight = activeAgentCount + queuedResearchCount
        if inFlight > 0 {
            return "Research already in progress…"
        }

        return "All \(total) ROMs already have research profiles."
    }
}