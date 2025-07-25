//
//  NewADFDialogView.swift
//  ADFinder
//
//  Created by Mario Esposito on 6/14/25.
//

import SwiftUI

struct NewADFDialogView: View {
    let config: NewADFDialogConfig
    
    enum BootBlockType: String, CaseIterable, Identifiable {
        case generic = "Generic (Non-Bootable)"
        case kick1_3 = "Kickstart 1.3 Compatible"
        case kick2_0 = "Kickstart 2.0+ Compatible"
        case sca = "SCA Virus Killer"
        case bandit = "Bandit Virus Killer"
        var id: Self { self }
    }
    
    @State private var volumeName: String
    @State private var fsType: UInt8
    @State private var bootBlockType: BootBlockType

    @Environment(\.dismiss) var dismiss

    init(config: NewADFDialogConfig) {
        self.config = config
        _volumeName = State(initialValue: "Workbench")
        _fsType = State(initialValue: FS_TYPE_OFS_SWIFT)
        _bootBlockType = State(initialValue: .generic)
    }

    var body: some View {
        VStack(spacing: 20) {
            Image("disk_maker")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Text("Create New Blank ADF")
                .font(.headline)

            Text("Specify a volume name and filesystem type for the new disk image.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            TextField("Volume Name", text: $volumeName)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()

            Picker("Filesystem:", selection: $fsType) {
                Text("OFS (Original File System)").tag(FS_TYPE_OFS_SWIFT)
                Text("FFS (Fast File System)").tag(FS_TYPE_FFS_SWIFT)
            }
            .pickerStyle(.radioGroup)
            
            Picker("Boot Block:", selection: $bootBlockType) {
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
                    config.action(volumeName, fsType, bootBlockType)
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
        .frame(width: 400)
    }
}
