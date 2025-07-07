//
//  ImageBrowserView.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/8/25.
//

import SwiftUI

/// The main view for the image browser feature.
struct ImageBrowserView: View {
    @StateObject private var viewModel = ImageBrowserViewModel()
    @State private var selectedImage: NSImage?
    @State private var isViewerPresented = false
    
    // Configure the adaptive grid layout.
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]

    var body: some View {
        ZStack {
            VStack {
                // Show a loading indicator while scanning.
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                        Text(viewModel.statusText)
                            .padding(.top)
                            .foregroundColor(.secondary)
                    }
                // Show the status text when idle or empty.
                } else if viewModel.browserItems.isEmpty {
                    Text(viewModel.statusText)
                        .font(.title)
                        .foregroundColor(.secondary)
                } else {
                    // The main scrollable grid of thumbnails.
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.browserItems) { item in
                                ThumbnailView(item: item)
                                    .onTapGesture {
                                        selectedImage = item.nsImage
                                        isViewerPresented = true
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Image Browser")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        viewModel.openFolder()
                    }) {
                        Label("Open Folder", systemImage: "folder.badge.plus")
                    }
                    .help("Select a folder to browse")
                }
            }
            
            // Present the full-screen viewer when an image is selected.
            if isViewerPresented, let image = selectedImage {
                ImageViewer(image: image, isPresented: $isViewerPresented)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Prompt the user to select a folder immediately if the browser is empty.
            if viewModel.browserItems.isEmpty {
                viewModel.openFolder()
            }
        }
    }
}
