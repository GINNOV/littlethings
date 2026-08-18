import Joy1
import Joy2
import SwiftUI

struct ModuleCard: View {
    @Bindable var model: PilotModel

    private var pendant: PendantModel { model.pendant }

    var body: some View {
        PendantCard(title: "Module") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "circle.dotted")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(width: 56, height: 56)
                        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Suction")
                            .font(.headline)
                        Text(String(format: "Angle  %.1f°", pendant.pose?.e ?? 0))
                            .font(.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                HStack {
                    Button("E−") { Task { await pendant.jogModule(sign: .neg) } }
                        .buttonStyle(PadKeyStyle(lit: model.highlights.contains(.eMinus)))
                        .disabled(!pendant.isConnected)
                        .accessibilityLabel("Module angle minus")
                    Button("E+") { Task { await pendant.jogModule(sign: .pos) } }
                        .buttonStyle(PadKeyStyle(lit: model.highlights.contains(.ePlus)))
                        .disabled(!pendant.isConnected)
                        .accessibilityLabel("Module angle plus")
                }

                Toggle(
                    "Suction",
                    isOn: Binding(
                        get: { pendant.vacuumOn },
                        set: { on in Task { await pendant.setVacuum(on) } }
                    )
                )
                .disabled(!pendant.isConnected)
                .padding(6)
                .background(
                    Color.accentColor.opacity(model.highlights.contains(.suction) ? 0.18 : 0),
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
                .accessibilityLabel("Suction")
            }
        }
    }
}
