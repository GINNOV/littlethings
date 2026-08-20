import AppKit
import SwiftUI

struct SettingsView: View {
    @AppStorage private var showInspectorOnLaunch: Bool
    @AppStorage private var retentionDays: Int
    @AppStorage private var diagnosticsOptIn: Bool
    @AppStorage private var defaultModelID: String
    @State private var resetConfirmationPresented = false

    init(preferenceSuite: String? = nil) {
        _showInspectorOnLaunch = AppStorage(
            wrappedValue: true,
            "showInspectorOnLaunch",
            store: preferenceSuite.flatMap { UserDefaults(suiteName: $0) }
        )
        let store = preferenceSuite.flatMap { UserDefaults(suiteName: $0) }
        _retentionDays = AppStorage(wrappedValue: 30, "retentionDays", store: store)
        _diagnosticsOptIn = AppStorage(wrappedValue: false, "diagnosticsOptIn", store: store)
        _defaultModelID = AppStorage(wrappedValue: "fixture.constant.detector", "defaultModelID", store: store)
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
                Stepper("Keep captures for \(retentionDays) days", value: $retentionDays, in: 1...365)
                TextField("Default model ID", text: $defaultModelID)
            }
            Section("Privacy") {
                Toggle("Include opt-in serial excerpts in support bundles", isOn: $diagnosticsOptIn)
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
        retentionDays = 30
        diagnosticsOptIn = false
        defaultModelID = "fixture.constant.detector"
    }
}
