//
//  IFFViewerApp.swift
//  IFFViewer
//
//  Created by Mario Esposito on 7/7/25.
//

import SwiftUI

@main
struct IFFViewerApp: App {
    private let updaterController = UpdaterController()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            UpdaterCommands(updaterController: updaterController)
        }
    }
}
