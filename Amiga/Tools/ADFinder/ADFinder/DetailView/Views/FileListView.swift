//
//  FileListView.swift
//  ADFinder
//
//  Created by Mario Esposito on 6/13/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileListView: View {
    @Binding var selectedEntryIDs: Set<AmigaEntry.ID>
    let sortedEntries: [AmigaEntry]
    let currentPath: [String]
    
    // State for drag-and-drop and for robust shift-click selection
    @State private var dragOverId: AmigaEntry.ID? = nil
    @State private var isUpButtonTargeted: Bool = false
    @State private var lastClickedEntryID: AmigaEntry.ID?

    // Closures from the parent view
    let goUpDirectory: () -> Void
    let handleEntryTap: (AmigaEntry) -> Void
    let showInfoAlert: (AmigaEntry) -> Void
    let viewFileContent: (AmigaEntry) -> Void
    let viewAsText: (AmigaEntry) -> Void
    let handleMove: (Set<AmigaEntry.ID>, AmigaEntry) -> Void
    let handleMoveToParent: (Set<AmigaEntry.ID>) -> Void
    let renameAction: (AmigaEntry) -> Void
    let deleteAction: ([AmigaEntry]) -> Void
    let newFolderAction: () -> Void

    var body: some View {
        List {
            if !currentPath.isEmpty {
                upDirectoryButton
            }

            ForEach(sortedEntries) { entry in
                FileEntryRowView(
                    entry: entry,
                    isSelected: selectedEntryIDs.contains(entry.id),
                    isDragTarget: dragOverId == entry.id,
                    onTap: { handleSelection(for: entry) },
                    onDoubleTap: { handleEntryTap(entry) },
                    onContextMenu: { contextMenuItems(for: entry) },
                    onDrag: {
                        let idsToDrag = selectedEntryIDs.contains(entry.id) ? selectedEntryIDs : [entry.id]
                        let idString = idsToDrag.map { String($0) }.joined(separator: ",")
                        return NSItemProvider(object: idString as NSString)
                    }
                )
                .onDrop(of: [.plainText], isTargeted: dragTargetBinding(for: entry.id)) { providers -> Bool in
                    handleDropOnEntry(providers: providers, entry: entry)
                }
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
        .listRowBackground(isUpButtonTargeted ? Color.accentColor.opacity(0.5) : Color.clear)
        .onDrop(of: [.plainText], isTargeted: $isUpButtonTargeted) { providers -> Bool in
            handleDropOnParent(providers: providers)
        }
    }
    
    // MARK: - Manual Selection Handling
    private func handleSelection(for entry: AmigaEntry) {
        guard let event = NSApp.currentEvent else { return }
        let modifierFlags = event.modifierFlags
        
        if modifierFlags.contains(.command) {
            if selectedEntryIDs.contains(entry.id) {
                selectedEntryIDs.remove(entry.id)
            } else {
                selectedEntryIDs.insert(entry.id)
            }
            lastClickedEntryID = entry.id
        } else if modifierFlags.contains(.shift) {
            guard let lastID = lastClickedEntryID,
                  let lastIndex = sortedEntries.firstIndex(where: { $0.id == lastID }),
                  let currentIndex = sortedEntries.firstIndex(where: { $0.id == entry.id })
            else {
                selectedEntryIDs = [entry.id]
                lastClickedEntryID = entry.id
                return
            }
            
            let range = min(lastIndex, currentIndex)...max(lastIndex, currentIndex)
            for i in range {
                selectedEntryIDs.insert(sortedEntries[i].id)
            }
        } else {
            selectedEntryIDs = [entry.id]
            lastClickedEntryID = entry.id
        }
    }
    
    // MARK: - Drag/Drop and Context Menu Logic
    private func dragTargetBinding(for entryID: AmigaEntry.ID) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.dragOverId == entryID },
            set: { isTargeted in
                self.dragOverId = isTargeted ? entryID : nil
            }
        )
    }

    private func handleDropOnEntry(providers: [NSItemProvider], entry: AmigaEntry) -> Bool {
        guard entry.type == .directory else { return false }
        loadSourceIDs(from: providers) { sourceIDs in
            if !sourceIDs.isEmpty { handleMove(sourceIDs, entry) }
        }
        return true
    }

    private func handleDropOnParent(providers: [NSItemProvider]) -> Bool {
        loadSourceIDs(from: providers) { sourceIDs in
            if !sourceIDs.isEmpty { handleMoveToParent(sourceIDs) }
        }
        return true
    }
    
    private func loadSourceIDs(from providers: [NSItemProvider], completion: @escaping (Set<AmigaEntry.ID>) -> Void) {
        guard let provider = providers.first else {
            completion([])
            return
        }
        
        provider.loadObject(ofClass: NSString.self) { string, _ in
            DispatchQueue.main.async {
                guard let idString = string as? String else {
                    completion([])
                    return
                }
                let ids = idString.split(separator: ",").compactMap { Int($0) }
                completion(Set(ids))
            }
        }
    }
    
    @ViewBuilder
    private func contextMenuItems(for entry: AmigaEntry) -> some View {
        Button("Get Info") { showInfoAlert(entry) }
        if entry.type == .file {
            Button("View as Hex") { viewFileContent(entry) }
            Button("Edit as Text") { viewAsText(entry) }
        }
        Divider()
        Button("New Folder...") { newFolderAction() }
        Divider()
        Button("Rename...") { renameAction(entry) }
        Button("Delete") {
            let entriesToDelete = selectedEntryIDs.contains(entry.id) ? sortedEntries.filter { selectedEntryIDs.contains($0.id) } : [entry]
            deleteAction(entriesToDelete)
        }
    }
}

// MARK: - Equatable Row View
struct FileEntryRowView<ContextMenuContent: View>: View, Equatable {
    let entry: AmigaEntry
    let isSelected: Bool
    let isDragTarget: Bool
    
    // Closures for actions
    let onTap: () -> Void
    let onDoubleTap: () -> Void
    let onContextMenu: () -> ContextMenuContent
    let onDrag: () -> NSItemProvider
    
    static func == (lhs: FileEntryRowView, rhs: FileEntryRowView) -> Bool {
        return lhs.entry.id == rhs.entry.id &&
               lhs.isSelected == rhs.isSelected &&
               lhs.isDragTarget == rhs.isDragTarget
    }
    
    var body: some View {
        FileRowView(entry: entry)
            .listRowBackground(isSelected ? Color.accentColor.opacity(0.3) : (isDragTarget ? Color.accentColor.opacity(0.5) : Color.clear))
            .contentShape(Rectangle())
            .contextMenu { onContextMenu() }
            .onDrag { onDrag() }
            .gesture(
                TapGesture(count: 2)
                    .onEnded { onDoubleTap() }
                    .exclusively(before: TapGesture(count: 1).onEnded { onTap() })
            )
    }
}
