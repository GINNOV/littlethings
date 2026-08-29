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
    @Published var automaticallyPlayNext: Bool {
        didSet {
            userDefaults.set(automaticallyPlayNext, forKey: automaticallyPlayNextKey)
        }
    }
    @Published var checkForUpdatesOnLaunch: Bool { didSet { persist(checkForUpdatesOnLaunch, key: "checkForUpdatesOnLaunch") } }
    @Published var playPlaylistOnLaunch: Bool { didSet { persist(playPlaylistOnLaunch, key: "playPlaylistOnLaunch") } }
    @Published var startupPlaylistID: UUID? { didSet { persist(startupPlaylistID?.uuidString, key: "startupPlaylistID") } }
    @Published var hideDockIconWhenMinimized: Bool { didSet { persist(hideDockIconWhenMinimized, key: "hideDockIconWhenMinimized") } }
    @Published var localAIEnabled: Bool { didSet { persist(localAIEnabled, key: "localAIEnabled") } }
    @Published var localAIProvider: LocalAIProvider { didSet { persist(localAIProvider.rawValue, key: "localAIProvider") } }
    @Published var localAIModelName: String { didSet { persist(localAIModelName, key: "localAIModelName") } }
    @Published var localAIEndpoint: String { didSet { persist(localAIEndpoint, key: "localAIEndpoint") } }

    // MARK: - Private Properties
    private let userDefaults: UserDefaults
    private let musicFolderBookmarkKey = "musicFolderBookmark"
    private let defaultSortOrderKey = "defaultSortOrder"
    private let playlistsKey = "customPlaylists"
    private let automaticallyPlayNextKey = "automaticallyPlayNext"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.musicFolderBookmark = userDefaults.data(forKey: musicFolderBookmarkKey)
        if let savedSortOrder = userDefaults.string(forKey: defaultSortOrderKey),
           let sortOrder = SortOrder(rawValue: savedSortOrder) {
            self.defaultSortOrder = sortOrder
        } else {
            self.defaultSortOrder = .name
        }
        
        // Default to 'true' if the key doesn't exist yet.
        self.automaticallyPlayNext = userDefaults.object(forKey: automaticallyPlayNextKey) as? Bool ?? true
        self.checkForUpdatesOnLaunch = userDefaults.object(forKey: "checkForUpdatesOnLaunch") as? Bool ?? true
        self.playPlaylistOnLaunch = userDefaults.object(forKey: "playPlaylistOnLaunch") as? Bool ?? false
        self.startupPlaylistID = userDefaults.string(forKey: "startupPlaylistID").flatMap(UUID.init(uuidString:))
        self.hideDockIconWhenMinimized = userDefaults.object(forKey: "hideDockIconWhenMinimized") as? Bool ?? false
        self.localAIEnabled = userDefaults.object(forKey: "localAIEnabled") as? Bool ?? false
        self.localAIProvider = LocalAIProvider(rawValue: userDefaults.string(forKey: "localAIProvider") ?? "") ?? .lmStudio
        self.localAIModelName = userDefaults.string(forKey: "localAIModelName") ?? ""
        self.localAIEndpoint = userDefaults.string(forKey: "localAIEndpoint") ?? LocalAIProvider.lmStudio.defaultEndpoint
        
        loadPlaylists()
        print("SettingsStore initialized.")
    }

    var startupPlaylist: Playlist? {
        guard let startupPlaylistID else { return nil }
        return playlists.first { $0.id == startupPlaylistID }
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
        if startupPlaylistID == playlist.id {
            startupPlaylistID = nil
            playPlaylistOnLaunch = false
        }
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

    private func persist(_ value: Any?, key: String) {
        if let value {
            userDefaults.set(value, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
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
