//
//  PreviewViewController.swift
//  AuDeluxeQL
//
//  Created by Mario Esposito on 7/17/25.
//

import Cocoa
import Quartz
import SwiftUI
import os.log

let logger = Logger(subsystem: "com.theblifemovement.AuDeluxe.AuDeluxeQL", category: "Preview")

class PreviewViewController: NSViewController, QLPreviewingController {
    
    func preparePreviewOfFile(at url: URL) async throws {
        
        logger.log("Starting async preview for file: \(url.path, privacy: .public)")

        guard let item = getMetadata(for: url) else {
            logger.error("Failed to get metadata for file. Throwing error.")
            struct MetadataError: LocalizedError {
                var errorDescription: String? { "Could not read the module's metadata." }
            }
            throw MetadataError()
        }
        
        logger.log("Successfully got metadata for: \(item.title)")
        
        // Use the new dedicated view
        let previewSwiftUIView = AuDeluxePreviewView(item: item)
        
        let hostingController = NSHostingController(rootView: previewSwiftUIView)
        
        self.view.addSubview(hostingController.view)
        hostingController.view.frame = self.view.bounds
        hostingController.view.autoresizingMask = [.width, .height]
        
        self.preferredContentSize = NSSize(width: 550, height: 450)
        
        logger.log("Preview preparation complete.")
    }
    
    private func getMetadata(for fileURL: URL) -> PlaylistItem? {
        // ... (this function remains the same) ...
        logger.log("Attempting to get metadata for URL: \(fileURL.path, privacy: .public)")
        
        guard let data = try? Data(contentsOf: fileURL) else {
            logger.error("Failed to read data from file.")
            return nil
        }
        logger.log("Successfully read \(data.count) bytes.")

        let modulePtr = data.withUnsafeBytes { openmpt_module_create_from_memory2($0.baseAddress, $0.count, nil, nil, nil, nil, nil, nil, nil) }
        guard let mod = modulePtr else {
            logger.error("libopenmpt failed to create module from memory.")
            return nil
        }
        defer { openmpt_module_destroy(mod) }
        logger.log("libopenmpt module created successfully.")
        
        var metadataDict: [String: String] = [:]
        if let keysCString = openmpt_module_get_metadata_keys(mod) {
            let keysString = String(cString: keysCString)
            let keys = keysString.components(separatedBy: ";")
            openmpt_free_string(keysCString)
            for key in keys {
                if let valueCString = openmpt_module_get_metadata(mod, key) {
                    metadataDict[key] = String(cString: valueCString)
                    openmpt_free_string(valueCString)
                }
            }
        }
        
        let duration = openmpt_module_get_duration_seconds(mod)
        metadataDict["duration"] = "\(duration)"
        
        if metadataDict["title"] == nil || metadataDict["title"]!.isEmpty {
            metadataDict["title"] = fileURL.deletingPathExtension().lastPathComponent
        }
        
        return PlaylistItem(fileURL: fileURL, metadata: metadataDict, rating: 0)
    }
}
