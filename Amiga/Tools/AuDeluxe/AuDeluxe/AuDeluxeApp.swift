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
    // We use @StateObject to create and manage a single instance of our SettingsStore.
    // This object will be created once when the app launches and will be kept alive
    // for the entire lifecycle of the app.
    @StateObject private var settings = SettingsStore()

    var body: some Scene {
        WindowGroup {
            // This is the root view of our application.
            // We pass the settings store into the environment so that any view
            // inside this hierarchy can access it.
            ContentView()
                .environmentObject(settings)
        }
    }
}
