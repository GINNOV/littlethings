//
//  ToolbarView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct ToolbarItems: ToolbarContent {
    @EnvironmentObject private var engine: OpenMPTEngine
    @EnvironmentObject private var settings: SettingsStore
    
    @Binding var selectedFileID: PlaylistItem.ID?
    @Binding var isShowingDeleteAlert: Bool
    @Binding var fileToDelete: PlaylistItem?
    @Binding var isShowingRenameAlert: Bool
    @Binding var fileToRename: PlaylistItem?
    @Binding var fileToInspect: PlaylistItem?
    @Binding var showingTrackerView: Bool
    @Binding var isShowingManagePlaylists: Bool
    @Binding var isShowingSelectPlaylist: Bool
    @Binding var isShowingAIPlaylistBuilder: Bool

    var body: some ToolbarContent {
        ToolbarItemGroup {
            Button(action: openSingleFile) {
                Label("Add Song", systemImage: "plus")
            }
            
            Spacer()
            
            Button(action: { showingTrackerView.toggle() }) {
                Label(showingTrackerView ? "Playlist" : "Tracker", systemImage: showingTrackerView ? "list.bullet" : "pianokeys")
            }

            Menu {
                Picker("Sort By", selection: $engine.sortOrder) {
                    ForEach(SortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down.circle")
            }
            .disabled(showingTrackerView || engine.isShuffling)
            
            Menu {
                Button("Manage Playlists...") { isShowingManagePlaylists = true }
                Button("Select Playlist...") { isShowingSelectPlaylist = true }
            } label: {
                Label("Playlists", systemImage: "music.note.list")
            }
            .disabled(showingTrackerView)

            Button("Create Playlist with AI", systemImage: "sparkles") {
                isShowingAIPlaylistBuilder = true
            }
            .disabled(showingTrackerView)

            Menu {
                Button("⭐️⭐️⭐️⭐️⭐️ - Love it") { rateSelectedItem(5) }
                Button("⭐️⭐️⭐️⭐️ - Awesome") { rateSelectedItem(4) }
                Button("⭐️⭐️⭐️ - Wow") { rateSelectedItem(3) }
                Button("⭐️⭐️ - Meh") { rateSelectedItem(2) }
                Button("⭐️ - Don't even...") { rateSelectedItem(1) }
                Divider()
                Button("Clear Rating") { rateSelectedItem(0) }
            } label: {
                Label("Rate", systemImage: "star")
            }
            .disabled(selectedFileID == nil)
            
            Button(action: {
                if let selectedItem = engine.playlistItems.first(where: { $0.id == selectedFileID }) {
                    fileToInspect = selectedItem
                }
            }) {
                Label("Inspect", systemImage: "info.square")
            }
            .disabled(selectedFileID == nil)

            Button(action: {
                if let selectedItem = engine.playlistItems.first(where: { $0.id == selectedFileID }) {
                    fileToRename = selectedItem
                    isShowingRenameAlert = true
                }
            }) {
                Label("Rename", systemImage: "pencil")
            }
            .disabled(selectedFileID == nil)

            Button(action: {
                if let selectedItem = engine.playlistItems.first(where: { $0.id == selectedFileID }) {
                    fileToDelete = selectedItem
                    isShowingDeleteAlert = true
                }
            }) {
                Label("Delete", systemImage: "trash")
            }
            .disabled(selectedFileID == nil)
            
        }
    }
    
    private func openSingleFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url, let folderURL = settings.musicFolderURL {
            Task {
                await engine.play(fileURL: url, musicFolderURL: folderURL)
            }
        }
    }
    
    private func rateSelectedItem(_ rating: Int) {
        guard let selectedID = selectedFileID,
              let item = engine.playlistItems.first(where: { $0.id == selectedID }),
              let musicFolderURL = settings.musicFolderURL else { return }

        if engine.rateFile(fileURL: item.fileURL, rating: rating, musicFolderURL: musicFolderURL),
           let index = engine.allPlaylistItems.firstIndex(where: { $0.id == selectedID }) {
            engine.allPlaylistItems[index].rating = rating
        }
    }
}
