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
    @State private var showDebugInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(details.fileName)
                    .font(.title)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
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
                
                DisclosureGroup("Debug Info", isExpanded: $showDebugInfo) {
                    VStack {
                        DetailRow(label: "Form Type", value: details.formType)
                        DetailRow(label: "Has CMAP Chunk", value: details.hasCMAP ? "Yes" : "No")
                    }
                    .padding(.top, 5)
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
        // AI_REVIEW: The `asyncAfter` call is updated to the modern syntax,
        // using `.now() + .seconds()`, which resolves the compiler error.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
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
