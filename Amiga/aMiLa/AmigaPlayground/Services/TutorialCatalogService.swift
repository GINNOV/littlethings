import Foundation
import Combine

struct TutorialEntry: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let summary: String
    let file: String
    let language: String
    let order: Int

    init(
        id: String,
        title: String,
        summary: String = "",
        file: String,
        language: String = "assembly",
        order: Int = 0
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.file = file
        self.language = language
        self.order = order
    }
}

struct TutorialSource: Equatable {
    let language: String
    let code: String
    let title: String
}

enum TutorialCatalogError: LocalizedError {
    case invalidURL
    case network(String)
    case emptyCatalog
    case missingSource(String)
    case decode(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Tutorial catalog URL is invalid."
        case .network(let message):
            return message
        case .emptyCatalog:
            return "No tutorials were found in the tutorials folder."
        case .missingSource(let file):
            return "Tutorial source file is missing: \(file)"
        case .decode(let message):
            return "Could not read tutorial catalog: \(message)"
        }
    }
}

/// Pulls playground-ready sources from the GitHub `tutorials` folder and caches them locally.
///
/// Remote layout (master):
///   Amiga/aMiLa/AmigaPlayground/tutorials/index.json
///   Amiga/aMiLa/AmigaPlayground/tutorials/*.s|*.asm|*.c
final class TutorialCatalogService: ObservableObject {
    static let shared = TutorialCatalogService()

    /// Repo-relative folder that is the source of truth on GitHub.
    static let remoteFolderPath = "Amiga/aMiLa/AmigaPlayground/tutorials"
    static let rawBaseURLString =
        "https://raw.githubusercontent.com/GINNOV/littlethings/master/\(remoteFolderPath)"
    static let contentsAPIURLString =
        "https://api.github.com/repos/GINNOV/littlethings/contents/\(remoteFolderPath)?ref=master"

    @Published private(set) var tutorials: [TutorialEntry] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastErrorMessage: String?
    @Published private(set) var lastSyncedAt: Date?

    private let session: URLSession
    private let fileManager: FileManager
    private let queue = DispatchQueue(label: "com.littlethings.amigaplayground.tutorials", qos: .utility)
    private var hasStarted = false

    private struct RemoteIndex: Codable {
        let version: Int?
        let tutorials: [RemoteTutorial]
    }

    private struct RemoteTutorial: Codable {
        let id: String
        let title: String
        let summary: String?
        let file: String
        let language: String?
        let order: Int?
    }

    private struct GitHubContentItem: Codable {
        let name: String
        let type: String
        let download_url: String?
    }

    init(session: URLSession = .shared, fileManager: FileManager = .default) {
        self.session = session
        self.fileManager = fileManager
    }

    /// Load cached tutorials immediately, then refresh from GitHub in the background.
    func loadIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true

        if let cached = loadCachedCatalog(), !cached.isEmpty {
            tutorials = cached
            lastErrorMessage = nil
        } else if let bundled = loadBundledCatalog(), !bundled.isEmpty {
            tutorials = bundled
            persistCatalog(bundled)
            seedCacheFromBundle(bundled)
        }

        refreshFromRemote()
    }

    /// Force a network refresh of index + sources.
    func refreshFromRemote() {
        isLoading = true
        lastErrorMessage = nil

        queue.async { [weak self] in
            guard let self else { return }
            do {
                let catalog = try self.fetchRemoteCatalog()
                try self.downloadSources(for: catalog)
                self.persistCatalog(catalog)
                DispatchQueue.main.async {
                    self.tutorials = catalog
                    self.isLoading = false
                    self.lastErrorMessage = nil
                    self.lastSyncedAt = Date()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    if self.tutorials.isEmpty {
                        self.lastErrorMessage = error.localizedDescription
                    }
                    // Keep showing whatever we already have when offline.
                }
            }
        }
    }

    func fetchSource(for tutorial: TutorialEntry, completion: @escaping (Result<TutorialSource, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self else { return }
            do {
                let code = try self.loadSourceCode(for: tutorial)
                let source = TutorialSource(
                    language: tutorial.language,
                    code: code,
                    title: tutorial.title
                )
                DispatchQueue.main.async { completion(.success(source)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: - Remote

    private func fetchRemoteCatalog() throws -> [TutorialEntry] {
        // 1) Preferred: index.json with human titles.
        var byID: [String: TutorialEntry] = [:]
        if let index = try? downloadIndex() {
            for item in index.tutorials {
                let entry = TutorialEntry(
                    id: item.id,
                    title: item.title,
                    summary: item.summary ?? "",
                    file: item.file,
                    language: item.language ?? Self.language(forFileName: item.file),
                    order: item.order ?? 0
                )
                byID[entry.id] = entry
            }
        }

        // 2) Merge with live folder listing so new files appear even before index is edited.
        if let listed = try? listRemoteSourceFiles() {
            for fileName in listed {
                let id = Self.id(forFileName: fileName)
                if byID[id] == nil {
                    byID[id] = TutorialEntry(
                        id: id,
                        title: Self.humanTitle(forFileName: fileName),
                        summary: "",
                        file: fileName,
                        language: Self.language(forFileName: fileName),
                        order: 10_000
                    )
                }
            }
        }

        let sorted = byID.values.sorted {
            if $0.order != $1.order { return $0.order < $1.order }
            return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
        if sorted.isEmpty {
            throw TutorialCatalogError.emptyCatalog
        }
        return sorted
    }

    private func downloadIndex() throws -> RemoteIndex {
        guard let url = URL(string: "\(Self.rawBaseURLString)/index.json") else {
            throw TutorialCatalogError.invalidURL
        }
        let data = try downloadData(from: url)
        do {
            return try JSONDecoder().decode(RemoteIndex.self, from: data)
        } catch {
            throw TutorialCatalogError.decode(error.localizedDescription)
        }
    }

    private func listRemoteSourceFiles() throws -> [String] {
        guard let url = URL(string: Self.contentsAPIURLString) else {
            throw TutorialCatalogError.invalidURL
        }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        let data = try downloadData(for: request)
        let items = try JSONDecoder().decode([GitHubContentItem].self, from: data)
        return items
            .filter { $0.type == "file" && Self.isSourceFile($0.name) }
            .map(\.name)
            .sorted()
    }

    private func downloadSources(for catalog: [TutorialEntry]) throws {
        try fileManager.createDirectory(at: sourcesDirectory, withIntermediateDirectories: true)
        for tutorial in catalog {
            guard let url = URL(string: "\(Self.rawBaseURLString)/\(tutorial.file)") else {
                continue
            }
            let data = try downloadData(from: url)
            let dest = sourcesDirectory.appendingPathComponent(tutorial.file)
            try data.write(to: dest, options: .atomic)
        }
    }

    private func downloadData(from url: URL) throws -> Data {
        try downloadData(for: URLRequest(url: url))
    }

    private func downloadData(for request: URLRequest) throws -> Data {
        let semaphore = DispatchSemaphore(value: 0)
        var resultData: Data?
        var resultError: Error?

        let task = session.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            if let error {
                resultError = TutorialCatalogError.network(error.localizedDescription)
                return
            }
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard let data, (200...299).contains(status) else {
                resultError = TutorialCatalogError.network("HTTP \(status) for \(request.url?.absoluteString ?? "request")")
                return
            }
            resultData = data
        }
        task.resume()
        semaphore.wait()

        if let resultError { throw resultError }
        guard let resultData else {
            throw TutorialCatalogError.network("Empty response")
        }
        return resultData
    }

    // MARK: - Local source

    private func loadSourceCode(for tutorial: TutorialEntry) throws -> String {
        let cached = sourcesDirectory.appendingPathComponent(tutorial.file)
        if let text = try? String(contentsOf: cached, encoding: .utf8),
           !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return text
        }

        // Try bundle seed
        if let bundled = bundleSourceURL(for: tutorial.file),
           let text = try? String(contentsOf: bundled, encoding: .utf8),
           !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try? text.write(to: cached, atomically: true, encoding: .utf8)
            return text
        }

        // Last resort: fetch single file now
        guard let url = URL(string: "\(Self.rawBaseURLString)/\(tutorial.file)") else {
            throw TutorialCatalogError.invalidURL
        }
        let data = try downloadData(from: url)
        guard let text = String(data: data, encoding: .utf8),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TutorialCatalogError.missingSource(tutorial.file)
        }
        try fileManager.createDirectory(at: sourcesDirectory, withIntermediateDirectories: true)
        try text.write(to: cached, atomically: true, encoding: .utf8)
        return text
    }

    // MARK: - Cache + bundle

    private var supportDirectory: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let dir = base.appendingPathComponent("AmigaPlayground/tutorials", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private var catalogCacheURL: URL {
        supportDirectory.appendingPathComponent("catalog.json")
    }

    private var sourcesDirectory: URL {
        let dir = supportDirectory.appendingPathComponent("sources", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func loadCachedCatalog() -> [TutorialEntry]? {
        guard let data = try? Data(contentsOf: catalogCacheURL) else { return nil }
        return try? JSONDecoder().decode([TutorialEntry].self, from: data)
    }

    private func persistCatalog(_ entries: [TutorialEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: catalogCacheURL, options: .atomic)
    }

    private func bundleTutorialsDirectory() -> URL? {
        // Prefer a folder reference copied into the app bundle.
        if let url = Bundle.main.resourceURL?.appendingPathComponent("tutorials", isDirectory: true),
           fileManager.fileExists(atPath: url.path) {
            return url
        }
        if let url = Bundle.main.url(forResource: "tutorials", withExtension: nil) {
            return url
        }
        return nil
    }

    private func bundleSourceURL(for fileName: String) -> URL? {
        if let dir = bundleTutorialsDirectory() {
            let url = dir.appendingPathComponent(fileName)
            if fileManager.fileExists(atPath: url.path) { return url }
        }
        let stem = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        return Bundle.main.url(forResource: stem, withExtension: ext, subdirectory: "tutorials")
    }

    private func loadBundledCatalog() -> [TutorialEntry]? {
        guard let dir = bundleTutorialsDirectory() else { return nil }
        let indexURL = dir.appendingPathComponent("index.json")
        if let data = try? Data(contentsOf: indexURL),
           let remote = try? JSONDecoder().decode(RemoteIndex.self, from: data) {
            return remote.tutorials.enumerated().map { idx, item in
                TutorialEntry(
                    id: item.id,
                    title: item.title,
                    summary: item.summary ?? "",
                    file: item.file,
                    language: item.language ?? Self.language(forFileName: item.file),
                    order: item.order ?? (idx + 1)
                )
            }
        }

        // Fall back to enumerating source files in the bundle folder.
        guard let files = try? fileManager.contentsOfDirectory(atPath: dir.path) else { return nil }
        return files
            .filter { Self.isSourceFile($0) }
            .sorted()
            .enumerated()
            .map { idx, name in
                TutorialEntry(
                    id: Self.id(forFileName: name),
                    title: Self.humanTitle(forFileName: name),
                    summary: "",
                    file: name,
                    language: Self.language(forFileName: name),
                    order: idx + 1
                )
            }
    }

    private func seedCacheFromBundle(_ catalog: [TutorialEntry]) {
        queue.async { [weak self] in
            guard let self else { return }
            try? self.fileManager.createDirectory(at: self.sourcesDirectory, withIntermediateDirectories: true)
            for tutorial in catalog {
                guard let src = self.bundleSourceURL(for: tutorial.file) else { continue }
                let dest = self.sourcesDirectory.appendingPathComponent(tutorial.file)
                if self.fileManager.fileExists(atPath: dest.path) { continue }
                try? self.fileManager.copyItem(at: src, to: dest)
            }
        }
    }

    // MARK: - Naming helpers

    static func isSourceFile(_ name: String) -> Bool {
        let lower = name.lowercased()
        guard !name.hasPrefix(".") else { return false }
        return lower.hasSuffix(".s") || lower.hasSuffix(".asm") || lower.hasSuffix(".c")
    }

    static func language(forFileName name: String) -> String {
        name.lowercased().hasSuffix(".c") ? "c" : "assembly"
    }

    static func id(forFileName name: String) -> String {
        let stem = (name as NSString).deletingPathExtension
        return stem
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: " ", with: "-")
    }

    /// Turn `copper-rainbow-bars.s` into "Copper Rainbow Bars".
    static func humanTitle(forFileName name: String) -> String {
        let stem = (name as NSString).deletingPathExtension
        let parts = stem
            .replacingOccurrences(of: "_", with: "-")
            .split(separator: "-")
            .map { part -> String in
                let s = String(part)
                guard let first = s.first else { return s }
                return String(first).uppercased() + s.dropFirst().lowercased()
            }
        return parts.joined(separator: " ")
    }

    // MARK: - Testing helpers

    static func parseIndexJSON(_ data: Data) throws -> [TutorialEntry] {
        let remote = try JSONDecoder().decode(RemoteIndex.self, from: data)
        return remote.tutorials.enumerated().map { idx, item in
            TutorialEntry(
                id: item.id,
                title: item.title,
                summary: item.summary ?? "",
                file: item.file,
                language: item.language ?? language(forFileName: item.file),
                order: item.order ?? (idx + 1)
            )
        }
    }
}
