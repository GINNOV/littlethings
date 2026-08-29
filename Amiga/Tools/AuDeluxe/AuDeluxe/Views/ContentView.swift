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
    @Binding var selectedFileID: PlaylistItem.ID?
    
    @State private var isShowingDeleteAlert = false
    @State private var fileToDelete: PlaylistItem?
    @State private var isShowingRenameAlert = false
    @State private var fileToRename: PlaylistItem?
    
    // State to manage sheets and view switching
    @State private var fileToInspect: PlaylistItem?
    @State private var showingTrackerView = false
    @State private var isShowingManagePlaylists = false
    @State private var isShowingSelectPlaylist = false
    
    @State private var scrollToSongID: PlaylistItem.ID?
    @State private var didApplyStartupPlayback = false

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

                LibraryScanStatusView()
                
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
                engine.onLibraryReady = startConfiguredPlaylist
                scanMusicFolder()
            }
            .onChange(of: settings.musicFolderURL) { scanMusicFolder() }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didMiniaturizeNotification)) { notification in
                DockVisibilityController.shared.handleMinimize(notification, enabled: settings.hideDockIconWhenMinimized)
            }
            .toolbar {
                ToolbarItems(
                    selectedFileID: $selectedFileID,
                    isShowingDeleteAlert: $isShowingDeleteAlert,
                    fileToDelete: $fileToDelete,
                    isShowingRenameAlert: $isShowingRenameAlert,
                    fileToRename: $fileToRename,
                    fileToInspect: $fileToInspect,
                    showingTrackerView: $showingTrackerView,
                    isShowingManagePlaylists: $isShowingManagePlaylists,
                    isShowingSelectPlaylist: $isShowingSelectPlaylist
                )
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
        .alert(item: $engine.presentedError) { error in
            Alert(
                title: Text("AuDeluxe Couldn’t Complete the Operation"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Logic
    private func scanMusicFolder() {
        engine.requestMusicFolderScan(for: settings.musicFolderURL)
    }

    private func startConfiguredPlaylist() {
        guard !didApplyStartupPlayback,
              settings.playPlaylistOnLaunch,
              let playlist = settings.startupPlaylist,
              let item = engine.allPlaylistItems.first(where: { playlist.fileURLs.contains($0.fileURL) }),
              let musicFolderURL = settings.musicFolderURL else { return }

        didApplyStartupPlayback = true
        engine.setActivePlaylist(playlist)
        selectedFileID = item.id
        Task { await engine.play(fileURL: item.fileURL, musicFolderURL: musicFolderURL) }
    }
    
    private func deleteFile(item: PlaylistItem) {
        guard let musicFolderURL = settings.musicFolderURL else {
            return
        }
        _ = engine.trashFile(item, musicFolderURL: musicFolderURL)
    }
    
    private func updateFile(item: PlaylistItem, newTitle: String, newArtist: String, newFilename: String) async {
        guard let musicFolderURL = settings.musicFolderURL else {
            return
        }

        let newURL: URL
        do {
            newURL = try EditedFilename.destinationURL(
                for: item.fileURL,
                editedFilename: newFilename
            )
        } catch let error as FileOperationError {
            engine.presentedError = error
            return
        } catch {
            engine.presentedError = .mutationFailed(error.localizedDescription)
            return
        }

        let success = await engine.updateFile(from: item.fileURL, to: newURL, newTitle: newTitle, newArtist: newArtist, musicFolderURL: musicFolderURL)
        if success {
            engine.requestMusicFolderScan(for: musicFolderURL)
        }
    }
}

// MARK: - Subviews in separate files

struct HeaderView: View {
    var onTitleClick: (() -> Void)?

    var body: some View {
        ZStack {
            Image("screamer")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: 170, maxHeight: 170)
                .overlay(Color.black.opacity(0.18))
                .clipped()
                .accessibilityHidden(true)

            Button("AuDeluxe", action: { onTitleClick?() })
                .font(.system(size: 36, weight: .thin, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.55), radius: 5, y: 2)
                .buttonStyle(.plain)
                .focusEffectDisabled()
                .accessibilityHint("Shows the current song in the library")
        }
        .frame(maxWidth: .infinity, minHeight: 170, maxHeight: 170)
        .background(.black)
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
