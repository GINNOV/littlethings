//
//  MenuBarView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 8/18/25.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var engine: OpenMPTEngine
    @EnvironmentObject private var settings: SettingsStore
    
    // This needs to be coordinated with the main ContentView
    @Binding var selectedFileID: PlaylistItem.ID?
    
    var body: some View {
        VStack(spacing: 15) {
            Text(engine.currentSongInfo ?? "AuDeluxe")
                .font(.headline)
                .lineLimit(1)
            
            if let details = engine.songDetails, !details.trimmingCharacters(in: .whitespaces).isEmpty {
                Text(details)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Button(action: { handlePlayPause(engine: engine, settings: settings, selectedFileID: selectedFileID) }) {
                Image(systemName: engine.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title)
            }
            .buttonStyle(.plain)
            .disabled(selectedFileID == nil && !engine.isPlaying)
            
            Divider()
            
            Button("Quit AuDeluxe") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
            
        }
        .padding()
        .frame(minWidth: 250)
    }
}
