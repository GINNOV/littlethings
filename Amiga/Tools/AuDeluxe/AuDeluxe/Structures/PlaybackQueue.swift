import Foundation

enum PlaybackQueue {
    static func make(
        items: [PlaylistItem],
        activePlaylist: Playlist?,
        searchText: String,
        sortOrder: SortOrder,
        shuffledIDs: [PlaylistItem.ID]?
    ) -> [PlaylistItem] {
        let playlistURLs = activePlaylist.map { Set($0.fileURLs) }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let filteredItems = items.filter { item in
            let belongsToPlaylist = playlistURLs?.contains(item.fileURL) ?? true
            let matchesSearch = query.isEmpty
                || item.title.localizedCaseInsensitiveContains(query)
                || item.artist.localizedCaseInsensitiveContains(query)
            return belongsToPlaylist && matchesSearch
        }

        guard let shuffledIDs else {
            return sort(filteredItems, by: sortOrder)
        }

        let itemsByID = Dictionary(uniqueKeysWithValues: filteredItems.map { ($0.id, $0) })
        let shuffledIDSet = Set(shuffledIDs)
        let shuffledItems = shuffledIDs.compactMap { itemsByID[$0] }
        let newItems = filteredItems.filter { !shuffledIDSet.contains($0.id) }
        return shuffledItems + sort(newItems, by: sortOrder)
    }

    private static func sort(_ items: [PlaylistItem], by order: SortOrder) -> [PlaylistItem] {
        switch order {
        case .name:
            items.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .duration:
            items.sorted { $0.duration < $1.duration }
        case .rating:
            items.sorted { $0.rating > $1.rating }
        case .folder:
            items.sorted {
                let comparison = $0.folderName.localizedCaseInsensitiveCompare($1.folderName)
                return comparison == .orderedSame
                    ? $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                    : comparison == .orderedAscending
            }
        case .fileType:
            items.sorted {
                let comparison = $0.fileType.localizedCaseInsensitiveCompare($1.fileType)
                return comparison == .orderedSame
                    ? $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                    : comparison == .orderedAscending
            }
        }
    }
}
