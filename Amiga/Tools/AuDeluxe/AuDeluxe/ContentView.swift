//
//  ContentView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
    // @EnvironmentObject gives us access to the SettingsStore instance from the environment.
    @EnvironmentObject private var settings: SettingsStore
    
    // @State controls the visibility of the settings sheet.
    @State private var isShowingSettings = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("AuDeluxe")
                .font(.largeTitle)

            // Display the current status of the ROMs folder setting.
            if let path = romsFolderPath {
                VStack {
                    Text("ROMs Folder is Set:")
                        .font(.headline)
                    // Display the path in a user-friendly way.
                    Text(path)
                        .font(.caption)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
            } else {
                Text("Please set your Kickstart ROMs folder in Settings.")
                    .foregroundColor(.red)
            }

            // Button to open the settings sheet.
            Button("Open Settings") {
                isShowingSettings = true
            }
            .padding()
        }
        .padding(40)
        .frame(minWidth: 450, minHeight: 300)
        // This presents the SettingsView as a sheet when isShowingSettings is true.
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
                // We must also pass the environment object to the sheet.
                .environmentObject(settings)
        }
    }
    
    /// A helper computed property to safely get the path from the security-scoped URL.
    /// This avoids using control flow like `defer` inside the ViewBuilder.
    private var romsFolderPath: String? {
        guard let url = settings.romsFolderURL else { return nil }
        
        let access = url.startAccessingSecurityScopedResource()
        defer {
            if access {
                url.stopAccessingSecurityScopedResource()
            }
        }
        return url.path
    }
}

// MARK: - SwiftUI Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // This preview will work once the 'SettingsStore' type is found in the target.
        ContentView()
            .environmentObject(SettingsStore())
    }
}
