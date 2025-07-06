//
//  UtilitiesCommands.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI

struct UtilitiesCommands: Commands {
    @FocusedBinding(\.document) var document: PixDeluxeDocument?

    var body: some Commands {
        CommandMenu("Utilities") {
            Button("Generate and Copy Hexdump") {
                document?.generateHexdump()
            }
            .disabled(document?.chunkyData == nil)
            .keyboardShortcut("h", modifiers: [.command, .shift])

            Divider()
            Button("Export as PNG...") {
                document?.exportToPNG()
            }
            .disabled(document?.image == nil)
        }
    }
}
