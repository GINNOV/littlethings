import SwiftUI

struct DestinationSidebarRow: View {
    let destination: AppDestination
    let isSelected: Bool
    let action: @MainActor () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.standard) {
                Label(destination.title, systemImage: destination.symbol)
                Spacer(minLength: DesignTokens.Spacing.compact)
                if isSelected {
                    Image(systemName: "checkmark")
                        .accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, DesignTokens.Spacing.compact)
        .padding(.horizontal, DesignTokens.Spacing.standard)
        .background(isSelected ? DesignTokens.Colors.selected : .clear, in: RoundedRectangle(cornerRadius: DesignTokens.Spacing.compact))
        .accessibilityLabel(destination.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityIdentifier("sidebar.\(destination.accessibilityName)")
    }
}
