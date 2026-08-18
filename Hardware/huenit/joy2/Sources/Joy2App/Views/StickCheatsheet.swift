import AppKit
import SwiftUI

struct StickCheatsheet: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How the stick works")
                .font(.title2.weight(.semibold))
            Text("Hold the stick in a direction to keep moving. Release to stop. The pad lights the same cells.")
                .foregroundStyle(.secondary)

            AnnotatedStickMap()
                .frame(minHeight: 420)

            Text("Hold left fire and the stick becomes Z (away / toward you) and cup angle (left / right).")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(minWidth: 760, minHeight: 560)
    }
}

private struct Callout {
    var title: String
    var target: CGPoint
    var label: CGPoint
    var align: HorizontalAlignment
}

private struct AnnotatedStickMap: View {
    private let callouts: [Callout] = [
        Callout(title: "Away  Y+", target: CGPoint(x: 0.50, y: 0.22), label: CGPoint(x: 0.50, y: 0.05), align: .center),
        Callout(title: "Left fire\nHold for Z / angle", target: CGPoint(x: 0.30, y: 0.30), label: CGPoint(x: 0.08, y: 0.14), align: .leading),
        Callout(title: "Right fire\nSuction on / off", target: CGPoint(x: 0.70, y: 0.30), label: CGPoint(x: 0.92, y: 0.14), align: .trailing),
        Callout(title: "Left  X−", target: CGPoint(x: 0.28, y: 0.42), label: CGPoint(x: 0.06, y: 0.48), align: .leading),
        Callout(title: "Right  X+", target: CGPoint(x: 0.72, y: 0.42), label: CGPoint(x: 0.94, y: 0.48), align: .trailing),
        Callout(title: "Stick  X / Y", target: CGPoint(x: 0.50, y: 0.36), label: CGPoint(x: 0.78, y: 0.62), align: .leading),
        Callout(title: "Toward you  Y−", target: CGPoint(x: 0.50, y: 0.52), label: CGPoint(x: 0.50, y: 0.90), align: .center),
    ]

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                Color(nsColor: .controlBackgroundColor)

                if let photo {
                    Image(nsImage: photo)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 150)
                        .padding(.vertical, 36)
                }

                Canvas { context, canvasSize in
                    for callout in callouts {
                        let from = point(callout.label, in: canvasSize)
                        let to = point(callout.target, in: canvasSize)
                        var line = Path()
                        line.move(to: from)
                        line.addLine(to: to)
                        context.stroke(line, with: .color(.primary.opacity(0.75)), lineWidth: 1.2)
                        let dot = Path(ellipseIn: CGRect(x: to.x - 3.5, y: to.y - 3.5, width: 7, height: 7))
                        context.fill(dot, with: .color(.primary))
                    }
                }
                .allowsHitTesting(false)

                ForEach(Array(callouts.enumerated()), id: \.offset) { _, callout in
                    Text(callout.title)
                        .font(.caption.weight(.semibold))
                        .multilineTextAlignment(callout.align == .leading ? .leading : callout.align == .trailing ? .trailing : .center)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .position(point(callout.label, in: size))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
    }

    private var photo: NSImage? {
        let bundles = [Bundle.main] + {
            #if SWIFT_PACKAGE
            [Bundle.module]
            #else
            [Bundle]()
            #endif
        }()
        for bundle in bundles {
            if let url = bundle.url(forResource: "joy_mapping", withExtension: "jpg") {
                return NSImage(contentsOf: url)
            }
        }
        return nil
    }

    private func point(_ unit: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: unit.x * size.width, y: unit.y * size.height)
    }
}
