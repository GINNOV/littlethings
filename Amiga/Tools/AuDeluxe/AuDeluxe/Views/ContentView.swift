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
    @State private var showingTrackerView = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView()
                
                if settings.musicFolderURL != nil {
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
                // This call now correctly matches the ToolbarItems definition
                ToolbarItems(
                    selectedFileID: $selectedFileID,
                    isShowingDeleteAlert: $isShowingDeleteAlert,
                    fileToDelete: $fileToDelete,
                    isShowingRenameAlert: $isShowingRenameAlert,
                    fileToRename: $fileToRename,
                    isShowingAboutSheet: $isShowingAboutSheet,
                    fileToInspect: $fileToInspect,
                    showingTrackerView: $showingTrackerView
                )
            }
            .sheet(isPresented: $isShowingAboutSheet) {
                AboutView(closeAction: {
                    isShowingAboutSheet = false
                })
            }
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
                        Task {
                            await updateFile(item: fileToRename, newTitle: newTitle, newArtist: newArtist, newFilename: newFilename)
                        }
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
    
    private func updateFile(item: PlaylistItem, newTitle: String, newArtist: String, newFilename: String) async {
        guard let musicFolderURL = settings.musicFolderURL else {
            print("Error updating file: Music folder URL is not available.")
            return
        }

        let fileExtension = item.fileURL.pathExtension
        let newURL = item.fileURL.deletingLastPathComponent()
                                 .appendingPathComponent(newFilename)
                                 .appendingPathExtension(fileExtension)

        let success = await engine.updateFile(from: item.fileURL, to: newURL, newTitle: newTitle, newArtist: newArtist, musicFolderURL: musicFolderURL)
        if success {
            await engine.scanMusicFolder(for: musicFolderURL)
        }
    }
}

// MARK: - Subviews in separate files

struct HeaderView: View {
    @EnvironmentObject private var engine: OpenMPTEngine

    var body: some View {
        HStack {
            Image("screamer")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .padding(.leading)
            
            Spacer()
            
            VStack {
                Text("AuDeluxe").font(.largeTitle).fontWeight(.thin)
                Text(engine.currentSongInfo ?? "Select a song to play").font(.headline).foregroundColor(.secondary).lineLimit(1)
                Text(engine.songDetails ?? " ").font(.caption).foregroundColor(.secondary).padding(.top, 1)
            }
            
            Spacer()
            
            // This invisible view is used to balance the one on the left
            // ensuring the VStack above remains perfectly centered.
            Rectangle()
                .fill(Color.clear)
                .frame(width: 64, height: 64)
                .padding(.trailing)

        }
        .padding(.vertical, 8)
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
