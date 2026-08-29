import SwiftUI

struct AIPlaylistDraftView: View {
    let draft: AIPlaylistDraft
    @Binding var playlistName: String
    let save: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Playlist name", text: $playlistName)
            Text("\(draft.items.count) matching songs")
                .font(.headline)

            ForEach(draft.items.prefix(8)) { item in
                LabeledContent(item.title) {
                    Text([item.artist, item.folderName, item.fileType]
                        .filter { $0.isEmpty == false }
                        .joined(separator: " · "))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            if draft.items.count > 8 {
                Text("and \(draft.items.count - 8) more")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()
                Button("Save Playlist", systemImage: "music.note.list", action: save)
                    .buttonStyle(.borderedProminent)
                    .disabled(playlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
