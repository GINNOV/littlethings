//
//  AppDelegate.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.set("always", forKey: "AppleWindowTabbingMode")
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let launchActionRaw = UserDefaults.standard.string(forKey: "launchAction")
        let launchAction = LaunchAction(rawValue: launchActionRaw ?? "")

        // This method is now only responsible for performing the actions,
        // not for controlling the initial window.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Reduced delay
            switch launchAction {
            case .openFileSelection:
                NSDocumentController.shared.openDocument(nil)
            case .openImageBrowser:
                NotificationCenter.default.post(name: .openImageBrowser, object: nil)
            case .doNothing, .none:
                break
            }
        }
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        let launchActionRaw = UserDefaults.standard.string(forKey: "launchAction")
        
        // If a preference has been set (even the default "Do Nothing"),
        // we take control and prevent the default window.
        if launchActionRaw != nil {
            return false
        }
        
        // If no preference has ever been set (truly the first launch), allow the default behavior.
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            let launchActionRaw = UserDefaults.standard.string(forKey: "launchAction")
            let launchAction = LaunchAction(rawValue: launchActionRaw ?? "")
            
            switch launchAction {
            case .openFileSelection:
                NSDocumentController.shared.openDocument(nil)
            case .openImageBrowser:
                NotificationCenter.default.post(name: .openImageBrowser, object: nil)
            case .doNothing, .none:
                // If "Do Nothing" is selected, we explicitly do nothing,
                // rather than opening a new window.
                break
            }
        }
        return true
    }
}
