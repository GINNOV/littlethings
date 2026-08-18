import Joy1
import SwiftUI

struct LabPad: View {
    @Bindable var model: PendantModel

    var body: some View {
        PendantCard(title: "Control") {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Mode", selection: Binding(
                    get: { model.controlMode },
                    set: { model.setControlMode($0) }
                )) {
                    Text("Hold").tag(ControlMode.hold)
                    Text("Step").tag(ControlMode.step)
                }
                .pickerStyle(.segmented)
                .disabled(!model.isConnected)
                .accessibilityLabel("Control mode")

                SpeedSlider(model: model)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Width of movement")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach([0.1, 1.0, 10.0], id: \.self) { width in
                            Button(width == 0.1 ? "0.1" : String(format: "%.0f", width)) {
                                model.setStepWidth(width)
                            }
                            .buttonStyle(PadKeyStyle(emphasized: model.stepWidthMm == width))
                            .disabled(!model.isConnected || model.controlMode != .step)
                        }
                    }
                    .accessibilityLabel("Width of movement")
                }

                Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                    GridRow {
                        pad("↖︎", -1, 1, 0, "X minus Y plus")
                        pad("Y+", 0, 1, 0, "Y plus")
                        pad("↗︎", 1, 1, 0, "X plus Y plus")
                        pad("Z+", 0, 0, 1, "Z plus")
                    }
                    GridRow {
                        pad("X−", -1, 0, 0, "X minus")
                        Button("⌂") { Task { await model.home() } }
                            .buttonStyle(PadKeyStyle(emphasized: true))
                            .disabled(!model.isConnected)
                            .accessibilityLabel("Home")
                        pad("X+", 1, 0, 0, "X plus")
                        Button("Z0") { Task { await model.zeroZ() } }
                            .buttonStyle(PadKeyStyle())
                            .disabled(!model.isConnected)
                            .accessibilityLabel("Z zero")
                    }
                    GridRow {
                        pad("↙︎", -1, -1, 0, "X minus Y minus")
                        pad("Y−", 0, -1, 0, "Y minus")
                        pad("↘︎", 1, -1, 0, "X plus Y minus")
                        pad("Z−", 0, 0, -1, "Z minus")
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Move to")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        coord("X", $model.targetX)
                        coord("Y", $model.targetY)
                        coord("Z", $model.targetZ)
                    }
                    Button("Move Now") { Task { await model.moveToTarget() } }
                        .buttonStyle(PadKeyStyle(emphasized: true))
                        .disabled(!model.isConnected)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Lab control pad")
    }

    @ViewBuilder
    private func pad(_ title: String, _ dx: Double, _ dy: Double, _ dz: Double, _ label: String) -> some View {
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
            .buttonStyle(PadKeyStyle())
            .disabled(!model.isConnected)
            .accessibilityLabel(label)
        }
    }

    private func coord(_ name: String, _ value: Binding<Double>) -> some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(name, value: value, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 72)
            Text("mm")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
