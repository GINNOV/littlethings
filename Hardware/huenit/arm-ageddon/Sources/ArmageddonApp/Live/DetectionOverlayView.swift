import ArmageddonCore
import SwiftUI

struct DetectionOverlayView: View {
    let observations: [DetectionObservation]
    let selectedObservationID: String?
    let sourceFormat: CaptureFormat?
    let modelSize: PixelSize
    let selectObservation: (String) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(observations) { observation in
                    if let sourceFormat,
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
                        detectionBox(
                            observation: observation,
                            viewBox: viewBox,
                            isSelected: selectedObservationID == observation.id
                        )
                        .position(
                            x: viewBox.x + viewBox.width / 2,
                            y: viewBox.y + viewBox.height / 2
                        )
                    }
                }

                if !observations.isEmpty {
                    Label(
                        "\(observations.count) detection\(observations.count == 1 ? "" : "s")",
                        systemImage: "viewfinder"
                    )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.68), in: Capsule())
                    .padding(DesignTokens.Spacing.standard)
                    .accessibilityHidden(true)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("live.detection-overlays")
    }

    private func detectionBox(
        observation: DetectionObservation,
        viewBox: PixelRect,
        isSelected: Bool
    ) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: isSelected ? 8 : 6)
                .stroke(isSelected ? .yellow : DesignTokens.Colors.danger, lineWidth: isSelected ? 3 : 2)
                .frame(width: viewBox.width, height: viewBox.height)
            HStack(spacing: 5) {
                Text("\(observation.label) \(observation.confidence, format: .percent.precision(.fractionLength(0)))")
                if isSelected {
                    Label("Selected", systemImage: "scope")
                        .labelStyle(.titleAndIcon)
                }
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(isSelected ? Color.yellow.opacity(0.9) : DesignTokens.Colors.danger.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .frame(width: viewBox.width, height: viewBox.height)
        .contentShape(Rectangle())
        .onTapGesture { selectObservation(observation.id) }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Detected \(observation.label)")
        .accessibilityValue(
            "\(observation.confidence, format: .percent.precision(.fractionLength(0))). \(isSelected ? "Selected" : "Detected")"
        )
        .accessibilityIdentifier("live.detection.\(observation.label)")
        .zIndex(isSelected ? 2 : 1)
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
