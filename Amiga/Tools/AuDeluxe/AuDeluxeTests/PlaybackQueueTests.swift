import Foundation
import Testing
@testable import AuDeluxe

struct PlaybackQueueTests {
    @Test("A shuffled queue preserves its explicit order")
    func shuffledQueuePreservesOrder() {
        // Given
        let alpha = item(named: "Alpha", duration: 10, rating: 1)
        let beta = item(named: "Beta", duration: 20, rating: 2)
        let gamma = item(named: "Gamma", duration: 30, rating: 3)

        // When
        let queue = PlaybackQueue.make(
            items: [alpha, beta, gamma],
            activePlaylist: nil,
            searchText: "",
            sortOrder: .name,
            shuffledIDs: [gamma.id, alpha.id, beta.id]
        )

        // Then
        #expect(queue.map(\.id) == [gamma.id, alpha.id, beta.id])
    }

    @Test("A normal queue applies the selected sort order")
    func normalQueueAppliesSortOrder() {
        // Given
        let short = item(named: "Zulu", duration: 10, rating: 1)
        let long = item(named: "Alpha", duration: 30, rating: 3)

        // When
        let queue = PlaybackQueue.make(
            items: [short, long],
            activePlaylist: nil,
            searchText: "",
            sortOrder: .duration,
            shuffledIDs: nil
        )

        // Then
        #expect(queue.map(\.id) == [short.id, long.id])
    }

    @Test("A queue can be sorted by containing folder")
    func queueSortsByFolder() {
        // Given
        let later = item(named: "Alpha", folder: "Zulu", fileExtension: "mod")
        let earlier = item(named: "Zulu", folder: "Alpha", fileExtension: "xm")

        // When
        let queue = PlaybackQueue.make(
            items: [later, earlier],
            activePlaylist: nil,
            searchText: "",
            sortOrder: .folder,
            shuffledIDs: nil
        )

        // Then
        #expect(queue.map(\.id) == [earlier.id, later.id])
    }

    @Test("A queue can be sorted by file type")
    func queueSortsByFileType() {
        // Given
        let module = item(named: "Zulu", folder: "Music", fileExtension: "mod")
        let instrument = item(named: "Alpha", folder: "Music", fileExtension: "xm")

        // When
        let queue = PlaybackQueue.make(
            items: [instrument, module],
            activePlaylist: nil,
            searchText: "",
            sortOrder: .fileType,
            shuffledIDs: nil
        )

        // Then
        #expect(queue.map(\.id) == [module.id, instrument.id])
    }

    @Test("An active playlist and search filter constrain the queue")
    func activePlaylistAndSearchConstrainQueue() {
        // Given
        let included = item(named: "Desert Dream", duration: 10, rating: 1)
        let filtered = item(named: "Ocean Dream", duration: 20, rating: 2)
        let outside = item(named: "Desert Night", duration: 30, rating: 3)
        let playlist = Playlist(name: "Favorites", fileURLs: [included.fileURL, filtered.fileURL])

        // When
        let queue = PlaybackQueue.make(
            items: [included, filtered, outside],
            activePlaylist: playlist,
            searchText: "desert",
            sortOrder: .name,
            shuffledIDs: nil
        )

        // Then
        #expect(queue.map(\.id) == [included.id])
    }

    private func item(named title: String, duration: TimeInterval, rating: Int) -> PlaylistItem {
        PlaylistItem(
            fileURL: URL(fileURLWithPath: "/tmp/\(title).mod"),
            metadata: ["title": title, "duration": String(duration)],
            rating: rating
        )
    }

    private func item(named title: String, folder: String, fileExtension: String) -> PlaylistItem {
        PlaylistItem(
            fileURL: URL(fileURLWithPath: "/tmp/\(folder)/\(title).\(fileExtension)"),
            metadata: ["title": title]
        )
    }
}
