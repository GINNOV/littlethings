//
//  UpdaterCommands.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 8/17/25.
//

import SwiftUI
import Sparkle

// This struct defines the "Check for Updates..." menu item
// that will be added to the main app menu.
struct UpdaterCommands: Commands {
    // We hold a reference to our updater controller.
    private let updaterController: UpdaterController

    init(updaterController: UpdaterController) {
        self.updaterController = updaterController
    }

    var body: some Commands {
        // Add the command to the main application menu.
        CommandGroup(after: .appInfo) {
            Button("Check for Updates…") {
                updaterController.checkForUpdates()
            }
        }
    }
}
