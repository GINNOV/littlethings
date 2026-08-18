import Joy1
import SwiftUI

struct LabPad: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Mode", selection: Binding(
                get: { model.controlMode },
                set: { model.setControlMode($0) }
            )) {
                Text("Hold (OS)").tag(ControlMode.hold)
                Text("Step (Lab)").tag(ControlMode.step)
            }
            .pickerStyle(.segmented)
            .disabled(!model.isConnected)

            HStack(spacing: 8) {
                ForEach([0.1, 1.0, 10.0], id: \.self) { width in
                    Button(width == 0.1 ? "0.1" : String(format: "%.0f", width)) {
                        model.setStepWidth(width)
                    }
                    .buttonStyle(.bordered)
                    .tint(model.stepWidthMm == width ? .accentColor : .gray)
                    .disabled(!model.isConnected || model.controlMode != .step)
                }
                Text("mm")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Width of movement")

            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                GridRow {
                    step("↖︎", -1, 1, 0, "X minus Y plus")
                    step("Y+", 0, 1, 0, "Y plus")
                    step("↗︎", 1, 1, 0, "X plus Y plus")
                    step("Z+", 0, 0, 1, "Z plus")
                }
                GridRow {
                    step("X−", -1, 0, 0, "X minus")
                    Button("⌂") { Task { await model.home() } }
                        .accessibilityLabel("Home")
                        .disabled(!model.isConnected)
                    step("X+", 1, 0, 0, "X plus")
                    Button("Z0") { Task { await model.zeroZ() } }
                        .accessibilityLabel("Z zero")
                        .disabled(!model.isConnected)
                }
                GridRow {
                    step("↙︎", -1, -1, 0, "X minus Y minus")
                    step("Y−", 0, -1, 0, "Y minus")
                    step("↘︎", 1, -1, 0, "X plus Y minus")
                    step("Z−", 0, 0, -1, "Z minus")
                }
            }

            HStack {
                Text("E")
                    .foregroundStyle(.secondary)
                Button("E−") { Task { await model.jogModule(sign: .neg) } }
                    .disabled(!model.isConnected)
                    .accessibilityLabel("Module angle minus")
                Button("E+") { Task { await model.jogModule(sign: .pos) } }
                    .disabled(!model.isConnected)
                    .accessibilityLabel("Module angle plus")
                Text(String(format: "%.1f°", model.pose?.e ?? 0))
                    .monospacedDigit()
            }

            HStack {
                Text("Move to")
                    .foregroundStyle(.secondary)
                coord("X", $model.targetX)
                coord("Y", $model.targetY)
                coord("Z", $model.targetZ)
                Button("Move Now") { Task { await model.moveToTarget() } }
                    .disabled(!model.isConnected)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Lab control pad")
    }

    @ViewBuilder
    private func step(_ title: String, _ dx: Double, _ dy: Double, _ dz: Double, _ label: String) -> some View {
        if model.controlMode == .hold {
            HoldButton(title: title, accessibilityLabel: label) { down in
                if dx != 0 { model.setHeld(.x, dx > 0 ? .pos : .neg, down: down) }
                if dy != 0 { model.setHeld(.y, dy > 0 ? .pos : .neg, down: down) }
                if dz != 0 { model.setHeld(.z, dz > 0 ? .pos : .neg, down: down) }
            }
        } else {
            Button(title) {
                Task { await model.step(dx: dx, dy: dy, dz: dz) }
            }
            .disabled(!model.isConnected)
            .accessibilityLabel(label)
        }
    }

    private func coord(_ name: String, _ value: Binding<Double>) -> some View {
        HStack(spacing: 4) {
            Text(name).foregroundStyle(.secondary)
            TextField(name, value: value, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 64)
        }
    }
}
