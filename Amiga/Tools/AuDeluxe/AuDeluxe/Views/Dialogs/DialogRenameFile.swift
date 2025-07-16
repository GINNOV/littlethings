//
//  DialogRenameFile.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct DialogRenameFile: View {
    // The file to be inspected/renamed.
    let file: PlaylistItem
    
    // Binding to control the visibility of this dialog.
    @Binding var isPresented: Bool
    
    // The action to perform when the user confirms the new name.
    let onSave: (_ newTitle: String, _ newArtist: String, _ newFilename: String) -> Void

    // State to hold the new values entered by the user.
    @State private var newTitle: String = ""
    @State private var newArtist: String = ""
    @State private var newFilename: String = ""

    // We'll sort the metadata keys for a consistent display order.
    private var sortedMetadataKeys: [String] {
        file.metadata.keys.sorted()
    }

    var body: some View {
        VStack(spacing: 15) {
            Image("rename_files")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .padding(.top)

            Text("Metadata Inspector")
                .font(.title3)
                .fontWeight(.bold)

            // Encapsulate content in a ScrollView to handle many metadata items
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("EDITABLE INFO")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Title", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Artist", text: $newArtist)
                        .textFieldStyle(.roundedBorder)

                    TextField("Filename", text: $newFilename)
                        .textFieldStyle(.roundedBorder)

                    Divider().padding(.vertical, 5)

                    Text("FILE METADATA (READ-ONLY)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Display all metadata
                    ForEach(sortedMetadataKeys, id: \.self) { key in
                        HStack(alignment: .top) {
                            Text("\(key.capitalized):")
                                .fontWeight(.semibold)
                                .frame(width: 100, alignment: .trailing)
                            
                            // Check if the key is duration and format it
                            if key == "duration", let durationValue = Double(file.metadata[key] ?? "0") {
                                Text(formatTime(durationValue))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text(file.metadata[key] ?? "N/A")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .font(.callout)
                    }
                }
                .padding(.horizontal)
            }
            
            HStack(spacing: 12) {
                Button("Cancel") { isPresented = false }
                    .keyboardShortcut(.cancelAction)
                    .frame(maxWidth: .infinity)

                Button("Save") {
                    onSave(newTitle, newArtist, newFilename)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .disabled(newFilename.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding([.horizontal, .bottom])
        }
        .onAppear {
            newTitle = file.title
            newArtist = file.artist
            newFilename = file.fileURL.deletingPathExtension().lastPathComponent
        }
        .padding()
        .frame(width: 500, height: 600) // Increased size for more content
        .background(.regularMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
