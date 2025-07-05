import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showingFileImporter = false

    var body: some View {
        NavigationSplitView {
            VStack {
                List(viewModel.recentFiles, id: \.self) { url in
                    Button(action: {
                        viewModel.selectRecentFile(url: url)
                    }) {
                        Text(url.lastPathComponent)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .navigationTitle("Recent Files")
                
                Button("Clear Recents") {
                    viewModel.clearRecents()
                }
                .padding()
            }
        } detail: {
            VStack(spacing: 20) {
                if let image = viewModel.image {
                    image
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .padding()

                    // The hexdump is now in a collapsible section for a cleaner UI.
                    if viewModel.hexdump != nil {
                        DisclosureGroup("Hexdump") {
                            ScrollView {
                                Text(viewModel.hexdump ?? "")
                                    .font(.system(.body, design: .monospaced))
                                    .padding()
                                    .textSelection(.enabled)
                            }
                            .frame(height: 200)
                            .border(Color.gray.opacity(0.5), width: 1)
                            .overlay(alignment: .topTrailing) {
                                Button(action: {
                                    viewModel.copyHexdumpToClipboard()
                                }) {
                                    Image(systemName: "doc.on.doc")
                                }
                                .padding(8)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Button("Generate Hexdump") {
                        viewModel.generateHexDump()
                    }
                    .disabled(viewModel.image == nil) // Disable if no image is loaded
                    

                } else {
                    Text("Select an Amiga IFF file to display.")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                
                Spacer() // Pushes content to the top
                
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
        }
    }
}
