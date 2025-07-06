//
//  PixDeluxeDocument.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct PixDeluxeDocument: FileDocument {
    var image: Image?
    var nsImage: NSImage?
    var details: IFFImageDetails?
    var chunkyData: [UInt8]?
    
    private let iffParser = IFFParser()
    private let imageConverter = ImageConverter()

    static var readableContentTypes: [UTType] = [UTType(filenameExtension: "iff") ?? .data, UTType(filenameExtension: "lbm") ?? .data]

    init() { }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(configuration.file.filename ?? UUID().uuidString)
        try data.write(to: tempURL)
        
        if let parseResult = iffParser.parse(url: tempURL) {
            self.details = parseResult.details
            self.chunkyData = parseResult.chunkyData
            let iffImage = parseResult.image
            let provider = CGDataProvider(data: Data(iffImage.pixels) as CFData)
            if let cgImage = CGImage(width: iffImage.width, height: iffImage.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: iffImage.width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider: provider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
                let loadedNSImage = NSImage(cgImage: cgImage, size: NSSize(width: iffImage.width, height: iffImage.height))
                self.nsImage = loadedNSImage
                self.image = Image(nsImage: loadedNSImage)
            }
        }
        try? FileManager.default.removeItem(at: tempURL)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw CocoaError(.featureUnsupported)
    }
    
    func generateHexdump() {
        guard let data = chunkyData else { return }
        let hexdump = HexdumpGenerator.format(data: data)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(hexdump, forType: .string)
        print("📋 Copied hexdump to clipboard.")
    }
    
    func exportToPNG() {
        guard let nsImage = nsImage else { return }
        imageConverter.export(nsImage: nsImage, to: .png)
    }
}
