import Foundation

struct LibraryFingerprint: Codable, Equatable {
    struct Entry: Codable, Equatable {
        let relativePath: String
        let size: Int
        let modificationTime: TimeInterval
        let metadataAttributes: [String: Data]

        init(
            relativePath: String,
            size: Int,
            modificationTime: TimeInterval,
            metadataAttributes: [String: Data] = [:]
        ) {
            self.relativePath = relativePath
            self.size = size
            self.modificationTime = modificationTime
            self.metadataAttributes = metadataAttributes
        }
    }

    struct Discovery {
        let fingerprint: LibraryFingerprint
        let moduleURLs: [URL]
    }

    let entries: [Entry]

    static func discover(in rootURL: URL) throws -> Discovery {
        let resourceKeys: [URLResourceKey] = [
            .contentModificationDateKey,
            .fileSizeKey,
            .isRegularFileKey,
        ]
        guard let enumerator = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return Discovery(fingerprint: LibraryFingerprint(entries: []), moduleURLs: [])
        }

        let rootPath = rootURL.standardizedFileURL.path
        var discovered: [(entry: Entry, url: URL)] = []

        for case let fileURL as URL in enumerator {
            try Task.checkCancellation()
            guard ModuleFormat.isSupported(fileURL) else { continue }
            let values = try fileURL.resourceValues(forKeys: Set(resourceKeys))
            guard values.isRegularFile == true else { continue }

            let path = fileURL.standardizedFileURL.path
            let relativePath = path.hasPrefix(rootPath + "/")
                ? String(path.dropFirst(rootPath.count + 1))
                : fileURL.lastPathComponent
            discovered.append((
                Entry(
                    relativePath: relativePath,
                    size: values.fileSize ?? 0,
                    modificationTime: values.contentModificationDate?.timeIntervalSince1970 ?? 0,
                    metadataAttributes: audeluxeMetadataAttributes(for: fileURL)
                ),
                fileURL
            ))
        }

        discovered.sort { $0.entry.relativePath < $1.entry.relativePath }
        return Discovery(
            fingerprint: LibraryFingerprint(entries: discovered.map(\.entry)),
            moduleURLs: discovered.map(\.url)
        )
    }

    private static func audeluxeMetadataAttributes(for fileURL: URL) -> [String: Data] {
        let keys = ["com.audeluxe.title", "com.audeluxe.artist", "com.audeluxe.rating"]
        return Dictionary(uniqueKeysWithValues: keys.compactMap { key in
            getAttribute(key: key, forFileAt: fileURL).map { (key, $0) }
        })
    }
}
