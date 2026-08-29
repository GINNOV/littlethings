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

    var body: some View {
        VStack(spacing: 20) {
            Image("rename_files")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .padding(.top)

            Text("Rename File")
                .font(.title3)
                .fontWeight(.bold)

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    Text("Title")
                    TextField("Title", text: $newTitle)
                }

                GridRow {
                    Text("Artist")
                    TextField("Artist", text: $newArtist)
                }

                GridRow {
                    Text("Filename")
                    TextField("Filename", text: $newFilename)
                    .textFieldStyle(.roundedBorder)
                }
            }
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            
            Spacer()

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
            newFilename = file.fileURL.lastPathComponent
        }
        .padding()
        .frame(width: 400, height: 300)
        .background(.regularMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
    }
}
