//
//  AuDeluxeApp.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import AppKit
import SwiftUI

// MARK: - Main App Structure

@main
struct AuDeluxeApp: App {
    @StateObject private var settings = SettingsStore()
    @StateObject private var engine = OpenMPTEngine()
    
    private let updaterController = UpdaterController()
    @State private var selectedFileID: PlaylistItem.ID?
    
    var body: some Scene {
        WindowGroup {
            // Inject both the settings and the engine into the environment.
            ContentView(selectedFileID: $selectedFileID)
                .environmentObject(settings)
                .environmentObject(engine)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "AuDeluxe")") {
                    
                    // Create the window instance FIRST.
                    let window = NSWindow(
                        contentRect: NSRect(x: 0, y: 0, width: 650, height: 400),
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
            UpdaterCommands(updaterController: updaterController)
            CommandGroup(after: .help) {
                Button("Supported Module Formats") {
                    guard let documentURL = Bundle.main.url(forResource: "formatypes", withExtension: "md") else {
                        NSSound.beep()
                        return
                    }
                    NSWorkspace.shared.open(documentURL)
                }
            }
        }
        
        MenuBarExtra {
                    MenuBarView(selectedFileID: $selectedFileID)
                        .environmentObject(settings)
                        .environmentObject(engine)
                } label: {
                    // The icon changes based on the playback state.
                    Image(systemName: engine.isPlaying ? "speaker.wave.2.fill" : "speaker.slash.fill")
                }
                .menuBarExtraStyle(.window) // This style provides a popover window.

        
        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }
}
