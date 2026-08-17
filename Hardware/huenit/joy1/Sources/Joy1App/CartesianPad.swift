import Joy1
import SwiftUI

struct CartesianPad: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(spacing: 8) {
            HoldButton(title: "Y+", accessibilityLabel: "Y plus") { down in
                model.setHeld(.y, .pos, down: down)
            }
            HStack(spacing: 8) {
                HoldButton(title: "X−", accessibilityLabel: "X minus") { down in
                    model.setHeld(.x, .neg, down: down)
                }
                HoldButton(title: "X+", accessibilityLabel: "X plus") { down in
                    model.setHeld(.x, .pos, down: down)
                }
            }
            HoldButton(title: "Y−", accessibilityLabel: "Y minus") { down in
                model.setHeld(.y, .neg, down: down)
            }
            HStack(spacing: 8) {
                HoldButton(title: "Z+", accessibilityLabel: "Z plus") { down in
                    model.setHeld(.z, .pos, down: down)
                }
                HoldButton(title: "Z−", accessibilityLabel: "Z minus") { down in
                    model.setHeld(.z, .neg, down: down)
                }
            }
            Text("Task space")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Task space")
    }
}
