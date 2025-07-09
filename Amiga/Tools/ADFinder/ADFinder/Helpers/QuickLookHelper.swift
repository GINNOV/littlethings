//
//  QuickLookHelper.swift
//  ADFinder
//
//  Created by Mario Esposito on 7/9/25.
//

import AppKit
import Quartz

// It manages the temporary file URL and handles cleanup when the panel is closed.
class QuickLookHelper: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    
    var previewItemURL: URL?

    // MARK: - QLPreviewPanelDataSource
    
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return previewItemURL == nil ? 0 : 1
    }

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        guard let url = previewItemURL else {
            return nil
        }
        // The QLPreviewItem is simply a URL pointing to the temporary file.
        return url as QLPreviewItem
    }

    // MARK: - QLPreviewPanelDelegate
    
    // This delegate method is crucial for cleanup. When the Quick Look panel
    // is closed, this method is called, allowing us to delete the temporary file.
    func previewPanelWillClose(_ panel: QLPreviewPanel!) {
        if let url = previewItemURL {
            do {
                try FileManager.default.removeItem(at: url)
                print("QuickLookHelper: Deleted temporary file at \(url.path)")
            } catch {
                print("QuickLookHelper: Error deleting temporary file: \(error.localizedDescription)")
            }
            previewItemURL = nil
        }
    }
}
