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

    private var currentItemIndex: Int? {
        guard let selectedID = selectedFileID else { return nil }
        return engine.playlistItems.firstIndex(where: { $0.id == selectedID })
    }

    var body: some View {
        VStack(spacing: 5) {
            Slider(value: Binding(
                get: { engine.currentPlaybackTime },
                set: { newTime in
                    // Wrap the async call in a Task
                    Task {
                        await engine.seek(to: newTime)
                    }
                }),
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
                Button(action: playPrevious) {
                    Image(systemName: "backward.fill").font(.title2)
                }
                .disabled(currentItemIndex == nil || currentItemIndex == 0)
                
                Button(action: handlePlayPause) {
                    Image(systemName: engine.isPlaying ? "pause.fill" : "play.fill").font(.largeTitle)
                }
                .disabled(selectedFileID == nil && !engine.isPlaying)
                
                Button(action: playNext) {
                    Image(systemName: "forward.fill").font(.title2)
                }
                .disabled(currentItemIndex == nil || currentItemIndex == engine.playlistItems.count - 1)
                
                Spacer()
                
                Button(action: {
                    // Wrap the async call in a Task
                    Task {
                        await engine.toggleLooping()
                    }
                }) {
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
        // Wrap the async calls in a Task
        Task {
            if engine.isPlaying {
                await engine.stop()
            } else if let selectedItem = engine.playlistItems.first(where: { $0.id == selectedFileID }),
                      let musicURL = settings.musicFolderURL {
                await engine.play(fileURL: selectedItem.fileURL, musicFolderURL: musicURL)
            }
        }
    }
    
    private func playNext() {
        // Wrap the async call in a Task
        Task {
            guard let index = currentItemIndex,
                  index + 1 < engine.playlistItems.count,
                  let musicURL = settings.musicFolderURL else { return }
            
            let nextItem = engine.playlistItems[index + 1]
            selectedFileID = nextItem.id // Update selection
            await engine.play(fileURL: nextItem.fileURL, musicFolderURL: musicURL)
        }
    }
    
    private func playPrevious() {
        // Wrap the async call in a Task
        Task {
            guard let index = currentItemIndex,
                  index > 0,
                  let musicURL = settings.musicFolderURL else { return }
            
            let prevItem = engine.playlistItems[index - 1]
            selectedFileID = prevItem.id // Update selection
            await engine.play(fileURL: prevItem.fileURL, musicFolderURL: musicURL)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
