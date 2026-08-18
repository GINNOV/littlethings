import Joy1
import SwiftUI

struct PoseHUD: View {
    let pose: ArmPose?

    var body: some View {
        PendantCard(title: "Status") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Coordinate")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                    GridRow {
                        labeled("x", pose?.cartesian.x, "mm")
                        labeled("y", pose?.cartesian.y, "mm")
                    }
                    GridRow {
                        labeled("z", pose?.cartesian.z, "mm")
                        labeled("e", pose?.e, "°")
                    }
                }
                if pose?.isStale == true {
                    Text("Stale")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(pose?.isStale == true ? .secondary : .primary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private func labeled(_ axis: String, _ value: Double?, _ unit: String) -> some View {
        HStack(spacing: 4) {
            Text("\(axis):")
                .foregroundStyle(.secondary)
            Text(format(value) + unit)
                .font(.body.monospacedDigit())
        }
    }

    private func format(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.2f", value)
    }

    private var accessibilityText: String {
        guard let pose else { return "Pose unavailable" }
        let prefix = pose.isStale ? "Stale pose " : "Pose "
        return prefix + [
            "X \(format(pose.cartesian.x))",
            "Y \(format(pose.cartesian.y))",
            "Z \(format(pose.cartesian.z))",
            "E \(format(pose.e))",
        ].joined(separator: " ")
    }
}
