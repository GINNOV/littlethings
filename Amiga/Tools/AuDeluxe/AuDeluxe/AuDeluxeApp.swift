//
//  AuDeluxeApp.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import SwiftUI

// MARK: - Main App Structure


@main
struct AuDeluxeApp: App {
    // Create and manage a single instance of our SettingsStore.
    @StateObject private var settings = SettingsStore()
    // Create and manage a single instance of our UADEEngine.
    @StateObject private var engine = UADEEngine()

    var body: some Scene {
        WindowGroup {
            // Inject both the settings and the engine into the environment
            // so that any view in the hierarchy can access them.
            ContentView()
                .environmentObject(settings)
                .environmentObject(engine)
        }
    }
}
