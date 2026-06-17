import Foundation

enum ROMCategory: String, CaseIterable, Identifiable, Hashable, Sendable {
    case kickstart
    case extendedROM = "extended-rom"
    case bootROM = "boot-rom"
    case bootstrap
    case cartridges
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .kickstart: "Kickstart"
        case .extendedROM: "Extended ROM"
        case .bootROM: "Boot ROM"
        case .bootstrap: "Bootstrap"
        case .cartridges: "Cartridges"
        case .other: "Other"
        }
    }

    var subtitle: String {
        switch self {
        case .kickstart: "Operating system firmware"
        case .extendedROM: "CDTV, CD32 & A570 media ROMs"
        case .bootROM: "Early A3000 boot loaders"
        case .bootstrap: "A1000 WCS bootstrap"
        case .cartridges: "Hardware expansion ROMs"
        case .other: "Uncategorized firmware"
        }
    }

    var symbolName: String {
        switch self {
        case .kickstart: "cpu"
        case .extendedROM: "opticaldisc"
        case .bootROM: "power"
        case .bootstrap: "arrow.triangle.branch"
        case .cartridges: "memorychip"
        case .other: "questionmark.folder"
        }
    }

    var accentHue: Double {
        switch self {
        case .kickstart: 0.08
        case .extendedROM: 0.58
        case .bootROM: 0.45
        case .bootstrap: 0.72
        case .cartridges: 0.32
        case .other: 0.0
        }
    }

    static func from(path: String) -> ROMCategory {
        let first = path.split(separator: "/").first.map(String.init) ?? ""
        return ROMCategory(rawValue: first) ?? .other
    }
}