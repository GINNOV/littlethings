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
    private static let maximumPreviewSize = 64 * 1_024 * 1_024

    func preparePreviewOfFile(at url: URL) async throws {
        logger.log("Starting async preview for file: \(url.lastPathComponent, privacy: .private)")

        guard let item = try getMetadata(for: url) else {
            logger.error("Failed to get metadata for file. Throwing error.")
            throw MetadataError()
        }
        
        logger.log("Successfully got metadata for: \(item.title)")
        
        // Use the new dedicated view
        let previewSwiftUIView = AuDeluxePreviewView(item: item)
        
        let hostingController = NSHostingController(rootView: previewSwiftUIView)

        children.forEach { child in
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        addChild(hostingController)
        self.view.addSubview(hostingController.view)
        hostingController.view.frame = self.view.bounds
        hostingController.view.autoresizingMask = [.width, .height]
        
        self.preferredContentSize = NSSize(width: 550, height: 450)
        
        logger.log("Preview preparation complete.")
    }
    
    private func getMetadata(for fileURL: URL) throws -> PlaylistItem? {
        logger.log("Attempting to get metadata for: \(fileURL.lastPathComponent, privacy: .private)")

        let values = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
        guard values.isRegularFile == true,
              let fileSize = values.fileSize,
              fileSize > 0,
              fileSize <= Self.maximumPreviewSize else {
            throw MetadataError()
        }

        let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
        guard data.count <= Self.maximumPreviewSize else { throw MetadataError() }
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

private struct MetadataError: LocalizedError {
    var errorDescription: String? { "Could not safely read the module's metadata." }
}
