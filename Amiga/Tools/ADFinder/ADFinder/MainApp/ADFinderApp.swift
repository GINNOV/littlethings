//
//  ADFinderApp.swift
//  ADFinder
//
//  Created by Mario Esposito on 5/23/25.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct ADFinderApp: App {
    @AppStorage("rememberWindowSize") private var rememberWindowSize = false
    @AppStorage("autoEnableTabs") private var autoEnableTabs = false
    @AppStorage("openLastKnownDisk") private var openLastKnownDisk = false
    @AppStorage("lastVersionPromptedFor") private var lastVersionPromptedFor: String = ""
    @AppStorage("dontShowWhatsNew") private var dontShowWhatsNew = false
    
    @State private var adfService = ADFService()
    @State private var recentFilesService = RecentFilesService()
    @State private var logStore = LogStore.shared
    
    private let updaterController = UpdaterController()
    
    @Environment(\.openWindow) internal var openWindow
    
    private static var didRunUpdateCheck = false

    static let adfUType = UTType("public.retro.adf")!
    static let hdfUType = UTType("public.retro.hdf")!

    init() {
        let openLast = UserDefaults.standard.bool(forKey: "openLastKnownDisk")
        let autoTabs = UserDefaults.standard.bool(forKey: "autoEnableTabs")
        if openLast || autoTabs {
            NSWindow.allowsAutomaticWindowTabbing = true
        } else {
            NSWindow.allowsAutomaticWindowTabbing = false
        }
    }
    
    var body: some Scene {
        WindowGroup(for: URL.self) { $url in
            ContentView(adfService: adfService, recentFilesService: recentFilesService, initialURL: url)
                .environment(logStore)
                .onAppear {
                    if !Self.didRunUpdateCheck {
                        presentWhatsNewIfNeeded()
                        Self.didRunUpdateCheck = true
                    }
                }
        }
        .commands {
            AmigaMenuCommands()
            
            CommandGroup(replacing: .appInfo) {
                Button("About ADFinder") {
                    NotificationCenter.default.post(name: .showAboutWindow, object: nil)
                }
                
                Button("Check for Updates...") {
                    updaterController.checkForUpdates()
                }
            }
            
            CommandGroup(after: .appInfo) {
                Button("What's new...") {
                    NotificationCenter.default.post(name: .showWhatsNewWindow, object: nil)
                }
            }
            
            CommandGroup(replacing: .importExport) {
                Button("Open ADF...") {
                    NotificationCenter.default.post(name: .openAdfFile, object: nil)
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            
            CommandGroup(after: .importExport) {
                Menu("Open Recent") {
                    ForEach(recentFilesService.recentFiles, id: \.self) { url in
                        Button(url.lastPathComponent) {
                            openWindow(value: url)
                        }
                    }
                    
                    if !recentFilesService.recentFiles.isEmpty {
                        Divider()
                        Button("Clear Menu") {
                            recentFilesService.clearRecents()
                        }
                    }
                }
            }
            
            CommandGroup(after: .windowList) {
                Button("Show ADFlib Console") {
                    openWindow(id: "console-window")
                }
                .keyboardShortcut("l", modifiers: [.command, .shift])
                
                Button("Show Disk Comparator") {
                    openWindow(id: "compare-window")
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])
            }
        }
        
        WindowGroup("ADFinder", id: "main") {
            ContentView(adfService: adfService, recentFilesService: recentFilesService)
                .environment(logStore)
                .onAppear {
                    if !Self.didRunUpdateCheck {
                        presentWhatsNewIfNeeded()
                        Self.didRunUpdateCheck = true
                    }
                }
                .onOpenURL { url in
                    // rationale: This log message will confirm if the app is receiving the "Open With" event from Finder.
                    logStore.add(message: "ADFinderApp: Received URL from onOpenURL: \(url.path)")
                    NotificationCenter.default.post(name: .openSpecificAdfFile, object: url)
                }
        }

        Settings {
            PreferencesView()
        }
        
        Window("ADFlib Console", id: "console-window") {
            ConsoleView()
                .environment(logStore)
        }
        
        Window("ADF Disk Comparator", id: "compare-window") {
            ADFCompareView()
        }
    }
    
    private func presentWhatsNewIfNeeded() {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        
        if !dontShowWhatsNew && currentVersion != lastVersionPromptedFor {
            NotificationCenter.default.post(name: .showWhatsNewWindow, object: nil)
        }
    }
}
