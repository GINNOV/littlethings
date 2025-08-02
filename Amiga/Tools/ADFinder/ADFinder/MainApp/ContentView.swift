//
//  ContentView.swift
//  ADFinder
//
//  Created by Mario Esposito on 5/23/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State var adfService: ADFService
    @Bindable var recentFilesService: RecentFilesService

    @State private var selectedFile: URL?
    var initialURL: URL?

    @AppStorage("openLastKnownDisk") private var openLastKnownDisk = false
    @Environment(\.openWindow) private var openWindow
    private static var didRunStartupLogic = false

    static let adfUType = UTType("public.retro.adf")!
    static let hdfUType = UTType("public.retro.hdf")!

    var body: some View {
        NavigationSplitView {
            SidebarView(
                adfService: adfService,
                recentFilesService: recentFilesService,
                selectedFile: $selectedFile
            )
        } detail: {
            DetailView(
                adfService: adfService,
                recentFilesService: recentFilesService,
                selectedFile: $selectedFile
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .openSpecificAdfFile)) { notification in
            if let url = notification.object as? URL {
                self.selectedFile = url
            }
        }
        .onAppear {
            if let url = initialURL {
                selectedFile = url
            } else {
                if !Self.didRunStartupLogic {
                    Self.didRunStartupLogic = true
                    if openLastKnownDisk {
                        let recentFiles = recentFilesService.recentFiles.prefix(5)
                        if let firstFile = recentFiles.first {
                            selectedFile = firstFile
                            for file in recentFiles.dropFirst() {
                                openWindow(value: file)
                            }
                        }
                    }
                }
            }
        }
    }
    
    init(adfService: ADFService, recentFilesService: RecentFilesService, initialURL: URL? = nil) {
        self.adfService = adfService
        self.recentFilesService = recentFilesService
        self.initialURL = initialURL
    }
}
