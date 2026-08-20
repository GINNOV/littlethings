import ArmageddonCore
import SwiftUI

struct DetectionOverlayView: View {
    let observations: [DetectionObservation]

    var body: some View {
        GeometryReader { geometry in
            if let observation = observations.first {
                let box = observation.boundingBox
                let width = box.width * geometry.size.width
                let height = box.height * geometry.size.height
                let x = (box.x + box.width / 2) * geometry.size.width
                let y = (box.y + box.height / 2) * geometry.size.height
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(DesignTokens.Colors.danger, lineWidth: 2)
                        .frame(width: width, height: height)
                    Text("\(observation.label) \(observation.confidence, format: .percent.precision(.fractionLength(0)))")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(DesignTokens.Colors.danger.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .accessibilityLabel("Detected \(observation.label)")
                }
                .position(x: x, y: y)
                    .accessibilityElement(children: .combine)
            }
        }
        .allowsHitTesting(false)
        .accessibilityIdentifier("live.detection-overlays")
    }
}
