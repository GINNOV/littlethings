//
//  ImageConverter.swift
//  PixDeluxe
//
//  Created by Engineer on 6/1/24.
//
import AppKit
import UniformTypeIdentifiers

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
        guard nPlanes > 0 && nPlanes <= 8 else {
            print("❌ Only 1–8 planes supported.")
            return nil
        }

        await MainActor.run {
            isConverting = true
            conversionProgress = 0.0
            conversionStatusText = "Loading..."
        }

        timestamp("Start convert")

        guard let nsImage = NSImage(contentsOf: url) else {
            print("❌ Image load failed.")
            await MainActor.run { isConverting = false }
            return nil
        }

        let numColors = 1 << nPlanes
        await MainActor.run {
            conversionProgress = 0.2
            conversionStatusText = "Quantizing to \(numColors) colors..."
        }

        timestamp("Start quantization")

        guard let (indexedPixels, palette, width, height) = await quantize(image: nsImage, numberOfColors: numColors) else {
            print("❌ Quantization failed.")
            await MainActor.run { isConverting = false }
            return nil
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.deletingPathExtension().lastPathComponent + ".iff")

        await MainActor.run {
            conversionProgress = 0.8
            conversionStatusText = "Writing IFF..."
        }

        timestamp("Creating IFF file")

        do {
            try await createIFFFile(indexedPixels: indexedPixels, palette: palette, width: width, height: height, nPlanes: nPlanes, outputURL: tempURL)
            timestamp("IFF file created")
        } catch {
            print("❌ IFF write failed: \(error.localizedDescription)")
            await MainActor.run { isConverting = false }
            return nil
        }

        await MainActor.run {
            isConverting = false
            conversionProgress = 1.0
            conversionStatusText = "Done!"
        }

        return tempURL
    }

    private func quantize(image: NSImage, numberOfColors: Int) async -> (indexedPixels: [UInt8], palette: [NSColor], width: Int, height: Int)? {
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

        let sampled = pixels.count > 4096 ? Array(pixels.shuffled().prefix(4096)) : pixels
        let palette = await medianCutQuantization(pixels: sampled, numberOfColors: numberOfColors)

        timestamp("Palette created")

        let indexed = pixels.map { color in
            findNearestColorIndex(pixel: color, palette: palette)
        }

        timestamp("Quantization complete")
        return (indexed, palette, width, height)
    }

    private func medianCutQuantization(pixels: [NSColor], numberOfColors: Int) async -> [NSColor] {
        var buckets: [ColorBucket] = [ColorBucket(colors: pixels)]
        while buckets.count < numberOfColors {
            guard let bucket = buckets.max(by: { $0.range < $1.range }) else { break }
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
        let bytesPerRow = (width + 7) / 8
        let totalSize = bytesPerRow * height * nPlanes
        var planar = Data(count: totalSize)

        for y in 0..<height {
            for x in 0..<width {
                let color = indexedPixels[y * width + x]
                for plane in 0..<nPlanes {
                    let bit = (color >> plane) & 1
                    let byteIndex = (plane * height + y) * bytesPerRow + (x / 8)
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

        try data.write(to: outputURL)
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
