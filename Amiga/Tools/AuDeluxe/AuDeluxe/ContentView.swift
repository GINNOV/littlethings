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
    @State private var isShowingSettings = false

    var body: some View {
        VStack {
            headerView
            
            // Show song details if available
            if let details = engine.songDetails {
                Text(details)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
            }
            
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
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
                .environmentObject(settings)
        }
        .onAppear(perform: initializeEngineIfNeeded)
        .onChange(of: settings.romsFolderURL) {
            initializeEngineIfNeeded()
        }
    }

    // MARK: - Subviews
    private var headerView: some View {
        VStack {
            Text("AuDeluxe")
                .font(.largeTitle)
            
            if let songInfo = engine.currentSongInfo {
                Text(songInfo)
                    .font(.headline)
                    .foregroundColor(.accentColor)
                    .lineLimit(1)
            } else {
                Text("Select a song to play")
                    .font(.headline)
                    .foregroundColor(.secondary)
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
            Text("Please select your music folder in the settings.")
            Button("Open Settings") {
                isShowingSettings = true
            }
            .padding(.top)
            Spacer()
        }
    }

    // MARK: - Logic
    private func initializeEngineIfNeeded() {
        if let url = settings.romsFolderURL, !engine.isUadeInitialized {
            engine.initializeUade(romsURL: url)
        }
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
            // Filter the list to only include files that UADE reports as playable.
            musicFiles = contents.filter { engine.isPlayable(fileURL: $0) }
                                 .sorted { $0.lastPathComponent < $1.lastPathComponent }
            print("Found \(musicFiles.count) playable files.")
        } catch {
            print("Error scanning music folder: \(error.localizedDescription)")
            musicFiles = []
        }
    }
}
