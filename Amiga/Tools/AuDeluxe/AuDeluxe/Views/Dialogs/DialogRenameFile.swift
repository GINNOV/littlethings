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
    let onSave: (String) -> Void

    // State to hold the new filename entered by the user.
    @State private var newFilename: String = ""

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "pencil.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundColor(.accentColor)
                .padding(.top)
                .symbolRenderingMode(.hierarchical)

            Text("Rename File")
                .font(.title3)
                .fontWeight(.bold)

            Text("Enter a new name for the file '\(file.fileURL.lastPathComponent)'. The file extension will be preserved.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            TextField("New Filename", text: $newFilename)
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    // Initialize the text field with the current name, without the extension.
                    newFilename = file.fileURL.deletingPathExtension().lastPathComponent
                }

            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                .frame(maxWidth: .infinity)

                Button("Save") {
                    onSave(newFilename)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .disabled(newFilename.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding([.horizontal, .bottom])
        }
        .padding()
        .frame(width: 400)
        .background(.regularMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
    }
}
