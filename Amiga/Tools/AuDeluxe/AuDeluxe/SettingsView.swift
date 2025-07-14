//
//  SettingsView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Settings")
                .font(.largeTitle)
                .frame(maxWidth: .infinity)

            // ROMs Folder Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Kickstart ROMs Folder")
                    .font(.title2)
                Text("UADE requires access to the Kickstart ROM files.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                if let path = folderPath(for: settings.romsFolderURL) {
                    Text("Current: \(path)")
                        .font(.footnote).lineLimit(1).truncationMode(.middle)
                }

                HStack {
                    Button("Select ROMs Folder...") { settings.selectRomsFolder() }
                    if settings.romsFolderBookmark != nil {
                        Button("Clear") { settings.clearRomsFolder() }
                    }
                }
            }

            Divider()

            // Music Folder Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Music Folder")
                    .font(.title2)
                Text("Select the folder containing your Amiga music files.")
                    .font(.callout)
                    .foregroundColor(.secondary)

                if let path = folderPath(for: settings.musicFolderURL) {
                    Text("Current: \(path)")
                        .font(.footnote).lineLimit(1).truncationMode(.middle)
                }
                
                HStack {
                    Button("Select Music Folder...") { settings.selectMusicFolder() }
                    if settings.musicFolderBookmark != nil {
                        Button("Clear") { settings.clearMusicFolder() }
                    }
                }
            }

            Spacer()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(30)
        .frame(minWidth: 550, minHeight: 350)
    }
    
    private func folderPath(for url: URL?) -> String? {
        guard let url = url else { return nil }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        return url.path
    }
}
