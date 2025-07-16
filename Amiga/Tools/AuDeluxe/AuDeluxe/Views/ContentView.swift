//
//  ContentView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/15/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var engine: OpenMPTEngine
    @EnvironmentObject private var settings: SettingsStore
    
    // State for the playlist selection and dialogs is managed here.
    @State private var selectedFileID: PlaylistItem.ID?
    @State private var isShowingDeleteAlert = false
    @State private var fileToDelete: PlaylistItem?

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            if settings.musicFolderURL != nil {
                PlaylistView(selectedFileID: $selectedFileID)
            } else {
                SetupPromptView()
            }
            
            PlaybackControlsView(selectedFileID: $selectedFileID)
        }
        .frame(minWidth: 550, minHeight: 450)
        .onAppear(perform: scanMusicFolder)
        .onChange(of: settings.musicFolderURL) { scanMusicFolder() }
        .toolbar {
            ToolbarItems(
                selectedFileID: $selectedFileID,
                isShowingDeleteAlert: $isShowingDeleteAlert,
                fileToDelete: $fileToDelete
            )
        }
        .alert("Delete File", isPresented: $isShowingDeleteAlert, presenting: fileToDelete) { file in
            Button("Delete", role: .destructive) { deleteFile(item: file) }
            Button("Cancel", role: .cancel) {}
        } message: { file in
            Text("Are you sure you want to delete '\(file.title)'? This action cannot be undone.")
        }
    }

    // MARK: - Logic
    private func scanMusicFolder() {
        guard let url = settings.musicFolderURL else {
            engine.playlistItems = []
            return
        }
        Task { await engine.scanMusicFolder(for: url) }
    }
    
    private func deleteFile(item: PlaylistItem) {
        do {
            try FileManager.default.trashItem(at: item.fileURL, resultingItemURL: nil)
            scanMusicFolder() // Refresh the list
        } catch {
            print("Error deleting file: \(error)")
        }
    }
}

// MARK: - Subviews in separate files

struct HeaderView: View {
    @EnvironmentObject private var engine: OpenMPTEngine

    var body: some View {
        VStack {
            Text("AuDeluxe").font(.largeTitle).fontWeight(.thin)
            Text(engine.currentSongInfo ?? "Select a song to play").font(.headline).foregroundColor(.secondary).lineLimit(1)
            Text(engine.songDetails ?? " ").font(.caption).foregroundColor(.secondary).padding(.top, 1)
        }.padding()
    }
}

struct SetupPromptView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "music.note.house").font(.system(size: 60)).foregroundColor(.secondary)
            Text("No Music Folder Selected").font(.title2)
            Text("Please select your music folder in Settings (Cmd+,).").padding(.bottom)
            Spacer()
        }
    }
}
