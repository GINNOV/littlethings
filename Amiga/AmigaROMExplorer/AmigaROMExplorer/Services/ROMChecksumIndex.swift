import Foundation

struct ROMChecksumIndex: Sendable {
    private let md5ByDestination: [String: String]

    init(md5ByDestination: [String: String]) {
        self.md5ByDestination = md5ByDestination
    }

    func md5(for destination: String) -> String? {
        md5ByDestination[destination]
    }

    static func loadBundled() -> ROMChecksumIndex {
        guard let url = bundledURL(),
              let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return ROMChecksumIndex(md5ByDestination: [:])
        }
        return parse(contents: contents)
    }

    static func bundledURL() -> URL? {
        Bundle.main.url(forResource: AppSettings.bundledChecksumsName, withExtension: "tsv")
            ?? Bundle.main.url(
                forResource: AppSettings.bundledChecksumsName,
                withExtension: "tsv",
                subdirectory: "Resources"
            )
    }

    static func parse(contents: String) -> ROMChecksumIndex {
        var map: [String: String] = [:]
        let lines = contents.split(whereSeparator: \.isNewline)
        guard lines.count > 1 else { return ROMChecksumIndex(md5ByDestination: map) }

        for line in lines.dropFirst() {
            let columns = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard columns.count >= 2 else { continue }
            let destination = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let md5 = columns[1].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !destination.isEmpty, !md5.isEmpty else { continue }
            map[destination] = md5
        }

        return ROMChecksumIndex(md5ByDestination: map)
    }
}