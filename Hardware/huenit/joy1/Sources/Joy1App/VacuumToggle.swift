import Joy1
import SwiftUI

struct VacuumToggle: View {
    @Bindable var model: PendantModel

    var body: some View {
        Toggle(
            "Vacuum",
            isOn: Binding(
                get: { model.vacuumOn },
                set: { on in
                    Task { await model.setVacuum(on) }
                }
            )
        )
        .disabled(!model.isConnected)
        .accessibilityLabel("Vacuum")
    }
}
