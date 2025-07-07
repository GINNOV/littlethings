//
//  PixDeluxeApp.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/1/25.
//

import SwiftUI

@main
struct PixDeluxeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        DocumentGroup(newDocument: PixDeluxeDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands {
            UtilitiesCommands()
            BrowserCommands() // Add the new commands to the menu bar.
        }
        
        // Define a new window scene for the image browser.
        // This allows the browser to exist in its own separate window.
        Window("Image Browser", id: "image-browser") {
            ImageBrowserView()
                .frame(minWidth: 400, minHeight: 300)
        }
    }
}

/// A new command set to add the "Open Image Browser" button to the File menu.
struct BrowserCommands: Commands {
    @Environment(\.openWindow) var openWindow

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Divider()
            Button("Open Image Browser...") {
                openWindow(id: "image-browser")
            }
            .keyboardShortcut("B", modifiers: [.command, .shift])
        }
    }
}
