import Foundation

enum BundledCacheExporter {
    @MainActor
    static func export(from manifestSource: URL, to outputDirectory: URL) throws {
        let contents = try String(contentsOf: manifestSource, encoding: .utf8)
        let entries = ManifestParser.parse(contents: contents)

        let manifestDest = outputDirectory.appendingPathComponent("manifest.tsv")
        try contents.write(to: manifestDest, atomically: true, encoding: .utf8)

        let items = entries.map { entry -> ROMCatalogItem in
            let parsed = ROMPathParser.parse(manifest: entry)
            return ROMCatalogItem(manifest: entry, parsed: parsed, fileInfo: nil)
        }

        try awaitResearchCacheExport(items: items, to: outputDirectory)
        print("Exported \(items.count) research profiles to \(outputDirectory.path)")
    }

    private static func awaitResearchCacheExport(items: [ROMCatalogItem], to outputDirectory: URL) throws {
        let semaphore = DispatchSemaphore(value: 0)
        var exportError: Error?

        Task {
            do {
                try await ResearchCache.shared.exportBundledResearch(for: items, to: outputDirectory)
            } catch {
                exportError = error
            }
            semaphore.signal()
        }

        semaphore.wait()
        if let exportError { throw exportError }
    }
}