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
    @StateObject private var settings = SettingsStore()
    @StateObject private var engine = OpenMPTEngine()
    
    // AI_REVIEW: The UpdaterController is created once here and holds the Sparkle engine. #END_REVIEW
    private let updaterController = UpdaterController()

    var body: some Scene {
        WindowGroup {
            // Inject both the settings and the engine into the environment.
            ContentView()
                .environmentObject(settings)
                .environmentObject(engine)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "AuDeluxe")") {
                    
                    // Create the window instance FIRST.
                    let window = NSWindow(
                        contentRect: NSRect(x: 0, y: 0, width: 450, height: 400),
                        styleMask: [.titled, .closable],
                        backing: .buffered,
                        defer: false)
                    
                    let aboutView = AboutView(closeAction: { [weak window] in
                        window?.close()
                    })
                    
                    // Place the view in the window and show it.
                    window.contentView = NSHostingView(rootView: aboutView)
                    window.center()
                    window.makeKeyAndOrderFront(nil)
                }
            }
            // AI_REVIEW: The UpdaterCommands are added to the scene here, which adds the menu item. #END_REVIEW
            UpdaterCommands(updaterController: updaterController)
        }
        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }
}
