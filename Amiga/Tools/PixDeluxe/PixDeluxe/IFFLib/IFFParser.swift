//
//  ImageConverter.swift
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
        print("ℹ️ Attempting to parse IFF file at: \(path)")

        guard let iffChunk = ILBM_read(path) else {
            print("❌ Error: libilbm could not read the IFF file at \(path).")
            return nil
        }
        defer { ILBM_free(iffChunk) }

        var imagesCount: UInt32 = 0
        guard let images = ILBM_extractImages(iffChunk, &imagesCount),
              imagesCount > 0,
              let imagePtr = images[0] else {
            print("❌ Error: Could not extract ILBM images from the file.")
            return nil
        }
        defer { ILBM_freeImages(images, imagesCount) }
        
        let image = imagePtr.pointee

        guard let bitMapHeader = image.bitMapHeader?.pointee else {
            print("❌ Error: Could not get bitmap header.")
            return nil
        }

        if bitMapHeader.compression == ILBM_CMP_BYTE_RUN.rawValue {
            ILBM_unpackByteRun(imagePtr)
        }

        if ILBM_imageIsILBM(imagePtr) == 1 {
            if ILBM_convertILBMToACBM(imagePtr) == 0 {
                print("❌ Error: Failed to convert IFF from planar to chunky format.")
                return nil
            }
        } else if !(ILBM_imageIsPBM(imagePtr) == 1 || ILBM_imageIsACBM(imagePtr) == 1) {
            print("❌ Error: Unsupported IFF image type.")
            return nil
        }
        
        guard let body = image.body?.pointee, let chunkyDataPtr = body.chunkData else {
            print("❌ Error: Could not get chunky pixel data from body.")
            return nil
        }
        let chunkyData = Array(UnsafeBufferPointer(start: chunkyDataPtr, count: Int(body.chunkSize)))

        guard let colorMap = image.colorMap?.pointee, let colors = colorMap.colorRegister else {
             print("❌ Error: Could not get color map.")
             return nil
        }
        let colorMapSize = Int(colorMap.colorRegisterLength)

        let width = Int(bitMapHeader.w)
        let height = Int(bitMapHeader.h)
        var rgbaPixels = [UInt8](repeating: 0, count: width * height * 4)

        for i in 0..<(width * height) {
            guard i < chunkyData.count else { break }
            let colorIndex = Int(chunkyData[i])
            guard colorIndex < colorMapSize else { continue }
            
            let color = colors[colorIndex]
            let pixelIndex = i * 4
            rgbaPixels[pixelIndex]     = color.red
            rgbaPixels[pixelIndex + 1] = color.green
            rgbaPixels[pixelIndex + 2] = color.blue
            rgbaPixels[pixelIndex + 3] = 255
        }
        
        let finalImage = IFFImage(width: width, height: height, pixels: rgbaPixels)
        let details = extractDetails(from: image)
        
        return ParseResult(image: finalImage, chunkyData: chunkyData, details: details)
    }
    
    private func extractDetails(from image: ILBM_Image) -> IFFImageDetails {
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

        return IFFImageDetails(
            width: Int(bmhd.w),
            height: Int(bmhd.h),
            depth: Int(bmhd.nPlanes),
            colors: Int(image.colorMap?.pointee.colorRegisterLength ?? 0),
            compression: compression,
            masking: masking,
            aspectRatio: "\(bmhd.xAspect):\(bmhd.yAspect)",
            pageDimensions: "\(bmhd.pageWidth) x \(bmhd.pageHeight)",
            viewportMode: viewportMode
        )
    }
}
