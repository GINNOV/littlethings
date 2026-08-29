import Foundation

struct AIPlaylistDraft: Equatable {
    let criteria: AIPlaylistCriteria
    let items: [PlaylistItem]

    var playlist: Playlist {
        Playlist(name: criteria.name, fileURLs: items.map(\.fileURL))
    }
}
