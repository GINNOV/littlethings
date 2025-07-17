//
//  PreviewViewController.swift
//  AuDeluxeQuickLook
//
//  Created by Mario Esposito on 7/17/25.
//

import Cocoa
import Quartz
import SwiftUI
import os.log // 1. Import the logging framework

class PreviewViewController: NSViewController, QLPreviewingController {
    
    // 2. Create a logger instance for this view
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "QuickLook")
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }

    override func loadView() {
        super.loadView()
        // Do any view setup here.
    }
    
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        
        logger.log("Preparing preview for file: \(url.path, privacy: .public)")

        guard let item = getMetadata(for: url) else {
            logger.error("Failed to get metadata for file.")
            let errorView = NSHostingView(rootView: Text("Unable to preview file."))
            self.view.addSubview(errorView)
            errorView.frame = self.view.bounds
            handler(nil)
            return
        }
        
        logger.log("Successfully got metadata: \(item.title)")
        
        let preview = InspectorView(item: item)
        let hostingView = NSHostingView(rootView: preview)
        
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        logger.log("Preview view prepared successfully.")
        
        handler(nil)
    }
    
    private func getMetadata(for fileURL: URL) -> PlaylistItem? {
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
