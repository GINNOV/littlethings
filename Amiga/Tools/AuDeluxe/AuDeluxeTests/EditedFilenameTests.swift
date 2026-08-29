import Foundation
import Testing
@testable import AuDeluxe

struct EditedFilenameTests {
    @Test("An edited filename preserves internal spaces and the chosen extension")
    func editedFilenamePreservesSpacesAndExtension() throws {
        // Given
        let original = URL(fileURLWithPath: "/Music/MODS/original.mod")

        // When
        let destination = try EditedFilename.destinationURL(
            for: original,
            editedFilename: "  Summer Breeze.xm  "
        )

        // Then
        #expect(destination.lastPathComponent == "Summer Breeze.xm")
        #expect(destination.deletingLastPathComponent() == original.deletingLastPathComponent())
    }
}
