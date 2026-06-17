import Foundation

actor ResearchSubAgent {
    private let agentID: String
    private let cache: ResearchCache
    private let ollama: OllamaClient
    private let useLLM: Bool

    init(
        agentID: String = UUID().uuidString,
        cache: ResearchCache = .shared,
        ollama: OllamaClient = OllamaClient(),
        useLLM: Bool = true
    ) {
        self.agentID = agentID
        self.cache = cache
        self.ollama = ollama
        self.useLLM = useLLM
    }

    nonisolated var name: String { "Agent-\(agentID.prefix(6))" }

    func research(
        item: ROMCatalogItem,
        forceRefresh: Bool = false,
        onProgress: (@Sendable (String) -> Void)? = nil
    ) async -> ROMResearch {
        if !forceRefresh, let cached = await cache.research(for: item.id) {
            return cached
        }

        onProgress?("\(name): analyzing manifest metadata…")
        let baseline = ROMKnowledgeBase.baselineResearch(for: item)

        guard useLLM, await ollama.isAvailable() else {
            onProgress?("\(name): knowledge base synthesis complete")
            await cache.store(baseline)
            return baseline
        }

        onProgress?("\(name): deep research via LLM sub-agent…")
        do {
            let enriched = try await ollama.researchROM(item: item, baseline: baseline)
            let merged = merge(baseline: baseline, enriched: enriched)
            await cache.store(merged)
            onProgress?("\(name): research complete")
            return merged
        } catch {
            onProgress?("\(name): LLM unavailable, using knowledge base")
            await cache.store(baseline)
            return baseline
        }
    }

    private func merge(baseline: ROMResearch, enriched: ROMResearch) -> ROMResearch {
        ROMResearch(
            romID: baseline.romID,
            title: enriched.title,
            summary: enriched.summary,
            contentsDescription: enriched.contentsDescription,
            purpose: enriched.purpose,
            hardwareIDs: enriched.hardwareIDs.isEmpty ? baseline.hardwareIDs : enriched.hardwareIDs,
            history: enriched.history,
            technicalInsights: unique(baseline.technicalInsights + enriched.technicalInsights),
            notableLibraries: unique(baseline.notableLibraries + enriched.notableLibraries),
            compatibilityNotes: enriched.compatibilityNotes,
            researchSource: .hybrid,
            researchedAt: Date()
        )
    }

    private func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }
}