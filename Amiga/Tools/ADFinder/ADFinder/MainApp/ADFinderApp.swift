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
    @AppStorage("lastVersionPromptedFor") private var lastVersionPromptedFor: String = ""
    @AppStorage("dontShowWhatsNew") private var dontShowWhatsNew = false
    
    @State private var recentFilesService = RecentFilesService()
    @State private var logStore = LogStore.shared
    @State private var showWhatsNew = false
    
    @Environment(\.openWindow) private var openWindow

    static let adfUType = UTType("public.retro.adf")!
    static let hdfUType = UTType("public.retro.hdf")!
    
    var body: some Scene {
        WindowGroup {
            ContentView(recentFilesService: recentFilesService)
                .environment(logStore)
                .sheet(isPresented: $showWhatsNew) {
                                    WhatsNewView(showWhatsNew: $showWhatsNew)
                                }
                                .onAppear {
                                    checkForUpdates()
                                }
        }
        .commands {
            AmigaMenuCommands()
            
                        CommandGroup(replacing: .appInfo) {
                Button("About ADFinder") {
                    
                    NotificationCenter.default.post(name: .showAboutWindow, object: nil)
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
                            NotificationCenter.default.post(name: .openSpecificAdfFile, object: url)
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
        
        // Show the dialog if the user hasn't opted out and the current version is new.
        if !dontShowWhatsNew && currentVersion != lastVersionPromptedFor {
            showWhatsNew = true
            lastVersionPromptedFor = currentVersion
        }
    }
}
