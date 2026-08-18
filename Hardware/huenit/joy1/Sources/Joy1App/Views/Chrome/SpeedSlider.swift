import Joy1
import SwiftUI

struct SpeedSlider: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Speed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(model.labSpeed))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(
                value: Binding(
                    get: { model.labSpeed },
                    set: { model.setLabSpeed($0) }
                ),
                in: 1...400,
                step: 1
            )
            .accessibilityLabel("Speed")
            .accessibilityValue("\(Int(model.labSpeed))")
        }
    }
}
