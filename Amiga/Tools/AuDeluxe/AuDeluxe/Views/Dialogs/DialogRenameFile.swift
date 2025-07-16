//
//  DialogRenameFile.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct DialogRenameFile: View {
    // The file to be renamed.
    let file: PlaylistItem
    
    // Binding to control the visibility of this dialog.
    @Binding var isPresented: Bool
    
    // The action to perform when the user confirms the new name.
    // It now passes back the new title, artist, and filename.
    let onSave: (_ newTitle: String, _ newArtist: String, _ newFilename: String) -> Void

    // State to hold the new values entered by the user.
    @State private var newTitle: String = ""
    @State private var newArtist: String = ""
    @State private var newFilename: String = ""

    var body: some View {
        VStack(spacing: 15) {
            // As requested, using your "rename_files" image from the asset catalog.
            Image("rename_files")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .padding(.top)

            Text("Edit Information")
                .font(.title3)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 10) {
                Text("METADATA (READ-ONLY FOR NOW)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("Title", text: $newTitle)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Artist", text: $newArtist)
                    .textFieldStyle(.roundedBorder)

                Text("FILENAME")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)

                TextField("Filename", text: $newFilename)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
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
            // Initialize the text fields with the current item's data.
            newTitle = file.title
            newArtist = file.artist
            newFilename = file.fileURL.deletingPathExtension().lastPathComponent
        }
        .padding()
        .frame(width: 420)
        .background(.regularMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
    }
}
