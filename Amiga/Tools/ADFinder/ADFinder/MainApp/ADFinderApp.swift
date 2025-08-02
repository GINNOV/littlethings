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
    
    // rationale: By creating the services here, we ensure they are singletons for the app's lifetime.
    @State private var adfService = ADFService()
    @State private var recentFilesService = RecentFilesService()
    @State private var logStore = LogStore.shared
    @State private var showWhatsNew = false
    
    @Environment(\.openWindow) private var openWindow
    
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
        // rationale: The single adfService instance is now passed to the ContentView.
        WindowGroup(for: URL.self) { $url in
            ContentView(adfService: adfService, recentFilesService: recentFilesService, initialURL: url)
                .environment(logStore)
        }
        .commands {
            AmigaMenuCommands()
            
            CommandGroup(replacing: .appInfo) {
                Button("About ADFinder") {
                    
                    NotificationCenter.default.post(name: .showAboutWindow, object: nil)
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
        
        // rationale: The single adfService instance is also passed to the main ContentView.
        WindowGroup("ADFinder", id: "main") {
            ContentView(adfService: adfService, recentFilesService: recentFilesService)
                .environment(logStore)
                .sheet(isPresented: $showWhatsNew) {
                    WhatsNewView(showWhatsNew: $showWhatsNew)
                }
                .onAppear {
                    checkForUpdates()
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
    
    private func checkForUpdates() {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        
        if !dontShowWhatsNew && currentVersion != lastVersionPromptedFor {
            showWhatsNew = true
            lastVersionPromptedFor = currentVersion
        }
    }
}
