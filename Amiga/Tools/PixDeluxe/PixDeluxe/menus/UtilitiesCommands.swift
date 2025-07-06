//
//  UtilitiesCommands.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/5/25.
//


import SwiftUI

struct UtilitiesCommands: Commands {
    @ObservedObject var viewModel: ContentViewModel

    var body: some Commands {
        CommandMenu("Utilities") {
            Button("Generate Hexdump") {
                viewModel.generateHexDump()
            }
            .disabled(viewModel.image == nil)
            
            Button("Copy Hexdump to Clipboard") {
                viewModel.copyHexdumpToClipboard()
            }
            .disabled(viewModel.hexdump == nil)
            
            Divider()
            
            Button("Convert to IFF...") {
                viewModel.convertToIFFFromImage()
            }
            .disabled(viewModel.image != nil)
            
            Button("Export as PNG...") {
                viewModel.exportToImage()
            }
            .disabled(viewModel.image == nil)
        }
    }
}
