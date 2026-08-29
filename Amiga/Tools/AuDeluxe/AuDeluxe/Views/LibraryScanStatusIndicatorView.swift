import SwiftUI

struct LibraryScanStatusIndicatorView: View {
    let status: LibraryScanStatus

    var body: some View {
        switch status {
        case .discovering:
            ProgressView()
                .controlSize(.small)
                .accessibilityLabel("Discovering music modules")
        case .processing:
            Image(systemName: "waveform.badge.magnifyingglass")
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .accessibilityHidden(true)
        case .cancelled:
            Image(systemName: "xmark.circle")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
        case .idle:
            EmptyView()
        }
    }
}
