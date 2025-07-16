//
//  PlaybackControlsView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct PlaybackControlsView: View {
    @EnvironmentObject private var engine: OpenMPTEngine
    @EnvironmentObject private var settings: SettingsStore
    
    @Binding var selectedFileID: PlaylistItem.ID?

    var body: some View {
        VStack(spacing: 5) {
            Slider(value: Binding(get: { engine.currentPlaybackTime }, set: { engine.seek(to: $0) }),
                   in: 0...(engine.currentSongDuration > 0 ? engine.currentSongDuration : 1))
                .disabled(!engine.isPlaying)
            
            HStack {
                Text(formatTime(engine.currentPlaybackTime))
                Spacer()
                Text(formatTime(engine.currentSongDuration))
            }
            .font(.caption.monospacedDigit())
            .foregroundColor(.secondary)
            
            HStack(spacing: 30) {
                Spacer()
                Button(action: { /* Previous song */ }) { Image(systemName: "backward.fill").font(.title2) }.disabled(true)
                
                Button(action: handlePlayPause) {
                    Image(systemName: engine.isPlaying ? "pause.fill" : "play.fill").font(.largeTitle)
                }
                .disabled(selectedFileID == nil && !engine.isPlaying)
                
                Button(action: { /* Next song */ }) { Image(systemName: "forward.fill").font(.title2) }.disabled(true)
                Spacer()
                
                Button(action: { engine.toggleLooping() }) {
                    Image(systemName: "repeat").font(.title2)
                        .foregroundColor(engine.isLooping ? .accentColor : .secondary)
                }
            }
            .padding(.top, 5)
        }
        .padding()
        .background(.regularMaterial)
    }
    
    private func handlePlayPause() {
        if engine.isPlaying {
            engine.stop()
        } else if let selectedItem = engine.playlistItems.first(where: { $0.id == selectedFileID }),
                  let musicURL = settings.musicFolderURL {
            engine.play(fileURL: selectedItem.fileURL, musicFolderURL: musicURL)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
