//
//  ImageDetailsView.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI

struct ImageDetailsView: View {
    let details: IFFImageDetails
    @State private var justCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // AI_REVIEW: The title is now the dynamic filename from the details struct.
                Text(details.fileName)
                    .font(.title)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                // AI_REVIEW: A button is added to copy the full file path to the clipboard.
                // It shows a temporary confirmation checkmark after being clicked.
                Button(action: copyPath) {
                    Image(systemName: justCopied ? "checkmark" : "doc.on.doc")
                }
                .buttonStyle(PlainButtonStyle())
                .help("Copy File Path")
                .foregroundColor(justCopied ? .green : .accentColor)
            }
            .padding(.bottom)

            Form {
                Section(header: Text("Dimensions")) {
                    DetailRow(label: "Width", value: "\(details.width) px")
                    DetailRow(label: "Height", value: "\(details.height) px")
                    DetailRow(label: "Depth", value: "\(details.depth) bitplanes")
                    DetailRow(label: "Aspect Ratio", value: details.aspectRatio)
                    DetailRow(label: "Page Size", value: details.pageDimensions)
                }
                
                Section(header: Text("Color & Compression")) {
                    DetailRow(label: "Colors", value: "\(details.colors)")
                    DetailRow(label: "Compression", value: details.compression)
                    DetailRow(label: "Masking", value: details.masking)
                }
                
                if let viewportMode = details.viewportMode {
                    Section(header: Text("Amiga Specific")) {
                        DetailRow(label: "Viewport Mode", value: viewportMode)
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 450)
    }
    
    private func copyPath() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(details.filePath, forType: .string)
        
        justCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            justCopied = false
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.bold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
