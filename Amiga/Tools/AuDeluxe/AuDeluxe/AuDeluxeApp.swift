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
    // Create and manage a single instance of our new OpenMPTEngine.
    @StateObject private var engine = OpenMPTEngine()

    var body: some Scene {
        WindowGroup {
            // Inject both the settings and the engine into the environment.
            ContentView()
                .environmentObject(settings)
                .environmentObject(engine)
        }
        .commands {
            // Adds a custom "About" menu item to the main app menu.
            CommandGroup(replacing: .help) {
                Button("About AuDeluxe") {
                    // This is a simple way to open a view in a new window.
                    // For a more robust solution, you might use a window controller.
                    let aboutView = AboutView()
                    let window = NSWindow(
                        contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
                        styleMask: [.titled, .closable],
                        backing: .buffered,
                        defer: false)
                    window.center()
                    window.contentView = NSHostingView(rootView: aboutView)
                    window.makeKeyAndOrderFront(nil)
                }
            }
        }

        // The Settings scene now points to our much simpler SettingsView.
        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }
}
