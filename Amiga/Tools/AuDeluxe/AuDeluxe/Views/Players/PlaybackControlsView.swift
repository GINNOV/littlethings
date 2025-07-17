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
        VStack(spacing: 8) {
            // --- Slider & Time ---
            HStack(spacing: 8) {
                Text(formatTime(engine.currentPlaybackTime))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)

                Slider(value: Binding(
                    get: { engine.currentPlaybackTime },
                    set: { newTime in
                        Task { await engine.seek(to: newTime) }
                    }),
                       in: 0...(engine.currentSongDuration > 0 ? engine.currentSongDuration : 1))
                    .disabled(!engine.isPlaying)

                Text(formatTime(engine.currentSongDuration))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .trailing)
            }

            // --- Buttons ---
            HStack(spacing: 20) {
                // Shuffle Button
                Button(action: {
                    Task { await engine.toggleShuffle(selectionID: selectedFileID) }
                }) {
                    Image(systemName: "shuffle")
                        .font(.title2)
                }
                .foregroundColor(engine.isShuffling ? .accentColor : .secondary)

                Spacer()

                // Main Controls
                HStack(spacing: 40) {
                    Button(action: playPrevious) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                    }
                    .disabled(currentItemIndex == nil || currentItemIndex == 0)

                    Button(action: handlePlayPause) {
                        Image(systemName: engine.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 44)) // Larger central button
                    }
                    .disabled(selectedFileID == nil && !engine.isPlaying)
                    .keyboardShortcut(.space, modifiers: [])
                    .foregroundColor(engine.isPlaying ? .red : .primary)

                    Button(action: playNext) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                    }
                    .disabled(currentItemIndex == nil || currentItemIndex == engine.playlistItems.count - 1)
                }
                
                Spacer()

                // Repeat Button
                Button(action: {
                    Task { await engine.toggleLooping() }
                }) {
                    Image(systemName: "repeat")
                        .font(.title2)
                }
                .foregroundColor(engine.isLooping ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 5)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
        .background(.regularMaterial)
    }
    
    private func handlePlayPause() {
        Task {
            guard let selectedItem = engine.playlistItems.first(where: { $0.id == selectedFileID }),
                  let musicURL = settings.musicFolderURL else {
                if engine.isPlaying { await engine.pause() }
                return
            }

            if engine.isPlaying {
                await engine.pause()
            } else {
                if selectedItem.fileURL == engine.currentlyPlayingFileURL {
                    await engine.resume()
                } else {
                    await engine.play(fileURL: selectedItem.fileURL, musicFolderURL: musicURL)
                }
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
