import SwiftUI

struct UpdaterCommands: Commands {
    private let updaterController: UpdaterController

    init(updaterController: UpdaterController) {
        self.updaterController = updaterController
    }

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button("Check for Updates...") {
                updaterController.checkForUpdates()
            }
        }
    }
}