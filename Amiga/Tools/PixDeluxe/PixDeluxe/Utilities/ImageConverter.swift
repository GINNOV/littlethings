// ImageConverter.swift
// PixDeluxe
//
// Created by Mario Esposito on 7/5/25.
// Updated on 07/07/2025 based on "ql-iff" and user feedback

import AppKit
import UniformTypeIdentifiers

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
        guard nPlanes >= 1 && nPlanes <= 8 else {
            print("❌ Number of planes must be between 1 and 8.")
            return nil
        }
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
        if createIFFFromPalette(path: tempURL.path, width: width, height: height, pixels: indexedPixels, palette: palette, nPlanes: UInt8(nPlanes)) {
            print("✅ Successfully created IFF file at \(tempURL.path)")
            return tempURL
        } else {
            print("❌ Failed to create IFF file.")
            return nil
        }
    }
    
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
            let a = UInt32(rgbaPixels[i+3])
            let color: UInt32 = (a == 0) ? 0 : ((r << 16) | (g << 8) | b) // Map fully transparent to index 0
            colorCounts[color, default: 0] += 1
        }

        let sortedColors = colorCounts.keys.sorted { colorCounts[$0]! > colorCounts[$1]! }
        let topColors = Array(sortedColors.prefix(numberOfColors))

        var palette = topColors.map { color -> ILBM_ColorRegister in
            let r = UInt8((color >> 16) & 0xFF) >> 4 // 4-bit shift for Amiga compatibility
            let g = UInt8((color >> 8) & 0xFF) >> 4
            let b = UInt8(color & 0xFF) >> 4
            return ILBM_ColorRegister(red: r, green: g, blue: b)
        }
        
        // Pad palette to match 2^nPlanes colors with black
        while palette.count < numberOfColors {
            palette.append(ILBM_ColorRegister(red: 0, green: 0, blue: 0))
        }
        
        var indexedPixels = [UInt8](repeating: 0, count: width * height)
        for i in 0..<(width * height) {
            let pixelIndex = i * 4
            let r = UInt32(rgbaPixels[pixelIndex])
            let g = UInt32(rgbaPixels[pixelIndex+1])
            let b = UInt32(rgbaPixels[pixelIndex+2])
            let a = UInt32(rgbaPixels[pixelIndex+3])
            
            indexedPixels[i] = (a == 0) ? 0 : findNearestColorIndex(r: r, g: g, b: b, palette: palette)
        }
        
        return (indexedPixels, palette, width, height)
    }
    
    private func findNearestColorIndex(r: UInt32, g: UInt32, b: UInt32, palette: [ILBM_ColorRegister]) -> UInt8 {
        var minDistance = Int.max
        var bestIndex: UInt8 = 0
        
        for (index, color) in palette.enumerated() {
            let dr = Int(r) - Int(color.red << 4) // Adjust for 4-bit to 8-bit comparison
            let dg = Int(g) - Int(color.green << 4)
            let db = Int(b) - Int(color.blue << 4)
            let distance = dr * dr + dg * dg + db * db
            
            if distance < minDistance {
                minDistance = distance
                bestIndex = UInt8(index)
            }
        }
        return bestIndex
    }
    
    private func interleave(chunkyPixels: [UInt8], width: Int, height: Int, planes: Int) -> [UInt8] {
        let bytesPerRowInPlane = ((width + 15) / 16) * 2 // Rounded to 16-bit boundary (42 bytes for 320 pixels)
        let rowSize = bytesPerRowInPlane * planes // 336 bytes for 8 planes
        let totalSize = rowSize * height // 67,200 bytes for 200 rows
        var output = [UInt8](repeating: 0, count: totalSize)

        for y in 0..<height {
            var rowData = [UInt8](repeating: 0, count: rowSize)
            for x in 0..<width {
                let chunkyIndex = y * width + x
                guard chunkyIndex < chunkyPixels.count else { break }
                let colorIndex = chunkyPixels[chunkyIndex]

                let byteOffset = (x / 8) % bytesPerRowInPlane // Ensure offset within plane boundary
                let bitPosition = 7 - (x % 8) // Revert to MSB to LSB for Amiga standard

                for plane in 0..<planes {
                    if (colorIndex >> plane) & 1 != 0 {
                        let planeOffset = plane * bytesPerRowInPlane
                        let indexInRowData = planeOffset + byteOffset
                        rowData[indexInRowData] |= (1 << bitPosition)
                        print("plane[\(plane)] byteOffset=\(byteOffset), row=\(y), bitPosition=\(bitPosition), index=\(indexInRowData)")
                    }
                }
            }
            let outputOffset = y * rowSize
            for i in 0..<rowSize {
                output[outputOffset + i] = rowData[i]
            }
            // Write each plane to a file for inspection
            for plane in 0..<planes {
                let planeData = Array(rowData[(plane * bytesPerRowInPlane)..<((plane + 1) * bytesPerRowInPlane)])
                let fileURL = URL(fileURLWithPath: "/tmp/plane\(plane)_row\(y).bin")
                try? Data(planeData).write(to: fileURL)
            }
        }
        print("Total output size: \(output.count) bytes, expected: \(totalSize) bytes")
        return output
    }

    private func createIFFFromPalette(path: String, width: Int, height: Int, pixels: [UInt8], palette: [ILBM_ColorRegister], nPlanes: UInt8) -> Bool {
        guard nPlanes >= 1 && nPlanes <= 8 else {
            print("❌ Number of planes must be between 1 and 8.")
            return false
        }
        
        guard let form = IFF_createEmptyForm(ILBM_ID_ILBM) else {
            print("❌ Failed to create empty form.")
            return false
        }
        let genericFormChunk = UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(form))
        defer { ILBM_free(genericFormChunk) }

        guard let bmhdChunk = ILBM_createBitMapHeader() else {
            print("❌ Failed to create bitmap header.")
            return false
        }
        bmhdChunk.pointee.w = UInt16(width)
        bmhdChunk.pointee.h = UInt16(height)
        bmhdChunk.pointee.nPlanes = nPlanes
        bmhdChunk.pointee.masking = 0 // No masking
        bmhdChunk.pointee.compression = 0 // ILBM_CMP_NONE
        bmhdChunk.pointee.xAspect = 5 // 5:6 aspect ratio per your recap
        bmhdChunk.pointee.yAspect = 6
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(bmhdChunk)))

        guard let cmapChunk = ILBM_createColorMap() else {
            print("❌ Failed to create color map.")
            return false
        }
        let requiredColors = 1 << nPlanes
        for i in 0..<requiredColors {
            let color = (i < palette.count) ? palette[i] : ILBM_ColorRegister(red: 0, green: 0, blue: 0)
            guard let newRegister = ILBM_addColorRegisterInColorMap(cmapChunk) else {
                print("❌ Failed to add color register to color map.")
                return false
            }
            newRegister.pointee = color
        }
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(cmapChunk)))
        
        let planarPixels = interleave(chunkyPixels: pixels, width: width, height: height, planes: Int(nPlanes))
        guard let bodyChunk = IFF_createRawChunk(ILBM_ID_BODY, Int32(planarPixels.count)) else {
            print("❌ Failed to create body chunk.")
            return false
        }
        let bodyRawChunk = UnsafeMutablePointer<IFF_RawChunk>(OpaquePointer(bodyChunk))
        
        var mutablePlanarPixels = planarPixels
        mutablePlanarPixels.withUnsafeMutableBufferPointer {
            IFF_copyDataToRawChunkData(bodyRawChunk, $0.baseAddress)
        }
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(bodyChunk)))
        
        if ILBM_write(path, genericFormChunk) != 0 {
            print("✅ Successfully created IFF file at \(path)")
            return true
        } else {
            print("❌ Failed to write IFF file.")
            return false
        }
    }
}
