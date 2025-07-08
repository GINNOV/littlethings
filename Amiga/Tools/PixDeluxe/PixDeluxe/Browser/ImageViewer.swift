//
//  ImageViewer.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/8/25.
//

import SwiftUI

/// A modal view to display a selected image in a larger format, overlaying the browser.
/// It can be dismissed by tapping the background or the close button.
struct ImageViewer: View {
    let image: NSImage
    @Binding var isPresented: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.95).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }

            // The image is displayed using nearest-neighbor interpolation to preserve pixel art.
            Image(nsImage: image)
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fit)
                .padding(40)

            // A clear dismiss button.
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.7))
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            
            Button("") {
                isPresented = false
            }
            .keyboardShortcut(.escape, modifiers: [])
            .hidden()
        }
    }
}
