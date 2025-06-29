//
//  RecentFilesManager.swift
//  ILBMViewer
//
//  Created by Mario Esposito on 6/18/25.
//

import Foundation

class RecentFilesManager: ObservableObject {
    @Published var files: [URL] = []
    private let key = "recentIFFBookmarks"
    private let maxRecents = 10 // Increased to a more common number

    init() {
        loadRecents()
    }

    /// Adds a URL to the recent files list, ensuring no duplicates and respecting the maximum limit.
    /// This method is now corrected to safely handle array manipulation.
    func add(url: URL) {
        // 1. Remove the URL if it already exists to avoid duplicates and ensure it moves to the top.
        files.removeAll { $0 == url }

        // 2. Add the new URL to the top of the list.
        files.insert(url, at: 0)

        // 3. Keep the list at the desired size by removing the last element if over limit.
        if files.count > maxRecents {
            files = Array(files.prefix(maxRecents))
        }

        // 4. Create new bookmark data from the updated URL list. This is more robust
        //    than trying to manipulate the bookmarks array directly.
        let bookmarks = files.compactMap { fileURL in
            try? fileURL.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
        }

        // 5. Save the new, correct array of bookmarks.
        UserDefaults.standard.set(bookmarks, forKey: key)
        
        // 6. The @Published files property is already updated, so no need to call loadRecents().
        //    SwiftUI will automatically pick up the change.
    }

    /// Loads the recent files from UserDefaults by resolving saved bookmarks.
    private func loadRecents() {
        guard let bookmarks = UserDefaults.standard.array(forKey: key) as? [Data] else {
            self.files = []
            return
        }
        
        files = bookmarks.compactMap { bookmark in
            var isStale = false
            // Resolve the bookmark data back into a URL.
            // Using .withSecurityScope is important for sandboxed apps.
            guard let url = try? URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale), !isStale else {
                // If the bookmark is stale (e.g., file was moved or deleted), we discard it.
                return nil
            }
            return url
        }
    }
}
