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
        List(selection: $selectedFileID) {
            Section(header: HStack {
                Text("Title")
                Spacer()
                Text("Rating")
                Text("Duration")
            }.font(.caption.weight(.semibold))) {
                ForEach(engine.playlistItems, id: \.id) { item in
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
                        HStack {
                            ForEach(0..<item.rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                            }
                        }
                        .foregroundColor(.yellow)
                        Text(formatTime(item.duration))
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    .tag(item.id)
                    .contentShape(Rectangle()) // Defines the hit-test area for the entire row.
                    .simultaneousGesture( // Use simultaneous to avoid conflicts with List's selection.
                        TapGesture(count: 2).onEnded {
                            selectedFileID = item.id
                            play(item: item)
                        }
                    )
                }
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
    }
    
    private func play(item: PlaylistItem) {
        Task {
            guard let musicURL = settings.musicFolderURL else { return }
            await engine.play(fileURL: item.fileURL, musicFolderURL: musicURL)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
