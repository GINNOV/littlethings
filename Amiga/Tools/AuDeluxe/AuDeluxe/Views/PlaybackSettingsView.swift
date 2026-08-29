import SwiftUI

struct PlaybackSettingsView: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        Form {
            Section("Playback") {
                Toggle("Automatically play the next module", isOn: $settings.automaticallyPlayNext)
                Toggle("Start playing a playlist when AuDeluxe opens", isOn: $settings.playPlaylistOnLaunch)
                    .disabled(settings.playlists.isEmpty)
                Picker("Startup playlist", selection: $settings.startupPlaylistID) {
                    Text("Choose a playlist").tag(UUID?.none)
                    ForEach(settings.playlists) { playlist in Text(playlist.name).tag(Optional(playlist.id)) }
                }
                .disabled(!settings.playPlaylistOnLaunch || settings.playlists.isEmpty)
            }
            Section {
                Text(settings.playlists.isEmpty
                     ? "Create a playlist from the Playlist toolbar menu before enabling startup playback."
                     : "AuDeluxe starts with the first available song in the selected playlist after the library index has loaded.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
