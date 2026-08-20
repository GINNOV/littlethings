import SwiftUI

struct ErrorStateView: View {
    let title: String
    let description: String
    let actionTitle: String
    let recoveryAction: @MainActor () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "exclamationmark.triangle")
        } description: {
            Text(description)
        } actions: {
            Button(actionTitle, action: recoveryAction)
                .accessibilityLabel(actionTitle)
                .accessibilityIdentifier("error.retry")
        }
        .accessibilityIdentifier("state.error")
    }
}
