//
//  PlaylistCache.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 8/17/25.
//

import Foundation

struct PlaylistCache: Codable {
    let folderModificationDate: Date
    let items: [PlaylistItem]
}
