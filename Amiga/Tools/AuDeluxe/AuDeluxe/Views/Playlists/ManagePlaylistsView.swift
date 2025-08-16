//
//  ManagePlaylistsView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/18/25.
//

import SwiftUI

struct ManagePlaylistsView: View {
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var engine: OpenMPTEngine
    
    // State for the multi-selection in the "All Songs" list
    @State private var selections: Set<PlaylistItem.ID> = []
    @State private var playlistName: String = ""
    
    // We need a dismiss action, which will be provided by the environment.
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Text("Playlist Manager")
                .font(.largeTitle.weight(.thin))
                .padding()

            HSplitView {
                // --- Left Pane: All Songs ---
                VStack {
                    Text("All Songs")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    // A List that supports multi-selection on macOS
                    List(engine.allPlaylistItems, selection: $selections) { item in
                        Text(item.title)
                            .tag(item.id)
                    }
                    .frame(minWidth: 250)

                    // --- Bottom Bar for Saving ---
                    HStack {
                        TextField("New Playlist Name", text: $playlistName)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Create Playlist") {
                            saveNewPlaylist()
                        }
                        .disabled(playlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selections.isEmpty)
                    }
                    .padding()
                }

                // --- Right Pane: Existing Playlists ---
                VStack {
                    Text("My Playlists")
                        .font(.headline)
                        .padding(.bottom, 5)

                    if settings.playlists.isEmpty {
                        Spacer()
                        Text("No custom playlists have been created yet.")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        List {
                            ForEach(settings.playlists) { playlist in
                                HStack {
                                    Text(playlist.name)
                                    Spacer()
                                    Text("\(playlist.fileURLs.count) songs")
                                        .foregroundColor(.secondary)
                                    Button(role: .destructive) {
                                        settings.deletePlaylist(playlist)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .frame(minWidth: 250)
            }
            
            // --- Bottom Done Button ---
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction) // Binds to Enter key
                .padding()
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }

    private func saveNewPlaylist() {
        let selectedItems = engine.allPlaylistItems.filter { selections.contains($0.id) }
        let urls = selectedItems.map { $0.fileURL }
        
        guard !urls.isEmpty else { return }
        
        let newPlaylist = Playlist(name: playlistName, fileURLs: urls)
        settings.savePlaylist(newPlaylist)
        
        // Reset fields
        playlistName = ""
        selections.removeAll()
    }
}
