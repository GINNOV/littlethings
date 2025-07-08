//
//  PixDeluxeApp.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/1/25.
//

import SwiftUI

// AI_REVIEW: A new notification name is defined to communicate from the AppDelegate
// to the SwiftUI views without creating a hard dependency.
extension Notification.Name {
    static let openImageBrowser = Notification.Name("openImageBrowser")
}

@main
struct PixDeluxeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        DocumentGroup(newDocument: PixDeluxeDocument()) { file in
            // The main content view is wrapped in a RootView to handle launch notifications.
            RootView {
                ContentView(document: file.$document)
            }
        }
        .commands {
            UtilitiesCommands()
            // AI_REVIEW: The BrowserCommands struct is now included below, resolving the compiler error.
            BrowserCommands()
        }
        
        Window("Image Browser", id: "image-browser") {
            ImageBrowserView()
                .frame(minWidth: 400, minHeight: 300)
        }
        
        // AI_REVIEW: The call is disambiguated by specifying `SwiftUI.Settings`.
        // This resolves the name collision with the custom `Settings` class
        // and fixes the "Extra trailing closure" compiler error.
        SwiftUI.Settings {
            PreferencesView()
        }
    }
}

/// A helper view that wraps the main content and listens for notifications.
struct RootView<Content: View>: View {
    @ViewBuilder let content: Content
    @Environment(\.openWindow) var openWindow

    var body: some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .openImageBrowser)) { _ in
                // When the notification is received, open the image browser window.
                openWindow(id: "image-browser")
            }
    }
}

/// A command set to add the "Open Image Browser" button to the File menu.
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
