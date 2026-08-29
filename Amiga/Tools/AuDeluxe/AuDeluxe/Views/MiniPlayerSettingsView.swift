import SwiftUI

struct MiniPlayerSettingsView: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        Form {
            Section("Menu Bar Mini Player") {
                Toggle("Hide AuDeluxe from the Dock when its window is minimized", isOn: $settings.hideDockIconWhenMinimized)
                Text("AuDeluxe continues running from the menu bar. Click its speaker icon, then choose Show AuDeluxe to restore the main window and Dock icon.")
                    .foregroundStyle(.secondary)
            }
            Section {
                Label("Playback continues while the main window is hidden.", systemImage: "speaker.wave.2")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
