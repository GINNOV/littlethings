//
//  RecentFilesService.swift
//  ADFinder
//
//  Created by Mario Esposito on 6/14/25.
//

import SwiftUI

@Observable
class RecentFilesService {
    // The key for storing recent file data in UserDefaults.
    private let recentsKey = "recentADFFilePaths"
    // The maximum number of recent files to keep.
    private let maxRecents = 10
    private var recentFilePaths: [String] = []

    // A computed property that converts the stored paths back into URL objects.
    // This is the property that views will access.
    var recentFiles: [URL] {
        recentFilePaths.compactMap { URL(fileURLWithPath: $0) }
    }
    
    init() {
        self.recentFilePaths = UserDefaults.standard.stringArray(forKey: recentsKey) ?? []
    }
    
    private func save() {
        UserDefaults.standard.set(recentFilePaths, forKey: recentsKey)
    }
    
    /// Adds a new URL to the top of the recents list.
    /// It ensures the URL is for an ADF file, removes any existing duplicate,
    // and trims the list to the maximum allowed count.
    // RecentFilesService.swift
    func addRecentFile(_ url: URL) {
        let ext = url.pathExtension.lowercased()
        guard ["adf", "hdf"].contains(ext) else { return }

        let path = url.path
        recentFilePaths.removeAll { $0 == path }
        recentFilePaths.insert(path, at: 0)
        recentFilePaths = Array(recentFilePaths.prefix(maxRecents))
        save()
    }
    
    /// Clears the entire list of recent files.
    func clearRecents() {
        recentFilePaths.removeAll()
        // Save the empty list.
        save()
    }
}
