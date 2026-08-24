import SwiftUI

struct StopButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: "stop.circle")
                    .font(.title)
                Text("STOP")
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(width: 92, height: 92)
        }
        .buttonStyle(.plain)
        .background(PendantChrome.stop, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .keyboardShortcut(.escape, modifiers: [])
        .accessibilityLabel("STOP motion")
        .accessibilityIdentifier("stop.button")
    }
}
