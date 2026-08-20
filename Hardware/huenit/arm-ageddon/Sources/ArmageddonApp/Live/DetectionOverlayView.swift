import ArmageddonCore
import SwiftUI

struct DetectionOverlayView: View {
    let observations: [DetectionObservation]
    let sourceFormat: CaptureFormat?
    let modelSize: PixelSize

    var body: some View {
        GeometryReader { geometry in
            if let observation = observations.first,
               let sourceFormat,
               let transform = try? DetectorCoordinateTransform(
                   sourceSize: PixelSize(
                       width: Double(sourceFormat.width),
                       height: Double(sourceFormat.height)
                   ),
                   modelSize: modelSize,
                   viewSize: PixelSize(width: geometry.size.width, height: geometry.size.height),
                   orientation: sourceFormat.orientation,
                   mirrored: sourceFormat.mirrored,
                   resizeMode: .letterbox
               ),
               let viewBox = viewBox(for: observation, transform: transform) {
                let width = viewBox.width
                let height = viewBox.height
                let x = viewBox.x + viewBox.width / 2
                let y = viewBox.y + viewBox.height / 2
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

    private func viewBox(
        for observation: DetectionObservation,
        transform: DetectorCoordinateTransform
    ) -> PixelRect? {
        switch observation.coordinateSpace {
        case .modelImage:
            try? transform.modelToView(transform.modelPixels(from: observation.boundingBox))
        case .orientedImage:
            try? transform.orientedToView(transform.orientedPixels(from: observation.boundingBox))
        }
    }
}
