import Foundation

actor ResearchCache {
    static let shared = ResearchCache()

    private let userDirectory: URL
    private var memory: [String: ROMResearch] = [:]

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        userDirectory = base.appendingPathComponent("AmigaROMExplorer/Research", isDirectory: true)
        try? FileManager.default.createDirectory(at: userDirectory, withIntermediateDirectories: true)
    }

    func research(for romID: String) -> ROMResearch? {
        memory[romID]
    }

    func allResearch() -> [ROMResearch] {
        Array(memory.values)
    }

    func store(_ research: ROMResearch) {
        memory[research.romID] = research
        let url = userFileURL(for: research.romID)
        if let data = try? JSONEncoder().encode(research) {
            try? data.write(to: url, options: .atomic)
        }
    }

    func loadAll() {
        loadBundled()
        loadUser()
    }

    func loadBundled() {
        let files = BundledCatalogLoader.bundledResearchFiles()
        guard !files.isEmpty else { return }
        ingest(files: files)
    }

    func loadUser() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: userDirectory, includingPropertiesForKeys: nil) else {
            return
        }

        ingest(files: files)
    }

    private func ingest(files: [URL]) {
        for file in files where file.pathExtension == "json" {
            if let data = try? Data(contentsOf: file),
               let research = try? JSONDecoder().decode(ROMResearch.self, from: data) {
                memory[research.romID] = research
            }
        }
    }

    func exportBundledResearch(for items: [ROMCatalogItem], to directory: URL) throws {
        let researchDir = directory.appendingPathComponent(AppSettings.bundledResearchFolderName, isDirectory: true)
        try FileManager.default.createDirectory(at: researchDir, withIntermediateDirectories: true)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        for item in items {
            let research = ROMKnowledgeBase.baselineResearch(for: item)
            let url = researchDir.appendingPathComponent(safeFileName(for: research.romID) + ".json")
            let data = try encoder.encode(research)
            try data.write(to: url, options: .atomic)
        }
    }

    private func userFileURL(for romID: String) -> URL {
        userDirectory.appendingPathComponent(safeFileName(for: romID) + ".json")
    }

    private func safeFileName(for romID: String) -> String {
        romID
            .replacingOccurrences(of: "/", with: "__")
            .replacingOccurrences(of: ":", with: "_")
    }
}