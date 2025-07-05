//
//  FileManagerService.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/5/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var showingFileImporter = false

    var body: some View {
        NavigationSplitView {
            VStack {
                List(viewModel.fileManager.recentFiles, id: \.self) { url in
                    Button(action: {
                        viewModel.selectFile(url: url)
                    }) {
                        Text(url.lastPathComponent)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .navigationTitle("Recent Files")
                
                Button("Clear Recents") {
                    viewModel.fileManager.clearRecents()
                }
                .padding()
            }
        } detail: {
            ZStack {
                VStack(spacing: 20) {
                    if let image = viewModel.image {
                        image
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    } else {
                        Text("Select an Amiga IFF file to display.")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Open IFF Image") {
                        showingFileImporter = true
                    }
                    .padding()
                    .fileImporter(
                        isPresented: $showingFileImporter,
                        allowedContentTypes: [UTType(filenameExtension: "iff") ?? .data, UTType(filenameExtension: "lbm") ?? .data],
                        allowsMultipleSelection: false
                    ) { result in
                        viewModel.handleFileImport(result: result)
                    }
                }
                .padding(.vertical)
                .navigationTitle("PixDeluxe")

                if viewModel.isGeneratingHexdump {
                    ProgressView("Generating Hexdump...")
                        .padding()
                        .background(Material.regular)
                        .cornerRadius(10)
                }
                
                if viewModel.isConverting {
                    ProgressView("Converting Image...")
                        .padding()
                        .background(Material.regular)
                        .cornerRadius(10)
                }
            }
        }
    }
}
