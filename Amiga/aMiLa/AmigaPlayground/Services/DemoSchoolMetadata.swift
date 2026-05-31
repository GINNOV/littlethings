import Foundation

struct DemoSchoolMetadata: Codable, Equatable {
    var difficulty: String
    var stage: String
    var language: String
    var effectType: String
    var hardware: [String]
    var concepts: [String]
    var value: [String]
    var status: String
    var dependencies: [String]

    init(
        difficulty: String = "Draft",
        stage: String = "Custom",
        language: String = "ASM",
        effectType: String = "None",
        hardware: [String] = [],
        concepts: [String] = [],
        value: [String] = [],
        status: String = "Draft",
        dependencies: [String] = []
    ) {
        self.difficulty = difficulty
        self.stage = stage
        self.language = language
        self.effectType = effectType
        self.hardware = hardware
        self.concepts = concepts
        self.value = value
        self.status = status
        self.dependencies = dependencies
    }

    private enum CodingKeys: String, CodingKey {
        case difficulty, stage, language, effectType, hardware, concepts, value, status, dependencies
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        difficulty = try container.decodeIfPresent(String.self, forKey: .difficulty) ?? "Draft"
        stage = try container.decodeIfPresent(String.self, forKey: .stage) ?? "Custom"
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? "ASM"
        effectType = try container.decodeIfPresent(String.self, forKey: .effectType) ?? "None"
        hardware = try container.decodeIfPresent([String].self, forKey: .hardware) ?? []
        concepts = try container.decodeIfPresent([String].self, forKey: .concepts) ?? []
        value = try container.decodeIfPresent([String].self, forKey: .value) ?? []
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "Draft"
        dependencies = try container.decodeIfPresent([String].self, forKey: .dependencies) ?? []
    }

    var searchableText: String {
        ([difficulty, stage, language, effectType, status] + hardware + concepts + value + dependencies)
            .joined(separator: " ")
    }

    var visibleTags: [String] {
        var tags = [difficulty, stage, language, effectType, status]
        tags.append(contentsOf: hardware)
        tags.append(contentsOf: concepts.prefix(3))
        tags.append(contentsOf: value)
        return orderedUnique(tags.compactMap { tag in
            let cleaned = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleaned.isEmpty ? nil : cleaned
        })
    }

    private func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        var unique: [String] = []
        for value in values {
            let key = value.lowercased()
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            unique.append(value)
        }
        return unique
    }
}

enum DemoSchoolFilterOptions {
    static let difficulties = ["All", "Beginner", "Intermediate", "Advanced", "Showcase"]
    static let stages = ["All", "Foundations", "System", "Custom Chips", "Copper", "Display", "Blitter", "Sprites", "Audio", "Math", "Effects", "C Integration", "Showcase"]
    static let languages = ["All", "ASM", "C", "C + ASM"]
    static let effectTypes = ["All", "None", "Reference", "System", "Raster Bars", "Bitplane", "Blitter", "Sprite Logo", "Audio", "Scroller", "Starfield", "Plasma", "Twister", "Rotozoom", "Parallax", "Logo", "Menu", "Megamix"]
    static let hardware = ["All", "Exec", "Copper", "Bitplanes", "Blitter", "Sprites", "Paula", "CIA", "Math"]
    static let statuses = ["All", "Verified", "Draft", "Needs VASM", "Needs Emulator"]
}

struct DemoSchoolLibraryFilter: Equatable {
    var searchText = ""
    var difficulty = "All"
    var stage = "All"
    var language = "All"
    var effectType = "All"
    var hardware = "All"
    var status = "All"
    var verifiedOnly = false
    var includesLanguage = true

    func matches(name: String, body: String, metadata: DemoSchoolMetadata, language itemLanguage: String? = nil) -> Bool {
        matchesSearch(name: name, body: body, metadata: metadata) &&
            matchesExact(difficulty, metadata.difficulty) &&
            matchesExact(stage, metadata.stage) &&
            matchesLanguage(itemLanguage ?? metadata.language) &&
            matchesExact(effectType, metadata.effectType) &&
            matchesHardware(metadata.hardware) &&
            matchesExact(status, metadata.status) &&
            matchesVerified(metadata.status)
    }

    private func matchesSearch(name: String, body: String, metadata: DemoSchoolMetadata) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }

        return name.localizedCaseInsensitiveContains(query) ||
            body.localizedCaseInsensitiveContains(query) ||
            metadata.searchableText.localizedCaseInsensitiveContains(query)
    }

    private func matchesLanguage(_ itemLanguage: String) -> Bool {
        !includesLanguage || matchesExact(language, itemLanguage)
    }

    private func matchesHardware(_ itemHardware: [String]) -> Bool {
        hardware == "All" || itemHardware.contains { $0.localizedCaseInsensitiveCompare(hardware) == .orderedSame }
    }

    private func matchesVerified(_ itemStatus: String) -> Bool {
        !verifiedOnly || itemStatus == "Verified"
    }

    private func matchesExact(_ filterValue: String, _ itemValue: String) -> Bool {
        filterValue == "All" || itemValue == filterValue
    }
}
