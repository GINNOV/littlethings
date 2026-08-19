import SwiftUI

struct SettingsView: View {
    @AppStorage("showInspectorOnLaunch") private var showInspectorOnLaunch = true

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
