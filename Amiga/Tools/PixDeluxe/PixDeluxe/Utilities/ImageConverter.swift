//
//  ImageConverter.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/5/25.
//

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

    func importAndConvertToIFF() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.png, .jpeg]
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false

        guard openPanel.runModal() == .OK, let url = openPanel.url else {
            print("ℹ️ Import cancelled by user.")
            return nil
        }

        guard let nsImage = NSImage(contentsOf: url) else {
            print("❌ Could not load image from \(url.path)")
            return nil
        }
        
        print("⏳ Starting image quantization...")
        guard let (indexedPixels, palette, width, height) = quantize(image: nsImage) else {
            print("❌ Failed to quantize image.")
            return nil
        }
        print("✅ Quantization complete. Palette size: \(palette.count)")
        
        let tempFileName = (url.deletingPathExtension().lastPathComponent) + ".iff"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(tempFileName)
        
        print("⏳ Creating IFF file at \(tempURL.path)...")
        createIFFFromPalette(path: tempURL.path, width: width, height: height, pixels: indexedPixels, palette: palette)
        
        return tempURL
    }
    
    private func quantize(image: NSImage) -> (indexedPixels: [UInt8], palette: [ILBM_ColorRegister], width: Int, height: Int)? {
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
        let topColors = Array(sortedColors.prefix(256))

        let palette = topColors.map { color -> ILBM_ColorRegister in
            let r = UInt8((color >> 16) & 0xFF)
            let g = UInt8((color >> 8) & 0xFF)
            let b = UInt8(color & 0xFF)
            return ILBM_ColorRegister(red: r, green: g, blue: b)
        }
        
        var colorToIndexMap: [UInt32: UInt8] = [:]
        for (index, color) in topColors.enumerated() {
            colorToIndexMap[color] = UInt8(index)
        }

        var indexedPixels = [UInt8](repeating: 0, count: width * height)
        for i in 0..<(width * height) {
            let pixelIndex = i * 4
            let r = UInt32(rgbaPixels[pixelIndex])
            let g = UInt32(rgbaPixels[pixelIndex+1])
            let b = UInt32(rgbaPixels[pixelIndex+2])
            let originalColor: UInt32 = (r << 16) | (g << 8) | b

            if let paletteIndex = colorToIndexMap[originalColor] {
                indexedPixels[i] = paletteIndex
            } else {
                indexedPixels[i] = 0
            }
        }
        
        return (indexedPixels, palette, width, height)
    }
    
    // AI_REVIEW (FIX): This new function, inspired by the provided Lua script, correctly converts
    // "chunky" pixel data (one byte per pixel) into the "planar" format required by IFF/ILBM.
    // It rearranges the bits from the pixel indexes into separate bitplanes.
    private func interleave(chunkyPixels: [UInt8], width: Int, height: Int, planes: Int) -> [UInt8] {
        // Calculate the size of one row in one bitplane, padded to a 16-bit boundary (must be even).
        var bytesPerRowInPlane = (width + 7) / 8
        if bytesPerRowInPlane % 2 != 0 {
            bytesPerRowInPlane += 1
        }
        
        let totalPlanarSize = bytesPerRowInPlane * height * planes
        var planarData = [UInt8](repeating: 0, count: totalPlanarSize)

        for y in 0..<height {
            for x in 0..<width {
                let chunkyIndex = y * width + x
                let colorIndex = chunkyPixels[chunkyIndex]
                
                // For each bit in the color index, set the corresponding bit in the correct plane.
                for plane in 0..<planes {
                    if (colorIndex >> plane) & 1 != 0 {
                        let planarByteIndex = (y * planes + plane) * bytesPerRowInPlane + (x / 8)
                        let bitInByte = 7 - (x % 8)
                        planarData[planarByteIndex] |= (1 << bitInByte)
                    }
                }
            }
        }
        return planarData
    }

    private func createIFFFromPalette(path: String, width: Int, height: Int, pixels: [UInt8], palette: [ILBM_ColorRegister]) {
        let nPlanes = 8 // For 256 colors
        
        // AI_REVIEW (FIX): The root cause of the corrupted image was writing chunky pixel data.
        // We now call the new `interleave` function to convert the pixels to the correct
        // planar format before creating the BODY chunk.
        let planarPixels = interleave(chunkyPixels: pixels, width: width, height: height, planes: nPlanes)
        
        guard let form = IFF_createEmptyForm(ILBM_ID_ILBM) else { return }
        let genericFormChunk = UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(form))
        defer { ILBM_free(genericFormChunk) }

        guard let bmhdChunk = ILBM_createBitMapHeader() else { return }
        bmhdChunk.pointee.w = UInt16(width)
        bmhdChunk.pointee.h = UInt16(height)
        bmhdChunk.pointee.nPlanes = UInt8(nPlanes)
        bmhdChunk.pointee.compression = UInt8(ILBM_CMP_NONE.rawValue)
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(bmhdChunk)))

        guard let cmapChunk = ILBM_createColorMap() else { return }
        for color in palette {
            if let newRegister = ILBM_addColorRegisterInColorMap(cmapChunk) {
                newRegister.pointee = color
            }
        }
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(cmapChunk)))
        
        // Create the BODY chunk with the new, correctly formatted planar pixel data.
        guard let bodyChunk = IFF_createRawChunk(ILBM_ID_BODY, IFF_Long(planarPixels.count)) else { return }
        let bodyRawChunk = UnsafeMutablePointer<IFF_RawChunk>(OpaquePointer(bodyChunk))
        var mutablePlanarPixels = planarPixels
        mutablePlanarPixels.withUnsafeMutableBufferPointer { IFF_copyDataToRawChunkData(bodyRawChunk, $0.baseAddress) }
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(bodyChunk)))
        
        if ILBM_write(path, genericFormChunk) == C_TRUE {
            print("✅ Successfully created IFF file at \(path)")
        } else {
            print("❌ Failed to write IFF file.")
        }
    }
    
    // MARK: - Importing to IFF (Grayscale - Original)

    private func convertToIFF_grayscale() {
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
        
        createIFF_grayscale(path: saveUrl.path, width: width, height: height, pixels: pixels)
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
    
    private func createIFF_grayscale(path: String, width: Int, height: Int, pixels: [UInt8]) {
        let nPlanes = 8
        let planarPixels = interleave(chunkyPixels: pixels, width: width, height: height, planes: nPlanes)
        
        guard let form = IFF_createEmptyForm(ILBM_ID_PBM) else { return }
        let genericFormChunk = UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(form))
        defer { ILBM_free(genericFormChunk) }
        
        guard let bmhd = ILBM_createBitMapHeader() else { return }
        bmhd.pointee.w = UInt16(width)
        bmhd.pointee.h = UInt16(height)
        bmhd.pointee.nPlanes = UInt8(nPlanes)
        bmhd.pointee.compression = UInt8(ILBM_CMP_NONE.rawValue)
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(bmhd)))
        
        guard let cmap = ILBM_createColorMap() else { return }
        for i in 0...255 {
            if let newRegister = ILBM_addColorRegisterInColorMap(cmap) {
                let value = UInt8(i)
                newRegister.pointee.red = value
                newRegister.pointee.green = value
                newRegister.pointee.blue = value
            }
        }
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(cmap)))

        guard let bodyChunk = IFF_createRawChunk(ILBM_ID_BODY, IFF_Long(planarPixels.count)) else { return }
        let bodyRawChunk = UnsafeMutablePointer<IFF_RawChunk>(OpaquePointer(bodyChunk))
        var mutablePlanarPixels = planarPixels
        mutablePlanarPixels.withUnsafeMutableBufferPointer { IFF_copyDataToRawChunkData(bodyRawChunk, $0.baseAddress) }
        IFF_addToForm(form, UnsafeMutablePointer<IFF_Chunk>(OpaquePointer(bodyChunk)))

        if ILBM_write(path, genericFormChunk) == C_TRUE {
            print("✅ Successfully created grayscale IFF file at \(path)")
        } else {
            print("❌ Failed to write IFF file.")
        }
    }
}
