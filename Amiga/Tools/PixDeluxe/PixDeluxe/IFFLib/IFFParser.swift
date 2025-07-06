// MARK: - IFFParser.swift

import Foundation

class IFFParser {
    // A struct to hold the final, displayable image data.
    struct IFFImage {
        let width: Int
        let height: Int
        let pixels: [UInt8] // Raw RGBA pixel data
    }

    // This function now calls the C library to parse the IFF file.
    // It returns both the final image and the raw chunky pixel data for debugging.
    func parse(url: URL) -> (image: IFFImage, chunkyData: [UInt8])? {
        let path = url.path
        print("ℹ️ Attempting to parse IFF file at: \(path)")

        // 1. Read the IFF file into a chunk structure.
        guard let iffChunk = ILBM_read(path) else {
            print("❌ Error: libilbm could not read the IFF file at \(path).")
            return nil
        }
        defer { ILBM_free(iffChunk) }

        // 2. Extract ILBM images from the IFF chunk.
        var imagesCount: UInt32 = 0
        guard let images = ILBM_extractImages(iffChunk, &imagesCount) else {
            print("❌ Error: Could not extract ILBM images from the file.")
            return nil
        }
        defer { ILBM_freeImages(images, imagesCount) }

        guard imagesCount > 0, let imagePtr = images[0] else {
            print("❌ Error: No images found in the IFF file.")
            return nil
        }
        
        let image = imagePtr.pointee

        // 3. Get image dimensions and check for compression.
        guard let bitMapHeader = image.bitMapHeader?.pointee else {
            print("❌ Error: Could not get bitmap header.")
            return nil
        }

        let width = Int(bitMapHeader.w)
        let height = Int(bitMapHeader.h)
        print("ℹ️ Image dimensions: \(width)x\(height)")

        // 4. Decompress the image body if it uses ByteRun1 compression.
        // This was the crucial missing step.
        if bitMapHeader.compression == ILBM_CMP_BYTE_RUN.rawValue {
            print("ℹ️ Image is compressed with ByteRun1. Unpacking...")
            ILBM_unpackByteRun(imagePtr)
            print("✅ Unpacked successfully.")
        }

        // 5. Handle different IFF types (ILBM, PBM, ACBM).
        // We only need to convert if it's a planar ILBM file.
        if ILBM_imageIsILBM(imagePtr) == 1 {
            print("ℹ️ Image is ILBM (Planar). Attempting conversion to chunky format.")
            if ILBM_convertILBMToACBM(imagePtr) == 0 { // Returns 1 on success
                print("❌ Error: Failed to convert IFF from planar to chunky format.")
                return nil
            }
            print("✅ Conversion to chunky format successful.")
        } else if ILBM_imageIsPBM(imagePtr) == 1 || ILBM_imageIsACBM(imagePtr) == 1 {
            print("ℹ️ Image is PBM or ACBM (already chunky). No conversion needed.")
        } else {
            print("❌ Error: Unsupported IFF image type.")
            return nil
        }
        
        // 6. The chunky pixel data (color indices) is now in the image's body.
        guard let body = image.body?.pointee, let chunkyDataPtr = body.chunkData else {
            print("❌ Error: Could not get chunky pixel data from body.")
            return nil
        }
        let chunkyDataSize = Int(body.chunkSize)
        // Convert the C pointer to a Swift array for safety and ease of use.
        let chunkyData = Array(UnsafeBufferPointer(start: chunkyDataPtr, count: chunkyDataSize))


        // 7. Get the color map to translate color indices to RGB values.
        guard let colorMap = image.colorMap?.pointee, let colors = colorMap.colorRegister else {
             print("❌ Error: Could not get color map.")
             return nil
        }
        let colorMapSize = Int(colorMap.colorRegisterLength)
        print("ℹ️ Found color map with \(colorMapSize) colors.")

        // 8. Create the final RGBA buffer by looking up each pixel's color index.
        var rgbaPixels = [UInt8](repeating: 0, count: width * height * 4)

        for i in 0..<(width * height) {
            // Make sure we don't read past the end of the chunky data buffer
            guard i < chunkyData.count else { break }

            let colorIndex = Int(chunkyData[i])
            
            // Safety check to prevent crashing on invalid color indices
            guard colorIndex < colorMapSize else {
                print("⚠️ Warning: Invalid color index \(colorIndex) at pixel \(i). Using black.")
                let pixelIndex = i * 4
                rgbaPixels[pixelIndex]     = 0
                rgbaPixels[pixelIndex + 1] = 0
                rgbaPixels[pixelIndex + 2] = 0
                rgbaPixels[pixelIndex + 3] = 255
                continue
            }
            
            let color = colors[colorIndex]
            let pixelIndex = i * 4
            
            rgbaPixels[pixelIndex]     = color.red
            rgbaPixels[pixelIndex + 1] = color.green
            rgbaPixels[pixelIndex + 2] = color.blue
            rgbaPixels[pixelIndex + 3] = 255 // Alpha
        }
        
        let finalImage = IFFImage(width: width, height: height, pixels: rgbaPixels)
        return (image: finalImage, chunkyData: chunkyData)
    }
}
