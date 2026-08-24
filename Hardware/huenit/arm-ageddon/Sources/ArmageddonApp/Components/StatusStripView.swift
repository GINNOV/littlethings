import SwiftUI

struct StatusStripView: View {
    let notice: String?
    let profile: LaunchProfile?
    let armConnected: Bool

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.roomy) {
            StatusItemView(
                title: "Arm",
                detail: armConnected ? "Connected" : "Disconnected",
                symbol: "hand.raised"
            )
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
                Text(notice)
                    .font(DesignTokens.Typography.supporting)
                    .lineLimit(2)
                    .accessibilityIdentifier(notice == "STOP requested" ? "stop.invoked" : "status.notice")
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.standard)
        .padding(.vertical, DesignTokens.Spacing.compact)
        .background(DesignTokens.Colors.status)
        .overlay(alignment: .top) { Divider() }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("status.strip")
    }
}
