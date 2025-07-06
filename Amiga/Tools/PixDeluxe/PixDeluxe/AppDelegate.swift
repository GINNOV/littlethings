//
//  AppDelegate.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.set("preferred", forKey: "AppleWindowTabbingMode")
    }
}
