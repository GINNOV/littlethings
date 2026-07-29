import Foundation
import Testing
@testable import AuDeluxe

struct ModuleFormatTests {
    @Test("Every declared module extension is recognized", arguments: ModuleFormat.supportedExtensions)
    func declaredExtensionIsRecognized(extension fileExtension: String) {
        // Given
        let url = URL(fileURLWithPath: "/tmp/song.\(fileExtension.uppercased())")

        // When
        let isSupported = ModuleFormat.isSupported(url)

        // Then
        #expect(isSupported)
    }

    @Test("Unrelated audio extensions are rejected")
    func unrelatedExtensionIsRejected() {
        // Given
        let url = URL(fileURLWithPath: "/tmp/song.mp3")

        // When
        let isSupported = ModuleFormat.isSupported(url)

        // Then
        #expect(!isSupported)
    }

    @Test("Malformed module data is rejected")
    func malformedModuleDataIsRejected() {
        // Given
        let malformedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mod")
        try? Data("not a tracker module".utf8).write(to: malformedURL)
        defer { try? FileManager.default.removeItem(at: malformedURL) }

        // When
        let metadata = getMetadata(
            for: malformedURL,
            ratingKey: "test.rating",
            titleKey: "test.title",
            artistKey: "test.artist"
        )

        // Then
        #expect(metadata == nil)
    }
}
