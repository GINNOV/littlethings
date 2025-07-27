//
//  FileListView.swift
//  ADFinder
//
//  Created by Mario Esposito on 6/13/25.
//

import SwiftUI

struct FileListView: View {
    @Binding var selectedEntryID: AmigaEntry.ID?
    let sortedEntries: [AmigaEntry]
    let currentPath: [String]
    @State private var dragOverId: AmigaEntry.ID? = nil
    @State private var isUpButtonTargeted: Bool = false

    // These closures are provided by the parent view to handle user actions.
    let goUpDirectory: () -> Void
    let handleEntryTap: (AmigaEntry) -> Void
    let showInfoAlert: (AmigaEntry) -> Void
    let viewFileContent: (AmigaEntry) -> Void
    let viewAsText: (AmigaEntry) -> Void
    let handleMove: (AmigaEntry.ID, AmigaEntry) -> Void
    let handleMoveToParent: (AmigaEntry.ID) -> Void

    var body: some View {
        // The List that shows the directory contents.
        List(selection: $selectedEntryID) {
            // Show the ".." (go up) button if we are not at the root.
            if !currentPath.isEmpty {
                upDirectoryButton
            }

            // Iterate over the sorted entries and create a row for each one.
            ForEach(sortedEntries) { entry in
                fileEntryRow(for: entry)
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
    }
    
    // MARK: - Up Directory Button
    private var upDirectoryButton: some View {
        Button(action: goUpDirectory) {
            Label(".. (Up one level)", systemImage: "arrow.up.left.circle.fill")
        }
        .buttonStyle(.plain)
        .selectionDisabled(true)
        .background(isUpButtonTargeted ? Color.accentColor.opacity(0.5) : Color.clear)
        .onDrop(of: [.plainText], isTargeted: $isUpButtonTargeted) { providers -> Bool in
            providers.first?.loadObject(ofClass: NSString.self) { string, error in
                if let idString = string as? String, let sourceID = Int(idString) {
                    DispatchQueue.main.async {
                        handleMoveToParent(sourceID)
                    }
                }
            }
            return true
        }
    }
    
    // MARK: - File Entry Row
    private func fileEntryRow(for entry: AmigaEntry) -> some View {
        FileRowView(entry: entry)
            .background(rowBackground(for: entry))
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                handleEntryTap(entry)
            }
            .onTapGesture(count: 1) {
                selectedEntryID = entry.id
            }
            .contextMenu {
                contextMenuItems(for: entry)
            }
            .tag(entry.id)
            .onDrag {
                // Fixed: entry.id is Int, not UUID
                NSItemProvider(object: "\(entry.id)" as NSString)
            }
            .onDrop(of: [.plainText], isTargeted: dragTargetBinding(for: entry)) { providers -> Bool in
                handleDropOnEntry(providers: providers, entry: entry)
            }
    }
    
    // MARK: - Helper Views and Functions
    private func rowBackground(for entry: AmigaEntry) -> Color {
        if dragOverId == entry.id && entry.type == .directory {
            return Color.accentColor.opacity(0.5)
        } else {
            return Color.clear
        }
    }
    
    @ViewBuilder
    private func contextMenuItems(for entry: AmigaEntry) -> some View {
        Button("Get Info") {
            showInfoAlert(entry)
        }
        
        if entry.type == .file {
            Button("View as Hex") {
                viewFileContent(entry)
            }
            Button("Edit as Text") {
                viewAsText(entry)
            }
        }
    }
    
    private func dragTargetBinding(for entry: AmigaEntry) -> Binding<Bool> {
        Binding(
            get: { dragOverId == entry.id },
            set: { isTargeted in
                dragOverId = isTargeted ? entry.id : nil
            }
        )
    }
    
    private func handleDropOnEntry(providers: [NSItemProvider], entry: AmigaEntry) -> Bool {
        guard entry.type == .directory else { return false }
        
        providers.first?.loadObject(ofClass: NSString.self) { string, error in
            if let idString = string as? String, let sourceID = Int(idString) {
                DispatchQueue.main.async {
                    handleMove(sourceID, entry)
                }
            }
        }
        return true
    }
}
