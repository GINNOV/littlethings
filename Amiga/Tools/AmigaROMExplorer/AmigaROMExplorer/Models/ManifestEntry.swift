import Foundation

struct ManifestEntry: Identifiable, Hashable, Codable, Sendable {
    let source: String
    let destination: String
    let status: ManifestStatus

    var id: String { destination }

    enum ManifestStatus: String, Codable, Sendable {
        case moved
        case duplicateSameContent = "duplicate-same-content"
        case missing
        case unknown

        init(raw: String) {
            self = ManifestStatus(rawValue: raw) ?? .unknown
        }

        var label: String {
            switch self {
            case .moved: "Installed"
            case .duplicateSameContent: "Duplicate"
            case .missing: "Missing"
            case .unknown: "Unknown"
            }
        }
    }
}