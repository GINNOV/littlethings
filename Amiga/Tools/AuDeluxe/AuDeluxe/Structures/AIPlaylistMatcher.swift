import Foundation

enum AIPlaylistMatcher {
    static func matches(in items: [PlaylistItem], criteria: AIPlaylistCriteria) -> [PlaylistItem] {
        items.lazy.filter { item in
            matches(item.title, terms: criteria.titleTerms)
                && matches(item.artist, terms: criteria.artistTerms)
                && matches(item.folderName, terms: criteria.folderTerms)
                && (criteria.fileTypes.isEmpty || criteria.fileTypes.contains(item.fileType))
                && (criteria.minimumDuration.map { item.duration >= $0 } ?? true)
                && (criteria.maximumDuration.map { item.duration <= $0 } ?? true)
                && (criteria.minimumRating.map { item.rating >= $0 } ?? true)
        }
        .prefix(criteria.limit)
        .map { $0 }
    }

    private static func matches(_ value: String, terms: [String]) -> Bool {
        terms.isEmpty || terms.contains { value.localizedStandardContains($0) }
    }
}
