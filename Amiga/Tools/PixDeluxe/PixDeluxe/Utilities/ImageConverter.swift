//
//  ImageConverter.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/5/25.
//

import AppKit
import UniformTypeIdentifiers

private let ILBM_ID_PBM: IFF_ID = (UInt32("P".unicodeScalars.first!.value) << 24 | UInt32("B".unicodeScalars.first!.value) << 16 | UInt32("M".unicodeScalars.first!.value) << 8 | UInt32(" ".unicodeScalars.first!.value))
private let ILBM_ID_BODY: IFF_ID = (UInt32("B".unicodeScalars.first!.value) << 24 | UInt32("O".unicodeScalars.first!.value) << 16 | UInt32("D".unicodeScalars.first!.value) << 8 | UInt32("Y".unicodeScalars.first!.value))
private let C_TRUE: IFF_Bool = 1

class ImageConverter {

    // MARK: - Exporting from IFF
    
    func export(nsImage: NSImage, to format: UTType) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [format]
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "Untitled"

        guard savePanel.runModal() == .OK, let url = savePanel.url else {
            print("ℹ️ Export cancelled by user.")
            return
        }

        guard let tiffData = nsImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            print("❌ Could not get bitmap representation of the image.")
            return
        }

        let fileType: NSBitmapImageRep.FileType = (format == .png) ? .png : .jpeg
        guard let data = bitmap.representation(using: fileType, properties: [:]) else {
            print("❌ Could not convert image to \(format.description).")
            return
        }

        do {
            try data.write(to: url)
            print("✅ Successfully exported image to \(url.path)")
        } catch {
            print("❌ Failed to write exported image to disk: \(error.localizedDescription)")
        }
    }

    // MARK: - Importing to IFF (Grayscale only for now)

    func convertToIFF() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.png, .jpeg]
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false

        guard openPanel.runModal() == .OK, let url = openPanel.url else {
            print("ℹ️ Import cancelled by user.")
            return
        }

        guard let nsImage = NSImage(contentsOf: url) else {
            print("❌ Could not load image from \(url.path)")
            return
        }
        
        guard let (pixels, width, height) = getGrayscalePixels(from: nsImage) else {
            print("❌ Failed to convert image to grayscale pixel data.")
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: "iff")!]
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "Untitled.iff"

        guard savePanel.runModal() == .OK, let saveUrl = savePanel.url else {
            print("ℹ️ IFF save cancelled by user.")
            return
        }
        
        createIFF(path: saveUrl.path, width: width, height: height, pixels: pixels)
    }
    
    private func getGrayscalePixels(from nsImage: NSImage) -> (pixels: [UInt8], width: Int, height: Int)? {
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var pixels = [UInt8](repeating: 0, count: width * height)
        
        guard let context = CGContext(data: &pixels,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return (pixels, width, height)
    }
    
    private func createIFF(path: String, width: Int, height: Int, pixels: [UInt8]) {
        guard let image = ILBM_createImage(ILBM_ID_PBM) else { return }
        defer { ILBM_freeImage(image) }
        
        // 1. Setup BitMapHeader
        guard let bmhd = ILBM_createBitMapHeader() else { return }
        bmhd.pointee.w = UInt16(width)
        bmhd.pointee.h = UInt16(height)
        bmhd.pointee.nPlanes = 8
        bmhd.pointee.compression = UInt8(ILBM_CMP_NONE.rawValue)
        image.pointee.bitMapHeader = bmhd
        
        // 2. Setup Grayscale ColorMap
        guard let cmap = ILBM_generateGrayscaleColorMap(image) else { return }
        image.pointee.colorMap = cmap
        
        // 3. Setup Body with pixel data
        guard let bodyChunk = IFF_createRawChunk(ILBM_ID_BODY, IFF_Long(pixels.count)) else { return }
        
        let bodyRawChunk = UnsafeMutablePointer<IFF_RawChunk>(OpaquePointer(bodyChunk))
        
        pixels.withUnsafeBufferPointer { buffer in
            IFF_copyDataToRawChunkData(bodyRawChunk, UnsafeMutablePointer(mutating: buffer.baseAddress))
        }
        image.pointee.body = bodyRawChunk
        
        // 4. Convert to a FORM structure
        guard let form = ILBM_convertImageToForm(image) else { return }

        let genericFormChunk = UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(form))
        defer { IFF_free(genericFormChunk, nil) }
        
        // 5. Write to file
        if ILBM_write(path, genericFormChunk) == C_TRUE {
            print("✅ Successfully created grayscale IFF file at \(path)")
        } else {
            print("❌ Failed to write IFF file.")
        }
    }
}
