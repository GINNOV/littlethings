//
//  ContentView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

//
//  ContentView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var engine: UADEEngine
    
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
            
            // The UI is gated by selecting a music folder, but the engine's
            // core functionality is now self-contained.
            if let musicURL = settings.musicFolderURL {
                playlistView
                    .onAppear { scanMusicFolder(url: musicURL) }
                    .onChange(of: settings.musicFolderURL) { _, newValue in
                        scanMusicFolder(url: newValue)
                    }
            } else {
                setupPromptView
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear(perform: initializeEngineIfNeeded)
        // Re-initialize the engine if any relevant setting changes.
        .onChange(of: settings.filterType) { initializeEngineIfNeeded() }
        .onChange(of: settings.panning) { initializeEngineIfNeeded() }
        .onChange(of: settings.gain) { initializeEngineIfNeeded() }
        .onChange(of: settings.headphonesEnabled) { initializeEngineIfNeeded() }
        .onChange(of: settings.ntscEnabled) { initializeEngineIfNeeded() }
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

    private var playlistView: some View {
        List(musicFiles, id: \.self) { fileURL in
            Button(action: {
                engine.play(fileURL: fileURL)
            }) {
                Text(fileURL.lastPathComponent)
            }
            .buttonStyle(.plain)
        }
        .disabled(!engine.isUadeInitialized)
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
    private func initializeEngineIfNeeded() {
        // The engine can now initialize itself without the ROMs path,
        // as it uses the bundled resources.
        engine.initializeUade(settings: settings)
    }
    
    private func scanMusicFolder(url: URL?) {
        guard let url = url, engine.isUadeInitialized else {
            musicFiles = []
            return
        }
        
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            musicFiles = contents.filter { engine.isPlayable(fileURL: $0) }
                                 .sorted { $0.lastPathComponent < $1.lastPathComponent }
            print("Found \(musicFiles.count) playable files.")
        } catch {
            print("Error scanning music folder: \(error.localizedDescription)")
            musicFiles = []
        }
    }
}
