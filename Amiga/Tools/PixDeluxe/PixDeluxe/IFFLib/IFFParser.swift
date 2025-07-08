//
//  IFFParser.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/5/25.
//

import Foundation

class IFFParser {
    struct ParseResult {
        let image: IFFImage
        let chunkyData: [UInt8]
        let details: IFFImageDetails
    }
    
    struct IFFImage {
        let width: Int
        let height: Int
        let pixels: [UInt8]
    }

    func parse(url: URL) -> ParseResult? {
        let path = url.path
        
        guard let iffChunk = ILBM_read(path) else {
            print("❌ [Debug] IFFParser failed at initial read for: \(url.lastPathComponent)")
            return nil
        }
        defer { ILBM_free(iffChunk) }
        
        let rawPtr = UnsafeMutableRawPointer(iffChunk)
        guard let form = rawPtr.assumingMemoryBound(to: IFF_Form.self) as UnsafeMutablePointer<IFF_Form>? else {
            print("❌ [Debug] Failed: Top-level chunk is not a FORM in \(url.lastPathComponent).")
            return nil
        }
        
        print("--- 🕵️ [Debug] Parsing: \(url.lastPathComponent) ---")
        
        guard let bmhdChunk = IFF_getChunkFromForm(form, ILBM_ID_BMHD) else {
            print("❌ [Debug] FAILED: Missing BMHD chunk in \(url.lastPathComponent).")
            return nil
        }
        let bitMapHeader = UnsafeMutableRawPointer(bmhdChunk).assumingMemoryBound(to: ILBM_BitMapHeader.self).pointee
        print("  - ✅ Found BMHD chunk.")

        var bodyChunk = IFF_getChunkFromForm(form, ILBM_ID_BODY)
        guard bodyChunk != nil else {
            print("❌ [Debug] FAILED: Missing BODY chunk in \(url.lastPathComponent).")
            return nil
        }
        print("  - ✅ Found BODY chunk.")

        let cmapChunk = IFF_getChunkFromForm(form, ILBM_ID_CMAP)
        if cmapChunk != nil { print("  - ✅ Found CMAP chunk.") } else { print("  - ℹ️ No CMAP chunk found (expected for PBM).") }
        
        let camgChunk = IFF_getChunkFromForm(form, ILBM_ID_CAMG)
        if camgChunk != nil { print("  - ✅ Found CAMG chunk.") }

        guard let image = ILBM_createImage(form.pointee.formType) else { return nil }
        defer { ILBM_freeImage(image) }
        
        image.pointee.bitMapHeader = UnsafeMutableRawPointer(bmhdChunk).assumingMemoryBound(to: ILBM_BitMapHeader.self)
        if let bChunk = bodyChunk {
            image.pointee.body = UnsafeMutableRawPointer(bChunk).assumingMemoryBound(to: IFF_RawChunk.self)
        }
        if let cmap = cmapChunk { image.pointee.colorMap = UnsafeMutableRawPointer(cmap).assumingMemoryBound(to: ILBM_ColorMap.self) }
        if let camg = camgChunk { image.pointee.viewport = UnsafeMutableRawPointer(camg).assumingMemoryBound(to: ILBM_Viewport.self) }

        if bitMapHeader.compression == ILBM_CMP_BYTE_RUN.rawValue {
            ILBM_unpackByteRun(image)
            print("  - ✅ Unpacked ByteRun compression.")
        }

        if image.pointee.formType == ILBM_ID_ILBM {
            if ILBM_convertILBMToACBM(image) == 1 {
                print("  - ✅ Converted ILBM to chunky (ACBM).")
                // AI_REVIEW: This is the critical fix. The C function re-allocates the body chunk.
                // We MUST update our local `bodyChunk` variable to point to the new memory location
                // returned by the C function to prevent using a stale pointer.
                if let newBody = image.pointee.body {
                     bodyChunk = UnsafeMutableRawPointer(newBody).assumingMemoryBound(to: IFF_Chunk.self)
                } else {
                     bodyChunk = nil
                }
            } else {
                print("  - ⚠️ Failed to convert ILBM to ACBM for \(url.lastPathComponent).")
            }
        }

        guard let finalBodyPtr = bodyChunk else {
            print("❌ [Debug] FAILED: Could not get final chunky data from BODY because bodyChunk is nil.")
            return nil
        }
        let finalBody = UnsafeMutableRawPointer(finalBodyPtr).assumingMemoryBound(to: IFF_RawChunk.self).pointee
        
        guard let chunkyDataPtr = finalBody.chunkData else {
            print("❌ [Debug] FAILED: Could not get final chunky data from BODY because chunkData is nil.")
            return nil
        }
        let chunkyData = Array(UnsafeBufferPointer<UInt8>(start: chunkyDataPtr, count: Int(finalBody.chunkSize)))
        
        var generatedColorMapToFree: UnsafeMutablePointer<ILBM_ColorMap>? = nil
        defer {
            if let map = generatedColorMapToFree {
                ILBM_freeColorMap(UnsafeMutablePointer(OpaquePointer(map)), nil)
            }
        }
        
        let colorRegisters: UnsafeMutablePointer<ILBM_ColorRegister>
        let colorMapSize: Int

        if let colorMap = image.pointee.colorMap?.pointee, let colors = colorMap.colorRegister {
            colorRegisters = colors
            colorMapSize = Int(colorMap.colorRegisterLength)
        } else {
            guard let generatedColorMap = ILBM_generateGrayscaleColorMap(image) else { return nil }
            generatedColorMapToFree = generatedColorMap
            guard let colors = generatedColorMap.pointee.colorRegister else { return nil }
            colorRegisters = colors
            colorMapSize = Int(generatedColorMap.pointee.colorRegisterLength)
            print("  - ✅ Generated grayscale palette.")
        }
        
        let width = Int(bitMapHeader.w)
        let height = Int(bitMapHeader.h)
        var rgbaPixels = [UInt8](repeating: 0, count: width * height * 4)

        for i in 0..<(width * height) {
            guard i < chunkyData.count else { break }
            let colorIndex = Int(chunkyData[i])
            guard colorIndex < colorMapSize else { continue }
            
            let color = colorRegisters[colorIndex]
            let pixelIndex = i * 4
            rgbaPixels[pixelIndex]     = color.red
            rgbaPixels[pixelIndex + 1] = color.green
            rgbaPixels[pixelIndex + 2] = color.blue
            rgbaPixels[pixelIndex + 3] = 255
        }
        
        let finalImage = IFFImage(width: width, height: height, pixels: rgbaPixels)
        let details = extractDetails(from: image.pointee, fileURL: url)
        
        print("--------------------------------------------------")
        return ParseResult(image: finalImage, chunkyData: chunkyData, details: details)
    }
    
    private func extractDetails(from image: ILBM_Image, fileURL: URL) -> IFFImageDetails {
        guard let bmhd = image.bitMapHeader?.pointee else {
            fatalError("Bitmap header should always be present.")
        }
        
        let compression: String
        switch bmhd.compression {
        case UInt8(ILBM_CMP_NONE.rawValue): compression = "None"
        case UInt8(ILBM_CMP_BYTE_RUN.rawValue): compression = "ByteRun1"
        default: compression = "Unknown"
        }
        
        let masking: String
        switch bmhd.masking {
        case UInt8(ILBM_MSK_NONE.rawValue): masking = "None"
        case UInt8(ILBM_MSK_HAS_MASK.rawValue): masking = "Image Mask"
        case UInt8(ILBM_MSK_HAS_TRANSPARENT_COLOR.rawValue): masking = "Transparent Color (\(bmhd.transparentColor))"
        case UInt8(ILBM_MSK_LASSO.rawValue): masking = "Lasso"
        default: masking = "Unknown"
        }
        
        let viewportMode: String?
        if let camg = image.viewport?.pointee {
            viewportMode = "0x" + String(format: "%08X", camg.viewportMode)
        } else {
            viewportMode = nil
        }
        
        let id = image.formType.bigEndian
        let c1 = Character(UnicodeScalar((id >> 24) & 0xFF) ?? " ")
        let c2 = Character(UnicodeScalar((id >> 16) & 0xFF) ?? " ")
        let c3 = Character(UnicodeScalar((id >> 8) & 0xFF) ?? " ")
        let c4 = Character(UnicodeScalar(id & 0xFF) ?? " ")
        let formTypeString = "\(c1)\(c2)\(c3)\(c4)"

        return IFFImageDetails(
            fileName: fileURL.lastPathComponent,
            filePath: fileURL.path,
            width: Int(bmhd.w),
            height: Int(bmhd.h),
            depth: Int(bmhd.nPlanes),
            colors: Int(image.colorMap?.pointee.colorRegisterLength ?? 0),
            compression: compression,
            masking: masking,
            aspectRatio: "\(bmhd.xAspect):\(bmhd.yAspect)",
            pageDimensions: "\(bmhd.pageWidth) x \(bmhd.pageHeight)",
            viewportMode: viewportMode,
            formType: formTypeString,
            hasCMAP: image.colorMap != nil
        )
    }
}
