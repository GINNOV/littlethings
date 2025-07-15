//
//  SettingsStore.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import SwiftUI
import Foundation

// Enum for the Filter Type setting for type safety
enum FilterType: String, CaseIterable, Identifiable {
    case a500 = "A500"
    case a1200 = "A1200"
    var id: Self { self }
}

@MainActor
final class SettingsStore: ObservableObject {
    // MARK: - Published Properties
    @Published var romsFolderBookmark: Data?
    @Published var musicFolderBookmark: Data?
    
    // New Audio Settings
    @AppStorage("filterType") var filterType: FilterType = .a1200
    @AppStorage("panning") var panning: Double = 0.7
    @AppStorage("gain") var gain: Double = 1.0
    @AppStorage("headphonesEnabled") var headphonesEnabled: Bool = false
    @AppStorage("ntscEnabled") var ntscEnabled: Bool = false

    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let romsFolderBookmarkKey = "romsFolderBookmark"
    private let musicFolderBookmarkKey = "musicFolderBookmark"

    init() {
        self.romsFolderBookmark = userDefaults.data(forKey: romsFolderBookmarkKey)
        self.musicFolderBookmark = userDefaults.data(forKey: musicFolderBookmarkKey)
        print("SettingsStore initialized.")
    }

    // MARK: - Computed URLs
    var romsFolderURL: URL? { resolveBookmark(romsFolderBookmark) }
    var musicFolderURL: URL? { resolveBookmark(musicFolderBookmark) }

    // MARK: - Public Methods
    func selectRomsFolder() {
        if let url = selectFolder(title: "Select your Amiga Kickstart ROMs folder") {
            saveBookmark(for: url, key: romsFolderBookmarkKey, property: \.romsFolderBookmark)
        }
    }

    func selectMusicFolder() {
        if let url = selectFolder(title: "Select your Amiga Music folder") {
            saveBookmark(for: url, key: musicFolderBookmarkKey, property: \.musicFolderBookmark)
        }
    }
    
    func clearRomsFolder() {
        romsFolderBookmark = nil
        userDefaults.removeObject(forKey: romsFolderBookmarkKey)
    }

    func clearMusicFolder() {
        musicFolderBookmark = nil
        userDefaults.removeObject(forKey: musicFolderBookmarkKey)
    }

    // MARK: - Private Helper Methods
    private func selectFolder(title: String) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.title = title
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        return openPanel.runModal() == .OK ? openPanel.url : nil
    }
    
    private func saveBookmark(for url: URL, key: String, property: ReferenceWritableKeyPath<SettingsStore, Data?>) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            self[keyPath: property] = bookmarkData
            userDefaults.set(bookmarkData, forKey: key)
        } catch {
            print("Error creating bookmark for key \(key): \(error.localizedDescription)")
        }
    }

    private func resolveBookmark(_ bookmarkData: Data?) -> URL? {
        guard let bookmark = bookmarkData else { return nil }
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale { print("Bookmark is stale, will be refreshed on next save.") }
            return url
        } catch {
            print("Error resolving bookmark: \(error.localizedDescription)")
            return nil
        }
    }
}
