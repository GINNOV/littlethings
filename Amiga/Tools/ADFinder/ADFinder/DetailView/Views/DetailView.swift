//
//  DetailView.swift
//  ADFinder
//
//  Created by Mario Esposito on 5/23/25.
//

import SwiftUI
import UniformTypeIdentifiers
import Quartz // Needed for QuickLook panel access

struct DetailView: View {
    @Environment(\.openWindow) private var openWindow
    @Bindable var adfService: ADFService
    @Bindable var recentFilesService: RecentFilesService
    @Binding var selectedFile: URL?

    // MARK: - State Properties
    @State var currentEntries: [AmigaEntry] = []
    @State var selectedEntryIDs: Set<AmigaEntry.ID> = []
    @State private var sortedEntries: [AmigaEntry] = []
    @State private var entryLookup: [AmigaEntry.ID: AmigaEntry] = [:]
    
    // MARK: - Advanced Selection Handling State
    @State private var isProcessingSelection = false
    @State private var selectionUpdateTask: Task<Void, Never>?

    // MARK: - UI State
    @State var alertMessage: String?
    @State var showingAlert = false
    @State var confirmationConfig: ConfirmationConfig?
    @State var inputDialogConfig: InputDialogConfig?
    @State var infoDialogConfig: InfoDialogConfig?
    @State var newAdfConfig: NewADFDialogConfig?
    @State var newHDFConfig: NewHDFDialogConfig?
    @State var setPermissionsConfig: SetPermissionsDialogConfig?
    @State var forceFlag: Bool = false
    @State var showingAboutView = false
    @State var showingWhatsnewView = false
    @State var showingFileViewer = false
    @State var selectedEntryForView: AmigaEntry?
    @State var fileContentData: Data?
    @State var showingTextViewer = false
    @State var selectedEntryForTextEdit: AmigaEntry?
    @State var textFileContent: String = ""
    @State private var showingFileImporter = false
    @State var isLoadingFileContent = false
    @State var loadingTask: Task<Void, Never>?
    @State private var isDetailViewTargetedForDrop = false
    @State var sortOrder: SortOrder = .nameAscending
    @State var showingFileExporter = false
    @State var adfDocumentToSave: ADFDocument?
    @State var quickLookHelper = QuickLookHelper()
    
    // MARK: - Computed Properties
    var selectedEntries: [AmigaEntry] {
        // Use the lookup dictionary for O(1) access per item
        return selectedEntryIDs.compactMap { entryLookup[$0] }
    }
    
    private var currentContentType: UTType {
        adfService.currentImageKind == .hdf ? ContentView.hdfUType : ContentView.adfUType
    }
    
    private var defaultSaveName: String {
        let base = adfService.volumeLabel.isEmpty ? "Disk" : adfService.volumeLabel
        let ext  = adfService.currentImageKind == .hdf ? "hdf" : "adf"
        return base.replacingOccurrences(of: "[:/\\?%*|\"<>]", with: "_", options: .regularExpression) + ".\(ext)"
    }
    
    // MARK: - Custom Selection Binding
    // This is the core of the advanced solution. It intercepts selection changes from the List.
    private var customSelectionBinding: Binding<Set<AmigaEntry.ID>> {
        Binding(
            get: { selectedEntryIDs },
            set: { newSelection in
                // For large changes, use our custom chunking processor.
                if abs(newSelection.count - selectedEntryIDs.count) > 50 {
                    self.processLargeSelectionChange(newSelection)
                } else {
                    // For small changes, update directly for immediate feedback.
                    self.selectedEntryIDs = newSelection
                }
            }
        )
    }
    
    // MARK: - Actions Closure
    // This connects the UI to the real methods in the FileHandlers extension.
    var detailActions: DetailToolbar.Actions {
        .init(
            newADF: {
                newAdfConfig = NewADFDialogConfig(action: { volumeName, fsType, bootBlockType in
                    createNewAdf(volumeName: volumeName, fsType: fsType, bootBlockType: bootBlockType)
                })
            },
            newHDF: {
                newHDFConfig = NewHDFDialogConfig { volumeName, sizeMB, fsType in
                    createNewHdf(volumeName: volumeName, sizeMB: sizeMB, fsType: fsType)
                }
            },
            saveADF: saveAdf,
            addFile: { showingFileImporter = true },
            newFolder: {
                inputDialogConfig = NewFolderDialogConfig.config { newName in
                    createFolder(name: newName)
                }
            },
            editVolumeName: {
                inputDialogConfig = RenameVolumeDialogConfig.config(currentName: adfService.volumeLabel) { newName in
                    if let errorMessage = adfService.renameVolume(newName: newName) {
                        showAlert(message: "Failed to rename volume: \(errorMessage)")
                    }
                }
            },
            getInfo: {
                if selectedEntries.count == 1, let entry = selectedEntries.first {
                    showInfoAlert(for: entry)
                } else {
                    showAlert(message: "Please select exactly one item to get info.")
                }
            },
            setPermissions: {
                if selectedEntries.count == 1, let entry = selectedEntries.first {
                    setPermissionsConfig = SetPermissionsDialogConfig(
                        entryName: entry.name,
                        initialBits: entry.protectionBits,
                        action: { newBits in
                            if let errorMsg = adfService.setProtectionBits(for: entry, newBits: newBits) {
                                showAlert(message: "Failed to set permissions: \(errorMsg)")
                            }
                            loadDirectoryContents()
                        }
                    )
                } else {
                    showAlert(message: "Please select exactly one item to set permissions.")
                }
            },
            viewContent: {
                if selectedEntries.count == 1, let entry = selectedEntries.first {
                    viewFileContent(entry)
                } else {
                    showAlert(message: "Please select exactly one file to view content.")
                }
            },
            viewAsText: {
                if selectedEntries.count == 1, let entry = selectedEntries.first {
                    viewTextContent(entry)
                } else {
                    showAlert(message: "Please select exactly one file to view as text.")
                }
            },
            export: exportSelectedItems,
            rename: {
                if selectedEntries.count == 1, let entry = selectedEntries.first {
                    inputDialogConfig = RenameEntryDialogConfig.config(entry: entry) { newName in
                        renameEntry(entry: entry, newName: newName)
                    }
                } else {
                    showAlert(message: "Please select exactly one item to rename.")
                }
            },
            delete: {
                let entriesToDelete = selectedEntries
                if entriesToDelete.isEmpty {
                    showAlert(message: "No items selected to delete.")
                    return
                }
                presentConfirmation(config: .deleteEntries(entries: entriesToDelete, action: { force in
                    deleteEntries(entriesToDelete, force: force)
                }))
            },
            about: { showingAboutView = true },
            showConsole: { openWindow(id: "console-window") },
            showComparator: { openWindow(id: "compare-window") },
            diskDump: {
                guard let url = selectedFile else { return }
                let (error, path) = adfService.createDiskDump(fileURL: url)
                if let error = error { showAlert(message: error) }
                else if let path = path { showAlert(message: "Disk dump saved to:\n\(path.path)") }
            },
            generateList: {
                let (error, path) = adfService.generateDirectoryListing()
                if let error = error { showAlert(message: error) }
                else if let path = path { showAlert(message: "Directory list saved to:\n\(path.path)") }
            },
            openWithEmulator: openWithEmulator
        )
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            mainContent
                .zIndex(1)
            
            if isProcessingSelection {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Processing \(selectedEntryIDs.count) items...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(radius: 10)
                .transition(.opacity.animation(.easeInOut))
                .zIndex(100)
            }
        }
        .confirmationSheet(config: $confirmationConfig, forceFlag: $forceFlag)
        .inputDialogSheet(config: $inputDialogConfig)
        .infoDialogSheet(config: $infoDialogConfig)
        .newAdfDialogSheet(config: $newAdfConfig)
        .newHdfDialogSheet(config: $newHDFConfig)
        .setPermissionsDialogSheet(config: $setPermissionsConfig)
        .sheet(isPresented: $showingFileViewer) {
            if let entry = selectedEntryForView, let data = fileContentData {
                FileHexView(fileName: entry.name, data: data)
            }
        }
        .sheet(isPresented: $showingTextViewer) {
            if let entry = selectedEntryForTextEdit {
                FileTextView(fileName: entry.name, textContent: $textFileContent, onSave: saveTextContent)
            }
        }
        .sheet(isPresented: $showingAboutView) { AboutView() }
        .sheet(isPresented: $showingWhatsnewView) { WhatsNewView(showWhatsNew: $showingWhatsnewView) }
        .alert("Notice", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "An unknown error occurred.")
        }
        .fileExporter(isPresented: $showingFileExporter, document: adfDocumentToSave, contentType: currentContentType, defaultFilename: defaultSaveName, onCompletion: handleFileExport)
//        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [ContentView.adfUType, ContentView.hdfUType], allowsMultipleSelection: true, onCompletion: handleFileImport)
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [UTType.data], allowsMultipleSelection: true, onCompletion: handleFileImport)
        .focusedSceneValue(\.amigaActions, detailActions)
        .focusedSceneValue(\.isFileOpen, selectedFile != nil)
        .focusedSceneValue(\.isEntrySelected, !selectedEntryIDs.isEmpty)
        .onReceive(NotificationCenter.default.publisher(for: .showAboutWindow)) { _ in showingAboutView = true }
        .onReceive(NotificationCenter.default.publisher(for: .showWhatsNewWindow)) { _ in showingWhatsnewView = true }
        .onReceive(NotificationCenter.default.publisher(for: .triggerQuickLook)) { _ in
            if selectedEntries.count == 1, let entry = selectedEntries.first {
                showQuickLook(for: entry)
            } else {
                showAlert(message: "Please select exactly one file for Quick Look.")
            }
        }
        .onChange(of: currentEntries) { _, _ in updateSortedEntries() }
        .onChange(of: sortOrder) { _, _ in updateSortedEntries() }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack {
            if selectedFile == nil {
                WelcomeView()
            } else {
                FileListView(
                    // Pass the custom binding to the list view.
                    selectedEntryIDs: customSelectionBinding,
                    sortedEntries: sortedEntries,
                    currentPath: adfService.currentPath,
                    goUpDirectory: goUpDirectory,
                    handleEntryTap: handleEntryTap,
                    showInfoAlert: showInfoAlert,
                    viewFileContent: viewFileContent,
                    viewAsText: viewTextContent,
                    handleMove: handleMove,
                    handleMoveToParent: handleMoveToParent
                )
                .refreshable { loadDirectoryContents() }
            }
        }
        .navigationTitle(selectedFile?.lastPathComponent ?? "ADFinder")
        .toolbar {
            DetailToolbar(selectedFile: $selectedFile, sortOrder: $sortOrder, selectedEntry: selectedEntries.first, actions: detailActions)
        }

        .onDrop(of: [UTType.fileURL], isTargeted: $isDetailViewTargetedForDrop) { providers in
            handleDrop(providers: providers)
        }
        .overlay(isDetailViewTargetedForDrop ? RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor, lineWidth: 3).background(Color.accentColor.opacity(0.2)).padding(5) : nil)
        .overlay {
            if isLoadingFileContent {
                LoadingSpinnerView(isLoading: $isLoadingFileContent, onCancel: {
                    loadingTask?.cancel()
                    isLoadingFileContent = false
                    loadingTask = nil
                })
            }
        }
        .onChange(of: selectedFile) { _, newValue in
            if let newFile = newValue {
                processDroppedURL(newFile)
                recentFilesService.addRecentFile(newFile)
            } else {
                currentEntries = []
                sortedEntries = []
                entryLookup = [:]
            }
        }
    }
    
    // MARK: - Advanced Selection Processing
    private func processLargeSelectionChange(_ newSelection: Set<AmigaEntry.ID>) {
        selectionUpdateTask?.cancel()
        isProcessingSelection = true
        
        selectionUpdateTask = Task { @MainActor in
            let diff = newSelection.symmetricDifference(selectedEntryIDs)
            let batchSize = 100
            var processedCount = 0
            
            var currentSelection = selectedEntryIDs
            
            for itemID in diff {
                if Task.isCancelled { break }
                
                if newSelection.contains(itemID) {
                    currentSelection.insert(itemID)
                } else {
                    currentSelection.remove(itemID)
                }
                
                processedCount += 1
                if processedCount % batchSize == 0 {
                    self.selectedEntryIDs = currentSelection
                    try? await Task.sleep(for: .milliseconds(2))
                }
            }
            
            if !Task.isCancelled {
                self.selectedEntryIDs = newSelection
            }
            
            isProcessingSelection = false
        }
    }
    
    // MARK: - Data Handling
    private func updateSortedEntries() {
        let entries = self.currentEntries
        let order = self.sortOrder
        
        Task(priority: .userInitiated) {
            let sortedResult = await performSort(entries: entries, order: order)
            let lookupResult = Dictionary(uniqueKeysWithValues: sortedResult.map { ($0.id, $0) })
            
            await MainActor.run {
                self.sortedEntries = sortedResult
                self.entryLookup = lookupResult
            }
        }
    }
    
    private func performSort(entries: [AmigaEntry], order: SortOrder) async -> [AmigaEntry] {
        let directories = entries.filter { $0.type == .directory }
        let files = entries.filter { $0.type != .directory }

        let sortedDirectories: [AmigaEntry]
        let sortedFiles: [AmigaEntry]

        switch order {
        case .nameAscending:
            sortedDirectories = directories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            sortedFiles = files.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDescending:
            sortedDirectories = directories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
            sortedFiles = files.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .sizeAscending:
            sortedDirectories = directories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            sortedFiles = files.sorted { $0.size < $1.size }
        case .sizeDescending:
            sortedDirectories = directories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            sortedFiles = files.sorted { $0.size > $1.size }
        }
        
        return sortedDirectories + sortedFiles
    }
}
