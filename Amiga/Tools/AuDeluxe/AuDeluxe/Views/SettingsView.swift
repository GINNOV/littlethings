import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView().tabItem { Label("General", systemImage: "gearshape") }
            PlaybackSettingsView().tabItem { Label("Playback", systemImage: "play.circle") }
            AISettingsView().tabItem { Label("AI", systemImage: "sparkles") }
            MiniPlayerSettingsView().tabItem { Label("Mini Player", systemImage: "menubar.rectangle") }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .frame(width: 720, height: 700)
    }
}
