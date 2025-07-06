//
//  FileMenuCommands.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI

struct FileMenuCommands: Commands {
    @ObservedObject var viewModel: ContentViewModel

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Open IFF Image...") {
                viewModel.openFile()
            }
            .keyboardShortcut("O", modifiers: .command)
        }
        
        // AI_REVIEW: The compiler error was correct. `.showHelp` is not a valid
        // member of `CommandGroupPlacement`. The correct anchor to place an
        // item in the standard "View" menu is `.toolbar`. This change
        // resolves the compiler error and correctly places the command.
        // #END_REVIEW
        CommandGroup(after: .toolbar) {
            Divider()
            Button("Image Details") {
                viewModel.toggleImageDetails()
            }
            .keyboardShortcut("i", modifiers: .command)
            .disabled(viewModel.imageDetails == nil)
        }
    }
}

