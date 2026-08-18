import Joy1
import SwiftUI

struct PoseHUD: View {
    let pose: ArmPose?

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 6) {
            GridRow {
                labeled("X", pose?.cartesian.x)
                labeled("Y", pose?.cartesian.y)
                labeled("Z", pose?.cartesian.z)
            }
            GridRow {
                labeled("A", pose?.joints.a)
                labeled("B", pose?.joints.b)
                labeled("C", pose?.joints.c)
            }
        }
        .font(.body.monospacedDigit())
        .foregroundStyle(pose?.isStale == true ? .secondary : .primary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private func labeled(_ axis: String, _ value: Double?) -> some View {
        HStack(spacing: 6) {
            Text(axis)
                .foregroundStyle(.secondary)
            Text(format(value))
                .gridColumnAlignment(.trailing)
        }
    }

    private func format(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%7.2f", value)
    }

    private var accessibilityText: String {
        guard let pose else { return "Pose unavailable" }
        let prefix = pose.isStale ? "Stale pose " : "Pose "
        return prefix + [
            "X \(format(pose.cartesian.x))",
            "Y \(format(pose.cartesian.y))",
            "Z \(format(pose.cartesian.z))",
            "A \(format(pose.joints.a))",
            "B \(format(pose.joints.b))",
            "C \(format(pose.joints.c))",
        ].joined(separator: " ")
    }
}
