import SwiftUI

struct AISettingsView: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        Form {
            Section {
                Toggle("Enable local AI features", isOn: $settings.localAIEnabled)
                Text("Local inference will use the indexed song library for features such as creating playlists from mood, format, artist, duration, or other criteria.")
                    .foregroundStyle(.secondary)
            }
            Section("Local Inference Server") {
                Picker("Provider", selection: $settings.localAIProvider) {
                    ForEach(LocalAIProvider.allCases) { provider in Text(provider.rawValue).tag(provider) }
                }
                .disabled(!settings.localAIEnabled)
                TextField("Model name", text: $settings.localAIModelName).disabled(!settings.localAIEnabled)
                TextField("API endpoint", text: $settings.localAIEndpoint).disabled(!settings.localAIEnabled)
                LabeledContent("Active configuration") {
                    Text(activeConfiguration).font(.body.monospaced()).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                }
                Button("Use Provider Default", systemImage: "arrow.counterclockwise", action: useProviderDefault)
                    .disabled(!settings.localAIEnabled)
            }
            AIPlaylistBuilderView()
            Section {
                Label("Requests stay on your Mac when the configured endpoint is local. AuDeluxe does not start or install an AI server.", systemImage: "lock.shield")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var activeConfiguration: String {
        let model = settings.localAIModelName.isEmpty ? "No model selected" : settings.localAIModelName
        return "\(settings.localAIEndpoint) · \(model)"
    }

    private func useProviderDefault() { settings.localAIEndpoint = settings.localAIProvider.defaultEndpoint }
}
