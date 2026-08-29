import Foundation

enum AIPlaylistPrompt {
    static func make(request: String, items: [PlaylistItem]) -> String {
        let folders = facets(items.map(\.folderName))
        let artists = facets(items.map(\.artist).filter { $0.isEmpty == false })
        let fileTypes = facets(items.map(\.fileType))
        return """
        Turn the user's playlist request into JSON filtering criteria for an indexed Amiga music library.
        Return only one JSON object with these keys: name (string), titleTerms (string array), artistTerms (string array), folderTerms (string array), fileTypes (string array), minimumDuration (seconds or null), maximumDuration (seconds or null), minimumRating (0 through 5 or null), limit (1 through 100).
        Terms within one array are alternatives. Different populated fields are combined. Use empty arrays and null when a filter was not requested. Do not invent a filter merely to fill a field.
        Available formats: \(fileTypes)
        Available folders: \(folders)
        Known artists: \(artists)
        User request: \(request)
        """
    }

    private static func facets(_ values: [String]) -> String {
        Array(Set(values)).sorted().prefix(200).joined(separator: ", ")
    }
}
