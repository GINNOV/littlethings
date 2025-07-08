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
    let onImageTap: () -> Void
    @State private var showingDetails = false

    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                Image(nsImage: item.nsImage)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150, alignment: .center)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .shadow(radius: 4)
                
                // The info button is a separate control that takes priority over the tap gesture.
                Button(action: {
                    print("🖱️ [Debug] Tapped on info button for: \(item.details.fileName)")
                    showingDetails.toggle()
                }) {
                    Image(systemName: "info.circle.fill")
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
            .contentShape(Rectangle()) // Explicitly define the tappable area.
            .onTapGesture {
                print("🖱️ [Debug] Tapped on image: \(item.details.fileName)")
                onImageTap()
            }
            
            Text("\(item.details.width)x\(item.details.height)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
