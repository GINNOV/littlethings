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

    var body: some ToolbarContent {
        ToolbarItemGroup {
            Button(action: openSingleFile) {
                Label("Open File", systemImage: "doc")
            }
            
            Spacer()

            Menu {
                Button("⭐️⭐️⭐️⭐️⭐️") { rateSelectedItem(5) }
                Button("⭐️⭐️⭐️⭐️") { rateSelectedItem(4) }
                Button("⭐️⭐️⭐️") { rateSelectedItem(3) }
                Button("⭐️⭐️") { rateSelectedItem(2) }
                Button("⭐️") { rateSelectedItem(1) }
                Divider()
                Button("Clear Rating") { rateSelectedItem(0) }
            } label: {
                Label("Rate", systemImage: "star")
            }
            .disabled(selectedFileID == nil)

            Button(action: { /* Rename logic to be implemented */ }) {
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
            engine.play(fileURL: url, musicFolderURL: folderURL)
        }
    }
    
    private func rateSelectedItem(_ rating: Int) {
        guard let selectedID = selectedFileID,
              let item = engine.playlistItems.first(where: { $0.id == selectedID }) else { return }
        print("Rating song '\(item.title)' with \(rating) stars.")
        // Rating persistence logic would go here.
    }
}
