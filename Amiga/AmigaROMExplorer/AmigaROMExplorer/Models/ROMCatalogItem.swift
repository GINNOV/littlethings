import Foundation

struct ROMCatalogItem: Identifiable, Hashable, Sendable {
    let manifest: ManifestEntry
    let parsed: ParsedROMMetadata
    let fileInfo: ROMFileInfo?

    var id: String { manifest.destination }

    var displayTitle: String { parsed.title }
    var displaySubtitle: String? { parsed.subtitle }
    var category: ROMCategory { parsed.category }
    var humanizedVariant: String { parsed.humanizedVariantLabel }
    var machines: [HardwareModel] { parsed.hardwareModels }
    var variantLabel: String { parsed.variantLabel }
    var versionLabel: String { parsed.versionLabel }
    var isOnDisk: Bool { fileInfo != nil }
}

struct ParsedROMMetadata: Hashable, Sendable {
    let category: ROMCategory
    let versionLabel: String
    let machinePath: String
    let variantLabel: String
    let title: String
    let subtitle: String?
    let hardwareTokens: [String]

    var humanizedVariantLabel: String {
        let lowered = variantLabel.lowercased()
        if ["standard", "common", "unknown"].contains(lowered) {
            return lowered.capitalized
        }
        return variantLabel
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    let hardwareModels: [HardwareModel]
    let publisher: String?
    let year: Int?
    let dumpQuality: DumpQuality
    let fileExtension: String

    enum DumpQuality: String, Sendable {
        case good
        case beta
        case developer
        case hack
        case modified
        case encrypted
        case overdump
        case badDump
        case unknown

        var label: String {
            switch self {
            case .good: "Verified Good"
            case .beta: "Beta"
            case .developer: "Developer"
            case .hack: "Hack / Crack"
            case .modified: "Modified"
            case .encrypted: "Encrypted"
            case .overdump: "Overdump"
            case .badDump: "Bad Dump"
            case .unknown: "Unknown"
            }
        }
    }
}

struct ROMFileInfo: Hashable, Sendable {
    let absolutePath: String
    let byteCount: Int
    let md5: String?
    let modifiedAt: Date?
}