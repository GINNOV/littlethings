import Foundation

enum ManifestParser {
    static func parse(contents: String) -> [ManifestEntry] {
        let lines = contents.split(whereSeparator: \.isNewline)
        guard lines.count > 1 else { return [] }

        return lines.dropFirst().compactMap { line in
            let columns = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard columns.count >= 3 else { return nil }

            let source = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let destination = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let status = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)

            guard !destination.isEmpty else { return nil }

            return ManifestEntry(
                source: source,
                destination: destination,
                status: ManifestEntry.ManifestStatus(raw: status)
            )
        }
    }

    static func load(from directory: URL) throws -> [ManifestEntry] {
        let manifestURL = directory.appendingPathComponent("manifest.tsv")
        let contents = try String(contentsOf: manifestURL, encoding: .utf8)
        return parse(contents: contents)
    }
}