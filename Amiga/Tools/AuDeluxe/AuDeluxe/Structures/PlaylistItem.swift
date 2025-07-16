//
//  PlaylistItem.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import Foundation

struct PlaylistItem: Identifiable, Hashable {
    let id = UUID()
    let fileURL: URL
    var metadata: [String: String]
    var rating: Int = 0

    // Computed properties for easy access to common metadata
    var title: String {
        metadata["title"] ?? fileURL.deletingPathExtension().lastPathComponent
    }

    var artist: String {
        metadata["artist"] ?? ""
    }

    var duration: TimeInterval {
        Double(metadata["duration"] ?? "0") ?? 0
    }
}
