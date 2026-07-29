import Foundation
import Testing
@testable import AuDeluxe

struct PlaylistCacheTests {
    @Test("A playlist cache round-trips its fingerprint and items")
    func playlistCacheRoundTrips() throws {
        // Given
        let item = PlaylistItem(
            fileURL: URL(fileURLWithPath: "/tmp/song.mod"),
            metadata: ["title": "Song", "duration": "1.5"],
            rating: 4
        )
        let fingerprint = LibraryFingerprint(
            entries: [.init(relativePath: "song.mod", size: 42, modificationTime: 100)]
        )
        let cache = PlaylistCache(fingerprint: fingerprint, items: [item])

        // When
        let decoded = try JSONDecoder().decode(
            PlaylistCache.self,
            from: JSONEncoder().encode(cache)
        )

        // Then
        #expect(decoded.fingerprint == fingerprint)
        #expect(decoded.items == [item])
    }
}
