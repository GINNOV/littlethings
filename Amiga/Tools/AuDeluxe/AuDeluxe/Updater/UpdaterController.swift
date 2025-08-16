//
//  UpdaterController.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 8/17/25.
//

import SwiftUI
import Sparkle

// This class is responsible for configuring and starting the Sparkle updater.
// It acts as a bridge between your SwiftUI app and the Sparkle framework.
final class UpdaterController {
    private let updaterController: SPUStandardUpdaterController

    init() {
        // Initialize the standard updater controller.
        // Sparkle will automatically find the necessary Info.plist keys (like SUFeedURL) to configure itself.
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }

    // This function can be used to manually trigger an update check.
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
