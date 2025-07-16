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

            // Music Folder Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Music Folder")
                    .font(.title2)
                Text("Select the folder containing your music files (.mod, .s3m, .xm, etc.).")
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

            Spacer()
        }
        .padding(30)
        .frame(minWidth: 500, minHeight: 200)
    }
    
    private func folderPath(for url: URL?) -> String? {
        guard let url = url else { return nil }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        return url.path
    }
}
