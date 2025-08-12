//
//  SidebarView.swift
//  ADFinder
//
//  Created by Mario Esposito on 5/23/25
//

import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @Bindable var adfService: ADFService
    @Bindable var recentFilesService: RecentFilesService
    @Binding var selectedFile: URL?
    
    @State private var showingFileImporter = false
    
    private var currentPathString: String {
        (adfService.currentVolumeName ?? "No Volume") + ":" + (adfService.currentPath.isEmpty ? "" : adfService.currentPath.joined(separator: "/"))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image("disk_maker")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 256, height: 256)
            }
            .padding(.bottom)
            
            // --- Custom Split Button ---
            HStack(spacing: 0) {
                // Main button area
                Button(action: { showingFileImporter = true }) {
                    Text("Open Disk...")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.plain) // Removes default button styling
                .padding(.horizontal, 12)

                // Menu area
                Menu {
                    if !recentFilesService.recentFiles.isEmpty {
                        Section(header: Text("Open Recent")) {
                            ForEach(recentFilesService.recentFiles.prefix(5), id: \.self) { url in
                                Button(url.lastPathComponent) {
                                    selectedFile = url
                                }
                            }
                        }
                    } else {
                        Text("No Recent Items")
                    }
                } label: {
                    Color.clear
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal, 10)
                }
                .menuStyle(.borderlessButton) // Removes button styling from the menu trigger
            }
            .frame(maxWidth: .infinity, minHeight: 36) // Set a fixed height for the whole component
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.bottom)
            // --- End Custom Split Button ---


            if selectedFile != nil {
                Text("Disk file:")
                    .font(.headline)
                Text(selectedFile?.lastPathComponent ?? "N/A")
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.bottom, 5)
                Text("VOLUME:")
                    .font(.headline)
                Text(currentPathString)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.bottom, 5)
            }
            
            Spacer()
            
            if selectedFile != nil {
                DiskInfoView(adfService: adfService)
                    .padding(.top)
            }
        }
        .padding()
        .navigationSplitViewColumnWidth(min: 280, ideal: 300, max: 500)
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [ContentView.adfUType, ContentView.hdfUType],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                selectedFile = url
            case .failure(let error):
                print("Failed to select file: \(error.localizedDescription)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openAdfFile)) { _ in
            showingFileImporter = true
        }
    }
}
