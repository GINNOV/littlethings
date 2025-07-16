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
    @Binding var isShowingAboutSheet: Bool
    @Binding var isShowingInspectorSheet: Bool
    @Binding var fileToInspect: PlaylistItem?

    var body: some ToolbarContent {
        ToolbarItemGroup {
            Button(action: openSingleFile) {
                Label("Open File", systemImage: "doc")
            }
            
            Spacer()

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

            Menu {
                Button("⭐️⭐️⭐️⭐️⭐️ - Five Stars") { rateSelectedItem(5) }
                Button("⭐️⭐️⭐️⭐️ - Four Stars") { rateSelectedItem(4) }
                Button("⭐️⭐️⭐️ - Three Stars") { rateSelectedItem(3) }
                Button("⭐️⭐️ - Two Stars") { rateSelectedItem(2) }
                Button("⭐️ - One Star") { rateSelectedItem(1) }
                Divider()
                Button("Clear Rating") { rateSelectedItem(0) }
            } label: {
                Label("Rate", systemImage: "star")
            }
            .disabled(selectedFileID == nil)
            
            Button(action: {
                if let selectedItem = engine.playlistItems.first(where: { $0.id == selectedFileID }) {
                    fileToInspect = selectedItem
                    isShowingInspectorSheet = true
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
            
            Button(action: {
                isShowingAboutSheet = true
            }) {
                Label("About", systemImage: "info.circle")
            }
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
              let item = engine.playlistItems.first(where: { $0.id == selectedID }),
              let musicFolderURL = settings.musicFolderURL else { return }

        engine.rateFile(fileURL: item.fileURL, rating: rating, musicFolderURL: musicFolderURL)

        if let index = engine.playlistItems.firstIndex(where: { $0.id == selectedID }) {
            engine.playlistItems[index].rating = rating
        }
    }
}
