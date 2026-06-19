import SwiftUI

struct HardwareModelImage: View {
    let model: HardwareModel
    var height: CGFloat = 88
    var cornerRadius: CGFloat = 12

    var body: some View {
        Group {
            if let assetName = model.imageAssetName {
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AmigaTheme.cardFill)
                    Image(systemName: model.symbolName)
                        .font(.system(size: height * 0.34, weight: .semibold))
                        .foregroundStyle(AmigaTheme.accentOrange.opacity(0.85))
                }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(AmigaTheme.cardStroke, lineWidth: 1)
        )
        .accessibilityLabel(model.name)
    }
}

struct CompatibleHardwareGallery: View {
    let models: [HardwareModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Used in these Amiga models", systemImage: "desktopcomputer")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AmigaTheme.heroGradient)

            if models.count == 1, let model = models.first {
                singleModelCard(model)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(models) { model in
                            compactModelCard(model)
                                .frame(width: 220)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func singleModelCard(_ model: HardwareModel) -> some View {
        HStack(alignment: .center, spacing: 16) {
            HardwareModelImage(model: model, height: 120)

            VStack(alignment: .leading, spacing: 8) {
                Text(model.name)
                    .font(.title3.weight(.bold))

                if let year = model.releaseYear {
                    Text("Released \(year)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(model.summary)
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    miniSpec(title: "CPU", value: model.cpu)
                    miniSpec(title: "Chipset", value: model.chipset)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AmigaTheme.cardFill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AmigaTheme.heroGradient.opacity(0.45), lineWidth: 1)
        )
    }

    private func compactModelCard(_ model: HardwareModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HardwareModelImage(model: model, height: 96)

            Text(model.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)

            Text(model.chipset)
                .font(.caption)
                .foregroundStyle(AmigaTheme.accentCyan)
                .lineLimit(1)
        }
        .padding(12)
        .background(AmigaTheme.cardFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AmigaTheme.cardStroke, lineWidth: 1)
        )
    }

    private func miniSpec(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}