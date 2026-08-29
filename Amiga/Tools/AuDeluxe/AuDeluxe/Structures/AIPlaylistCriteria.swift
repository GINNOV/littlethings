import Foundation

struct AIPlaylistCriteria: Equatable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case titleTerms
        case artistTerms
        case folderTerms
        case fileTypes
        case minimumDuration
        case maximumDuration
        case minimumRating
        case limit
    }

    let name: String
    let titleTerms: [String]
    let artistTerms: [String]
    let folderTerms: [String]
    let fileTypes: [String]
    let minimumDuration: TimeInterval?
    let maximumDuration: TimeInterval?
    let minimumRating: Int?
    let limit: Int

    init(
        name: String,
        titleTerms: [String] = [],
        artistTerms: [String] = [],
        folderTerms: [String] = [],
        fileTypes: [String] = [],
        minimumDuration: TimeInterval? = nil,
        maximumDuration: TimeInterval? = nil,
        minimumRating: Int? = nil,
        limit: Int = 25
    ) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = cleanName.isEmpty ? "AI Playlist" : cleanName
        self.titleTerms = titleTerms.filter { $0.isEmpty == false }
        self.artistTerms = artistTerms.filter { $0.isEmpty == false }
        self.folderTerms = folderTerms.filter { $0.isEmpty == false }
        self.fileTypes = fileTypes.map { $0.uppercased() }.filter { $0.isEmpty == false }
        self.minimumDuration = minimumDuration
        self.maximumDuration = maximumDuration
        self.minimumRating = minimumRating.map { min(max($0, 0), 5) }
        self.limit = min(max(limit, 1), 100)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try values.decodeIfPresent(String.self, forKey: .name) ?? "AI Playlist",
            titleTerms: try values.decodeIfPresent([String].self, forKey: .titleTerms) ?? [],
            artistTerms: try values.decodeIfPresent([String].self, forKey: .artistTerms) ?? [],
            folderTerms: try values.decodeIfPresent([String].self, forKey: .folderTerms) ?? [],
            fileTypes: try values.decodeIfPresent([String].self, forKey: .fileTypes) ?? [],
            minimumDuration: try values.decodeIfPresent(TimeInterval.self, forKey: .minimumDuration),
            maximumDuration: try values.decodeIfPresent(TimeInterval.self, forKey: .maximumDuration),
            minimumRating: try values.decodeIfPresent(Int.self, forKey: .minimumRating),
            limit: try values.decodeIfPresent(Int.self, forKey: .limit) ?? 25
        )
    }

    static func decodeModelResponse(_ response: String) throws -> AIPlaylistCriteria {
        guard let openingBrace = response.firstIndex(of: "{"),
              let closingBrace = response.lastIndex(of: "}"),
              openingBrace <= closingBrace else {
            throw AIPlaylistError.invalidResponse
        }
        let json = response[openingBrace...closingBrace]
        do {
            return try JSONDecoder().decode(AIPlaylistCriteria.self, from: Data(json.utf8))
        } catch {
            throw AIPlaylistError.invalidResponse
        }
    }
}
