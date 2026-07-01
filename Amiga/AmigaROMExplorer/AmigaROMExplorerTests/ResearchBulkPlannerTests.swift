import Testing
@testable import AmigaROMExplorer

struct ResearchBulkPlannerTests {
    private let sampleResearch = ROMResearch(
        romID: "kickstart/test.rom",
        title: "Test Kickstart",
        summary: "Summary",
        contentsDescription: "Contents",
        purpose: "Purpose",
        hardwareIDs: ["a500"],
        history: "History",
        technicalInsights: [],
        notableLibraries: [],
        compatibilityNotes: "Notes",
        researchSource: .knowledgeBase,
        researchedAt: .now
    )

    @Test func shouldQueueIdleAndFailed() {
        #expect(ResearchBulkPlanner.shouldQueue(state: .idle, forceRefresh: false))
        #expect(ResearchBulkPlanner.shouldQueue(state: .failed("error"), forceRefresh: false))
    }

    @Test func shouldNotQueueInFlight() {
        #expect(!ResearchBulkPlanner.shouldQueue(state: .queued, forceRefresh: false))
        #expect(!ResearchBulkPlanner.shouldQueue(state: .researching(progress: "…"), forceRefresh: false))
    }

    @Test func completedRequiresForceRefresh() {
        let completed = ResearchState.completed(sampleResearch)
        #expect(!ResearchBulkPlanner.shouldQueue(state: completed, forceRefresh: false))
        #expect(ResearchBulkPlanner.shouldQueue(state: completed, forceRefresh: true))
    }

    @Test func bulkMessageWhenAllCached() {
        let message = ResearchBulkPlanner.bulkMessage(
            queued: 0,
            total: 125,
            forceRefresh: false,
            useSubAgents: true,
            activeAgentCount: 0,
            queuedResearchCount: 0
        )
        #expect(message == "All 125 ROMs already have research profiles.")
    }

    @Test func bulkMessageWhenQueuingForOllama() {
        let message = ResearchBulkPlanner.bulkMessage(
            queued: 42,
            total: 125,
            forceRefresh: true,
            useSubAgents: true,
            activeAgentCount: 0,
            queuedResearchCount: 42
        )
        #expect(message == "Queued 42 ROMs for Ollama deep research…")
    }

    @Test func bulkMessageWhenResearchInProgress() {
        let message = ResearchBulkPlanner.bulkMessage(
            queued: 0,
            total: 125,
            forceRefresh: false,
            useSubAgents: true,
            activeAgentCount: 2,
            queuedResearchCount: 0
        )
        #expect(message == "Research already in progress…")
    }
}