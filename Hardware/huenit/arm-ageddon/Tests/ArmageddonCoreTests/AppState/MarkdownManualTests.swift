import Foundation
import Testing
@testable import ArmageddonCore

struct MarkdownManualTests {
    @Test("Manual markdown parses titles, headings, paragraphs, and bullets")
    func parsesLiveSourceManualShape() {
        let markdown = """
        # Live sources

        Intro paragraph.

        ## Native camera

        A Mac or USB webcam.

        - Grant Camera access.
        - Capture frame stores that JPEG.
        """
        let blocks = MarkdownManual.parse(markdown)
        #expect(blocks == [
            .title("Live sources"),
            .paragraph("Intro paragraph."),
            .heading("Native camera"),
            .paragraph("A Mac or USB webcam."),
            .bullets([
                "Grant Camera access.",
                "Capture frame stores that JPEG.",
            ]),
        ])
    }

    @Test("Bundled documentation.md is the live-source manual")
    func bundledDocumentationDescribesEverySource() throws {
        let url = try #require(Self.documentationURL())
        let markdown = try MarkdownManual.load(from: url)
        let headings = MarkdownManual.parse(markdown).compactMap { block -> String? in
            if case .heading(let text) = block { return text }
            return nil
        }
        #expect(headings.contains("Native camera"))
        #expect(headings.contains("Recorded fixture"))
        #expect(headings.contains("HUENIT telemetry · detection only"))
        #expect(markdown.contains("does not send video"))
    }

    private static func documentationURL() -> URL? {
        var directory = URL(fileURLWithPath: #filePath)
        for _ in 0..<4 {
            directory.deleteLastPathComponent()
        }
        let url = directory
            .appending(path: "Sources/ArmageddonApp/Resources/documentation.md")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
}
