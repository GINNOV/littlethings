import SwiftUI

struct StickCheatsheet: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How the stick works")
                .font(.title2.weight(.semibold))

            Text("Keep the stick held. The arm moves for as long as you point. Release to stop that direction.")
                .foregroundStyle(.secondary)

            cheatsheetRow("Stick", "Slide the cup on the table (X / Y). Away is Y+, right is X+.")
            cheatsheetRow("Hold left fire", "Stick is now height and cup twist: forward/back = Z, left/right = angle.")
            cheatsheetRow("Right fire", "Suction on or off (one press).")
            cheatsheetRow("Both fires", "Still just suction plus Z/angle mode. Nothing extra.")
            cheatsheetRow("STOP or Esc", "Halt motion and turn suction off. Also happens if you leave the window.")

            Text("The pad lights the same cells the stick is using.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(minWidth: 420, idealWidth: 480)
    }

    private func cheatsheetRow(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(body)
                .foregroundStyle(.secondary)
        }
    }
}
