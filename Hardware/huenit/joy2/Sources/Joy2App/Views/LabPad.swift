import Joy1
import Joy2
import SwiftUI

struct LabPad: View {
    @Bindable var model: PilotModel

    private var pendant: PendantModel { model.pendant }

    var body: some View {
        PendantCard(title: "Control") {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Mode", selection: Binding(
                    get: { pendant.controlMode },
                    set: { pendant.setControlMode($0) }
                )) {
                    Text("Hold").tag(ControlMode.hold)
                    Text("Step").tag(ControlMode.step)
                }
                .pickerStyle(.segmented)
                .disabled(!pendant.isConnected)
                .accessibilityLabel("Control mode")

                SpeedSlider(model: pendant)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Width of movement")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach([0.1, 1.0, 10.0], id: \.self) { width in
                            Button(width == 0.1 ? "0.1" : String(format: "%.0f", width)) {
                                pendant.setStepWidth(width)
                            }
                            .buttonStyle(PadKeyStyle(emphasized: pendant.stepWidthMm == width))
                            .disabled(!pendant.isConnected || pendant.controlMode != .step)
                        }
                    }
                    .accessibilityLabel("Width of movement")
                }

                if model.highlights.contains(.zAngleMode) {
                    Text("Z / angle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }

                Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                    GridRow {
                        pad("↖︎", -1, 1, 0, "X minus Y plus", .xyNW)
                        pad("Y+", 0, 1, 0, "Y plus", .yPlus)
                        pad("↗︎", 1, 1, 0, "X plus Y plus", .xyNE)
                        pad("Z+", 0, 0, 1, "Z plus", .zPlus)
                    }
                    GridRow {
                        pad("X−", -1, 0, 0, "X minus", .xMinus)
                        Button("⌂") { Task { await pendant.home() } }
                            .buttonStyle(PadKeyStyle(emphasized: true))
                            .disabled(!pendant.isConnected)
                            .accessibilityLabel("Home")
                        pad("X+", 1, 0, 0, "X plus", .xPlus)
                        Button("Z0") { Task { await pendant.zeroZ() } }
                            .buttonStyle(PadKeyStyle())
                            .disabled(!pendant.isConnected)
                            .accessibilityLabel("Z zero")
                    }
                    GridRow {
                        pad("↙︎", -1, -1, 0, "X minus Y minus", .xySW)
                        pad("Y−", 0, -1, 0, "Y minus", .yMinus)
                        pad("↘︎", 1, -1, 0, "X plus Y minus", .xySE)
                        pad("Z−", 0, 0, -1, "Z minus", .zMinus)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Move to")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        coord("X", $model.pendant.targetX)
                        coord("Y", $model.pendant.targetY)
                        coord("Z", $model.pendant.targetZ)
                    }
                    Button("Move Now") { Task { await pendant.moveToTarget() } }
                        .buttonStyle(PadKeyStyle(emphasized: true))
                        .disabled(!pendant.isConnected)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Lab control pad")
    }

    @ViewBuilder
    private func pad(_ title: String, _ dx: Double, _ dy: Double, _ dz: Double, _ label: String, _ cell: PadCell) -> some View {
        let lit = model.highlights.contains(cell)
            || (cell == .xPlus && model.highlights.contains(.xPlus))
        if pendant.controlMode == .hold {
            HoldButton(title: title, accessibilityLabel: label, lit: lit) { down in
                if dx != 0 { pendant.setHeld(.x, dx > 0 ? .pos : .neg, down: down) }
                if dy != 0 { pendant.setHeld(.y, dy > 0 ? .pos : .neg, down: down) }
                if dz != 0 { pendant.setHeld(.z, dz > 0 ? .pos : .neg, down: down) }
            }
        } else {
            Button(title) {
                Task { await pendant.step(dx: dx, dy: dy, dz: dz) }
            }
            .buttonStyle(PadKeyStyle(lit: lit))
            .disabled(!pendant.isConnected)
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
