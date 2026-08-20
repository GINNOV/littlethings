import SwiftUI

struct StatusStripView: View {
    let notice: String?
    let profile: LaunchProfile?
    let armed: Bool
    let cameraWorkCancelled: Bool
    let stopAction: @MainActor () -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.roomy) {
            StatusItemView(title: "Camera", detail: "Fixture ready", symbol: "video")
            StatusItemView(title: "Model", detail: "No active model", symbol: "cube")
            StatusItemView(title: "Arm", detail: armed ? "Armed" : "Disarmed", symbol: "hand.raised")
                .accessibilityIdentifier("arm.status")
            if let profile {
                Label(profile.title, systemImage: "checkmark.seal")
                    .font(DesignTokens.Typography.supporting)
                    .accessibilityIdentifier("launch.profile.\(profile.rawValue)")
                Text("Fixture state ready")
                    .accessibilityIdentifier("launch.ready")
            }
            Spacer(minLength: DesignTokens.Spacing.standard)
            if let notice {
                HStack(spacing: DesignTokens.Spacing.compact) {
                    Image(systemName: notice == "STOP requested" ? "exclamationmark.octagon.fill" : "info.circle")
                        .accessibilityHidden(true)
                    Text(notice)
                        .accessibilityIdentifier(identifier(for: notice))
                }
                .font(DesignTokens.Typography.supporting)
            }
            if cameraWorkCancelled {
                Text("Camera work cancelled")
                    .font(DesignTokens.Typography.supporting)
                    .accessibilityIdentifier("camera.work-cancelled")
            }
            Button("STOP", systemImage: "stop.circle.fill", action: stopAction)
                .buttonStyle(.borderedProminent)
                .tint(DesignTokens.Colors.danger)
                .keyboardShortcut(.escape, modifiers: [])
                .accessibilityLabel("STOP motion")
                .accessibilityIdentifier("stop.button")
        }
        .padding(.horizontal, DesignTokens.Spacing.standard)
        .padding(.vertical, DesignTokens.Spacing.compact)
        .background(DesignTokens.Colors.status)
        .overlay(alignment: .top) { Divider() }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("status.strip")
    }

    private func identifier(for notice: String) -> String {
        switch notice {
        case "STOP requested": "stop.invoked"
        case "Navigation recovered to Live": "navigation.recovered"
        default: "status.notice"
        }
    }
}
