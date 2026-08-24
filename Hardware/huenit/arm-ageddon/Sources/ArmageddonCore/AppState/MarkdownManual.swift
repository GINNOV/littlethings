import Foundation

public enum MarkdownManualBlock: Equatable, Sendable {
    case title(String)
    case heading(String)
    case paragraph(String)
    case bullets([String])
}

public enum MarkdownManual {
    public static func parse(_ markdown: String) -> [MarkdownManualBlock] {
        var blocks: [MarkdownManualBlock] = []
        var bullets: [String] = []
        func flushBullets() {
            guard !bullets.isEmpty else { return }
            blocks.append(.bullets(bullets))
            bullets = []
        }

        for rawLine in markdown.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                flushBullets()
                continue
            }
            if line.hasPrefix("# ") {
                flushBullets()
                blocks.append(.title(String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                flushBullets()
                blocks.append(.heading(String(line.dropFirst(3))))
            } else if line.hasPrefix("- ") {
                bullets.append(String(line.dropFirst(2)))
            } else {
                flushBullets()
                blocks.append(.paragraph(line))
            }
        }
        flushBullets()
        return blocks
    }

    public static func load(from url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }
}
