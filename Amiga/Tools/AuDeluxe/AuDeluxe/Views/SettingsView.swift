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
        HStack(spacing: 0) {
            // Left Side: Image
            VStack {
                Image("prefs")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
            .frame(width: 180)
            .background(Color(NSColor.windowBackgroundColor))

            // Right Side: Controls
            VStack(alignment: .leading, spacing: 25) {
                Text("Settings")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)

                // Music Folder Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Music Folder")
                        .font(.title2)
                    Text("Select the folder containing your music files (.mod, .s3m, .xm, etc.). This will be scanned recursively.")
                        .font(.callout)
                        .foregroundColor(.secondary)

                    if let path = folderPath(for: settings.musicFolderURL) {
                        Text("Current: \(path)")
                            .font(.footnote)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    
                    HStack {
                        Button("Select Music Folder...") { settings.selectMusicFolder() }
                        if settings.musicFolderBookmark != nil {
                            Button("Clear") { settings.clearMusicFolder() }
                        }
                    }
                }

                Divider()

                // Default Sort Order Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Playlist")
                        .font(.title2)
                    Picker("Default Sort Order:", selection: $settings.defaultSortOrder) {
                        ForEach(SortOrder.allCases) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(.radioGroup)
                }

                Spacer()
            }
            .padding(30)
            .frame(minWidth: 400)
        }
        .frame(minHeight: 350)
    }
    
    private func folderPath(for url: URL?) -> String? {
        guard let url = url else { return nil }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        return url.path
    }
}
