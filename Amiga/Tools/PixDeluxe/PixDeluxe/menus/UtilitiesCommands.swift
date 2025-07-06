//
//  UtilitiesCommands.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI

struct UtilitiesCommands: Commands {
    @FocusedBinding(\.document) var document: PixDeluxeDocument?
    // AI_REVIEW: Added a private instance of ImageConverter to handle the new conversion task. #END_REVIEW
    private let imageConverter = ImageConverter()

    var body: some Commands {
        CommandMenu("Utilities") {
            Button("Generate and Copy Hexdump") {
                document?.generateHexdump()
            }
            .disabled(document?.chunkyData == nil)
            .keyboardShortcut("h", modifiers: [.command, .shift])
            
            // AI_REVIEW: This new button initiates the PNG/JPG to IFF conversion process.
            // It is always enabled as it doesn't depend on a currently open document.
            // After conversion, it opens the new IFF file in a new tab. #END_REVIEW
            Button("Convert to IFF...") {
                if let url = imageConverter.importAndConvertToIFF() {
                    NSDocumentController.shared.openDocument(withContentsOf: url, display: true, completionHandler: { document, documentWasAlreadyOpen, error in
                        if let error = error {
                            // In a real app, you'd present this error to the user.
                            print("❌ Failed to open converted IFF document: \(error.localizedDescription)")
                        }
                        // The temp file will be managed by the system/document controller
                    })
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
