import SwiftUI

struct ContentView: View {
    // The new engine is much simpler and always ready to go.
    @EnvironmentObject private var engine: OpenMPTEngine
    @EnvironmentObject private var settings: SettingsStore
    
    @State private var musicFiles: [URL] = []

    var body: some View {
        VStack {
            headerView
            
            if let details = engine.songDetails {
                Text(details)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
            }
            
            if let musicURL = settings.musicFolderURL {
                // Pass the musicURL to the playlistView
                playlistView(musicURL: musicURL)
                    .onAppear { scanMusicFolder(url: musicURL) }
                    .onChange(of: settings.musicFolderURL) { _, newValue in
                        scanMusicFolder(url: newValue)
                    }
            } else {
                setupPromptView
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }

    // MARK: - Subviews
    private var headerView: some View {
        VStack {
            Text("AuDeluxe")
                .font(.largeTitle)
            
            HStack {
                if engine.isPlaying {
                    Button(action: { engine.stop() }) {
                        Image(systemName: "stop.fill")
                    }
                }
                Text(engine.currentSongInfo ?? "Select a song to play")
                    .font(.headline)
                    .foregroundColor(engine.isPlaying ? .accentColor : .secondary)
                    .lineLimit(1)
            }
        }
        .padding()
    }

    // The playlistView now accepts the music folder URL as a parameter.
    private func playlistView(musicURL: URL) -> some View {
        List(musicFiles, id: \.self) { fileURL in
            Button(action: {
                // Pass the required musicFolderURL parameter to the play function.
                engine.play(fileURL: fileURL, musicFolderURL: musicURL)
            }) {
                Text(fileURL.lastPathComponent)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var setupPromptView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "music.note.house")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Music Folder Selected")
                .font(.title2)
            Text("Please select your music folder in Settings (Cmd+,).")
            Spacer()
        }
    }

    // MARK: - Logic
    private func scanMusicFolder(url: URL?) {
        guard let url = url else {
            musicFiles = []
            return
        }
        
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            // Use the new engine's isPlayable method for filtering.
            musicFiles = contents.filter { engine.isPlayable(fileURL: $0) }
                                 .sorted { $0.lastPathComponent < $1.lastPathComponent }
            print("Found \(musicFiles.count) playable files.")
        } catch {
            print("Error scanning music folder: \(error.localizedDescription)")
            musicFiles = []
        }
    }
}
