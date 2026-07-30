//
//  UpdaterController.swift
//  ADFinder
//
//  Created by Mario Esposito on 8/12/25.
//

import Sparkle

final class UpdaterController {
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
