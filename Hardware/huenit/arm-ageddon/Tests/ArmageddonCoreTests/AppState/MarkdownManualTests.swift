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

        let sources = MarkdownManual.section(named: "Live sources", in: markdown)
        let models = MarkdownManual.section(named: "Detection models", in: markdown)
        #expect(sources.contains("Native camera"))
        #expect(sources.contains("HUENIT telemetry"))
        let modelHeadings = MarkdownManual.parse(models).compactMap { block -> String? in
            if case .heading(let text) = block { return text }
            return nil
        }
        #expect(modelHeadings.contains("Fixture detector"))
        #expect(modelHeadings.contains("Recorded fixture detector"))
        #expect(modelHeadings.contains("Imported models"))
        #expect(sources.contains("Fixture detector") == false)
    }

    @Test("Section extraction stops at the next top-level title")
    func sectionStopsAtNextTitle() {
        let markdown = """
        # Live sources

        Source body.

        # Detection models

        Model body.
        """
        #expect(MarkdownManual.section(named: "Live sources", in: markdown) == "# Live sources\n\nSource body.")
        #expect(MarkdownManual.section(named: "Detection models", in: markdown) == "# Detection models\n\nModel body.")
        #expect(MarkdownManual.section(named: "Missing", in: markdown).isEmpty)
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
