//
//  SelectPlaylistView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/18/25.
//

import SwiftUI

struct SelectPlaylistView: View {
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var engine: OpenMPTEngine
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 15) {
            Text("Select a Playlist")
                .font(.largeTitle.weight(.thin))
                .padding()

            List {
                // Option to show all songs
                Button(action: {
                    engine.setActivePlaylist(nil)
                    dismiss()
                }) {
                    HStack {
                        Text("All Songs")
                        Spacer()
                        if engine.activePlaylist == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .buttonStyle(.plain)

                Divider()

                // Custom playlists
                ForEach(settings.playlists) { playlist in
                    Button(action: {
                        engine.setActivePlaylist(playlist)
                        dismiss()
                    }) {
                        HStack {
                            Text(playlist.name)
                            Spacer()
                            if engine.activePlaylist?.id == playlist.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))

            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
            .padding()
        }
        .frame(minWidth: 400, minHeight: 400)
    }
}
