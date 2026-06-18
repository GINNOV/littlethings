import CryptoKit
import Foundation

struct LocalROMFile: Sendable {
    let url: URL
    let basename: String
    let normalizedName: String
    let byteCount: Int
    let md5: String
}

struct LocalROMIndex: Sendable {
    let files: [LocalROMFile]
    let byBasename: [String: [LocalROMFile]]
    let byMD5: [String: [LocalROMFile]]
    let byNormalizedName: [String: [LocalROMFile]]

    static let firmwareExtensions: Set<String> = ["rom", "bin", "adf"]

    static func build(root: URL) -> LocalROMIndex {
        let manager = FileManager.default
        guard let enumerator = manager.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return empty
        }

        var files: [LocalROMFile] = []
        for case let fileURL as URL in enumerator {
            guard isFirmwareFile(fileURL) else { continue }
            guard let file = inspect(fileURL) else { continue }
            files.append(file)
        }

        return index(from: files)
    }

    private static var empty: LocalROMIndex {
        index(from: [])
    }

    private static func index(from files: [LocalROMFile]) -> LocalROMIndex {
        var byBasename: [String: [LocalROMFile]] = [:]
        var byMD5: [String: [LocalROMFile]] = [:]
        var byNormalizedName: [String: [LocalROMFile]] = [:]

        for file in files {
            byBasename[file.basename, default: []].append(file)
            byMD5[file.md5, default: []].append(file)
            byNormalizedName[file.normalizedName, default: []].append(file)
        }

        return LocalROMIndex(
            files: files,
            byBasename: byBasename,
            byMD5: byMD5,
            byNormalizedName: byNormalizedName
        )
    }

    private static func isFirmwareFile(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        guard firmwareExtensions.contains(ext) else { return false }
        if ext == "zip" { return false }
        return true
    }

    private static func inspect(_ url: URL) -> LocalROMFile? {
        let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey, .fileSizeKey])
        if values?.isDirectory == true { return nil }
        if values?.isRegularFile == false { return nil }

        let data = try? Data(contentsOf: url, options: [.mappedIfSafe])
        guard let data, !data.isEmpty else { return nil }

        let basename = url.lastPathComponent.lowercased()
        return LocalROMFile(
            url: url,
            basename: basename,
            normalizedName: normalizeName(basename),
            byteCount: values?.fileSize ?? data.count,
            md5: digestMD5(data)
        )
    }

    private static func digestMD5(_ data: Data) -> String {
        Insecure.MD5.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func normalizeName(_ name: String) -> String {
        var normalized = name.lowercased()
        if let dot = normalized.lastIndex(of: ".") {
            normalized = String(normalized[..<dot])
        }

        normalized = normalized.replacingOccurrences(
            of: #"\[[^\]]*\]"#,
            with: "",
            options: .regularExpression
        )

        return normalized
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: ".", with: " ")
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

enum LocalROMMatcher {
    static func match(
        entry: ManifestEntry,
        localRoot: URL,
        index: LocalROMIndex,
        checksums: ROMChecksumIndex
    ) -> URL? {
        let exact = localRoot.appendingPathComponent(entry.destination)
        if FileManager.default.fileExists(atPath: exact.path) {
            return exact
        }

        if let md5 = checksums.md5(for: entry.destination),
           let file = index.byMD5[md5]?.first {
            return file.url
        }

        let destinationBasename = (entry.destination as NSString).lastPathComponent.lowercased()
        if let file = singleCandidate(index.byBasename[destinationBasename]) {
            return file.url
        }

        let sourceBasename = ((entry.source as NSString).lastPathComponent as NSString)
            .deletingPathExtension
            .lowercased()
        if let file = singleCandidate(index.byBasename["\(sourceBasename).rom"]) {
            return file.url
        }

        let normalizedSource = LocalROMIndex.normalizeName((entry.source as NSString).lastPathComponent)
        if let file = singleCandidate(index.byNormalizedName[normalizedSource]) {
            return file.url
        }

        if let aliasKeys = aliasKeys(for: entry),
           let file = matchAliasKeys(aliasKeys, in: index, checksums: checksums, destination: entry.destination) {
            return file.url
        }

        return nil
    }

    private static func singleCandidate(_ candidates: [LocalROMFile]?) -> LocalROMFile? {
        guard let candidates, candidates.count == 1 else { return nil }
        return candidates[0]
    }

    private static func aliasKeys(for entry: ManifestEntry) -> [String]? {
        let destination = entry.destination.lowercased()
        let source = entry.source.lowercased()
        let combined = "\(destination) \(source)"

        if combined.contains("bootstrap") {
            return ["kickstart bootstrap", "amiga 1000 rom bootstrap", "bootstrap"]
        }

        if combined.contains("boot-rom") || combined.contains("boot rom") {
            if combined.contains("rom0") { return ["rom0", "boot rom 0"] }
            if combined.contains("rom1") { return ["rom1", "boot rom 1"] }
        }

        guard combined.contains("kickstart") || destination.contains("/kickstart/") else {
            return nil
        }

        if let version = extractKickstartVersion(from: combined) {
            let compactMinor = version.minor < 10 ? "\(version.minor)" : String(version.minor)
            return [
                "kick\(version.major)\(compactMinor)",
                "kickstart\(version.major)\(compactMinor)",
                "kickstart\(version.major).\(version.minor)",
                "kickstart \(version.major).\(version.minor)",
                "kickstart v\(version.major).\(version.minor)",
                "kickstart v\(version.major) \(version.minor)",
                "kickstart\(version.major) \(version.minor)"
            ]
        }

        return nil
    }

    private static func extractKickstartVersion(from text: String) -> (major: Int, minor: Int)? {
        if let match = text.range(of: #"v(\d+)[\-\.](\d+)"#, options: .regularExpression) {
            let token = String(text[match])
            let digits = token.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
            if digits.count >= 2 { return (digits[0], digits[1]) }
        }

        if let match = text.range(of: #"kickstart[\-/]?v?(\d+)[\-\.](\d+)"#, options: .regularExpression) {
            let token = String(text[match])
            let digits = token.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
            if digits.count >= 2 { return (digits[0], digits[1]) }
        }

        return nil
    }

    private static func matchAliasKeys(
        _ keys: [String],
        in index: LocalROMIndex,
        checksums: ROMChecksumIndex,
        destination: String
    ) -> LocalROMFile? {
        var candidates: [LocalROMFile] = []

        for key in keys {
            let normalizedKey = LocalROMIndex.normalizeName(key)
            for file in index.files where file.normalizedName.contains(normalizedKey) || normalizedKey.contains(file.normalizedName) {
                candidates.append(file)
            }
        }

        candidates = Array(Set(candidates.map(\.url))).compactMap { url in
            index.files.first { $0.url == url }
        }

        guard !candidates.isEmpty else { return nil }
        if candidates.count == 1 { return candidates[0] }

        if let md5 = checksums.md5(for: destination) {
            return candidates.first { $0.md5 == md5 }
        }

        return nil
    }
}