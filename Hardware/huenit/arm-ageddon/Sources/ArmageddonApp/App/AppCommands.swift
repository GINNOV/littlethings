import SwiftUI

struct AppCommands: Commands {
    let actions: AppActions

    var body: some Commands {
        CommandGroup(after: .appTermination) {
            Divider()
            Button("STOP Motion", action: actions.stop)
                .keyboardShortcut(.escape, modifiers: [])
        }
    }
}
