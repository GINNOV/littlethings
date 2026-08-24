import Joy1
import SwiftUI

struct ModuleCard: View {
    @Bindable var model: PendantModel

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
                        Text(String(format: "Angle  %.1f°", model.pose?.e ?? 0))
                            .font(.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                HStack {
                    Button("E−") { Task { await model.jogModule(sign: .neg) } }
                        .buttonStyle(PadKeyStyle())
                        .disabled(!model.isConnected)
                        .accessibilityLabel("Module angle minus")
                    Button("E+") { Task { await model.jogModule(sign: .pos) } }
                        .buttonStyle(PadKeyStyle())
                        .disabled(!model.isConnected)
                        .accessibilityLabel("Module angle plus")
                }

                VacuumToggle(model: model)
            }
        }
    }
}
