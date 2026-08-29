import SwiftUI

struct LibraryScanStatusView: View {
    @EnvironmentObject private var engine: OpenMPTEngine

    var body: some View {
        if engine.scanStatus.isVisible {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    LibraryScanStatusIndicatorView(status: engine.scanStatus)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(engine.scanStatus.statusText)
                            .font(.callout)
                            .bold()

                        if let detail = engine.scanStatus.detailText {
                            Text(detail)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }

                    Spacer()

                    if engine.scanStatus.isActive {
                        Button("Cancel", role: .cancel, action: engine.cancelMusicFolderScan)
                    } else {
                        Button("Dismiss", systemImage: "xmark", action: engine.dismissScanStatus)
                            .labelStyle(.iconOnly)
                    }
                }

                if let progress = engine.scanStatus.progressFraction,
                   engine.scanStatus.isActive {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .accessibilityLabel("Music library scan progress")
                        .accessibilityValue(progress.formatted(.percent.precision(.fractionLength(0))))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.regularMaterial)
            .overlay(alignment: .bottom) {
                Divider()
            }
        }
    }
}
