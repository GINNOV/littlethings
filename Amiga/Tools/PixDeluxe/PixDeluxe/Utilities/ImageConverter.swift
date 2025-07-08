//
//  ImageConverter.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/5/25.
//

import AppKit
import UniformTypeIdentifiers
import Foundation
import CoreGraphics

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

    // MARK: - Importing to IFF (Color)

    func convert(url: URL, nPlanes: Int) -> URL? {
        let numberOfColors = Int(pow(2.0, Double(nPlanes)))

        guard let nsImage = NSImage(contentsOf: url) else {
            print("❌ Could not load image from \(url.path)")
            return nil
        }

        print("⏳ Starting image quantization to \(numberOfColors) colors...")
        guard let (indexedPixels, palette, width, height) = quantize(image: nsImage, numberOfColors: numberOfColors) else {
            print("❌ Failed to quantize image.")
            return nil
        }
        print("✅ Quantization complete. Palette size: \(palette.count)")

        let tempFileName = (url.deletingPathExtension().lastPathComponent) + ".iff"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(tempFileName)

        print("⏳ Creating IFF file at \(tempURL.path)...")
        createIFFFromPalette(path: tempURL.path, width: width, height: height, pixels: indexedPixels, palette: palette, nPlanes: UInt8(nPlanes))

        return tempURL
    }

    // MARK: - Nearest Color Matching

    private func findNearestColorIndex(r: UInt8, g: UInt8, b: UInt8, palette: [ILBM_ColorRegister]) -> UInt8 {
        var bestIndex: Int = 0
        var bestDistance: Int = Int.max

        for (i, color) in palette.enumerated() {
            let dr = Int(color.red) - Int(r)
            let dg = Int(color.green) - Int(g)
            let db = Int(color.blue) - Int(b)
            let distance = dr * dr + dg * dg + db * db
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = i
            }
        }
        return UInt8(bestIndex)
    }

    // MARK: - Quantization

    private func quantize(image: NSImage, numberOfColors: Int) -> (indexedPixels: [UInt8], palette: [ILBM_ColorRegister], width: Int, height: Int)? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }

        let width = cgImage.width
        let height = cgImage.height

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var rgbaPixels = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(data: &rgbaPixels,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var colorCounts: [UInt32: Int] = [:]
        for i in stride(from: 0, to: rgbaPixels.count, by: 4) {
            let r = UInt32(rgbaPixels[i])
            let g = UInt32(rgbaPixels[i+1])
            let b = UInt32(rgbaPixels[i+2])
            let color: UInt32 = (r << 16) | (g << 8) | b
            colorCounts[color, default: 0] += 1
        }

        let sortedColors = colorCounts.keys.sorted { colorCounts[$0]! > colorCounts[$1]! }
        let topColors = Array(sortedColors.prefix(numberOfColors))

        var palette = topColors.map { color -> ILBM_ColorRegister in
            let r = UInt8((color >> 16) & 0xFF)
            let g = UInt8((color >> 8) & 0xFF)
            let b = UInt8(color & 0xFF)
            return ILBM_ColorRegister(red: r, green: g, blue: b)
        }

        // Optional: pad palette to 256 if needed
        while palette.count < numberOfColors {
            palette.append(ILBM_ColorRegister(red: 0, green: 0, blue: 0))
        }

        var indexedPixels = [UInt8](repeating: 0, count: width * height)
        for i in 0..<(width * height) {
            let pixelIndex = i * 4
            let r = rgbaPixels[pixelIndex]
            let g = rgbaPixels[pixelIndex + 1]
            let b = rgbaPixels[pixelIndex + 2]
            indexedPixels[i] = findNearestColorIndex(r: r, g: g, b: b, palette: palette)
        }

        return (indexedPixels, palette, width, height)
    }

    // MARK: - Planar Interleave (Chunky to Planar) - FIXED VERSION

    private func interleave(chunkyPixels: [UInt8], width: Int, height: Int, planes: Int) -> [UInt8] {
        let bytesPerRowInPlane = ((width + 15) / 16) * 2  // Word-aligned
        let planeSize = bytesPerRowInPlane * height
        let totalSize = planeSize * planes
        
        var output = [UInt8](repeating: 0, count: totalSize)
        
        // Process each bitplane separately
        for plane in 0..<planes {
            let planeOffset = plane * planeSize
            
            // Process each row in this bitplane
            for y in 0..<height {
                let rowOffset = planeOffset + (y * bytesPerRowInPlane)
                
                // Process each pixel in this row
                for x in 0..<width {
                    let chunkyIndex = y * width + x
                    let colorIndex = chunkyPixels[chunkyIndex]
                    
                    // Check if this bit is set in the current plane
                    if (colorIndex >> plane) & 1 != 0 {
                        let byteIndex = x / 8
                        let bitPosition = 7 - (x % 8)
                        output[rowOffset + byteIndex] |= (1 << bitPosition)
                    }
                }
            }
        }
        
        print("🧠 Interleaved: width=\(width), height=\(height), planes=\(planes)")
        print("   bytesPerRowInPlane=\(bytesPerRowInPlane), planeSize=\(planeSize), totalBytes=\(totalSize)")
        
        return output
    }

    // MARK: - IFF Writing

    private func createIFFFromPalette(path: String, width: Int, height: Int, pixels: [UInt8], palette: [ILBM_ColorRegister], nPlanes: UInt8) {
        let planarPixels = interleave(chunkyPixels: pixels, width: width, height: height, planes: Int(nPlanes))

        guard let form = IFF_createEmptyForm(ILBM_ID_ILBM) else { return }
        let genericFormChunk = UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(form))
        defer { ILBM_free(genericFormChunk) }

        guard let bmhdChunk = ILBM_createBitMapHeader() else { return }
        bmhdChunk.pointee.w = UInt16(width)
        bmhdChunk.pointee.h = UInt16(height)
        bmhdChunk.pointee.x = 0
        bmhdChunk.pointee.y = 0
        bmhdChunk.pointee.nPlanes = nPlanes
        bmhdChunk.pointee.masking = UInt8(ILBM_MSK_NONE.rawValue)
        bmhdChunk.pointee.compression = UInt8(ILBM_CMP_NONE.rawValue)
        bmhdChunk.pointee.transparentColor = 0
        bmhdChunk.pointee.xAspect = 5
        bmhdChunk.pointee.yAspect = 6
        bmhdChunk.pointee.pageWidth = IFF_Word(UInt16(width))
        bmhdChunk.pointee.pageHeight = IFF_Word(UInt16(height))
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(bmhdChunk)))

        guard let cmapChunk = ILBM_createColorMap() else { return }
        for color in palette {
            if let newRegister = ILBM_addColorRegisterInColorMap(cmapChunk) {
                newRegister.pointee = color
            }
        }
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(cmapChunk)))

        let actualBodySize = planarPixels.count
        guard let bodyChunk = IFF_createRawChunk(ILBM_ID_BODY, IFF_Long(actualBodySize)) else { return }
        let bodyRawChunk = UnsafeMutablePointer<IFF_RawChunk>(OpaquePointer(bodyChunk))

        var mutablePlanarPixels = planarPixels
        mutablePlanarPixels.withUnsafeMutableBufferPointer {
            IFF_copyDataToRawChunkData(bodyRawChunk, $0.baseAddress)
        }
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(bodyChunk)))

        if ILBM_write(path, genericFormChunk) == C_TRUE {
            print("✅ Successfully created IFF file at \(path)")
        } else {
            print("❌ Failed to write IFF file.")
        }
    }
    
    // MARK: - Debug Helper
    
    private func debugPlanarData(planarPixels: [UInt8], width: Int, height: Int, planes: Int) {
        let bytesPerRowInPlane = ((width + 15) / 16) * 2
        let planeSize = bytesPerRowInPlane * height
        
        print("🔍 Planar data verification:")
        print("   Expected total size: \(planeSize * planes)")
        print("   Actual data size: \(planarPixels.count)")
        
        // Check if we have any data in each plane
        for plane in 0..<planes {
            let planeOffset = plane * planeSize
            let planeData = Array(planarPixels[planeOffset..<min(planeOffset + planeSize, planarPixels.count)])
            let nonZeroBytes = planeData.filter { $0 != 0 }.count
            print("   Plane \(plane): \(nonZeroBytes) non-zero bytes out of \(planeData.count)")
        }
    }
}
