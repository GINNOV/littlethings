import SwiftUI

struct StatusItemView: View {
    let title: String
    let detail: String
    let symbol: String

    var body: some View {
        Label {
            Text("\(title): \(detail)")
                .font(DesignTokens.Typography.supporting)
        } icon: {
            Image(systemName: symbol)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(detail)")
    }
}
