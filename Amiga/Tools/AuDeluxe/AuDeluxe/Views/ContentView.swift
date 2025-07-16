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
    @State private var isShowingRenameAlert = false
    @State private var fileToRename: PlaylistItem?
    
    // State to manage sheets and view switching
    @State private var isShowingAboutSheet = false
    @State private var fileToInspect: PlaylistItem?
    @State private var isShowingInspectorSheet = false // Kept for compatibility with ToolbarItems
    @State private var showingTrackerView = false


    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // The tracker toggle is now part of the HeaderView
                HeaderView(showingTrackerView: $showingTrackerView)
                
                if settings.musicFolderURL != nil {
                    // Switch between Playlist and Tracker view
                    if showingTrackerView {
                        TrackerView()
                    } else {
                        PlaylistView(selectedFileID: $selectedFileID)
                    }
                } else {
                    SetupPromptView()
                }
                
                PlaybackControlsView(selectedFileID: $selectedFileID)
            }
            .frame(minWidth: 550, minHeight: 450)
            .onAppear(perform: scanMusicFolder)
            .onChange(of: settings.musicFolderURL) { scanMusicFolder() }
            .toolbar {
                // Corrected the parameters to match what the compiler expects
                ToolbarItems(
                    selectedFileID: $selectedFileID,
                    isShowingDeleteAlert: $isShowingDeleteAlert,
                    fileToDelete: $fileToDelete,
                    isShowingRenameAlert: $isShowingRenameAlert,
                    fileToRename: $fileToRename,
                    isShowingAboutSheet: $isShowingAboutSheet,
                    isShowingInspectorSheet: $isShowingInspectorSheet,
                    fileToInspect: $fileToInspect
                )
            }
            .sheet(isPresented: $isShowingAboutSheet) {
                AboutView(closeAction: {
                    isShowingAboutSheet = false
                })
            }
            // Corrected sheet presentation to use the item binding
            .sheet(item: $fileToInspect) { item in
                InspectorView(item: item)
            }

            if isShowingDeleteAlert, let fileToDelete = fileToDelete {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                DialogDeleteFile(
                    file: fileToDelete,
                    isPresented: $isShowingDeleteAlert,
                    onDelete: { deleteFile(item: fileToDelete) }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
            
            if isShowingRenameAlert, let fileToRename = fileToRename {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                DialogRenameFile(
                    file: fileToRename,
                    isPresented: $isShowingRenameAlert,
                    onSave: { newTitle, newArtist, newFilename in
                        updateFile(item: fileToRename, newTitle: newTitle, newArtist: newArtist, newFilename: newFilename)
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.spring(), value: isShowingDeleteAlert || isShowingRenameAlert)
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
        guard let musicFolderURL = settings.musicFolderURL else {
            print("Error deleting file: Music folder URL is not available.")
            return
        }
        
        guard musicFolderURL.startAccessingSecurityScopedResource() else {
            print("Error deleting file: Could not gain access to the music folder for deletion.")
            return
        }
        defer { musicFolderURL.stopAccessingSecurityScopedResource() }

        do {
            try FileManager.default.trashItem(at: item.fileURL, resultingItemURL: nil)
            scanMusicFolder() // Refresh the list
        } catch {
            print("Error deleting file: \(error)")
        }
    }
    
    private func updateFile(item: PlaylistItem, newTitle: String, newArtist: String, newFilename: String) {
        guard let musicFolderURL = settings.musicFolderURL else {
            print("Error updating file: Music folder URL is not available.")
            return
        }

        let fileExtension = item.fileURL.pathExtension
        let newURL = item.fileURL.deletingLastPathComponent()
                                 .appendingPathComponent(newFilename)
                                 .appendingPathExtension(fileExtension)

        Task {
            let success = await engine.updateFile(from: item.fileURL, to: newURL, newTitle: newTitle, newArtist: newArtist, musicFolderURL: musicFolderURL)
            if success {
                await engine.scanMusicFolder(for: musicFolderURL)
            }
        }
    }
}

// MARK: - Subviews in separate files

struct HeaderView: View {
    @EnvironmentObject private var engine: OpenMPTEngine
    @Binding var showingTrackerView: Bool // Binding to control view state

    var body: some View {
        VStack {
            HStack {
                Text("AuDeluxe").font(.largeTitle).fontWeight(.thin)
                Spacer()
                // Button to toggle between Playlist and Tracker view
                Button(action: { showingTrackerView.toggle() }) {
                    Label(showingTrackerView ? "Playlist" : "Tracker", systemImage: showingTrackerView ? "list.bullet" : "pianokeys")
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 8)
            }
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
