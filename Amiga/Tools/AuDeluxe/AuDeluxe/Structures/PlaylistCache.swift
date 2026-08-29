//
//  PlaylistCache.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 8/17/25.
//

import Foundation

struct PlaylistCache: Codable {
    let metadataVersion: Int
    let fingerprint: LibraryFingerprint
    let items: [PlaylistItem]

    init(fingerprint: LibraryFingerprint, items: [PlaylistItem]) {
        metadataVersion = 2
        self.fingerprint = fingerprint
        self.items = items
    }
}
