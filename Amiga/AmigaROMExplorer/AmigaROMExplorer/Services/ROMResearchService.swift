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

    private let cache = ResearchCache.shared
    private let agentPool = ResearchAgentPool(maxConcurrent: 4)
    private var ollamaClient: OllamaClient
    private var useSubAgents: Bool

    init() {
        ollamaClient = OllamaClient(
            baseURL: UserDefaults.standard.string(forKey: AppSettings.ollamaBaseURLKey) ?? AppSettings.defaultOllamaBaseURL,
            model: UserDefaults.standard.string(forKey: AppSettings.ollamaModelKey) ?? AppSettings.defaultOllamaModel
        )
        useSubAgents = UserDefaults.standard.object(forKey: AppSettings.enableSubAgentsKey) as? Bool ?? true

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
        let cached = await cache.allResearch()
        for research in cached {
            states[research.romID] = .completed(research)
        }
        completedCount = cached.count
        isCacheReady = true
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
            spawnAgent(for: item)
        case .completed where forceRefresh:
            states[item.id] = .queued
            spawnAgent(for: item)
        case .queued, .researching, .completed:
            break
        }
    }

    func prefetch(items: [ROMCatalogItem]) {
        for item in items.prefix(12) where states[item.id] == nil {
            requestResearch(for: item)
        }
    }

    func researchAll(items: [ROMCatalogItem]) {
        for item in items where states[item.id] == nil || states[item.id] == .idle {
            requestResearch(for: item)
        }
    }

    private func spawnAgent(for item: ROMCatalogItem) {
        Task {
            await agentPool.acquire()
            activeAgentCount = await agentPool.activeCount

            let agent = ResearchSubAgent(ollama: ollamaClient, useLLM: useSubAgents)
            states[item.id] = .researching(progress: "\(agent.name) starting…")

            let result = await agent.research(item: item) { progress in
                Task { @MainActor in
                    self.states[item.id] = .researching(progress: progress)
                }
            }

            states[item.id] = .completed(result)
            completedCount = states.values.compactMap {
                if case .completed = $0 { return $0 }
                return nil
            }.count

            await agentPool.release()
            activeAgentCount = await agentPool.activeCount
        }
    }
}