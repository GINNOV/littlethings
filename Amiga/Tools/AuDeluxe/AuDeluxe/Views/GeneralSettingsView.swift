import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        Form {
            Section("Music Library") {
                LabeledContent("Folder") {
                    Text(folderPath).lineLimit(1).truncationMode(.middle).foregroundStyle(.secondary).textSelection(.enabled)
                }
                HStack {
                    Button("Choose Folder…", systemImage: "folder", action: settings.selectMusicFolder)
                    if settings.musicFolderBookmark != nil {
                        Button("Clear", role: .destructive, action: settings.clearMusicFolder)
                    }
                }
                Text("AuDeluxe scans supported modules recursively and indexes their metadata.").foregroundStyle(.secondary)
            }
            Section("Library") {
                Picker("Default sort order", selection: $settings.defaultSortOrder) {
                    ForEach(SortOrder.allCases) { order in Text(order.rawValue).tag(order) }
                }
                Toggle("Check for a new AuDeluxe app release when the app starts", isOn: $settings.checkForUpdatesOnLaunch)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var folderPath: String {
        guard let url = settings.musicFolderURL else { return "Not selected" }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        return url.path
    }
}
