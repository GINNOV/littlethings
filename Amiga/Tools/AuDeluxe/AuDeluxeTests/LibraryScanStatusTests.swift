import Testing
@testable import AuDeluxe

struct LibraryScanStatusTests {
    @Test("Processing exposes determinate progress and counts")
    func processingProgress() {
        // Given
        let status = LibraryScanStatus.processing(
            processed: 25,
            total: 100,
            loaded: 24,
            skipped: 1,
            currentFile: "Nested/song.mod"
        )

        // When / Then
        #expect(status.isActive)
        #expect(status.progressFraction == 0.25)
        #expect(status.statusText == "Processing 25 of 100")
        #expect(status.detailText == "Nested/song.mod")
    }

    @Test("Completion summarizes loaded and skipped files")
    func completionSummary() {
        // Given
        let status = LibraryScanStatus.completed(loaded: 4_960, skipped: 8, usedCache: false)

        // When / Then
        #expect(!status.isActive)
        #expect(status.progressFraction == 1)
        #expect(status.statusText == "Loaded 4,960 modules")
        #expect(status.detailText == "Skipped 8 unreadable files")
    }

    @Test("Cancelled and failed states remain visible")
    func terminalStates() {
        // Given
        let cancelled = LibraryScanStatus.cancelled
        let failed = LibraryScanStatus.failed(message: "Folder access denied")

        // When / Then
        #expect(cancelled.statusText == "Scan cancelled")
        #expect(failed.statusText == "Scan failed")
        #expect(failed.detailText == "Folder access denied")
    }
}
