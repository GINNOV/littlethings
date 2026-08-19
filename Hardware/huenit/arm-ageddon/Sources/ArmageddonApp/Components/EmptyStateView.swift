import SwiftUI

struct EmptyStateView: View {
    let title: String
    let symbol: String
    let description: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: symbol,
            description: Text(description)
        )
        .accessibilityIdentifier("state.empty")
    }
}
