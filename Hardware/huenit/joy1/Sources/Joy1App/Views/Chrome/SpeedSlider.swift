import Joy1
import SwiftUI

struct SpeedSlider: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Slider(
                value: Binding(
                    get: { model.speedMmPerSec },
                    set: { model.setSpeed($0) }
                ),
                in: 1...80,
                step: 1
            ) {
                Text("Speed")
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Text("80")
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
        let value = model.speedMmPerSec
        return String(format: "%.0f mm/s   %.0f °/s", value, value)
    }
}
