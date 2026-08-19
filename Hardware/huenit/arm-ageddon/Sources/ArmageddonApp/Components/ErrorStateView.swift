import SwiftUI

struct ErrorStateView: View {
    let title: String
    let description: String
    let recoveryAction: @MainActor () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "exclamationmark.triangle")
        } description: {
            Text(description)
        } actions: {
            Button("Try Again", action: recoveryAction)
                .accessibilityLabel("Try Again")
                .accessibilityIdentifier("error.retry")
        }
        .accessibilityIdentifier("state.error")
    }
}
