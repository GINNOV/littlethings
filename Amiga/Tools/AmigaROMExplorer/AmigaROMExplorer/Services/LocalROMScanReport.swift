import Foundation

struct ScannedROMFileSummary: Identifiable, Hashable, Sendable {
    let url: URL
    let displayName: String
    let md5: String
    let byteCount: Int

    var id: String { url.standardizedFileURL.path }
}

struct ChecksumMismatchSummary: Identifiable, Hashable, Sendable {
    let file: ScannedROMFileSummary
    let hint: String
    let expectedMD5: String?
    let catalogDestination: String?

    var id: String { file.id }
}

struct LocalROMScanReport: Equatable, Sendable {
    let scannedFirmwareFiles: Int
    let matchedCatalogEntries: Int
    let skippedArchiveFiles: [ScannedROMFileSummary]
    let unrecognizedFiles: [ScannedROMFileSummary]
    let checksumMismatches: [ChecksumMismatchSummary]

    static let empty = LocalROMScanReport(
        scannedFirmwareFiles: 0,
        matchedCatalogEntries: 0,
        skippedArchiveFiles: [],
        unrecognizedFiles: [],
        checksumMismatches: []
    )

    var summaryLine: String {
        var parts = ["Scanned \(scannedFirmwareFiles) file\(scannedFirmwareFiles == 1 ? "" : "s")"]
        parts.append("\(matchedCatalogEntries) matched catalog entr\(matchedCatalogEntries == 1 ? "y" : "ies")")

        if !checksumMismatches.isEmpty {
            let count = checksumMismatches.count
            parts.append("\(count) checksum mismatch\(count == 1 ? "" : "es")")
        }

        if !unrecognizedFiles.isEmpty {
            let count = unrecognizedFiles.count
            parts.append("\(count) unrecognized")
        }

        if !skippedArchiveFiles.isEmpty {
            let count = skippedArchiveFiles.count
            parts.append("\(count) skipped (.zip)")
        }

        return parts.joined(separator: " · ")
    }

    var hasIssues: Bool {
        !checksumMismatches.isEmpty || !unrecognizedFiles.isEmpty || !skippedArchiveFiles.isEmpty
    }
}

struct LocalROMScanBundle: Sendable {
    let index: LocalROMIndex
    let skippedArchives: [ScannedROMFileSummary]
}

enum LocalROMScanner {
    static let archiveExtensions: Set<String> = ["zip", "7z", "rar", "lha", "lzx"]

    static func scan(root: URL) -> LocalROMScanBundle {
        LocalROMScanBundle(
            index: LocalROMIndex.build(root: root),
            skippedArchives: collectSkippedArchives(root: root)
        )
    }

    private static func collectSkippedArchives(root: URL) -> [ScannedROMFileSummary] {
        let manager = FileManager.default
        guard let enumerator = manager.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return []
        }

        var skipped: [ScannedROMFileSummary] = []
        for case let fileURL as URL in enumerator {
            let ext = fileURL.pathExtension.lowercased()
            guard archiveExtensions.contains(ext) else { continue }

            let values = try? fileURL.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey, .fileSizeKey])
            if values?.isDirectory == true { continue }
            if values?.isRegularFile == false { continue }

            skipped.append(
                ScannedROMFileSummary(
                    url: fileURL,
                    displayName: fileURL.lastPathComponent,
                    md5: "",
                    byteCount: values?.fileSize ?? 0
                )
            )
        }

        return skipped.sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }
}

enum LocalROMScanAnalyzer {
    static func makeReport(
        scanBundle: LocalROMScanBundle,
        matchedURLs: Set<URL>,
        entries: [ManifestEntry],
        checksums: ROMChecksumIndex,
        matchedCatalogEntries: Int
    ) -> LocalROMScanReport {
        let normalizedMatched = Set(matchedURLs.map(\.standardizedFileURL))
        var unrecognized: [ScannedROMFileSummary] = []
        var mismatches: [ChecksumMismatchSummary] = []

        for file in scanBundle.index.files {
            guard !normalizedMatched.contains(file.url.standardizedFileURL) else { continue }

            let summary = ScannedROMFileSummary(
                url: file.url,
                displayName: file.url.lastPathComponent,
                md5: file.md5,
                byteCount: file.byteCount
            )

            if let mismatch = mismatchHint(for: file, entries: entries, checksums: checksums) {
                mismatches.append(
                    ChecksumMismatchSummary(
                        file: summary,
                        hint: mismatch.hint,
                        expectedMD5: mismatch.expectedMD5,
                        catalogDestination: mismatch.catalogDestination
                    )
                )
            } else {
                unrecognized.append(summary)
            }
        }

        return LocalROMScanReport(
            scannedFirmwareFiles: scanBundle.index.files.count,
            matchedCatalogEntries: matchedCatalogEntries,
            skippedArchiveFiles: scanBundle.skippedArchives,
            unrecognizedFiles: unrecognized,
            checksumMismatches: mismatches
        )
    }

    private struct MismatchHint {
        let hint: String
        let expectedMD5: String?
        let catalogDestination: String?
    }

    private static func mismatchHint(
        for file: LocalROMFile,
        entries: [ManifestEntry],
        checksums: ROMChecksumIndex
    ) -> MismatchHint? {
        for entry in entries {
            let catalogBasename = ((entry.destination as NSString).lastPathComponent).lowercased()
            guard catalogBasename == file.basename else { continue }

            if let expected = checksums.md5(for: entry.destination), file.md5 != expected {
                return MismatchHint(
                    hint: "Filename matches catalog entry but checksum differs",
                    expectedMD5: expected,
                    catalogDestination: entry.destination
                )
            }
        }

        if file.normalizedName.contains("bootstrap") {
            return versionFamilyMismatch(
                for: file,
                entries: entries.filter { $0.destination.hasPrefix("bootstrap/") },
                checksums: checksums,
                hint: "Looks like an Amiga 1000 bootstrap ROM"
            )
        }

        if let version = kickstartVersionHint(from: file.normalizedName) {
            let family = entries.filter {
                entryMatchesKickstartVersion($0, major: version.major, minor: version.minor)
            }
            return versionFamilyMismatch(
                for: file,
                entries: family,
                checksums: checksums,
                hint: "Looks like Kickstart v\(version.major).\(version.minor)"
            )
        }

        if let aliasMatch = aliasOverlapMismatch(for: file, entries: entries, checksums: checksums) {
            return aliasMatch
        }

        return nil
    }

    private static func versionFamilyMismatch(
        for file: LocalROMFile,
        entries: [ManifestEntry],
        checksums: ROMChecksumIndex,
        hint: String
    ) -> MismatchHint? {
        let expectedMD5s = Set(entries.compactMap { checksums.md5(for: $0.destination) })
        guard !expectedMD5s.isEmpty, !expectedMD5s.contains(file.md5) else { return nil }

        let closest = entries.first { entry in
            checksums.md5(for: entry.destination) != nil
        }

        return MismatchHint(
            hint: hint,
            expectedMD5: closest.flatMap { checksums.md5(for: $0.destination) },
            catalogDestination: closest?.destination
        )
    }

    private static func aliasOverlapMismatch(
        for file: LocalROMFile,
        entries: [ManifestEntry],
        checksums: ROMChecksumIndex
    ) -> MismatchHint? {
        for entry in entries {
            guard let aliasKeys = LocalROMMatcher.aliasKeys(for: entry) else { continue }

            let overlaps = aliasKeys.contains { key in
                let normalizedKey = LocalROMIndex.normalizeName(key)
                return file.normalizedName.contains(normalizedKey)
                    || normalizedKey.contains(file.normalizedName)
            }
            guard overlaps else { continue }

            if let expected = checksums.md5(for: entry.destination), file.md5 != expected {
                return MismatchHint(
                    hint: "Filename resembles \(entryTitle(entry)) but checksum doesn't match catalog",
                    expectedMD5: expected,
                    catalogDestination: entry.destination
                )
            }
        }

        return nil
    }

    private static func entryTitle(_ entry: ManifestEntry) -> String {
        ROMPathParser.parse(manifest: entry).title
    }

    private static func entryMatchesKickstartVersion(_ entry: ManifestEntry, major: Int, minor: Int) -> Bool {
        let marker = "/v\(major)-\(minor)-"
        return entry.destination.hasPrefix("kickstart/") && entry.destination.contains(marker)
    }

    private static func kickstartVersionHint(from normalizedName: String) -> (major: Int, minor: Int)? {
        if let version = LocalROMMatcher.extractKickstartVersion(from: normalizedName) {
            return version
        }

        let patterns = [
            #"kick(\d)(\d)\b"#,
            #"kickstart(\d)(\d)\b"#
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: normalizedName, range: NSRange(normalizedName.startIndex..., in: normalizedName)),
                  let majorRange = Range(match.range(at: 1), in: normalizedName),
                  let minorRange = Range(match.range(at: 2), in: normalizedName),
                  let major = Int(normalizedName[majorRange]),
                  let minor = Int(normalizedName[minorRange]) else {
                continue
            }
            return (major, minor)
        }

        return nil
    }
}