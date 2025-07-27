//
//  ADFService+DiskUtilities.swift
//  ADFinder
//
//  Created by Mario Esposito on 7/25/25.
//

import Foundation

extension ADFService {
    
    private func getDownloadURL() -> URL? {
        if let bookmarkData = UserDefaults.standard.data(forKey: "downloadLocationBookmark") {
            do {
                var isStale = false
                let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                if isStale {
                    let newBookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                    UserDefaults.standard.set(newBookmarkData, forKey: "downloadLocationBookmark")
                }
                return url
            } catch {
                print("Error resolving bookmark: \(error.localizedDescription). Falling back to default.")
                return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            }
        } else {
            return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        }
    }

    
    func createDiskDump(fileURL: URL) -> (String?, URL?) {
        var downloadURL: URL?
        var needsToStopAccessing = false
        if let resolvedURL = getDownloadURL() {
            downloadURL = resolvedURL
            if resolvedURL.startAccessingSecurityScopedResource() {
                needsToStopAccessing = true
            }
        } else {
             return ("Could not determine download location.", nil)
        }
        defer {
            if needsToStopAccessing {
                downloadURL?.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            var hexdumpString = ""
            let bytesPerRow = 16
            
            for i in stride(from: 0, to: data.count, by: bytesPerRow) {
                let offsetStr = String(format: "%08x", i)
                let chunk = data[i..<min(i + bytesPerRow, data.count)]
                
                var hexPart = ""
                for (j, byte) in chunk.enumerated() {
                    if j == 8 { hexPart += " " }
                    hexPart += String(format: "%02x ", byte)
                }
                
                var asciiPart = ""
                for byte in chunk {
                    asciiPart += (byte >= 32 && byte <= 126) ? String(UnicodeScalar(byte)) : "."
                }
                
                hexdumpString += "\(offsetStr)  \(hexPart.padding(toLength: bytesPerRow * 3 + 1, withPad: " ", startingAt: 0))|\(asciiPart)|\n"
            }

            guard let finalDownloadURL = downloadURL else {
                return ("Download location is invalid.", nil)
            }

            let baseName = self.volumeLabel.isEmpty ? fileURL.deletingPathExtension().lastPathComponent : self.volumeLabel
            let invalidChars = CharacterSet(charactersIn: ":/\\?%*|\"<>")
            let cleanName = baseName.components(separatedBy: invalidChars).joined(separator: "_")
            let outputURL = finalDownloadURL.appendingPathComponent("\(cleanName)_dump.txt")

            try hexdumpString.write(to: outputURL, atomically: true, encoding: .utf8)
            
            return (nil, outputURL) // Success
        } catch {
            return ("Failed to create disk dump: \(error.localizedDescription)", nil)
        }
    }
    
    func generateDirectoryListing() -> (String?, URL?) {
        guard self.adfVolume != nil else {
            return ("Volume not mounted.", nil)
        }

        let originalPath = self.currentPath
        self.currentPath = []
        _ = navigateToInternalPath()
        
        var output = "Contents of \(self.volumeLabel)\n"
        output += String(repeating: "-", count: 79) + "\n"
        output += " PERMSSN    UID  GID    PACKED    SIZE RATIO     CRC-STAMP         NAME\n"
        output += String(repeating: "-", count: 79) + "\n"

        let listing = _recursiveList(pathPrefix: "")
        output += listing

        self.currentPath = originalPath
        if !navigateToInternalPath() {
            log("ADFService: CRITICAL - Failed to restore path after directory listing.")
        }

        var downloadURL: URL?
        var needsToStopAccessing = false
        if let resolvedURL = getDownloadURL() {
            downloadURL = resolvedURL
            if resolvedURL.startAccessingSecurityScopedResource() {
                needsToStopAccessing = true
            }
        } else {
             return ("Could not determine download location.", nil)
        }
        defer {
            if needsToStopAccessing {
                downloadURL?.stopAccessingSecurityScopedResource()
            }
        }

        do {
            guard let finalDownloadURL = downloadURL else {
                return ("Download location is invalid.", nil)
            }
            let baseName = self.volumeLabel.isEmpty ? "UntitledDisk" : self.volumeLabel
            let invalidChars = CharacterSet(charactersIn: ":/\\?%*|\"<>")
            let cleanName = baseName.components(separatedBy: invalidChars).joined(separator: "_")
            let outputURL = finalDownloadURL.appendingPathComponent("\(cleanName)_dirs.txt")

            try output.write(to: outputURL, atomically: true, encoding: .utf8)
            
            return (nil, outputURL)
        } catch {
            return ("Failed to save directory listing: \(error.localizedDescription)", nil)
        }
    }

    private func protectionBitsToString(_ bits: UInt32) -> String {
        var string = "---"
        string += (bits & FIBF_HOLD_SWIFT) != 0 ? "h" : "-"
        string += (bits & FIBF_SCRIPT_SWIFT) != 0 ? "s" : "-"
        string += (bits & FIBF_PURE_SWIFT) != 0 ? "p" : "-"
        string += (bits & FIBF_ARCHIVE_SWIFT) != 0 ? "a" : "-"
        string += (bits & ACCMASK_R_SWIFT) == 0 ? "r" : "-"
        string += (bits & ACCMASK_W_SWIFT) == 0 ? "w" : "-"
        string += (bits & ACCMASK_E_SWIFT) == 0 ? "e" : "-"
        string += (bits & ACCMASK_D_SWIFT) == 0 ? "d" : "-"
        return string
    }
    
    private func _recursiveList(pathPrefix: String) -> String {
            var resultString = ""
            let entries = self.listCurrentDirectory()

            let sortedEntries = entries.sorted {
                if $0.type == .directory && $1.type != .directory { return true }
                if $0.type != .directory && $1.type == .directory { return false }
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }

            for entry in sortedEntries {
                let fullPath = pathPrefix + entry.name
                
                if entry.type == .directory {
                    let perms = protectionBitsToString(entry.protectionBits).padding(toLength: 10, withPad: " ", startingAt: 0)
                    let line = "\(perms)    0    0         -       - ---       ---- -------- \(fullPath)/\n"
                    resultString += line
                    
                    let parentPath = self.currentPath
                    if navigateToDirectory(entry.name) {
                        resultString += _recursiveList(pathPrefix: fullPath + "/")
                        self.currentPath = parentPath
                        _ = self.navigateToInternalPath()
                    }
                } else if entry.type == .file {
                    let perms = protectionBitsToString(entry.protectionBits).padding(toLength: 10, withPad: " ", startingAt: 0)
                    let sizeStr = String(entry.size).padding(toLength: 8, withPad: " ", startingAt: 0)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MMM-yyyy"
                    let dateStr = dateFormatter.string(from: entry.date).padding(toLength: 12, withPad: " ", startingAt: 0)

                    let line = "\(perms)    0    0 \(sizeStr) \(sizeStr) 100.0%%    ---- \(dateStr) \(fullPath)\n"
                    resultString += line
                }
            }
            return resultString
        }
}
