import SwiftUI

// A dedicated, simple view for the Quick Look extension.
// It has no dependencies on the main app's environment.
struct AuDeluxePreviewView: View {
    let item: PlaylistItem

    private var sortedMetadataKeys: [String] {
        item.metadata.keys.filter { $0 != "title" && $0 != "artist" && $0 != "duration" }.sorted()
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Module Preview")
                .font(.largeTitle.weight(.thin))
                .padding(.bottom, 5)

            Text(item.title)
                .font(.title2.weight(.semibold))

            if !item.artist.isEmpty {
                Text("by \(item.artist)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text("Duration:")
                            .fontWeight(.semibold)
                            .frame(width: 120, alignment: .trailing)
                        Text(formatTime(item.duration))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.system(.body, design: .monospaced))

                    ForEach(sortedMetadataKeys, id: \.self) { key in
                        HStack(alignment: .top) {
                            Text("\(key.capitalized):")
                                .fontWeight(.semibold)
                                .frame(width: 120, alignment: .trailing)
                            Text(item.metadata[key] ?? "N/A")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(3)
                        }
                        .font(.system(.body, design: .monospaced))
                    }
                }
                .padding()
            }
        }
        .padding(30)
        .frame(minWidth: 550, minHeight: 450)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
