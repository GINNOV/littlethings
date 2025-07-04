import Foundation
import libilbm

// --- Main Logic ---

// Check if a file path was provided as a command-line argument.
guard CommandLine.arguments.count > 1 else {
    print("❌ Error: Please provide a path to an IFF/LBM file.")
    print("   Usage: swift run TestApp /path/to/your/image.iff")
    exit(1)
}

var filePath = CommandLine.arguments[1]
print("▶️ Received path: \(filePath)")

// **CORRECTION**: C libraries often don't understand shell shortcuts like '~'.
// We must expand the tilde to the full home directory path before passing it.
let fullPath = (filePath as NSString).expandingTildeInPath
print("▶️ Attempting to read full path: \(fullPath)")


// 1. Use the ILBM_read function from the C library to parse the file.
guard let iffChunk = ILBM_read(fullPath) else {
    // The C library prints its own "cannot open file" error message.
    print("❌ Failure: The libilbm library could not read or parse the file.")
    exit(1)
}

// Ensure the memory for the IFF chunk is freed when we're done.
defer {
    print("   - Freeing IFF chunk memory.")
    ILBM_free(iffChunk)
}

print("✅ Success! The file was successfully read by the libilbm library.")

// 2. Extract the ILBM image structures from the IFF chunk.
var imageCount: IFF_Long = 0 // This is an Int32
guard let images = ILBM_extractImages(iffChunk, &imageCount), imageCount > 0 else {
    print("❌ Failure: Could not extract any ILBM images from the file.")
    exit(1)
}

// Ensure the memory for the extracted images is freed.
defer {
    print("   - Freeing ILBM_Image memory.")
    ILBM_freeImages(images, UInt32(imageCount))
}

print("✅ Success! Extracted \(imageCount) image(s) from the file.")

// 3. Inspect the properties of the first image.
guard let firstImagePtr = images[0] else {
    print("❌ Failure: Could not access the first image.")
    exit(1)
}

let image = firstImagePtr.pointee
let header = image.bitMapHeader.pointee

let width = header.w
let height = header.h
let depth = header.nPlanes
let masking = header.masking
let compression = header.compression

print("\n--- Image Properties ---")
print("  - Dimensions: \(width) x \(height)")
print("  - Bit-planes (depth): \(depth)")
print("  - Compression: \(compression == 1 ? "ByteRun1" : "None")")
print("  - Masking: \(masking)")
print("------------------------\n")

// 4. Deinterleave the planar data to a raw pixel buffer (optional validation)
guard let rawPixelData = ILBM_deinterleave(firstImagePtr) else {
    print("❌ Failure: Could not deinterleave pixel data.")
    exit(1)
}
// Free the memory for the deinterleaved data once we're done with it.
defer {
    free(rawPixelData)
}


print("✅ Success! Image data was successfully deinterleaved.")
print("   The image is valid and its data can now be processed.")

