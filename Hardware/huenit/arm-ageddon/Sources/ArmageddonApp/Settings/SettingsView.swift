import SwiftUI

struct SettingsView: View {
    @AppStorage private var showInspectorOnLaunch: Bool

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
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.roomy)
        .frame(minWidth: 420, minHeight: 240)
        .navigationTitle("Settings")
        .accessibilityIdentifier("settings.scene")
    }
}
