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
    @State private var isShowingManagePlaylists = false
    @State private var isShowingSelectPlaylist = false
    
    @State private var scrollToSongID: PlaylistItem.ID?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView {
                    if engine.isPlaying, let currentID = selectedFileID {
                        if showingTrackerView {
                            showingTrackerView = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                scrollToSongID = currentID
                            }
                        } else {
                            scrollToSongID = currentID
                        }
                    }
                }
                
                if settings.musicFolderURL != nil {
                    if showingTrackerView {
                        TrackerView()
                            .onAppear { engine.isTrackerVisible = true }
                            .onDisappear { engine.isTrackerVisible = false }
                    } else {
                        ScrollViewReader { proxy in
                            PlaylistView(selectedFileID: $selectedFileID)
                                .searchable(text: $engine.searchText, prompt: "Search Songs or Artists")
                                .onChange(of: scrollToSongID) { _, newID in
                                    if let id = newID {
                                        withAnimation {
                                            proxy.scrollTo(id, anchor: .center)
                                        }
                                        scrollToSongID = nil
                                    }
                                }
                        }
                    }
                } else {
                    SetupPromptView()
                }
                
                PlaybackControlsView(selectedFileID: $selectedFileID)
            }
            .frame(minWidth: 550, minHeight: 450)
            .onAppear {
                engine.settingsStore = settings
                engine.sortOrder = settings.defaultSortOrder
                engine.onSongChange = { newID in
                    self.selectedFileID = newID
                }
                scanMusicFolder()
            }
            .onChange(of: settings.musicFolderURL) { scanMusicFolder() }
            .toolbar {
                ToolbarItems(
                    selectedFileID: $selectedFileID,
                    isShowingDeleteAlert: $isShowingDeleteAlert,
                    fileToDelete: $fileToDelete,
                    isShowingRenameAlert: $isShowingRenameAlert,
                    fileToRename: $fileToRename,
                    isShowingAboutSheet: $isShowingAboutSheet,
                    fileToInspect: $fileToInspect,
                    showingTrackerView: $showingTrackerView,
                    isShowingManagePlaylists: $isShowingManagePlaylists,
                    isShowingSelectPlaylist: $isShowingSelectPlaylist
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
            .sheet(isPresented: $isShowingManagePlaylists) {
                ManagePlaylistsView()
                    .environmentObject(settings)
                    .environmentObject(engine)
            }
            .sheet(isPresented: $isShowingSelectPlaylist) {
                SelectPlaylistView()
                    .environmentObject(settings)
                    .environmentObject(engine)
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
            engine.clearAllSongs()
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
            scanMusicFolder()
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
    var onTitleClick: (() -> Void)?

    private var statusText: String {
        if let songInfo = engine.currentSongInfo {
            return songInfo
        } else {
            if engine.allPlaylistItems.isEmpty {
                return "Select a music folder in Settings"
            } else {
                return "Select a song to play (out of \(engine.allPlaylistItems.count))"
            }
        }
    }

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
                
                Button(action: { onTitleClick?() }) {
                    Text(statusText)
                        .font(.headline)
                        .foregroundColor(engine.isPlaying ? .accentColor : .secondary)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
                .disabled(!engine.isPlaying)
                
                Text(engine.songDetails ?? " ").font(.caption).foregroundColor(.secondary).padding(.top, 1)
            }
            
            Spacer()
            
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
