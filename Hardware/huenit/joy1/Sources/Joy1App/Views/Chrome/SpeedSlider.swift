import Joy1
import SwiftUI

struct SpeedSlider: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Slider(
                value: Binding(
                    get: { model.labSpeed },
                    set: { model.setLabSpeed($0) }
                ),
                in: 1...400,
                step: 1
            ) {
                Text("Speed")
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Text("400")
            }
            Text(speedCaption)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Speed")
        .accessibilityValue(speedCaption)
    }

    private var speedCaption: String {
        String(format: "Lab %.0f   F %.0f mm/min", model.labSpeed, model.feedMmPerMin)
    }
}
