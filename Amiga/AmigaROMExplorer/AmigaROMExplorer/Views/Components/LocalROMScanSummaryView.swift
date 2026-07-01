import SwiftUI

struct LocalROMScanSummaryView: View {
    let report: LocalROMScanReport
    var showMatchedCount: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(report.summaryLine)
                .font(.subheadline)
                .foregroundStyle(AmigaTheme.accentOrange)
                .fixedSize(horizontal: false, vertical: true)

            if showMatchedCount {
                Text("\(report.matchedCatalogEntries) of catalog entries linked to files on disk")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if report.hasIssues {
                issueSections
            } else if report.scannedFirmwareFiles > 0 {
                Label("All scanned ROM files matched the reference catalog.", systemImage: "checkmark.seal")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
    }

    @ViewBuilder
    private var issueSections: some View {
        if !report.checksumMismatches.isEmpty {
            issueSection(
                title: "Checksum mismatches",
                symbol: "exclamationmark.triangle.fill",
                tint: .orange
            ) {
                ForEach(report.checksumMismatches) { mismatch in
                    mismatchRow(mismatch)
                }
            }
        }

        if !report.unrecognizedFiles.isEmpty {
            issueSection(
                title: "Unrecognized files",
                symbol: "questionmark.folder.fill",
                tint: AmigaTheme.accentCyan
            ) {
                ForEach(report.unrecognizedFiles) { file in
                    fileRow(file, detail: "Not in the reference catalog")
                }
            }
        }

        if !report.skippedArchiveFiles.isEmpty {
            issueSection(
                title: "Skipped archives",
                symbol: "doc.zipper",
                tint: .secondary
            ) {
                ForEach(report.skippedArchiveFiles) { file in
                    fileRow(file, detail: "Extract before scanning")
                }
            }
        }
    }

    private func issueSection<Content: View>(
        title: String,
        symbol: String,
        tint: Color,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(.top, 6)
        } label: {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
        }
    }

    private func mismatchRow(_ mismatch: ChecksumMismatchSummary) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mismatch.file.displayName)
                .font(.caption.weight(.semibold))
                .textSelection(.enabled)

            Text(mismatch.hint)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let expected = mismatch.expectedMD5 {
                Text("Expected MD5: \(expected)")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            Text("Found MD5: \(mismatch.file.md5)")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AmigaTheme.cardFill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func fileRow(_ file: ScannedROMFileSummary, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(file.displayName)
                .font(.caption.weight(.semibold))
                .textSelection(.enabled)

            Text(detail)
                .font(.caption2)
                .foregroundStyle(.secondary)

            if !file.md5.isEmpty {
                Text("MD5: \(file.md5)")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AmigaTheme.cardFill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}