//
//  ADFService+FileOperations.swift
//  ADFinder
//
//  Created by Mario Esposito on 7/25/25.
//

import Foundation

extension ADFService {
    
    internal func navigateToInternalPath() -> Bool {
        guard let vol = self.adfVolume else { return false }
        if adfToRootDir(vol) != ADF_RC_OK {
            _ = getADFLibError(context: "adfToRootDir")
            return false
        }
        for dirName in currentPath {
            if !dirName.withCString({ cDirName -> Bool in adfChangeDir(vol, cDirName) == ADF_RC_OK }) {
                _ = getADFLibError(context: "adfChangeDir to \(dirName)")
                adfToRootDir(vol)
                return false
            }
        }
        return true
    }
    
    func listCurrentDirectory() -> [AmigaEntry] {
        guard let vol = self.adfVolume else { return [] }
        if !navigateToInternalPath() { return [] }
        
        let dirSector = vol.pointee.curDirPtr
        var entries: [AmigaEntry] = []
        
        let adfListHead: UnsafeMutablePointer<AdfList>? = adfGetDirEnt(vol, dirSector)
        
        if adfListHead == nil {
            // This is normal for an empty directory.
        }

        var currentAdfListNode = adfListHead
        while let currentNodePtr = currentAdfListNode {
            let currentNode = currentNodePtr.pointee
            if let entryDataVoidPtr = currentNode.content {
                let adfEntryOpaquePtr = entryDataVoidPtr.assumingMemoryBound(to: AdfEntry.self)
                
                let entryNamePtr = get_AdfEntry_name_ptr(adfEntryOpaquePtr)
                let name = entryNamePtr != nil ? String(cString: entryNamePtr!) : "Invalid Name"
                
                let entryTypeCInt = get_AdfEntry_type(adfEntryOpaquePtr)
                let type: EntryType
                switch entryTypeCInt {
                    case ST_FILE_SWIFT: type = .file
                    case ST_DIR_SWIFT: type = .directory
                    case ST_LFILE_SWIFT: type = .softLinkFile
                    case ST_LDIR_SWIFT: type = .softLinkDir
                    default: type = .unknown
                }
                
                var date: Date? = nil
                let year = Int(get_AdfEntry_year(adfEntryOpaquePtr))
                let month = Int(get_AdfEntry_month(adfEntryOpaquePtr))
                let day = Int(get_AdfEntry_days(adfEntryOpaquePtr))
                let hour = Int(get_AdfEntry_hour(adfEntryOpaquePtr))
                let minute = Int(get_AdfEntry_mins(adfEntryOpaquePtr))
                let second = Int(get_AdfEntry_secs(adfEntryOpaquePtr))

                if year >= 1900 && (month >= 1 && month <= 12) && (day >= 1 && day <= 31) {
                    var components = DateComponents()
                    components.year = year
                    components.month = month
                    components.day = day
                    components.hour = hour
                    components.minute = minute
                    components.second = second
                    date = Calendar.current.date(from: components)
                }

                var commentStr: String? = nil
                if let commentCStringPtr = get_AdfEntry_comment_ptr(adfEntryOpaquePtr) {
                     commentStr = String(cString: commentCStringPtr)
                }
                
                let entrySize = get_AdfEntry_size(adfEntryOpaquePtr)
                let entryAccess = get_AdfEntry_access(adfEntryOpaquePtr)
                
                entries.append(AmigaEntry(name: name, type: type, size: Int32(entrySize),
                                          protectionBits: entryAccess, date: date, comment: commentStr))
            }
            if currentNode.next == nil { break }
            currentAdfListNode = currentNode.next
        }
        if adfListHead != nil { adfFreeDirList(adfListHead) }
        
        return entries.sorted {
            if $0.type == .directory && $1.type != .directory { return true }
            if $0.type != .directory && $1.type == .directory { return false }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
    
    func navigateToDirectory(_ name: String) -> Bool {
        guard self.adfVolume != nil, !name.isEmpty, name != "." else { return false }
        
        if name == ".." {
            if currentPath.isEmpty { return false }
            currentPath.removeLast()
            if !navigateToInternalPath() {
                 log("ADFService: Failed to navigate up to parent directory.")
                 return false
            }
            return true
        } else {
            currentPath.append(name)
            if !navigateToInternalPath() {
                log("ADFService: Failed to navigate into '\(name)'.")
                currentPath.removeLast()
                return false
            }
            return true
        }
    }

    func goUpDirectory() -> Bool {
         if currentPath.isEmpty { return false }
         currentPath.removeLast()
         return navigateToInternalPath()
    }

    func readFileContent(entry: AmigaEntry) -> Data? {
        guard let vol = self.adfVolume, entry.type == .file else { return nil }
        if !navigateToInternalPath() {
            _ = getADFLibError(context: "navigateToInternalPath for \(entry.name) before readFileContent")
            return nil
        }
        var fileData = Data()
        let bufferSize: UInt32 = 4096
        var buffer = [UInt8](repeating: 0, count: Int(bufferSize))

        let adfFilePtr = entry.name.withCString { cFileName -> UnsafeMutablePointer<AdfFile>? in
            return adfFileOpen(vol, cFileName, AdfFileMode(rawValue: UInt32(ADF_FILE_MODE_READ_SWIFT)))
        }

        if adfFilePtr == nil {
            _ = getADFLibError(context: "adfFileOpen for \(entry.name)")
            return nil
        }
        defer { adfFileClose(adfFilePtr) }

        while true {
            let bytesRead = adfFileRead(adfFilePtr, bufferSize, &buffer)
            if bytesRead == 0 {
                break
            }
            fileData.append(buffer, count: Int(bytesRead))
        }
        return fileData
    }
    
    func writeTextFile(entry: AmigaEntry, content: String) -> String? {
        guard let vol = self.adfVolume, entry.type == .file else { return "Invalid entry or volume." }
        if !navigateToInternalPath() {
            return getADFLibError(context: "navigateToInternalPath for \(entry.name) before writeTextFile")
        }

        var processedContent = content
            .replacingOccurrences(of: "“", with: "\"")
            .replacingOccurrences(of: "”", with: "\"")
            .replacingOccurrences(of: "‘", with: "'")
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "…", with: "...")
            .replacingOccurrences(of: "—", with: "--")
        
        processedContent = processedContent.replacingOccurrences(of: "\r\n", with: "\n")
        
        guard let data = processedContent.data(using: .isoLatin1) else {
            return "Failed to encode string to Amiga-compatible format."
        }
        
        let result = data.withUnsafeBytes { (bufferPtr: UnsafeRawBufferPointer) -> ADF_RETCODE in
            let unsafePointer = bufferPtr.baseAddress?.assumingMemoryBound(to: UInt8.self)
            
            return entry.name.withCString { cAmigaPath in
                return add_file_to_adf_c(vol, cAmigaPath, unsafePointer, UInt32(data.count))
            }
        }
        
        if result.rawValue == ADF_RC_OK_SWIFT {
            log("ADFService: Successfully wrote to '\(entry.name)'.")
            populateDiskInfo()
            return nil
        } else {
            log("ADFService: add_file_to_adf_c failed for '\(entry.name)'. Check C-Log for details.")
            return "ADFlib failed to write the file. The disk may be full."
        }
    }
    
    func addFile(from url: URL) -> String? {
        guard let vol = self.adfVolume else { return "Volume not mounted." }
        
        if !navigateToInternalPath() {
            return "Failed to navigate to current ADF directory."
        }
        
        let amigaPath = url.lastPathComponent
        
        if let existingEntry = self.listCurrentDirectory().first(where: { $0.name.lowercased() == amigaPath.lowercased() }) {
            if existingEntry.type == .directory {
                return "An entry named '\(amigaPath)' already exists and it is a directory. Cannot overwrite."
            }
            
            log("ADFService: File '\(amigaPath)' exists. Deleting it before overwrite.")
            if let deleteError = self.deleteEntryRecursively(entry: existingEntry, force: true) {
                return "Failed to delete existing file to overwrite: \(deleteError)"
            }
        }

        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            let errorMessage = "Could not read data from local file. Reason: \(error.localizedDescription)"
            log("ADFService Error: \(errorMessage)")
            return errorMessage
        }
        
        let result = data.withUnsafeBytes { (bufferPtr: UnsafeRawBufferPointer) -> ADF_RETCODE in
            let unsafePointer = bufferPtr.baseAddress?.assumingMemoryBound(to: UInt8.self)
            
            return amigaPath.withCString { cAmigaPath in
                return add_file_to_adf_c(vol, cAmigaPath, unsafePointer, UInt32(data.count))
            }
        }
        
        if result.rawValue == ADF_RC_OK_SWIFT {
            log("ADFService: Successfully added '\(amigaPath)'.")
            populateDiskInfo()
            return nil
        } else {
            log("ADFService: add_file_to_adf_c failed for '\(amigaPath)'. Check C-Log for details.")
            return "ADFlib failed to write the file. The disk may be full."
        }
    }

    func createDirectory(name: String, force: Bool) -> String? {
        guard let vol = self.adfVolume else {
            return "Cannot create directory, volume is nil."
        }
        if !navigateToInternalPath() {
            return "Cannot create directory, failed to navigate to current path."
        }
        
        let parentSector = vol.pointee.curDirPtr
        
        if !force {
            var parentBlock = AdfEntryBlock()
            if adfReadEntryBlock(vol, parentSector, &parentBlock).rawValue != ADF_RC_OK_SWIFT {
                return "Could not read parent directory information to check permissions."
            }
            if (UInt32(parentBlock.access) & ACCMASK_W_SWIFT) != 0 {
                return "Parent directory is write-protected. (Use 'Force Operations' to override)."
            }
        }
        
        let success = name.withCString { cName -> Bool in
            return adfCreateDir(vol, parentSector, cName).rawValue == ADF_RC_OK_SWIFT
        }
        
        if success {
            populateDiskInfo()
            return nil
        } else {
            log("ADFService: adfCreateDir failed. Check C-Log for details.")
            return "ADFLib failed to create the directory."
        }
    }
    
    func deleteEntryRecursively(entry: AmigaEntry, force: Bool) -> String? {
        let originalPath = self.currentPath
        let result = _deleteRecursively(entryToDelete: entry, force: force)
        self.currentPath = originalPath
        if !navigateToInternalPath() {
            log("ADFService: CRITICAL - Failed to restore path to \(originalPath.joined(separator: "/")) after deletion operation.")
        }
        if result == nil {
            populateDiskInfo()
        }
        return result
    }

    private func _deleteRecursively(entryToDelete: AmigaEntry, force: Bool) -> String? {
        guard let vol = self.adfVolume else { return "Volume not mounted." }
        
        if !force && (entryToDelete.protectionBits & ACCMASK_D_SWIFT) != 0 {
            return "Entry '\(entryToDelete.name)' is delete-protected."
        }
        
        if entryToDelete.type == .directory {
            if !navigateToDirectory(entryToDelete.name) {
                return "Failed to navigate into directory '\(entryToDelete.name)' to empty it."
            }
            
            let children = listCurrentDirectory()
            for child in children {
                if let error = _deleteRecursively(entryToDelete: child, force: force) {
                    _ = goUpDirectory()
                    return error
                }
            }
            
            if !goUpDirectory() {
                 return "Failed to navigate out of directory '\(entryToDelete.name)' after emptying it. Cannot complete deletion."
            }
        }
        
        let parentSector = vol.pointee.curDirPtr
        let success = entryToDelete.name.withCString { cName -> Bool in
            return adfRemoveEntry(vol, parentSector, cName).rawValue == ADF_RC_OK_SWIFT
        }
        
        if success {
            log("ADFService: Successfully deleted '\(entryToDelete.name)'.")
            return nil
        } else {
            log("ADFService: adfRemoveEntry failed for '\(entryToDelete.name)'. Check C-Log for details.")
            return "ADFLib failed to delete '\(entryToDelete.name)'."
        }
    }

    func moveEntry(entryNameToMove: String, toDestinationDirName: String) -> String? {
        guard let vol = self.adfVolume else { return "Volume not mounted." }

        let parentSector = vol.pointee.curDirPtr

        let destDirSector = toDestinationDirName.withCString { cDestName in
            return adfGetEntryBlockNum(vol, parentSector, cDestName)
        }
        
        if destDirSector <= 0 {
            return "Destination directory '\(toDestinationDirName)' not found."
        }
        
        var destBlock = AdfEntryBlock()
        guard adfReadEntryBlock(vol, destDirSector, &destBlock) == ADF_RC_OK, destBlock.secType == ST_DIR_SWIFT else {
            return "'\(toDestinationDirName)' is not a directory."
        }
        
        let success = entryNameToMove.withCString { cEntryNameToMove -> Bool in
            return adfRenameEntry(vol, parentSector, cEntryNameToMove, destDirSector, cEntryNameToMove).rawValue == ADF_RC_OK_SWIFT
        }

        if success {
            log("ADFService: Moved '\(entryNameToMove)' to '\(toDestinationDirName)'.")
            populateDiskInfo()
            return nil
        } else {
            log("ADFService: adfRenameEntry (for move) failed. Check C-Log for details.")
            return "ADFLib failed to move the entry. An entry with the same name may already exist in the destination."
        }
    }
    
    func moveEntryToParent(entryNameToMove: String) -> String? {
        guard let vol = self.adfVolume else { return "Volume not mounted." }
        
        if currentPath.isEmpty {
            return "Cannot move item up from the root directory."
        }

        let sourceDirSector = vol.pointee.curDirPtr
        
        if adfParentDir(vol) != ADF_RC_OK {
            _ = navigateToInternalPath()
            return "Could not navigate to parent directory to perform move."
        }
        let destDirSector = vol.pointee.curDirPtr
        
        let success = entryNameToMove.withCString { cEntryName -> Bool in
            return adfRenameEntry(vol, sourceDirSector, cEntryName, destDirSector, cEntryName).rawValue == ADF_RC_OK_SWIFT
        }

        if success {
            log("ADFService: Moved '\(entryNameToMove)' up to parent directory.")
            populateDiskInfo()
            return nil
        } else {
            _ = navigateToInternalPath()
            log("ADFService: moveEntryToParent failed. Check C-Log.")
            return "ADFLib failed to move the entry up."
        }
    }

    func renameEntry(oldName: String, newName: String) -> String? {
        guard let vol = self.adfVolume else { return "Volume is not open." }
        if newName.isEmpty { return "New name cannot be empty." }
        
        if !navigateToInternalPath() {
            return "Failed to navigate to current path."
        }
        
        let parentSector = vol.pointee.curDirPtr
        let success = oldName.withCString { cOldName -> Bool in
            return newName.withCString { cNewName -> Bool in
                return adfRenameEntry(vol, parentSector, cOldName, parentSector, cNewName).rawValue == ADF_RC_OK_SWIFT
            }
        }
        
        if success {
            log("ADFService: Renamed '\(oldName)' to '\(newName)'.")
            return nil
        } else {
            log("ADFService: adfRenameEntry failed. Check C-Log for details.")
            return "ADFLib failed to rename the entry. A file with the new name may already exist."
        }
    }
    
    func renameVolume(newName: String) -> String? {
        guard let vol = self.adfVolume else { return "Volume not mounted." }

        let maxLen = Int(ADF_MAX_NAME_LEN)
        var finalName = newName
        if newName.count > maxLen {
            finalName = String(newName.prefix(maxLen))
        }
        if finalName.contains(":") || finalName.contains("/") {
            return "Volume name cannot contain ':' or '/'."
        }

        let rootBlockSector = adfVolCalcRootBlk(vol)
        var rootBlock = AdfRootBlock()
        guard adfReadRootBlock(vol, UInt32(rootBlockSector), &rootBlock) == ADF_RC_OK else {
            return "Failed to read the volume's root block."
        }

        rootBlock.nameLen = UInt8(finalName.count)
        let cName = finalName.cString(using: .utf8)!
        withUnsafeMutableBytes(of: &rootBlock.diskName) { buffer in
            buffer.baseAddress?.initializeMemory(as: UInt8.self, repeating: 0, count: buffer.count)
            
            cName.withUnsafeBytes { cNameBuffer in
                let count = min(buffer.count - 1, cNameBuffer.count)
                buffer.baseAddress!.copyMemory(from: cNameBuffer.baseAddress!, byteCount: count)
            }
        }
        
        guard adfWriteRootBlock(vol, UInt32(rootBlockSector), &rootBlock) == ADF_RC_OK else {
            return "Failed to write the updated root block."
        }

        finalName.withCString { cFinalName in
            adf_set_vol_name(vol, cFinalName)
        }

        populateDiskInfo()
        return nil
    }
    
    func exportEntry(entry: AmigaEntry, toDirectory destinationURL: URL) -> String? {
        let originalPath = self.currentPath
        let result = _exportRecursively(entry: entry, toDirectory: destinationURL)
        
        self.currentPath = originalPath
        if !navigateToInternalPath() {
            return "Critical Error: Failed to restore ADF path after export. Please reopen the ADF."
        }
        
        return result
    }

    private func _exportRecursively(entry: AmigaEntry, toDirectory destinationURL: URL) -> String? {
        let exportPath = destinationURL.appendingPathComponent(entry.name)
        
        if entry.type == .file {
            guard let fileData = readFileContent(entry: entry) else {
                return "Could not read content of file '\(entry.name)' from ADF."
            }
            do {
                try fileData.write(to: exportPath)
            } catch {
                return "Failed to write file '\(entry.name)' to local disk: \(error.localizedDescription)"
            }
        } else if entry.type == .directory {
            do {
                try FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return "Failed to create local directory for '\(entry.name)': \(error.localizedDescription)"
            }
            
            if !navigateToDirectory(entry.name) {
                return "Failed to navigate into ADF directory '\(entry.name)'."
            }
            
            let children = listCurrentDirectory()
            for child in children {
                if let error = _exportRecursively(entry: child, toDirectory: exportPath) {
                    _ = goUpDirectory()
                    return error
                }
            }
            
            if !goUpDirectory() {
                 return "Failed to navigate out of directory '\(entry.name)' after emptying it. Cannot complete deletion."
            }
        }
        
        return nil
    }

    func createNewBlankADF(volumeName: String, fsType: UInt8, bootBlockType: NewADFDialogView.BootBlockType) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "blank_\(UUID().uuidString).adf"
        let tempURL = tempDir.appendingPathComponent(fileName)
        let tempPath = tempURL.path
        
        log("ADFService: Creating new blank ADF at: \(tempPath) with FS Type: \(fsType)")
        
        let success = tempPath.withCString { cPath in
            volumeName.withCString { cVolName in
                return create_blank_adf_c(cPath, cVolName, fsType).rawValue == ADF_RC_OK_SWIFT
            }
        }

        guard success else {
            log("ADFService: create_blank_adf_c helper failed.")
            return nil
        }
        
        // Open the newly created ADF to install the bootblock if needed.
        if openADF(filePath: tempPath) {
            log("ADFService: Successfully created blank ADF. Now checking for boot block installation.")
            
            var installError: String? = nil
            switch bootBlockType {
            case .generic:
                // Do nothing, the generic boot block is already there.
                log("ADFService: Generic boot block selected. No installation needed.")
                break
            case .kick1_3:
                log("ADFService: Installing Kickstart 1.3 boot block.")
                installError = installBootBlock(data: kick13BootBlock)
            case .kick2_0:
                log("ADFService: Installing Kickstart 2.0+ boot block.")
                installError = installBootBlock(data: kick20BootBlock)
            }
            
            if let error = installError {
                log("ADFService: Boot block installation failed: \(error)")
                closeADF() // clean up
                return nil // Indicate failure
            }
            
            log("ADFService: Successfully created and configured new ADF.")
            return tempURL
        } else {
            log("ADFService: Failed to open the newly created ADF for boot block installation.")
            return nil
        }
    }
    
    private func installBootBlock(data: Data) -> String? {
        guard let vol = self.adfVolume else {
            return "Volume is not mounted."
        }

        let result = data.withUnsafeBytes { (bufferPtr: UnsafeRawBufferPointer) -> ADF_RETCODE in
            let unsafePointer = bufferPtr.baseAddress?.assumingMemoryBound(to: UInt8.self)
            return install_bootblock_c(vol, unsafePointer)
        }

        if result.rawValue == ADF_RC_OK_SWIFT {
            log("ADFService: Boot block installed successfully.")
            // Re-populate disk info as the bootable status might have changed.
            populateDiskInfo()
            return nil
        } else {
            let errorMsg = "ADFlib failed to install the boot block. Check C-Log."
            log("ADFService: \(errorMsg)")
            return errorMsg
        }
    }

    
    func setProtectionBits(for entry: AmigaEntry, newBits: UInt32) -> String? {
        guard let vol = self.adfVolume else { return "Volume is not open." }

        if !navigateToInternalPath() {
            return "Failed to navigate to the entry's directory."
        }
        
        let parentSector = vol.pointee.curDirPtr
        let result = entry.name.withCString { cName in
            return adfSetEntryAccess(vol, parentSector, cName, Int32(bitPattern: newBits))
        }
        
        if result.rawValue == ADF_RC_OK_SWIFT {
            log("ADFService: Successfully set protection bits for '\(entry.name)'.")
            return nil
        } else {
            log("ADFService: adfSetEntryAccess failed for '\(entry.name)'. Check C-Log for details.")
            return "ADFLib failed to set permissions for the entry."
        }
    }
}
