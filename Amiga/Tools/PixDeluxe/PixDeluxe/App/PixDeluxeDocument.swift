//
//  PixDeluxeDocument.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct PixDeluxeDocument: FileDocument {
    var cgImage: CGImage?
    var details: IFFImageDetails?
    var chunkyData: [UInt8]?
    
    @MainActor
    var image: Image? {
        guard let cgImage = cgImage else { return nil }
        return Image(cgImage, scale: 1.0, label: Text("IFF Image"))
    }
    
    @MainActor
    var nsImage: NSImage? {
        guard let cgImage = cgImage else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }
    
    private let iffWrapper = IFFWrapper()
    private let imageConverter = ImageConverter()

    static var readableContentTypes: [UTType] = [UTType(filenameExtension: "iff") ?? .data, UTType(filenameExtension: "lbm") ?? .data]

    init() { }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        // We need a URL for the details struct, even if we parse from data.
        // We can create a temporary one for this purpose.
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(configuration.file.filename ?? UUID().uuidString)

        if let parseResult = iffWrapper.parse(data: data, fileURL: tempURL) {
            self.details = parseResult.details
            self.chunkyData = parseResult.chunkyData
            self.cgImage = parseResult.cgImage
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw CocoaError(.featureUnsupported)
    }
    
    @MainActor
    func generateHexdump() {
        guard let data = chunkyData else {
            print("Hexdump not available for this image as it was parsed with the new wrapper.")
            return
        }
        let hexdump = HexdumpGenerator.format(data: data)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(hexdump, forType: .string)
        print("📋 Copied hexdump to clipboard.")
    }
    
    @MainActor
    func exportToPNG() {
        guard let cgImage = cgImage else {
            print("❌ No CGImage to export.")
            return
        }
        imageConverter.export(cgImage: cgImage, fileExtension: "png")
    }
    @MainActor
    func exportToJPEG() {
        guard let cgImage = cgImage else { return }
        imageConverter.export(cgImage: cgImage, fileExtension: "jpg")
    }
}
