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
    
    @Binding var selectedFileID: PlaylistItem.ID?
    
    private var currentItemIndex: Int? {
        guard let selectedID = selectedFileID else { return nil }
        return engine.playlistItems.firstIndex(where: { $0.id == selectedID })
    }
    
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
            
            HStack(spacing: 30) {
                Button(action: playPrevious) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .disabled(currentItemIndex == nil || currentItemIndex == 0)

                Button(action: { handlePlayPause(engine: engine, settings: settings, selectedFileID: selectedFileID) }) {
                    Image(systemName: engine.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                .tint(.green)
                .disabled(selectedFileID == nil && !engine.isPlaying)
                
                Button(action: playNext) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .disabled(currentItemIndex == nil || currentItemIndex == engine.playlistItems.count - 1)
            }
            .buttonStyle(.plain)

            Divider()

            Button("Show AuDeluxe", systemImage: "macwindow", action: DockVisibilityController.shared.showMainWindow)

            Divider()
            
            Button("Quit AuDeluxe") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
            
        }
        .padding()
        .frame(minWidth: 300)
    }
    
    private func playNext() {
        Task {
            guard let index = currentItemIndex,
                  index + 1 < engine.playlistItems.count,
                  let musicURL = settings.musicFolderURL else { return }
            
            let nextItem = engine.playlistItems[index + 1]
            selectedFileID = nextItem.id
            await engine.play(fileURL: nextItem.fileURL, musicFolderURL: musicURL)
        }
    }
    
    private func playPrevious() {
        Task {
            guard let index = currentItemIndex,
                  index > 0,
                  let musicURL = settings.musicFolderURL else { return }
            
            let prevItem = engine.playlistItems[index - 1]
            selectedFileID = prevItem.id
            await engine.play(fileURL: prevItem.fileURL, musicFolderURL: musicURL)
        }
    }
}
