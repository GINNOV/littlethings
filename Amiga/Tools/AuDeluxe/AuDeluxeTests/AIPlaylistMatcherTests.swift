import Foundation
import Testing
@testable import AuDeluxe

struct AIPlaylistMatcherTests {
    @Test("Generated criteria match the complete indexed library")
    func criteriaMatchIndexedLibrary() {
        // Given
        let jazzMOD = item(path: "/Music/Jazz and Acid Jazz/blue.mod", title: "Blue Coins", artist: "Moby", duration: 180, rating: 4)
        let jazzXM = item(path: "/Music/Jazz and Acid Jazz/night.xm", title: "Night", artist: "Moby", duration: 220, rating: 5)
        let rockMOD = item(path: "/Music/Rock/loud.mod", title: "Loud", artist: "Other", duration: 150, rating: 5)
        let criteria = AIPlaylistCriteria(
            name: "Jazz MODs",
            artistTerms: ["Moby"],
            folderTerms: ["Jazz"],
            fileTypes: ["MOD"],
            minimumDuration: 120,
            maximumDuration: 200,
            minimumRating: 3,
            limit: 20
        )

        // When
        let matches = AIPlaylistMatcher.matches(in: [jazzMOD, jazzXM, rockMOD], criteria: criteria)

        // Then
        #expect(matches == [jazzMOD])
    }

    @Test("Playlist size is clamped to a useful boundary", arguments: [(0, 1), (500, 100)])
    func playlistSizeIsClamped(input: Int, expected: Int) {
        // Given
        let criteria = AIPlaylistCriteria(name: "Sized", limit: input)

        // When
        let limit = criteria.limit

        // Then
        #expect(limit == expected)
    }

    private func item(path: String, title: String, artist: String, duration: TimeInterval, rating: Int) -> PlaylistItem {
        PlaylistItem(
            fileURL: URL(fileURLWithPath: path),
            metadata: ["title": title, "artist": artist, "duration": String(duration)],
            rating: rating
        )
    }
}
