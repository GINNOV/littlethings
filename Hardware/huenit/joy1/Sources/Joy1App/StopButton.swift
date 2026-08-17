import SwiftUI

struct StopButton: View {
    let action: () -> Void

    var body: some View {
        Button("Stop", role: .destructive, action: action)
            .keyboardShortcut(.cancelAction)
            .accessibilityLabel("Stop")
    }
}
