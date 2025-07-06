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
        }
    }
}
