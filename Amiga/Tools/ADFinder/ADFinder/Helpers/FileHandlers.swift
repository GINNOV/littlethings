//
//  FileHandlers.swift
//  ADFinder
//
//  Created by Mario Esposito on 6/13/25.
//

import SwiftUI
import UniformTypeIdentifiers
import Quartz

extension DetailView {
    // MARK: - Core ADF Operations
    
    func openWithEmulator() {
        guard let url = selectedFile else {
            showAlert(message: "No file is currently open.")
            return
        }
        
        if !NSWorkspace.shared.open(url) {
            showAlert(message: "Could not open \(url.lastPathComponent). Make sure you have a default application set for .adf or .hdf files.")
        }
    }

    func showQuickLook(for entry: AmigaEntry) {
        print("DEBUG: showQuickLook called for '\(entry.name)'.")
        guard entry.type == .file else {
            print("DEBUG: Entry is not a file. Aborting.")
            return
        }
        
        guard let fileData = adfService.readFileContent(entry: entry) else {
            print("DEBUG: Failed to read file data.")
            showAlert(message: "Could not read data for \(entry.name).")
            return
        }
        print("DEBUG: Successfully read \(fileData.count) bytes.")
        
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent(entry.name)
        print("DEBUG: Temporary file URL: \(tempURL.path)")
        
        do {
            try fileData.write(to: tempURL)
            print("DEBUG: Successfully wrote temporary file.")
        } catch {
            print("DEBUG: Failed to write temporary file: \(error)")
            showAlert(message: "Could not create temporary file for Quick Look: \(error.localizedDescription)")
            return
        }
        
        if QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared().isVisible {
            print("DEBUG: Closing existing Quick Look panel.")
            QLPreviewPanel.shared().orderOut(nil)
        }
        
        print("DEBUG: Setting up Quick Look panel.")
        self.quickLookHelper.previewItemURL = tempURL
        QLPreviewPanel.shared().dataSource = self.quickLookHelper
        QLPreviewPanel.shared().delegate = self.quickLookHelper
        QLPreviewPanel.shared().makeKeyAndOrderFront(nil)
        print("DEBUG: Called makeKeyAndOrderFront.")
    }
    
    func handleMoveToParent(sourceEntryIDs: Set<AmigaEntry.ID>) {
        var errors: [String] = []
        for id in sourceEntryIDs {
            guard let sourceEntry = currentEntries.first(where: { $0.id == id }) else {
                errors.append("Could not find source item with ID \(id).")
                continue
            }
            if let errorMessage = adfService.moveEntryToParent(entryNameToMove: sourceEntry.name) {
                errors.append("Failed to move \(sourceEntry.name): \(errorMessage)")
            }
        }
        if !errors.isEmpty {
            showAlert(message: errors.joined(separator: "\n"))
        }
        loadDirectoryContents()
    }
    
    func handleMove(sourceEntryIDs: Set<AmigaEntry.ID>, destinationEntry: AmigaEntry) {
        guard destinationEntry.type == .directory else { return }
        
        var errors: [String] = []
        for id in sourceEntryIDs {
            guard let sourceEntry = currentEntries.first(where: { $0.id == id }) else {
                errors.append("Could not find source item with ID \(id).")
                continue
            }
            if sourceEntry.id == destinationEntry.id {
                continue
            }
            if let errorMessage = adfService.moveEntry(entryNameToMove: sourceEntry.name, toDestinationDirName: destinationEntry.name) {
                errors.append("Failed to move \(sourceEntry.name): \(errorMessage)")
            }
        }
        if !errors.isEmpty {
            showAlert(message: errors.joined(separator: "\n"))
        }
        loadDirectoryContents()
    }
    
    func loadDirectoryContents() {
        guard selectedFile != nil else {
            currentEntries = []
            selectedEntryIDs = []
            return
        }
        currentEntries = adfService.listCurrentDirectory()
        selectedEntryIDs = []
    }
    
    func goUpDirectory() {
        if adfService.goUpDirectory() {
            loadDirectoryContents()
        }
    }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (itemData, error) in
            DispatchQueue.main.async {
                guard
                    let data = itemData as? Data,
                    let url = URL(dataRepresentation: data, relativeTo: nil),
                    url.isFileURL
                else {
                    self.adfService.log("handleDrop: Could not create URL from dropped item data. Error: \(error?.localizedDescription ?? "Unknown")")
                    self.showAlert(message: "Could not open the dropped item.")
                    return
                }

                self.adfService.log("handleDrop: Successfully loaded URL from bookmark data: \(url.absoluteString)")

                let fileExtension = url.pathExtension.lowercased()
                guard ["adf", "hdf"].contains(fileExtension) else {
                    self.adfService.log("handleDrop: Invalid file type dropped: \(fileExtension)")
                    self.showAlert(message: "Only .adf and .hdf files can be opened.")
                    return
                }
                
                if self.selectedFile != nil {
                    self.adfService.log("handleDrop: A file is already open. Showing confirmation dialog.")
                    self.presentConfirmation(config: .replaceOpenDisk {
                        self.selectedFile = url
                    })
                } else {
                    self.selectedFile = url
                }
            }
        }
        return true
    }
    
    func processDroppedURL(_ url: URL) {
        adfService.log("processDroppedURL: Processing URL: \(url.path)")
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer { if didStartAccessing { url.stopAccessingSecurityScopedResource() } }
        
        if adfService.openADF(filePath: url.path) {
            loadDirectoryContents()
        } else {
            adfService.log("processDroppedURL: Failed to open or mount ADF.")
            showAlert(message: "Failed to open or mount ADF: \"\(url.lastPathComponent)\". The file path may contain invalid characters.")
            selectedFile = nil
        }
    }
    
    func createNewAdf(volumeName: String, fsType: UInt8, bootBlockType: BootBlockType) {
        if let newAdfUrl = adfService.createNewBlankADF(volumeName: volumeName, fsType: fsType, bootBlockType: bootBlockType) {
            self.selectedFile = newAdfUrl
        } else {
            showAlert(message: "Failed to create a new blank ADF image.")
        }
    }
    
    func createNewHdf(volumeName: String, sizeMB: Int, fsType: UInt8) {
        if let newHdfUrl = adfService.createNewBlankHDF(
            volumeName: volumeName,
            sizeMB: sizeMB,
            fsType: fsType
        ) {
            self.selectedFile = newHdfUrl
        } else {
            showAlert(message: "Failed to create a new blank HDF image.")
        }
    }
    
    func saveAdf() {
        guard let url = selectedFile else { return }
        
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            adfDocumentToSave = ADFDocument(data: data, volumeName: adfService.volumeLabel)
            showingFileExporter = true
        } catch {
            showAlert(message: "Could not read data from the current ADF file to save it: \(error.localizedDescription)")
        }
    }
    
    func handleFileExport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            print("Successfully saved ADF to \(url.path)")
            self.selectedFile = url
        case .failure(let error):
            showAlert(message: "Failed to save file: \(error.localizedDescription)")
        }
    }
    
    func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            var errors: [String] = []
            for url in urls {
                if let errorMessage = adfService.addFile(from: url) {
                    errors.append("Could not add \(url.lastPathComponent): \(errorMessage)")
                }
            }
            if !errors.isEmpty {
                showAlert(message: errors.joined(separator: "\n"))
            }
            loadDirectoryContents()
        case .failure(let error):
            showAlert(message: "Failed to import files: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Entry Actions
    
    func handleEntryTap(_ entry: AmigaEntry) {
        switch entry.type {
        case .directory:
            if adfService.navigateToDirectory(entry.name) {
                loadDirectoryContents()
            } else {
                showAlert(message: "Could not enter directory: \(entry.name)")
            }
        case .file:
            viewFileContent(entry)
        default:
            showAlert(message: "Cannot open item of type: \(entry.type.rawValue)")
        }
    }
    
    func viewFileContent(_ entry: AmigaEntry) {
        guard entry.type == .file else { return }
        selectedEntryForView = entry
        isLoadingFileContent = true
        loadingTask = Task {
            let data = adfService.readFileContent(entry: entry)
            await MainActor.run {
                guard !Task.isCancelled else { return }
                self.fileContentData = data
                self.isLoadingFileContent = false
                if data != nil {
                    self.showingFileViewer = true
                } else {
                    self.showAlert(message: "Could not read content for file: \(entry.name)")
                }
            }
        }
    }
    
    func viewTextContent(_ entry: AmigaEntry) {
        guard entry.type == .file else { return }
        
        selectedEntryForTextEdit = entry
        isLoadingFileContent = true
        
        loadingTask = Task {
            guard let data = adfService.readFileContent(entry: entry) else {
                await MainActor.run {
                    showAlert(message: "Could not read data for \(entry.name).")
                    isLoadingFileContent = false
                }
                return
            }
            
            let string = String(data: data, encoding: .isoLatin1) ?? ""
            
            await MainActor.run {
                guard !Task.isCancelled else { return }
                self.textFileContent = string
                self.isLoadingFileContent = false
                self.showingTextViewer = true
            }
        }
    }
    
    func saveTextContent() {
        guard let entry = selectedEntryForTextEdit else { return }
        
        if let errorMessage = adfService.writeTextFile(entry: entry, content: textFileContent) {
            showAlert(message: "Failed to save file: \(errorMessage)")
        } else {
            loadDirectoryContents()
        }
    }
    
    func createFolder(name: String) {
        guard !name.isEmpty else {
            showAlert(message: "Folder name cannot be empty.")
            return
        }
        if let errorMessage = adfService.createDirectory(name: name, force: false) {
            showAlert(message: "Failed to create folder \"\(name)\": \(errorMessage)")
        } else {
            loadDirectoryContents()
        }
    }
    
    func deleteEntry(_ entry: AmigaEntry, force: Bool) {
        if let errorMessage = adfService.deleteEntryRecursively(entry: entry, force: force) {
            showAlert(message: "Failed to delete \"\(entry.name)\": \(errorMessage)")
        } else {
            loadDirectoryContents()
        }
    }
    
    func deleteEntries(_ entries: [AmigaEntry], force: Bool) {
        var errors: [String] = []
        for entry in entries {
            if let errorMessage = adfService.deleteEntryRecursively(entry: entry, force: force) {
                errors.append("Failed to delete \"\(entry.name)\": \(errorMessage)")
            }
        }
        if !errors.isEmpty {
            showAlert(message: errors.joined(separator: "\n"))
        }
        loadDirectoryContents()
    }
    
    func renameEntry(entry: AmigaEntry, newName: String) {
        guard !newName.isEmpty else {
            showAlert(message: "New name cannot be empty.")
            return
        }
        if let errorMessage = adfService.renameEntry(oldName: entry.name, newName: newName) {
            showAlert(message: "Failed to rename \"\(entry.name)\": \(errorMessage)")
        } else {
            loadDirectoryContents()
        }
    }
    
    func exportSelectedItems() {
        let selected = selectedEntries
        if selected.isEmpty {
            showAlert(message: "No items selected to export.")
            return
        }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Choose destination folder"
        panel.message = "The selected items will be exported into the folder you choose."
        panel.prompt = "Export Here"
        
        panel.begin { response in
            if response == .OK, let destinationURL = panel.url {
                DispatchQueue.global(qos: .userInitiated).async {
                    var errorMessages: [String] = []
                    for entry in selected {
                        if let errorMessage = self.adfService.exportEntry(entry: entry, toDirectory: destinationURL) {
                            errorMessages.append(errorMessage)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if errorMessages.isEmpty {
                            let names = selected.map { $0.name }.joined(separator: ", ")
                            self.showAlert(message: "\(selected.count) item(s) (\(names)) were successfully exported.")
                        } else {
                            self.showAlert(message: "Some exports failed:\n\(errorMessages.joined(separator: "\n"))")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Alert & Dialog Presentation
    
    func showAlert(message: String) {
        self.alertMessage = message
        self.showingAlert = true
    }
    
    func showInfoAlert(for entry: AmigaEntry) {
        self.infoDialogConfig = InfoDialogConfig(entry: entry)
    }
    
    func presentConfirmation(config: ConfirmationConfig) {
        self.forceFlag = false
        self.confirmationConfig = config
    }
}
