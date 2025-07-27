//
//  NewADFDialogView.swift
//  ADFinder
//
//  Created by Mario Esposito on 6/14/25.
//

import SwiftUI

struct NewADFDialogView: View {
    let config: NewADFDialogConfig

    @State private var volumeName: String = "Workbench"
    @State private var fsType: FileSystem = .ffs
    @State private var selectedBootBlock: BootBlockType = .generic
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "opticaldiscdrive.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.accentColor)

            Text("Create New Blank ADF")
                .font(.headline)

            Text("Specify a volume name, filesystem, and boot block for the new disk image.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            TextField("Volume Name", text: $volumeName)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()

            Picker("Filesystem:", selection: $fsType) {
                ForEach(FileSystem.allCases) { fs in
                    Text(fs.rawValue).tag(fs)
                }
            }
            .pickerStyle(.radioGroup)
            
            Picker("Boot Block:", selection: $selectedBootBlock) {
                ForEach(BootBlockType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.menu)

            HStack(spacing: 12) {
                Button(role: .cancel, action: { dismiss() }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.cancelAction)

                Button(action: {
                    let fsTypeUInt8 = (fsType == .ofs) ? FS_TYPE_OFS_SWIFT : FS_TYPE_FFS_SWIFT
                    config.action(volumeName, fsTypeUInt8, selectedBootBlock)
                    dismiss()
                }) {
                    Text("Create ADF")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(volumeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(30)
        .frame(width: 420)
    }
}
