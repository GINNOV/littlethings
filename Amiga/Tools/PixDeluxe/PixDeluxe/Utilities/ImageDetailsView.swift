//
//  ImageDetailsView.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI

struct ImageDetailsView: View {
    let details: IFFImageDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Image Details")
                .font(.title)
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
        .frame(minWidth: 350, idealWidth: 400)
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
