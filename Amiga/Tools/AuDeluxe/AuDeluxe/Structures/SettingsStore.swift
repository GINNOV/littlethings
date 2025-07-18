//
//  SettingsStore.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import SwiftUI
import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    // MARK: - Published Properties
    @Published var musicFolderBookmark: Data?
    @Published var defaultSortOrder: SortOrder {
        didSet {
            userDefaults.set(defaultSortOrder.rawValue, forKey: defaultSortOrderKey)
        }
    }
    @Published var playlists: [Playlist] = []

    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let musicFolderBookmarkKey = "musicFolderBookmark"
    private let defaultSortOrderKey = "defaultSortOrder"
    private let playlistsKey = "customPlaylists"

    init() {
        self.musicFolderBookmark = userDefaults.data(forKey: musicFolderBookmarkKey)
        if let savedSortOrder = userDefaults.string(forKey: defaultSortOrderKey),
           let sortOrder = SortOrder(rawValue: savedSortOrder) {
            self.defaultSortOrder = sortOrder
        } else {
            self.defaultSortOrder = .name
        }
        
        loadPlaylists()
        print("SettingsStore initialized.")
    }

    // MARK: - Computed URL
    var musicFolderURL: URL? {
        resolveBookmark(musicFolderBookmark)
    }

    // MARK: - Public Methods
    func selectMusicFolder() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select your Amiga Music folder"
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            saveBookmark(for: url)
        }
    }
    
    func clearMusicFolder() {
        musicFolderBookmark = nil
        userDefaults.removeObject(forKey: musicFolderBookmarkKey)
    }
    
    // MARK: - Playlist Management
    func savePlaylist(_ playlist: Playlist) {
        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            playlists[index] = playlist
        } else {
            playlists.append(playlist)
        }
        persistPlaylists()
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        playlists.removeAll { $0.id == playlist.id }
        persistPlaylists()
    }
    
    private func loadPlaylists() {
        if let data = userDefaults.data(forKey: playlistsKey) {
            do {
                let decodedPlaylists = try JSONDecoder().decode([Playlist].self, from: data)
                self.playlists = decodedPlaylists
            } catch {
                print("Error decoding playlists: \(error)")
            }
        }
    }
    
    private func persistPlaylists() {
        do {
            let data = try JSONEncoder().encode(playlists)
            userDefaults.set(data, forKey: playlistsKey)
        } catch {
            print("Error encoding playlists: \(error)")
        }
    }

    // MARK: - Private Helper Methods
    private func saveBookmark(for url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            self.musicFolderBookmark = bookmarkData
            userDefaults.set(bookmarkData, forKey: musicFolderBookmarkKey)
            print("Successfully saved music folder bookmark.")
        } catch {
            print("Error creating bookmark: \(error.localizedDescription)")
        }
    }

    private func resolveBookmark(_ bookmarkData: Data?) -> URL? {
        guard let bookmark = bookmarkData else { return nil }
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                print("Bookmark is stale, will be refreshed on next save.")
                saveBookmark(for: url)
            }
            return url
        } catch {
            print("Error resolving bookmark: \(error.localizedDescription)")
            return nil
        }
    }
}
