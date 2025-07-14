//
//  SettingsView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import SwiftUI

// MARK: - Settings View
// NOTE: If you are seeing an error like "Cannot find type 'SettingsStore' in scope",
// it means the file containing the SettingsStore class (e.g., SettingsStore.swift)
// has not been correctly added to your app's target in Xcode.
//
// To fix this:
// 1. Select the SettingsStore.swift file in the Project Navigator on the left.
// 2. Open the Inspector pane on the right (Option-Command-1).
// 3. Go to the "File Inspector" tab (the first icon).
// 4. In the "Target Membership" section, make sure the checkbox next to your app's name (e.g., "AuDeluxe") is checked.

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 25) {
            Text("Settings")
                .font(.largeTitle)
                .padding(.bottom)

            VStack(alignment: .leading, spacing: 10) {
                Text("Kickstart ROMs Folder")
                    .font(.title2)
                Text("UADE requires access to the Kickstart ROM files (e.g., kick34005.A500) to function correctly. Please select the folder containing these files.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }

            // Show the current path if it's set, using a helper to handle security scope.
            if let path = romsFolderPath {
                Text("Current: \(path)")
                    .font(.footnote)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            HStack(spacing: 15) {
                // Button to trigger the folder selection dialog.
                Button("Select Folder...") {
                    settings.selectRomsFolder()
                }

                // Add a button to clear the setting if it's already set.
                if settings.romsFolderBookmark != nil {
                    Button("Clear") {
                        settings.clearRomsFolder()
                    }
                }
            }
            
            Spacer()

            // A standard button to close the settings sheet.
            Button("Done") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction) // Allows pressing Enter to trigger this button.
        }
        .padding(30)
        .frame(minWidth: 500, minHeight: 300)
    }
    
    /// A helper computed property to safely get the path from the security-scoped URL.
    /// This avoids using control flow like `defer` inside the ViewBuilder.
    private var romsFolderPath: String? {
        guard let url = settings.romsFolderURL else { return nil }
        
        // Start accessing the resource. This must be balanced with a call to stopAccessing.
        let access = url.startAccessingSecurityScopedResource()
        
        // Use a defer block to ensure we stop accessing the resource when this scope exits.
        defer {
            if access {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        // Now that we have access, we can get the path.
        return url.path
    }
}

// MARK: - SwiftUI Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // The preview will work once the 'SettingsStore' type is found in the target.
        SettingsView()
            .environmentObject(SettingsStore())
    }
}
