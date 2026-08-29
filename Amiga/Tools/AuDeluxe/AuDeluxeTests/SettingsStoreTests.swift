import Foundation
import Testing
@testable import AuDeluxe

@MainActor
struct SettingsStoreTests {
    @Test("New preferences persist across settings-store instances")
    func newPreferencesPersist() throws {
        let suiteName = "SettingsStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let playlistID = UUID()

        let settings = SettingsStore(userDefaults: defaults)
        settings.checkForUpdatesOnLaunch = false
        settings.playPlaylistOnLaunch = true
        settings.startupPlaylistID = playlistID
        settings.hideDockIconWhenMinimized = true
        settings.localAIEnabled = true
        settings.localAIProvider = .ollama
        settings.localAIModelName = "qwen2.5"
        settings.localAIEndpoint = "http://localhost:11434"

        let restored = SettingsStore(userDefaults: defaults)
        #expect(restored.checkForUpdatesOnLaunch == false)
        #expect(restored.playPlaylistOnLaunch)
        #expect(restored.startupPlaylistID == playlistID)
        #expect(restored.hideDockIconWhenMinimized)
        #expect(restored.localAIEnabled)
        #expect(restored.localAIProvider == .ollama)
        #expect(restored.localAIModelName == "qwen2.5")
        #expect(restored.localAIEndpoint == "http://localhost:11434")
    }

    @Test("Startup playlist resolves from saved playlists")
    func startupPlaylistResolves() throws {
        let suiteName = "SettingsStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let playlist = Playlist(name: "Morning", fileURLs: [])
        let settings = SettingsStore(userDefaults: defaults)

        settings.savePlaylist(playlist)
        settings.startupPlaylistID = playlist.id

        #expect(settings.startupPlaylist == playlist)
    }

    @Test("Deleting the startup playlist disables startup playback")
    func deletingStartupPlaylistClearsSelection() throws {
        let suiteName = "SettingsStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let playlist = Playlist(name: "Morning", fileURLs: [])
        let settings = SettingsStore(userDefaults: defaults)
        settings.savePlaylist(playlist)
        settings.startupPlaylistID = playlist.id
        settings.playPlaylistOnLaunch = true

        settings.deletePlaylist(playlist)

        #expect(settings.startupPlaylistID == nil)
        #expect(settings.playPlaylistOnLaunch == false)
    }
}
