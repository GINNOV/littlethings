import SwiftUI

enum AmigaTheme {
    static let backgroundTop = Color(red: 0.07, green: 0.04, blue: 0.16)
    static let backgroundBottom = Color(red: 0.04, green: 0.10, blue: 0.22)
    static let accentOrange = Color(red: 1.0, green: 0.42, blue: 0.21)
    static let accentMagenta = Color(red: 0.93, green: 0.28, blue: 0.60)
    static let accentCyan = Color(red: 0.20, green: 0.85, blue: 0.95)
    static let cardFill = Color.white.opacity(0.06)
    static let cardStroke = Color.white.opacity(0.12)

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [accentOrange.opacity(0.9), accentMagenta.opacity(0.8), accentCyan.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundTop, backgroundBottom], startPoint: .top, endPoint: .bottom)
    }
}

struct AmigaBackground: View {
    var body: some View {
        ZStack {
            AmigaTheme.backgroundGradient
            RadialGradient(
                colors: [AmigaTheme.accentMagenta.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 500
            )
            RadialGradient(
                colors: [AmigaTheme.accentCyan.opacity(0.12), .clear],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 450
            )
        }
        .ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AmigaTheme.cardStroke, lineWidth: 1)
            )
    }
}

struct StatPill: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(AmigaTheme.accentCyan)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.caption.weight(.semibold))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AmigaTheme.cardFill, in: Capsule())
    }
}

struct CategoryBadge: View {
    let category: ROMCategory

    var body: some View {
        Label(category.title, systemImage: category.symbolName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hue: category.accentHue, saturation: 0.65, brightness: 0.35).opacity(0.55), in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.15)))
    }
}

struct DumpQualityBadge: View {
    let quality: ParsedROMMetadata.DumpQuality

    var body: some View {
        Text(quality.label)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.25), in: Capsule())
            .foregroundStyle(color)
    }

    private var color: Color {
        switch quality {
        case .good: .green
        case .beta, .developer: .yellow
        case .hack, .modified: .orange
        case .encrypted, .badDump, .overdump: .red
        case .unknown: .gray
        }
    }
}