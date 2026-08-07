import Foundation

enum BundledCatalogLoader {
    static func manifestURL() -> URL? {
        Bundle.main.url(forResource: AppSettings.bundledManifestName, withExtension: "tsv")
            ?? Bundle.main.url(forResource: AppSettings.bundledManifestName, withExtension: "tsv", subdirectory: "Resources")
    }

    static func researchDirectoryURL() -> URL? {
        guard let resources = Bundle.main.resourceURL else { return nil }

        let candidates = [
            resources.appendingPathComponent(AppSettings.bundledResearchFolderName, isDirectory: true),
            resources.appendingPathComponent("Resources/\(AppSettings.bundledResearchFolderName)", isDirectory: true)
        ]

        return candidates.first { FileManager.default.fileExists(atPath: $0.path) }
    }

    static func bundledResearchFiles() -> [URL] {
        if let directory = researchDirectoryURL(),
           let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
            return files.filter { $0.pathExtension == "json" }
        }

        guard let resources = Bundle.main.resourceURL,
              let files = try? FileManager.default.contentsOfDirectory(at: resources, includingPropertiesForKeys: nil) else {
            return []
        }

        return files.filter { $0.pathExtension == "json" && $0.lastPathComponent.contains(".rom.json") }
    }

    static func loadManifest() throws -> [ManifestEntry] {
        guard let url = manifestURL() else {
            throw BundledCatalogError.missingManifest
        }
        let contents = try String(contentsOf: url, encoding: .utf8)
        return ManifestParser.parse(contents: contents)
    }

    enum BundledCatalogError: LocalizedError {
        case missingManifest

        var errorDescription: String? {
            switch self {
            case .missingManifest:
                "Bundled reference catalog is missing from the app."
            }
        }
    }
}