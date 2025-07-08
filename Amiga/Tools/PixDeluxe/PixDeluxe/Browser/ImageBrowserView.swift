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
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]

    var body: some View {
        ZStack {
            VStack {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                        Text(viewModel.statusText)
                            .padding(.top)
                            .foregroundColor(.secondary)
                    }
                } else if viewModel.browserItems.isEmpty {
                    Text(viewModel.statusText)
                        .font(.title)
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.browserItems) { item in
                                ThumbnailView(item: item, onImageTap: {
                                    self.selectedImage = item.nsImage
                                    self.isViewerPresented = true
                                })
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
            
            if isViewerPresented, let image = selectedImage {
                ImageViewer(image: image, isPresented: $isViewerPresented)
                    .transition(.opacity)
            }
        }
        .onAppear {
            if viewModel.browserItems.isEmpty {
                viewModel.openFolder()
            }
        }
    }
}
