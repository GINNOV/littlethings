import AppKit
import SwiftUI

struct SettingsView: View {
    @AppStorage private var showInspectorOnLaunch: Bool
    @State private var resetConfirmationPresented = false

    init(preferenceSuite: String? = nil) {
        _showInspectorOnLaunch = AppStorage(
            wrappedValue: true,
            "showInspectorOnLaunch",
            store: preferenceSuite.flatMap { UserDefaults(suiteName: $0) }
        )
    }

    var body: some View {
        Form {
            Section("Workspace") {
                Toggle("Show inspector on launch", isOn: $showInspectorOnLaunch)
                    .accessibilityLabel("Show inspector on launch")
                    .accessibilityIdentifier("settings.show-inspector")
            }
            Section("Capture") {
                Text("Captures are stored locally as JPEG with their source, model, and timing provenance.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("Privacy") {
                Text("Frames, thumbnails, model bytes, credentials, full device serials, and raw logs are never included by default.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                LabeledContent("Local data", value: dataLocation.path)
                Button("Reveal local data in Finder", systemImage: "folder") {
                    NSWorkspace.shared.activateFileViewerSelecting([dataLocation])
                }
            }
            Section("Safety profile") {
                Label("Required interlocks are always on", systemImage: "checkmark.shield.fill")
                    .foregroundStyle(.green)
                Text("Calibration, fresh pose, bounded XY motion, explicit arming, confirmation, and STOP cannot be disabled here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section {
                Button("Reset safe preferences", role: .destructive) {
                    resetConfirmationPresented = true
                }
                .confirmationDialog("Reset safe preferences?", isPresented: $resetConfirmationPresented) {
                    Button("Reset Preferences", role: .destructive) { resetPreferences() }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Captures and models remain untouched. Motion is always disarmed after relaunch.")
                }
            }
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.roomy)
        .frame(minWidth: 420, minHeight: 240)
        .navigationTitle("Settings")
        .accessibilityIdentifier("settings.scene")
    }

    private var dataLocation: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Armageddon", isDirectory: true)
    }

    private func resetPreferences() {
        showInspectorOnLaunch = true
    }
}
