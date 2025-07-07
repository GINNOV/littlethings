//
//  ThumbnailView.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/8/25.
//

import SwiftUI

/// The view for a single item in the browser's grid.
struct ThumbnailView: View {
    let item: BrowserItem
    @State private var showingDetails = false

    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                // The thumbnail image.
                Image(nsImage: item.nsImage)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150, alignment: .center)
                    .clipped()
                    .cornerRadius(8)
                    // AI_REVIEW: A subtle stroke is added to improve readability against various backgrounds.
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .shadow(radius: 4)
                
                // The info button, which shows a popover with image details.
                Button(action: { showingDetails.toggle() }) {
                    Image(systemName: "info.circle.fill")
                        // AI_REVIEW: The font size is reduced to make the icon less prominent.
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(6)
                .popover(isPresented: $showingDetails, arrowEdge: .bottom) {
                    ImageDetailsView(details: item.details)
                }
            }
            
            // The image resolution displayed below the thumbnail.
            Text("\(item.details.width)x\(item.details.height)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
