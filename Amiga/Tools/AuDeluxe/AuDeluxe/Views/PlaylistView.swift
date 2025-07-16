//
//  PlaylistView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct PlaylistView: View {
    @EnvironmentObject private var engine: OpenMPTEngine
    @EnvironmentObject private var settings: SettingsStore
    
    @Binding var selectedFileID: PlaylistItem.ID?

    var body: some View {
        // FIX: Use the engine's playlistItems directly.
        List(engine.playlistItems, id: \.id, selection: $selectedFileID) { item in
            HStack {
                VStack(alignment: .leading) {
                    Text(item.title)
                        .fontWeight(item.id == selectedFileID ? .bold : .regular)
                        .foregroundColor(item.fileURL.lastPathComponent == engine.currentSongInfo ? .accentColor : .primary)
                    if !item.artist.isEmpty {
                        Text(item.artist)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text(formatTime(item.duration))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
