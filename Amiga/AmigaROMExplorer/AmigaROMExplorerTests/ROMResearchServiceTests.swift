import Testing
@testable import AmigaROMExplorer

@MainActor
struct ROMResearchServiceTests {
    private func makeItem(id: String) -> ROMCatalogItem {
        let manifest = ManifestEntry(source: "src/\(id)", destination: id, status: .moved)
        let parsed = ParsedROMMetadata(
            category: .kickstart,
            versionLabel: "v1.3",
            machinePath: "a500",
            variantLabel: "good",
            title: "Kickstart \(id)",
            subtitle: nil,
            hardwareTokens: ["a500"],
            hardwareModels: [],
            publisher: "Commodore",
            year: 1987,
            dumpQuality: .good,
            fileExtension: "rom"
        )
        return ROMCatalogItem(manifest: manifest, parsed: parsed, fileInfo: nil)
    }

    private func completedResearch(for item: ROMCatalogItem) -> ROMResearch {
        ROMKnowledgeBase.baselineResearch(for: item)
    }

    @Test func researchAllWithCachedProfilesShowsFeedback() {
        let service = ROMResearchService(autoHydrate: false, runsAgents: false)
        let items = [makeItem(id: "kickstart/a.rom"), makeItem(id: "kickstart/b.rom")]

        for item in items {
            service.setState(.completed(completedResearch(for: item)), for: item)
        }

        service.researchAll(items: items, forceRefresh: false)

        #expect(service.bulkResearchMessage == "All 2 ROMs already have research profiles.")
        #expect(service.queuedResearchCount == 0)
    }

    @Test func researchAllQueuesIdleItems() {
        let service = ROMResearchService(autoHydrate: false, runsAgents: false)
        let items = [makeItem(id: "kickstart/idle.rom")]

        service.researchAll(items: items, forceRefresh: false)

        #expect(service.bulkResearchMessage == "Queued 1 ROMs for research…")
        #expect(service.queuedResearchCount == 1)
        #expect(service.state(for: items[0]) == .queued)
    }

    @Test func researchAllForceRefreshRequeuesCompleted() {
        let service = ROMResearchService(autoHydrate: false, runsAgents: false, useSubAgents: true)
        let items = [makeItem(id: "kickstart/cached.rom")]
        service.setState(.completed(completedResearch(for: items[0])), for: items[0])

        service.researchAll(items: items, forceRefresh: true)

        #expect(service.bulkResearchMessage == "Queued 1 ROMs for Ollama deep research…")
        #expect(service.queuedResearchCount == 1)
        #expect(service.state(for: items[0]) == .queued)
    }

    @Test func hydrateFromCacheDoesNotOverwriteQueuedWork() async {
        let service = ROMResearchService(autoHydrate: false, runsAgents: false)
        let item = makeItem(id: "kickstart/inflight.rom")
        service.setState(.queued, for: item)

        await service.hydrateFromCache(merging: [completedResearch(for: item)])

        #expect(service.state(for: item) == .queued)
    }

    @Test func hydrateFromCacheFillsIdleSlots() async {
        let service = ROMResearchService(autoHydrate: false, runsAgents: false)
        let item = makeItem(id: "kickstart/idle.rom")

        await service.hydrateFromCache(merging: [completedResearch(for: item)])

        if case .completed = service.state(for: item) {
            // expected
        } else {
            Issue.record("Expected completed state after hydration")
        }
    }
}