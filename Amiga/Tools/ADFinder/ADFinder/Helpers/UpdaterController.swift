//
//  UpdaterController.swift
//  ADFinder
//
//  Created by Mario Esposito on 8/12/25.
//

import SwiftUI
import Sparkle

// This class is responsible for managing the Sparkle updater.
// It acts as a wrapper around the SPUStandardUpdaterController.
final class UpdaterController: NSObject {
    private let updaterController: SPUStandardUpdaterController

    override init() {
        // Initialize the standard updater controller from the Sparkle framework.
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        super.init()
    }

    // This method is called from the UI (e.g., a menu item) to start the update check process.
    @objc func checkForUpdates() {
        updaterController.checkForUpdates(self)
    }
}
