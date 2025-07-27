//
//  DataStructures.swift
//  ADFinder
//
//  Created by Mario Esposito on 5/23/25.
//

import SwiftUI
import AppIntents

struct AmigaEntry: Identifiable, Hashable {
    let id: Int
    let name: String
    let type: EntryType
    let size: Int
    let date: Date
    let protection: String
    let comment: String
    let protectionBits: UInt32

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AmigaEntry, rhs: AmigaEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    enum EntryType: String {
        case file = "file"
        case directory = "dir"
        case link = "link"
        case unknown
    }
    
    var icon: NSImage {
        switch type {
        case .file:
            return NSImage(systemSymbolName: "doc", accessibilityDescription: "File") ?? NSImage()
        case .directory:
            return NSImage(systemSymbolName: "folder", accessibilityDescription: "Directory") ?? NSImage()
        default:
            return NSImage(systemSymbolName: "questionmark.diamond", accessibilityDescription: "Unknown") ?? NSImage()
        }
    }
    
    var sizeFormatted: String {
        guard type == .file else { return "--" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum SortOrder: String, CaseIterable, Identifiable {
    case nameAscending = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case sizeAscending = "Size (Smallest First)"
    case sizeDescending = "Size (Largest First)"
    
    var id: Self { self }
}

enum EntryType: String {
    case file = "File"
    case directory = "Directory"
    case softLinkFile = "Soft-Link File"
    case softLinkDir = "Soft-Link Dir"
    case unknown = "Unknown"
}

enum BootBlockType: String, AppEnum, CaseIterable, Identifiable {
    case generic = "Generic (No Bootblock)"
    case kick1_3 = "Kickstart 1.3 (OFS)"
    case kick2_0 = "Kickstart 2.0+ (FFS)"
    case sca = "SCA Bootblock"
    case bandit = "Bandit Bootblock"
    
    var id: Self { self }

    // Required by AppEnum for display in the Shortcuts app
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Boot Block Type"
    static var caseDisplayRepresentations: [BootBlockType: DisplayRepresentation] = [
        .generic: "Generic (No Bootblock)",
        .kick1_3: "Kickstart 1.3 (OFS)",
        .kick2_0: "Kickstart 2.0+ (FFS)",
        .sca: "SCA Bootblock",
        .bandit: "Bandit Bootblock"
    ]
}

enum FileSystem: String, CaseIterable, Identifiable {
    case ofs = "OFS (Original File System)"
    case ffs = "FFS (Fast File System)"
    
    var id: Self { self }
}
