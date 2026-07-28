//
//  ImageConverter.swift
//  PixDeluxe
//
//  Created by Engineer on 6/1/24.
//
import AppKit
import UniformTypeIdentifiers

enum ImageConversionError: LocalizedError {
    case invalidPlaneCount(Int)
    case imageLoadFailed(URL)
    case quantizationFailed(URL)

    var errorDescription: String? {
        switch self {
        case .invalidPlaneCount(let count):
            return "Only 1–8 bitplanes are supported (received \(count))."
        case .imageLoadFailed(let url):
            return "Could not load \(url.lastPathComponent) as an image."
        case .quantizationFailed(let url):
            return "Could not quantize \(url.lastPathComponent)."
        }
    }
}

func timestamp(_ label: String) {
    print("⏱️ [\(label)] at \(Date().timeIntervalSince1970)")
}

class ColorBucket {
    let colors: [NSColor]

    init(colors: [NSColor]) {
        self.colors = colors
    }

    var range: Double {
        guard !colors.isEmpty else { return 0 }
        let r = colors.map { $0.redComponent }
        let g = colors.map { $0.greenComponent }
        let b = colors.map { $0.blueComponent }
        return max(r.max()! - r.min()!, g.max()! - g.min()!, b.max()! - b.min()!)
    }

    var averageColor: NSColor {
        let r = colors.reduce(0.0) { $0 + $1.redComponent } / Double(colors.count)
        let g = colors.reduce(0.0) { $0 + $1.greenComponent } / Double(colors.count)
        let b = colors.reduce(0.0) { $0 + $1.blueComponent } / Double(colors.count)
        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

class ImageConverter: ObservableObject {
    @Published var isConverting = false
    @Published var conversionProgress: Double = 0.0
    @Published var conversionStatusText = "Starting..."

    func export(cgImage: CGImage, fileExtension: String) {
        Task { @MainActor in
            let savePanel = NSSavePanel()
            if let type = UTType(filenameExtension: fileExtension) {
                savePanel.allowedContentTypes = [type]
            }
            savePanel.canCreateDirectories = true
            savePanel.nameFieldStringValue = "Untitled"

            guard savePanel.runModal() == .OK, let url = savePanel.url else {
                print("ℹ️ Export cancelled.")
                return
            }

            Task.detached {
                let bitmap = NSBitmapImageRep(cgImage: cgImage)
                let fileType: NSBitmapImageRep.FileType
                switch fileExtension.lowercased() {
                case "png": fileType = .png
                case "jpg", "jpeg": fileType = .jpeg
                default:
                    print("❌ Unsupported format: \(fileExtension)")
                    return
                }

                guard let data = bitmap.representation(using: fileType, properties: [:]) else {
                    print("❌ Conversion failed.")
                    return
                }

                do {
                    try data.write(to: url)
                    print("✅ Exported to \(url.path)")
                } catch {
                    print("❌ Write error: \(error.localizedDescription)")
                }
            }
        }
    }

    func convert(url: URL, nPlanes: Int) async -> URL? {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent(url.deletingPathExtension().lastPathComponent)
            .appendingPathExtension("iff")

        do {
            try FileManager.default.createDirectory(
                at: outputURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try await convert(url: url, nPlanes: nPlanes, outputURL: outputURL)
            return outputURL
        } catch {
            print("❌ Conversion failed: \(error.localizedDescription)")
            await MainActor.run { isConverting = false }
            return nil
        }
    }

    func convert(url: URL, nPlanes: Int, outputURL: URL) async throws {
        guard (1...8).contains(nPlanes) else {
            throw ImageConversionError.invalidPlaneCount(nPlanes)
        }

        await MainActor.run {
            isConverting = true
            conversionProgress = 0.0
            conversionStatusText = "Loading..."
        }
        defer {
            Task { @MainActor in
                isConverting = false
            }
        }

        try Task.checkCancellation()
        timestamp("Start convert")

        guard let nsImage = NSImage(contentsOf: url) else {
            throw ImageConversionError.imageLoadFailed(url)
        }

        let numColors = 1 << nPlanes
        await MainActor.run {
            conversionProgress = 0.2
            conversionStatusText = "Quantizing to \(numColors) colors..."
        }

        timestamp("Start quantization")

        guard let (indexedPixels, palette, width, height) = try await quantize(image: nsImage, numberOfColors: numColors) else {
            throw ImageConversionError.quantizationFailed(url)
        }

        await MainActor.run {
            conversionProgress = 0.8
            conversionStatusText = "Writing IFF..."
        }

        timestamp("Creating IFF file")

        try Task.checkCancellation()
        try await createIFFFile(indexedPixels: indexedPixels, palette: palette, width: width, height: height, nPlanes: nPlanes, outputURL: outputURL)
        timestamp("IFF file created")

        await MainActor.run {
            conversionProgress = 1.0
            conversionStatusText = "Done!"
        }
    }

    private func quantize(image: NSImage, numberOfColors: Int) async throws -> (indexedPixels: [UInt8], palette: [NSColor], width: Int, height: Int)? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let bpp = 4
        let bpr = width * bpp
        let totalBytes = height * bpr

        var pixelData = Data(count: totalBytes)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(
            data: pixelData.withUnsafeMutableBytes { $0.baseAddress },
            width: width, height: height,
            bitsPerComponent: 8,
            bytesPerRow: bpr,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        ctx?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let bytes = pixelData.withUnsafeBytes { $0.bindMemory(to: UInt8.self) }
        let pixels: [NSColor] = stride(from: 0, to: totalBytes, by: bpp).map { i in
            NSColor(red: Double(bytes[i]) / 255.0,
                    green: Double(bytes[i + 1]) / 255.0,
                    blue: Double(bytes[i + 2]) / 255.0,
                    alpha: 1.0)
        }

        print("📊 Extracted \(pixels.count) pixels")

        let sampled: [NSColor]
        if pixels.count > 4096 {
            let stride = max(1, pixels.count / 4096)
            sampled = Swift.stride(from: 0, to: pixels.count, by: stride)
                .prefix(4096)
                .map { pixels[$0] }
        } else {
            sampled = pixels
        }
        let palette = try await medianCutQuantization(pixels: sampled, numberOfColors: numberOfColors)

        timestamp("Palette created")

        var indexed = [UInt8]()
        indexed.reserveCapacity(pixels.count)
        for (index, color) in pixels.enumerated() {
            if index.isMultiple(of: 4096) {
                try Task.checkCancellation()
            }
            indexed.append(findNearestColorIndex(pixel: color, palette: palette))
        }

        timestamp("Quantization complete")
        return (indexed, palette, width, height)
    }

    private func medianCutQuantization(pixels: [NSColor], numberOfColors: Int) async throws -> [NSColor] {
        var buckets: [ColorBucket] = [ColorBucket(colors: pixels)]
        while buckets.count < numberOfColors {
            try Task.checkCancellation()
            guard let bucket = buckets
                .filter({ $0.colors.count > 1 })
                .max(by: { $0.range < $1.range }) else { break }
            let (b1, b2) = splitBucket(bucket)
            if let i = buckets.firstIndex(where: { $0 === bucket }) {
                buckets.remove(at: i)
                buckets.append(contentsOf: [b1, b2])
            }
        }
        return buckets.map { $0.averageColor }
    }

    private func splitBucket(_ bucket: ColorBucket) -> (ColorBucket, ColorBucket) {
        let colors = bucket.colors

        let rRange = colors.max { $0.redComponent < $1.redComponent }!.redComponent -
                     colors.min { $0.redComponent < $1.redComponent }!.redComponent
        let gRange = colors.max { $0.greenComponent < $1.greenComponent }!.greenComponent -
                     colors.min { $0.greenComponent < $1.greenComponent }!.greenComponent
        let bRange = colors.max { $0.blueComponent < $1.blueComponent }!.blueComponent -
                     colors.min { $0.blueComponent < $1.blueComponent }!.blueComponent

        let sorted: [NSColor]
        if rRange >= gRange && rRange >= bRange {
            sorted = colors.sorted { $0.redComponent < $1.redComponent }
        } else if gRange >= bRange {
            sorted = colors.sorted { $0.greenComponent < $1.greenComponent }
        } else {
            sorted = colors.sorted { $0.blueComponent < $1.blueComponent }
        }

        let mid = sorted.count / 2
        return (
            ColorBucket(colors: Array(sorted[..<mid])),
            ColorBucket(colors: Array(sorted[mid...]))
        )
    }

    private func findNearestColorIndex(pixel: NSColor, palette: [NSColor]) -> UInt8 {
        var best = 0
        var bestDist = Double.infinity
        for (i, c) in palette.enumerated() {
            let dist = pow(pixel.redComponent - c.redComponent, 2) +
                       pow(pixel.greenComponent - c.greenComponent, 2) +
                       pow(pixel.blueComponent - c.blueComponent, 2)
            if dist < bestDist {
                bestDist = dist
                best = i
            }
        }
        return UInt8(best)
    }

    private func convertToBitPlanes(indexedPixels: [UInt8], width: Int, height: Int, nPlanes: Int) -> Data {
        let bytesPerRow = ((width + 15) / 16) * 2
        let totalSize = bytesPerRow * height * nPlanes
        var planar = Data(count: totalSize)

        for y in 0..<height {
            for x in 0..<width {
                let color = indexedPixels[y * width + x]
                for plane in 0..<nPlanes {
                    let bit = (color >> plane) & 1
                    let byteIndex = (y * nPlanes + plane) * bytesPerRow + (x / 8)
                    let mask = UInt8(1 << (7 - (x % 8)))
                    if bit == 1 {
                        planar[byteIndex] |= mask
                    }
                }
            }
        }
        return planar
    }

    private func createIFFFile(indexedPixels: [UInt8], palette: [NSColor], width: Int, height: Int, nPlanes: Int, outputURL: URL) async throws {
        let planarData = convertToBitPlanes(indexedPixels: indexedPixels, width: width, height: height, nPlanes: nPlanes)

        var data = Data()
        data.append("FORM".data(using: .ascii)!)
        let sizeOffset = data.count
        data.append(contentsOf: [0, 0, 0, 0])
        data.append("ILBM".data(using: .ascii)!)

        // BMHD
        data.append("BMHD".data(using: .ascii)!)
        data.append(contentsOf: [0, 0, 0, 20])
        data.append(contentsOf: [
            UInt8((width >> 8) & 0xFF), UInt8(width & 0xFF),
            UInt8((height >> 8) & 0xFF), UInt8(height & 0xFF),
            0, 0, 0, 0,
            UInt8(nPlanes), 0, 0, 0,
            0, 0, 1, 1,
            UInt8((width >> 8) & 0xFF), UInt8(width & 0xFF),
            UInt8((height >> 8) & 0xFF), UInt8(height & 0xFF)
        ])

        // CMAP
        data.append("CMAP".data(using: .ascii)!)
        let cmap = palette.flatMap {
            [UInt8($0.redComponent * 255),
             UInt8($0.greenComponent * 255),
             UInt8($0.blueComponent * 255)]
        }
        let cmapLen = cmap.count
        data.append(contentsOf: [
            UInt8((cmapLen >> 24) & 0xFF), UInt8((cmapLen >> 16) & 0xFF),
            UInt8((cmapLen >> 8) & 0xFF), UInt8(cmapLen & 0xFF)
        ])
        data.append(contentsOf: cmap)
        if cmapLen % 2 == 1 { data.append(0) }

        // BODY
        data.append("BODY".data(using: .ascii)!)
        let bodySize = planarData.count
        data.append(contentsOf: [
            UInt8((bodySize >> 24) & 0xFF), UInt8((bodySize >> 16) & 0xFF),
            UInt8((bodySize >> 8) & 0xFF), UInt8(bodySize & 0xFF)
        ])
        data.append(planarData)
        if bodySize % 2 == 1 { data.append(0) }

        // FORM size
        let finalSize = data.count - 8
        data.replaceSubrange(sizeOffset..<sizeOffset+4, with: [
            UInt8((finalSize >> 24) & 0xFF), UInt8((finalSize >> 16) & 0xFF),
            UInt8((finalSize >> 8) & 0xFF), UInt8(finalSize & 0xFF)
        ])

        try data.write(to: outputURL, options: .atomic)
        print("✅ Wrote IFF to \(outputURL.path)")

        let tail = data.suffix(32)
        let hexBytes = tail.map { String(format: "%02X", $0) }.joined(separator: " ")
        print("🔍 Tail: \(hexBytes)")
    }
}

extension FixedWidthInteger {
    func toData() -> Data {
        var val = self
        return Data(bytes: &val, count: MemoryLayout<Self>.size)
    }
}
