//
//  NewHDFDialogView.swift
//  ADFinder
//
//  Created by Mario Esposito on 7/25/25.
//

import SwiftUI

struct NewHDFDialogView: View {
    let config: NewHDFDialogConfig
    
    enum HDFSizeType: String, CaseIterable, Identifiable {
        case mb10 = "10 MB"
        case mb20 = "20 MB"
        case mb50 = "50 MB"
        case mb100 = "100 MB"
        case custom = "Custom"
        
        var id: Self { self }
        
        var sizeInMB: Int {
            switch self {
            case .mb10: return 10
            case .mb20: return 20
            case .mb50: return 50
            case .mb100: return 100
            case .custom: return 0
            }
        }
    }
    
    @State private var volumeName: String = "PlayHard"
    @State private var fsType: UInt8 = FS_TYPE_FFS_SWIFT
    @State private var selectedSizeType: HDFSizeType = .mb20
    @State private var customSizeText: String = "20"
    
    private var finalSize: Int {
        if selectedSizeType == .custom {
            return Int(customSizeText) ?? 0
        }
        return selectedSizeType.sizeInMB
    }

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "externaldrive.fill.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.accentColor)

            Text("Create New Hardfile (HDF)")
                .font(.headline)

            Text("Specify a volume name, size, and filesystem for the new hard disk image.")
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
            
            Picker("Size:", selection: $selectedSizeType) {
                ForEach(HDFSizeType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            if selectedSizeType == .custom {
                HStack {
                    TextField("Custom Size (MB)", text: $customSizeText)
                        .textFieldStyle(.roundedBorder)
                    Text("MB")
                }
            }

            HStack(spacing: 12) {
                Button(role: .cancel, action: { dismiss() }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.cancelAction)

                Button(action: {
                    config.action(volumeName, finalSize, fsType)
                    dismiss()
                }) {
                    Text("Create HDF")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(volumeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || finalSize <= 0)
            }
        }
        .padding(30)
        .frame(width: 420)
        .onChange(of: selectedSizeType) {
            if selectedSizeType != .custom {
                customSizeText = "\(selectedSizeType.sizeInMB)"
            }
        }
    }
}
