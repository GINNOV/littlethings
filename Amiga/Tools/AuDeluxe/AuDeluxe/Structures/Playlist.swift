//
//  Playlist.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/18/25.
//

import Foundation

// A simple structure to represent a custom playlist.
// It's Codable so we can easily save it to UserDefaults.
struct Playlist: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var fileURLs: [URL]
}
