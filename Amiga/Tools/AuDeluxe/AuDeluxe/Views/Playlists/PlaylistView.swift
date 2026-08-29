//
//  PlaylistView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct PlaylistView: View {
    @EnvironmentObject private var engine: OpenMPTEngine
    @EnvironmentObject private var settings: SettingsStore
    
    @Binding var selectedFileID: PlaylistItem.ID?

    var body: some View {
        List(selection: $selectedFileID) {
            Section(header: HStack {
                Text("Title")
                Spacer()
                Text("Artist")
                    .frame(width: 160, alignment: .leading)
                Text("Folder")
                    .frame(width: 140, alignment: .leading)
                Text("Type")
                    .frame(width: 50, alignment: .leading)
                Text("Rating")
                    .frame(width: 70, alignment: .leading)
                Text("Duration")
                    .frame(width: 58, alignment: .trailing)
            }.font(.caption.weight(.semibold))) {
                ForEach(engine.playlistItems, id: \.id) { item in
                    HStack {
                        Text(item.title)
                            .fontWeight(item.id == selectedFileID ? .bold : .regular)
                            .foregroundColor(item.fileURL.lastPathComponent == engine.currentSongInfo ? .accentColor : .primary)
                        Spacer()
                        Text(item.artist.isEmpty ? "—" : item.artist)
                            .font(.caption)
                            .foregroundStyle(item.artist.isEmpty ? .tertiary : .secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(width: 160, alignment: .leading)
                        Text(item.folderName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(width: 140, alignment: .leading)
                        Text(item.fileType)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                            .frame(width: 50, alignment: .leading)
                        HStack {
                            ForEach(0..<item.rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                            }
                        }
                        .foregroundStyle(.yellow)
                        .frame(width: 70, alignment: .leading)
                        Text(formatTime(item.duration))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 58, alignment: .trailing)
                    }
                    .padding(.vertical, 4)
                    .tag(item.id)
                    .id(item.id) // to find the song scrolled to
                    .contentShape(Rectangle())
                    .gesture(
                        TapGesture(count: 2).onEnded {
                            self.selectedFileID = item.id
                            if let musicURL = settings.musicFolderURL {
                                Task {
                                    await engine.play(fileURL: item.fileURL, musicFolderURL: musicURL)
                                }
                            }
                        }
                        .exclusively(before: TapGesture().onEnded {
                            self.selectedFileID = item.id
                        })
                    )
                }
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
