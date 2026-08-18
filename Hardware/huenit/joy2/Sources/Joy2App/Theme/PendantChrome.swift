import SwiftUI

enum PendantChrome {
    static let canvas = Color(nsColor: .windowBackgroundColor)
    static let cardFill = Color(nsColor: .controlBackgroundColor)
    static let hairline = Color.primary.opacity(0.08)
    static let stop = Color(red: 0.78, green: 0.18, blue: 0.16)
    static let connected = Color(red: 0.16, green: 0.55, blue: 0.38)
}

struct PendantCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(PendantChrome.cardFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(PendantChrome.hairline)
        )
    }
}

struct PadKeyStyle: ButtonStyle {
    var emphasized = false
    var destructive = false
    var lit = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.medium))
            .frame(maxWidth: .infinity, minHeight: 36)
            .padding(.horizontal, 6)
            .background(fill(configuration.isPressed), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(PendantChrome.hairline)
            )
    }

    private func fill(_ pressed: Bool) -> Color {
        let on = pressed || lit
        if destructive { return PendantChrome.stop.opacity(on ? 0.85 : 1) }
        if emphasized { return Color.accentColor.opacity(on ? 0.28 : 0.16) }
        return Color.primary.opacity(on ? 0.14 : 0.06)
    }
}
