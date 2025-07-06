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
                    
                    // AI_REVIEW: As requested, the "Open IFF Image" button has been
                    // removed from the main view body and replaced by a toolbar item.
                    // #END_REVIEW
                }
                .padding(.vertical)
                .navigationTitle("PixDeluxe")
                // AI_REVIEW: A new toolbar is added here to provide quick access to
                // common actions, replacing the old button.
                // #END_REVIEW
                .toolbar {
                    ToolbarItemGroup {
                        Button(action: {
                            viewModel.openFile()
                        }) {
                            Image(systemName: "folder")
                        }
                        .help("Open") // Tooltip

                        Button(action: {
                            viewModel.exportToImage()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .help("Export") // Tooltip
                        .disabled(viewModel.image == nil)

                        Button(action: {
                            viewModel.toggleImageDetails()
                        }) {
                            Image(systemName: "info.circle")
                        }
                        .help("Metadata") // Tooltip
                        .disabled(viewModel.imageDetails == nil)
                    }
                }

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
            .sheet(isPresented: $viewModel.showingImageDetails) {
                if let details = viewModel.imageDetails {
                    ImageDetailsView(details: details)
                }
            }
            .fileImporter(
                isPresented: $viewModel.isFileImporterPresented,
                allowedContentTypes: [UTType(filenameExtension: "iff") ?? .data, UTType(filenameExtension: "lbm") ?? .data],
                allowsMultipleSelection: false
            ) { result in
                viewModel.handleFileImport(result: result)
            }
        }
    }
}

