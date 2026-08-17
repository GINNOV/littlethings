import Joy1
import SwiftUI

struct JointPad: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                HoldButton(title: "A+", accessibilityLabel: "A plus") { down in
                    model.setHeld(.a, .pos, down: down)
                }
                HoldButton(title: "B+", accessibilityLabel: "B plus") { down in
                    model.setHeld(.b, .pos, down: down)
                }
                HoldButton(title: "C+", accessibilityLabel: "C plus") { down in
                    model.setHeld(.c, .pos, down: down)
                }
            }
            HStack(spacing: 8) {
                HoldButton(title: "A−", accessibilityLabel: "A minus") { down in
                    model.setHeld(.a, .neg, down: down)
                }
                HoldButton(title: "B−", accessibilityLabel: "B minus") { down in
                    model.setHeld(.b, .neg, down: down)
                }
                HoldButton(title: "C−", accessibilityLabel: "C minus") { down in
                    model.setHeld(.c, .neg, down: down)
                }
            }
            Text("Joint space")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Joint space")
    }
}
