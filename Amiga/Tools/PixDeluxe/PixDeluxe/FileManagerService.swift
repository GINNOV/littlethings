//
//  FileManagerService.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/5/25.
//

import SwiftUI

class FileManagerService: ObservableObject {
    @Published var recentFiles: [URL] = []
    
    @AppStorage("recentFileBookmarks") private var recentFileBookmarksData: Data = Data()
    
    init() {
        loadRecentFilesFromBookmarks()
    }
    
    func addRecentFile(url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            var bookmarks = (try? JSONDecoder().decode([Data].self, from: recentFileBookmarksData)) ?? []
            
            if let index = recentFiles.firstIndex(of: url) {
                recentFiles.remove(at: index)
                if index < bookmarks.count {
                    bookmarks.remove(at: index)
                }
            }

            recentFiles.insert(url, at: 0)
            bookmarks.insert(bookmarkData, at: 0)
            
            if recentFiles.count > 10 {
                recentFiles.removeLast()
                bookmarks.removeLast()
            }
            
            recentFileBookmarksData = (try? JSONEncoder().encode(bookmarks)) ?? Data()
            print("💾 Saved bookmark for: \(url.lastPathComponent)")

        } catch {
            print("❌ Error creating or saving bookmark for \(url.path): \(error.localizedDescription)")
        }
    }
    
    func clearRecents() {
        recentFiles.removeAll()
        recentFileBookmarksData = Data()
        print("Cleared all recent files.")
    }

    private func loadRecentFilesFromBookmarks() {
        guard let bookmarks = try? JSONDecoder().decode([Data].self, from: recentFileBookmarksData) else {
            return
        }
        
        var resolvedURLs: [URL] = []
        var updatedBookmarks: [Data] = []

        for bookmarkData in bookmarks {
            do {
                var isStale = false
                let resolvedURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                
                if isStale {
                     print("🗑️ Removing stale bookmark.")
                } else {
                    resolvedURLs.append(resolvedURL)
                    updatedBookmarks.append(bookmarkData)
                }
            } catch {
                print("❌ Error resolving bookmark, removing it: \(error.localizedDescription)")
            }
        }
        
        self.recentFiles = resolvedURLs
        self.recentFileBookmarksData = (try? JSONEncoder().encode(updatedBookmarks)) ?? Data()
        print("📚 Loaded \(recentFiles.count) recent files from bookmarks.")
    }
}
