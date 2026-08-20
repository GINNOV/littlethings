//
//  Streamer.swift
//  Dremel Watcher
//
//  Created by Mario Esposito on 12/31/24.
//

import Foundation
import SwiftUI

struct MJPEGStreamView: View {
    @StateObject private var streamHandler = MJPEGStreamHandler()
    let url: String
    var body: some View {
        GeometryReader { geometry in
            if let image = streamHandler.currentImage {
                HStack(alignment: .top) {  // Added alignment .top
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.8)  // Changed to fixed width
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(3.7),
                                            Color.cyan.opacity(5.5),
                                            Color.blue.opacity(1.7)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 10
                                )
                        )
                        .padding(6)
                    Spacer(minLength: geometry.size.width * 0.2)  // Explicit space for buttons
                }
                .background(Color.black) // Add explicit black background to GeometryReader
            } else {
                Color.black
            }
        }
        .onAppear {
            streamHandler.startStream(urlString: url)
        }
        .onDisappear {
            streamHandler.stopStream()
        }
    }
}
