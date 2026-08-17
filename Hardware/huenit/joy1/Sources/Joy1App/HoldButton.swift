import SwiftUI

struct HoldButton: View {
    let title: String
    var accessibilityLabel: String
    let onChanged: (Bool) -> Void

    @State private var isPressed = false

    var body: some View {
        Text(title)
            .font(.title2.monospaced())
            .frame(minWidth: 56, minHeight: 40)
            .padding(.horizontal, 10)
            .background(isPressed ? Color.accentColor.opacity(0.35) : Color.secondary.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .contentShape(RoundedRectangle(cornerRadius: 8))
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
