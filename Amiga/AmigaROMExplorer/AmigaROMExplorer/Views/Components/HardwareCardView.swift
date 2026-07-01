import SwiftUI

struct HardwareCardView: View {
    let model: HardwareModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: model.symbolName)
                    .font(.title2)
                    .foregroundStyle(AmigaTheme.accentOrange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(model.name)
                        .font(.headline)
                    if let year = model.releaseYear {
                        Text("Released \(year)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
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
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AmigaTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AmigaTheme.heroGradient.opacity(0.6), lineWidth: 1)
        )
    }

    private func miniSpec(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HardwareGrid: View {
    let models: [HardwareModel]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 14)], spacing: 14) {
            ForEach(models) { model in
                HardwareCardView(model: model)
            }
        }
    }
}