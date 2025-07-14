//
//  SettingsStore.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import SwiftUI
import Foundation

// MARK: - Settings Store (ObservableObject)

// This class is the single source of truth for our application's settings.
// By marking it with @MainActor, we ensure all its updates happen on the main thread,
// which is required for UI changes.
@MainActor
final class SettingsStore: ObservableObject {
    // @Published tells SwiftUI to update any views that use this property whenever it changes.
    // We store the bookmark data for the ROMs folder, not the direct path.
    @Published var romsFolderBookmark: Data?

    // We use UserDefaults to persist the settings between app launches.
    private let userDefaults = UserDefaults.standard
    private let romsFolderBookmarkKey = "romsFolderBookmark"

    init() {
        // When the app starts, we immediately try to load the saved bookmark.
        self.romsFolderBookmark = userDefaults.data(forKey: romsFolderBookmarkKey)
        print("SettingsStore initialized. Loaded bookmark: \(romsFolderBookmark != nil)")
    }

    /// Resolves the stored bookmark data into a usable URL.
    /// Bookmarks are Apple's recommended way to maintain access to file system locations
    /// across app launches and system restarts, even if the user moves or renames the folder.
    var romsFolderURL: URL? {
        guard let bookmark = romsFolderBookmark else {
            print("No bookmark data found.")
            return nil
        }

        do {
            var isStale = false
            // This is the crucial step: we resolve the bookmark data back into a URL.
            let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)

            if isStale {
                // If the bookmark is stale, it means the original folder was moved.
                // We should try to create a new bookmark from the resolved URL and save it.
                print("Bookmark is stale, attempting to refresh.")
                saveRomsFolder(url: url)
            }
            return url
        } catch {
            // If resolving fails, the bookmark is invalid. We should clear it.
            print("Error resolving bookmark: \(error.localizedDescription)")
            clearRomsFolder()
            return nil
        }
    }

    /// Prompts the user to select a folder and saves it as a security-scoped bookmark.
    func selectRomsFolder() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select your Amiga Kickstart ROMs folder"
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false

        // This presents the folder selection dialog to the user.
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                print("Folder selected: \(url.path)")
                saveRomsFolder(url: url)
            }
        }
    }

    /// Saves the URL as security-scoped bookmark data to both the class property and UserDefaults.
    private func saveRomsFolder(url: URL) {
        do {
            // Create the bookmark data. The `.withSecurityScope` option is vital for sandboxed apps
            // to maintain access to the selected folder.
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            // Update the @Published property, which will trigger UI updates.
            self.romsFolderBookmark = bookmarkData
            
            // Persist the bookmark data to UserDefaults for the next app launch.
            userDefaults.set(bookmarkData, forKey: romsFolderBookmarkKey)
            print("Successfully saved bookmark data.")
        } catch {
            print("Error creating bookmark: \(error.localizedDescription)")
        }
    }

    /// Clears the stored bookmark from the property and UserDefaults.
    func clearRomsFolder() {
        self.romsFolderBookmark = nil
        userDefaults.removeObject(forKey: romsFolderBookmarkKey)
        print("Cleared ROMs folder bookmark.")
    }
}
