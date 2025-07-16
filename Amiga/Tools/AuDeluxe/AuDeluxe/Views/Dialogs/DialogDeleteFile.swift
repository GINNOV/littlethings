//
//  DialogDeleteFile.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct DialogDeleteFile: View {
    // The file being considered for deletion.
    let file: PlaylistItem
    
    // Binding to control the visibility of this dialog.
    @Binding var isPresented: Bool
    
    // The action to perform when the user confirms deletion.
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            // As requested, using your "trash_files" image from the asset catalog.
            Image("trash_files")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .padding(.top)

            Text("Delete File")
                .font(.title3)
                .fontWeight(.bold)

            Text("Are you sure you want to delete '\(file.title)'? This action cannot be undone.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)

            HStack(spacing: 12) {
                // The cancel button dismisses the dialog.
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.cancelAction)

                // The delete button performs the delete action and then dismisses.
                Button(action: {
                    onDelete()
                    isPresented = false
                }) {
                    Text("Delete")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding()
        }
        .padding()
        .frame(width: 380)
        .background(.regularMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
    }
}
