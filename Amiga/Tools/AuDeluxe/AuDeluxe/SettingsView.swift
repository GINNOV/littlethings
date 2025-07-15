//
//  SettingsView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .padding(.bottom)

            // Folder Settings
            folderSettings
            
            Divider()
            
            // Audio Settings
            audioSettings

            Spacer()
        }
        .padding(30)
        .frame(minWidth: 550, minHeight: 650)
    }
    
    private var folderSettings: some View {
        VStack(alignment: .leading, spacing: 20) {
            // ROMs Folder Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Kickstart ROMs Folder").font(.title2)
                Text("UADE requires access to the Kickstart ROM files.").font(.callout).foregroundColor(.secondary)
                if let path = folderPath(for: settings.romsFolderURL) {
                    Text("Current: \(path)").font(.footnote).lineLimit(1).truncationMode(.middle)
                }
                HStack {
                    Button("Select ROMs Folder...") { settings.selectRomsFolder() }
                    if settings.romsFolderBookmark != nil { Button("Clear") { settings.clearRomsFolder() } }
                }
            }
            // Music Folder Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Music Folder").font(.title2)
                Text("Select the folder containing your Amiga music files.").font(.callout).foregroundColor(.secondary)
                if let path = folderPath(for: settings.musicFolderURL) {
                    Text("Current: \(path)").font(.footnote).lineLimit(1).truncationMode(.middle)
                }
                HStack {
                    Button("Select Music Folder...") { settings.selectMusicFolder() }
                    if settings.musicFolderBookmark != nil { Button("Clear") { settings.clearMusicFolder() } }
                }
            }
        }
    }
    
    private var audioSettings: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Audio Options").font(.title2)
            
            Picker("Filter Emulation", selection: $settings.filterType) {
                ForEach(FilterType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            VStack(alignment: .leading) {
                Text("Panning: \(settings.panning, specifier: "%.2f")")
                Slider(value: $settings.panning, in: 0.0...1.0)
            }
            
            VStack(alignment: .leading) {
                Text("Gain: \(settings.gain, specifier: "%.2f")")
                Slider(value: $settings.gain, in: 0.0...1.0)
            }
            
            Toggle("Headphones Effect", isOn: $settings.headphonesEnabled)
            Toggle("NTSC (60Hz) Timing", isOn: $settings.ntscEnabled)
        }
    }
    
    private func folderPath(for url: URL?) -> String? {
        guard let url = url else { return nil }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        return url.path
    }
}
