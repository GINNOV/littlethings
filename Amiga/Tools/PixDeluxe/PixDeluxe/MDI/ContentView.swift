//
//  ContentView.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/1/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Binding var document: PixDeluxeDocument

    var body: some View {
        VStack {
            if let image = document.image {
                image
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Text("Open an IFF file to begin.")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(document.details?.fileName ?? "PixDeluxe")
        .toolbar {
            DetailToolbar(document: $document)
        }
        .focusedSceneValue(\.document, $document)
    }
}
