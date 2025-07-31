//
//  FileListView.swift
//  ADFinder
//
//  Created by Mario Esposito on 6/13/25.
//

import SwiftUI

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

    var body: some View {
        List {
            if !currentPath.isEmpty {
                upDirectoryButton
            }

            // The ForEach now uses the new, optimized row view.
            ForEach(sortedEntries) { entry in
                FileEntryRowView(
                    entry: entry,
                    isSelected: selectedEntryIDs.contains(entry.id),
                    isDragTarget: dragOverId == entry.id,
                    onTap: { handleSelection(for: entry) },
                    onDoubleTap: { handleEntryTap(entry) },
                    onContextMenu: { contextMenuItems(for: entry) },
                    onDrag: { NSItemProvider(object: "\(entry.id)" as NSString) },
                    onDrop: { providers in handleDropOnEntry(providers: providers, entry: entry) }
                )
                // THE FIX: The drag target binding needs to be applied here,
                // outside the Equatable view, to ensure it updates correctly.
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
    
    // MARK: - Manual Selection Handling (with improved Shift-click)
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
    
    private func loadSourceIDs(from providers: [NSItemProvider], completion: @escaping (Set<Int>) -> Void) {
        let group = DispatchGroup()
        var sourceIDs: Set<Int> = []
        for provider in providers {
            group.enter()
            provider.loadObject(ofClass: NSString.self) { string, _ in
                if let idString = string as? String, let sourceID = Int(idString) {
                    sourceIDs.insert(sourceID)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { completion(sourceIDs) }
    }
    
    @ViewBuilder
    private func contextMenuItems(for entry: AmigaEntry) -> some View {
        Button("Get Info") { showInfoAlert(entry) }
        if entry.type == .file {
            Button("View as Hex") { viewFileContent(entry) }
            Button("Edit as Text") { viewAsText(entry) }
        }
    }
}

// MARK: - Equatable Row View
// This view is now generic to accept any kind of Context Menu content.
struct FileEntryRowView<ContextMenuContent: View>: View, Equatable {
    let entry: AmigaEntry
    let isSelected: Bool
    let isDragTarget: Bool
    
    // Closures for actions
    let onTap: () -> Void
    let onDoubleTap: () -> Void
    let onContextMenu: () -> ContextMenuContent // THE FIX: Use a generic type instead of AnyView
    let onDrag: () -> NSItemProvider
    let onDrop: ([NSItemProvider]) -> Bool
    
    static func == (lhs: FileEntryRowView, rhs: FileEntryRowView) -> Bool {
        // This Equatable conformance is the key to performance.
        // It prevents SwiftUI from re-rendering rows whose state hasn't changed.
        return lhs.entry.id == rhs.entry.id &&
               lhs.isSelected == rhs.isSelected &&
               lhs.isDragTarget == rhs.isDragTarget
    }
    
    var body: some View {
        FileRowView(entry: entry)
            .listRowBackground(isSelected ? Color.accentColor.opacity(0.3) : Color.clear)
            .background(isDragTarget && entry.type == .directory ? Color.accentColor.opacity(0.5) : Color.clear)
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

// Generated: FileListView.swift @ 04:38
