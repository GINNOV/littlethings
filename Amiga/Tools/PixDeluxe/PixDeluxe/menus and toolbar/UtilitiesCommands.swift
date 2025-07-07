//
//  UtilitiesCommands.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI

struct UtilitiesCommands: Commands {
    @FocusedBinding(\.document) var document: PixDeluxeDocument?
    private let imageConverter = ImageConverter()

    var body: some Commands {
        CommandMenu("Utilities") {
            Button("Generate and Copy Hexdump") {
                document?.generateHexdump()
            }
            .disabled(document?.chunkyData == nil)
            .keyboardShortcut("h", modifiers: [.command, .shift])
            
            // AI_REVIEW: The conversion process is now orchestrated here. It first opens a file picker,
            // then shows the new dedicated color depth dialog, and finally calls the purely
            // algorithmic image converter with the results.
            Button("Convert to IFF...") {
                let openPanel = NSOpenPanel()
                openPanel.allowedContentTypes = [.png, .jpeg]
                openPanel.canChooseFiles = true
                openPanel.canChooseDirectories = false
                openPanel.allowsMultipleSelection = false

                guard openPanel.runModal() == .OK, let url = openPanel.url else {
                    print("ℹ️ Import file selection cancelled by user.")
                    return
                }
                
                let dialog = ColorDepthDialog()
                guard let nPlanes = dialog.runModal() else {
                    print("ℹ️ IFF conversion cancelled by user at color depth selection.")
                    return
                }

                if let newURL = imageConverter.convert(url: url, nPlanes: nPlanes) {
                    NSDocumentController.shared.openDocument(withContentsOf: newURL, display: true) { document, documentWasAlreadyOpen, error in
                        if let error = error {
                            print("❌ Failed to open converted IFF document: \(error.localizedDescription)")
                        }
                    }
                }
            }

            Divider()
            
            Button("Export as PNG...") {
                document?.exportToPNG()
            }
            .disabled(document?.image == nil)
        }
    }
}
