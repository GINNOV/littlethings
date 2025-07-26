//
//  ADFDocument.swift
//  ADFinder
//
//  Created by Mario Esposito on 5/23/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ADFDocument: FileDocument {
    // 1. Accept both ADF and HDF.
    static var readableContentTypes: [UTType] {
        [ContentView.adfUType, ContentView.hdfUType]
    }

    var data: Data
    var volumeName: String?
    var imageKind: ADFService.ImageKind

    // 2. Dynamic extension based on the actual kind.
    var defaultFileName: String {
        let base = volumeName?.isEmpty == false ? volumeName! : "Untitled"
        let clean = base
            .components(separatedBy: CharacterSet(charactersIn: ":/\\?%*|\"<>"))
            .joined(separator: "_")
        let ext = imageKind == .hdf ? "hdf" : "adf"
        return "\(clean).\(ext)"
    }

    // MARK: – Initialisers
    init(data: Data = Data(), volumeName: String? = nil, imageKind: ADFService.ImageKind = .adf) {
        self.data = data
        self.volumeName = volumeName
        self.imageKind = imageKind
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
        self.volumeName = nil
        // We don’t know the kind until the service tells us, so default to .adf
        self.imageKind = .adf
    }

    // MARK: – FileDocument conformance
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
