import Foundation

private actor ResearchAgentPool {
    private let maxConcurrent: Int
    private var running = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(maxConcurrent: Int) {
        self.maxConcurrent = maxConcurrent
    }

    func acquire() async {
        if running < maxConcurrent {
            running += 1
            return
        }

        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func release() {
        if let next = waiters.first {
            waiters.removeFirst()
            next.resume()
        } else {
            running = max(0, running - 1)
        }
    }

    var activeCount: Int { running }
}

@MainActor
@Observable
final class ROMResearchService {
    private(set) var states: [String: ResearchState] = [:]
    private(set) var activeAgentCount = 0
    private(set) var completedCount = 0
    private(set) var isCacheReady = false
    private(set) var bulkResearchMessage: String?
    private(set) var queuedResearchCount = 0

    private let cache: ResearchCache
    private let agentPool = ResearchAgentPool(maxConcurrent: 4)
    private var ollamaClient: OllamaClient
    private var useSubAgents: Bool
    private let runsAgents: Bool

    init(
        autoHydrate: Bool = true,
        runsAgents: Bool = true,
        cache: ResearchCache = .shared,
        useSubAgents: Bool? = nil
    ) {
        self.cache = cache
        self.runsAgents = runsAgents
        ollamaClient = OllamaClient(
            baseURL: UserDefaults.standard.string(forKey: AppSettings.ollamaBaseURLKey) ?? AppSettings.defaultOllamaBaseURL,
            model: UserDefaults.standard.string(forKey: AppSettings.ollamaModelKey) ?? AppSettings.defaultOllamaModel
        )
        self.useSubAgents = useSubAgents
            ?? UserDefaults.standard.object(forKey: AppSettings.enableSubAgentsKey) as? Bool
            ?? true

        guard autoHydrate else { return }

        Task {
            await cache.loadAll()
            await hydrateFromCache()
        }
    }

    func configure(ollamaBaseURL: String, model: String, enableSubAgents: Bool) {
        ollamaClient = OllamaClient(baseURL: ollamaBaseURL, model: model)
        useSubAgents = enableSubAgents
    }

    func hydrateFromCache() async {
        await hydrateFromCache(merging: await cache.allResearch())
    }

    func hydrateFromCache(merging cached: [ROMResearch]) async {
        for research in cached {
            switch states[research.romID] ?? .idle {
            case .queued, .researching:
                continue
            case .idle, .failed, .completed:
                states[research.romID] = .completed(research)
            }
        }
        completedCount = states.values.filter { if case .completed = $0 { true } else { false } }.count
        isCacheReady = true
    }

    func setState(_ state: ResearchState, for item: ROMCatalogItem) {
        states[item.id] = state
    }

    func state(for item: ROMCatalogItem) -> ResearchState {
        states[item.id] ?? .idle
    }

    func research(for item: ROMCatalogItem) -> ROMResearch? {
        if case .completed(let research) = states[item.id] {
            return research
        }
        return nil
    }

    func requestResearch(for item: ROMCatalogItem, forceRefresh: Bool = false) {
        if !forceRefresh, case .completed = states[item.id] ?? .idle {
            return
        }

        switch states[item.id] ?? .idle {
        case .idle, .failed:
            states[item.id] = .queued
            spawnAgent(for: item, forceRefresh: forceRefresh)
        case .completed where forceRefresh:
            states[item.id] = .queued
            spawnAgent(for: item, forceRefresh: true)
        case .queued, .researching, .completed:
            break
        }
    }

    func prefetch(items: [ROMCatalogItem]) {
        for item in items.prefix(12) where states[item.id] == nil {
            requestResearch(for: item)
        }
    }

    func researchAll(items: [ROMCatalogItem], forceRefresh: Bool = false) {
        var queued = 0

        for item in items where ResearchBulkPlanner.shouldQueue(state: states[item.id], forceRefresh: forceRefresh) {
            requestResearch(for: item, forceRefresh: forceRefresh)
            queued += 1
        }

        queuedResearchCount = ResearchBulkPlanner.queuedCount(in: states)
        bulkResearchMessage = ResearchBulkPlanner.bulkMessage(
            queued: queued,
            total: items.count,
            forceRefresh: forceRefresh,
            useSubAgents: useSubAgents,
            activeAgentCount: activeAgentCount,
            queuedResearchCount: queuedResearchCount
        )
    }

    private func refreshBulkResearchCompletionState() {
        queuedResearchCount = ResearchBulkPlanner.queuedCount(in: states)

        guard activeAgentCount == 0, queuedResearchCount == 0 else { return }

        let researching = states.values.contains { if case .researching = $0 { true } else { false } }
        guard !researching else { return }

        bulkResearchMessage = "Research complete — \(completedCount) profiles ready."
    }

    private func spawnAgent(for item: ROMCatalogItem, forceRefresh: Bool = false) {
        guard runsAgents else { return }

        Task {
            await agentPool.acquire()
            activeAgentCount = await agentPool.activeCount
            bulkResearchMessage = "Researching \(item.displayTitle)…"

            let agent = ResearchSubAgent(ollama: ollamaClient, useLLM: useSubAgents)
            states[item.id] = .researching(progress: "\(agent.name) starting…")

            let result = await agent.research(item: item, forceRefresh: forceRefresh) { progress in
                Task { @MainActor in
                    self.states[item.id] = .researching(progress: progress)
                    self.bulkResearchMessage = progress
                }
            }

            states[item.id] = .completed(result)
            completedCount = states.values.compactMap {
                if case .completed = $0 { return $0 }
                return nil
            }.count

            await agentPool.release()
            activeAgentCount = await agentPool.activeCount
            refreshBulkResearchCompletionState()
        }
    }
}