//
//  IFFPreviewView.swift
//  IFFViewer Extension
//
//  Created by Mario Esposito on 7/7/25.
//
import SwiftUI
import CoreGraphics

// This view is responsible for displaying the IFF image in the Quick Look preview.
struct IFFPreviewView: View {
    // The image to display. It's an optional because loading might fail.
    var image: CGImage?

    var body: some View {
        // Use a GeometryReader to get the available size for the preview.
        GeometryReader { geometry in
            if let img = image {
                // If the image loaded successfully, display it.
                // We convert the CGImage to a SwiftUI Image.
                Image(img, scale: 1.0, label: Text("IFF Image"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            } else {
                // If the image failed to load, show an error message.
                Text("Could not load IFF image.")
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
