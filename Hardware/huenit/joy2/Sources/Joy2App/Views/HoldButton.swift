import SwiftUI

struct HoldButton: View {
    let title: String
    var accessibilityLabel: String
    var lit = false
    let onChanged: (Bool) -> Void

    @State private var isPressed = false

    var body: some View {
        Text(title)
            .font(.callout.weight(.medium))
            .frame(maxWidth: .infinity, minHeight: 36)
            .padding(.horizontal, 6)
            .background(
                Color.primary.opacity((isPressed || lit) ? 0.14 : 0.06),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(PendantChrome.hairline)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        onChanged(true)
                    }
                    .onEnded { _ in
                        isPressed = false
                        onChanged(false)
                    }
            )
            .onDisappear {
                guard isPressed else { return }
                isPressed = false
                onChanged(false)
            }
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(.isButton)
    }
}
