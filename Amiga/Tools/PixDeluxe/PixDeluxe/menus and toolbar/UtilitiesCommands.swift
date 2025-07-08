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

                Task {
                    if let newURL = await imageConverter.convert(url: url, nPlanes: nPlanes) {
                        NSDocumentController.shared.openDocument(withContentsOf: newURL, display: true) { document, alreadyOpen, error in
                            if let error = error {
                                print("❌ Failed to open IFF: \(error.localizedDescription)")
                            }
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
