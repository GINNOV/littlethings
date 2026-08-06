import Foundation
import Combine

struct TutorialEntry: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let relativePath: String
    let absoluteURLString: String

    var absoluteURL: URL? {
        URL(string: absoluteURLString)
    }
}

struct TutorialSource: Equatable {
    let language: String
    let code: String
}

enum TutorialCatalogError: LocalizedError {
    case invalidCatalogURL
    case invalidTutorialURL
    case network(String)
    case emptyCatalog
    case noSourceCode
    case cacheWriteFailed

    var errorDescription: String? {
        switch self {
        case .invalidCatalogURL:
            return "Tutorial catalog URL is invalid."
        case .invalidTutorialURL:
            return "Tutorial URL is invalid."
        case .network(let message):
            return message
        case .emptyCatalog:
            return "No tutorials were found in the walkthroughs catalog."
        case .noSourceCode:
            return "No assembly or C source code block was found in the tutorial page."
        case .cacheWriteFailed:
            return "Failed to write the tutorial cache."
        }
    }
}

/// Fetches and caches tutorials listed on littlethings/amiga/walkthroughs.html.
final class TutorialCatalogService: ObservableObject {
    static let shared = TutorialCatalogService()

    static let catalogURLString = "https://ginnov.github.io/littlethings/amiga/walkthroughs.html"
    static let catalogBaseURLString = "https://ginnov.github.io/littlethings/amiga/"

    @Published private(set) var tutorials: [TutorialEntry] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastErrorMessage: String?

    private let session: URLSession
    private let fileManager: FileManager
    private let cacheFileName = "tutorial_catalog.json"
    private let sourceCacheDirectoryName = "tutorial_sources"
    private var hasLoaded = false
    private let queue = DispatchQueue(label: "com.littlethings.amigaplayground.tutorials")

    init(session: URLSession = .shared, fileManager: FileManager = .default) {
        self.session = session
        self.fileManager = fileManager
    }

    func loadIfNeeded() {
        guard !hasLoaded else { return }
        hasLoaded = true

        if let cached = loadCachedCatalog(), !cached.isEmpty {
            tutorials = cached
            lastErrorMessage = nil
            return
        }

        refreshCatalog()
    }

    func refreshCatalog() {
        guard let catalogURL = URL(string: Self.catalogURLString) else {
            lastErrorMessage = TutorialCatalogError.invalidCatalogURL.localizedDescription
            return
        }

        isLoading = true
        lastErrorMessage = nil

        let task = session.dataTask(with: catalogURL) { [weak self] data, response, error in
            guard let self else { return }

            if let error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.lastErrorMessage = TutorialCatalogError.network(error.localizedDescription).localizedDescription
                }
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard let data, (200...299).contains(statusCode) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.lastErrorMessage = TutorialCatalogError.network("HTTP \(statusCode) while fetching tutorials.").localizedDescription
                }
                return
            }

            let html = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
            let parsed = Self.parseCatalogHTML(html, baseURLString: Self.catalogBaseURLString)

            DispatchQueue.main.async {
                self.isLoading = false
                if parsed.isEmpty {
                    self.lastErrorMessage = TutorialCatalogError.emptyCatalog.localizedDescription
                    return
                }
                self.tutorials = parsed
                self.lastErrorMessage = nil
                self.persistCatalog(parsed)
            }
        }
        task.resume()
    }

    func fetchSource(for tutorial: TutorialEntry, completion: @escaping (Result<TutorialSource, Error>) -> Void) {
        if let cached = loadCachedSource(for: tutorial) {
            completion(.success(cached))
            return
        }

        guard let url = tutorial.absoluteURL else {
            completion(.failure(TutorialCatalogError.invalidTutorialURL))
            return
        }

        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self else { return }

            if let error {
                DispatchQueue.main.async {
                    completion(.failure(TutorialCatalogError.network(error.localizedDescription)))
                }
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard let data, (200...299).contains(statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(TutorialCatalogError.network("HTTP \(statusCode) while fetching \(tutorial.title).")))
                }
                return
            }

            let html = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
            guard let source = Self.extractSource(from: html) else {
                DispatchQueue.main.async {
                    completion(.failure(TutorialCatalogError.noSourceCode))
                }
                return
            }

            self.persistSource(source, for: tutorial)
            DispatchQueue.main.async {
                completion(.success(source))
            }
        }
        task.resume()
    }

    // MARK: - Parsing

    static func parseCatalogHTML(_ html: String, baseURLString: String) -> [TutorialEntry] {
        var entries: [TutorialEntry] = []
        var seen = Set<String>()

        // Match each article card: title in <h3>, first tutorial link in the card.
        let articlePattern = #"<article[\s\S]*?<h3[^>]*>(.*?)</h3>[\s\S]*?href=\"(tutorials/[^\"]+\.html)\""#
        guard let regex = try? NSRegularExpression(pattern: articlePattern, options: [.caseInsensitive]) else {
            return []
        }

        let ns = html as NSString
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: ns.length))
        for match in matches {
            guard match.numberOfRanges >= 3 else { continue }
            let rawTitle = ns.substring(with: match.range(at: 1))
            let relative = ns.substring(with: match.range(at: 2))
            let title = decodeHTMLEntities(stripTags(rawTitle)).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty, !relative.isEmpty else { continue }
            guard !seen.contains(relative) else { continue }
            seen.insert(relative)

            let absolute = baseURLString.hasSuffix("/")
                ? baseURLString + relative
                : baseURLString + "/" + relative

            entries.append(
                TutorialEntry(
                    id: relative,
                    title: title,
                    relativePath: relative,
                    absoluteURLString: absolute
                )
            )
        }

        return entries
    }

    static func extractSource(from html: String) -> TutorialSource? {
        let patterns: [(language: String, pattern: String)] = [
            ("assembly", #"<code[^>]*(?:class=\"[^\"]*language-assembly[^\"]*\"|data-lang=\"assembly\")[^>]*>([\s\S]*?)</code>"#),
            ("c", #"<code[^>]*(?:class=\"[^\"]*language-c[^\"]*\"|data-lang=\"c\")[^>]*>([\s\S]*?)</code>"#),
            ("assembly", #"<pre[^>]*>\s*<code[^>]*>([\s\S]*?)</code>\s*</pre>"#)
        ]

        for item in patterns {
            guard let regex = try? NSRegularExpression(pattern: item.pattern, options: [.caseInsensitive]) else {
                continue
            }
            let ns = html as NSString
            guard let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: ns.length)),
                  match.numberOfRanges >= 2 else {
                continue
            }
            let raw = ns.substring(with: match.range(at: 1))
            let decoded = decodeHTMLEntities(raw)
                .replacingOccurrences(of: "\r\n", with: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !decoded.isEmpty {
                return TutorialSource(language: item.language, code: decoded)
            }
        }
        return nil
    }

    static func stripTags(_ value: String) -> String {
        value.replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
    }

    static func decodeHTMLEntities(_ value: String) -> String {
        var result = value
        let named: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#34;": "\"",
            "&#39;": "'",
            "&apos;": "'",
            "&nbsp;": " "
        ]
        for (entity, replacement) in named {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }

        // Numeric entities &#NNN; and &#xHH;
        if let regex = try? NSRegularExpression(pattern: #"&#(x?[0-9A-Fa-f]+);"#) {
            let ns = result as NSString
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: ns.length)).reversed()
            for match in matches {
                let token = ns.substring(with: match.range(at: 1))
                let scalarValue: UInt32?
                if token.lowercased().hasPrefix("x") {
                    scalarValue = UInt32(token.dropFirst(), radix: 16)
                } else {
                    scalarValue = UInt32(token)
                }
                if let scalarValue, let scalar = UnicodeScalar(scalarValue) {
                    result = (result as NSString).replacingCharacters(in: match.range, with: String(Character(scalar)))
                }
            }
        }
        return result
    }

    // MARK: - Cache

    private var supportDirectory: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let dir = base.appendingPathComponent("AmigaPlayground", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private var catalogCacheURL: URL {
        supportDirectory.appendingPathComponent(cacheFileName)
    }

    private var sourceCacheDirectory: URL {
        let dir = supportDirectory.appendingPathComponent(sourceCacheDirectoryName, isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func loadCachedCatalog() -> [TutorialEntry]? {
        guard let data = try? Data(contentsOf: catalogCacheURL) else { return nil }
        return try? JSONDecoder().decode([TutorialEntry].self, from: data)
    }

    private func persistCatalog(_ entries: [TutorialEntry]) {
        queue.async {
            guard let data = try? JSONEncoder().encode(entries) else { return }
            try? data.write(to: self.catalogCacheURL, options: .atomic)
        }
    }

    private func sourceCacheURL(for tutorial: TutorialEntry) -> URL {
        let safeName = tutorial.id
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        return sourceCacheDirectory.appendingPathComponent(safeName).appendingPathExtension("json")
    }

    private struct CachedSource: Codable {
        let language: String
        let code: String
    }

    private func loadCachedSource(for tutorial: TutorialEntry) -> TutorialSource? {
        let url = sourceCacheURL(for: tutorial)
        guard let data = try? Data(contentsOf: url),
              let cached = try? JSONDecoder().decode(CachedSource.self, from: data) else {
            return nil
        }
        return TutorialSource(language: cached.language, code: cached.code)
    }

    private func persistSource(_ source: TutorialSource, for tutorial: TutorialEntry) {
        queue.async {
            let payload = CachedSource(language: source.language, code: source.code)
            guard let data = try? JSONEncoder().encode(payload) else { return }
            try? data.write(to: self.sourceCacheURL(for: tutorial), options: .atomic)
        }
    }
}
