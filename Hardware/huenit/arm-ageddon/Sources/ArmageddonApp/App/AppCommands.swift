import SwiftUI

struct AppCommands: Commands {
    let actions: AppActions

    var body: some Commands {
        CommandMenu("Navigate") {
            ForEach(Array(AppDestination.allCases.enumerated()), id: \.element) { index, destination in
                Button(destination.title) {
                    actions.navigate(destination)
                }
                .keyboardShortcut(KeyEquivalent(Character(String(index + 1))), modifiers: .command)
            }
        }
        CommandGroup(after: .appTermination) {
            Divider()
            Button("STOP Motion", action: actions.stop)
                .keyboardShortcut(.escape, modifiers: [])
        }
    }
}
