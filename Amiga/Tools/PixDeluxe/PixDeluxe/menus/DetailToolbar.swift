//
//  DetailToolbar.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI

struct DetailToolbar: ToolbarContent {
    @Binding var document: PixDeluxeDocument
    @State private var showingDetails = false
    
    var body: some ToolbarContent {
        ToolbarItemGroup {
            Button(action: { NSDocumentController.shared.openDocument(nil) }) {
                Image(systemName: "folder")
            }.help("Open a file")

            Button(action: { document.exportToPNG() }) {
                Image(systemName: "square.and.arrow.up")
            }.help("Export as PNG").disabled(document.image == nil)

            Button(action: { showingDetails.toggle() }) {
                Image(systemName: "info.circle")
            }.help("Metadata").disabled(document.details == nil)
            .sheet(isPresented: $showingDetails) {
                if let details = document.details {
                    ImageDetailsView(details: details)
                }
            }
        }
    }
}
