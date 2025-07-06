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
    }
}
