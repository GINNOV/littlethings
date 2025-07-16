//
//  PlaylistItem.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import Foundation

// A struct to hold metadata for each item in the playlist.
// Defining it in its own file makes it accessible across the entire app.
struct PlaylistItem: Identifiable, Hashable {
    let id = UUID()
    let fileURL: URL
    let title: String
    let artist: String
    let duration: TimeInterval
    var rating: Int = 0
}
