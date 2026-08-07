import SwiftUI

struct ResearchSectionView: View {
    let title: String
    let symbol: String
    let content: String

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: symbol)
                    .font(.headline)
                    .foregroundStyle(AmigaTheme.accentCyan)
                Text(content)
                    .font(.body)
                    .foregroundStyle(.primary.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct InsightListView: View {
    let title: String
    let items: [String]

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label(title, systemImage: "cpu.fill")
                    .font(.headline)
                    .foregroundStyle(AmigaTheme.accentOrange)

                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(AmigaTheme.accentMagenta)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.9))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ResearchLoadingView: View {
    let progress: String

    var body: some View {
        GlassCard {
            HStack(spacing: 14) {
                ProgressView()
                    .controlSize(.regular)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sub-agent researching…")
                        .font(.headline)
                    Text(progress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}