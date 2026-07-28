import AppKit
import Foundation

enum TestImageFormat {
    case png
    case jpeg

    var fileExtension: String {
        switch self {
        case .png:
            "png"
        case .jpeg:
            "jpg"
        }
    }

    var bitmapType: NSBitmapImageRep.FileType {
        switch self {
        case .png:
            .png
        case .jpeg:
            .jpeg
        }
    }
}

enum TestImageFactory {
    static func writeImage(
        named name: String,
        format: TestImageFormat,
        to directory: URL
    ) throws -> URL {
        let width = 16
        let height = 8
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: width * 4,
            bitsPerPixel: 32
        ) else {
            throw TestFixtureError.bitmapCreationFailed
        }

        for y in 0..<height {
            for x in 0..<width {
                let isLight = (x + y).isMultiple(of: 2)
                bitmap.setColor(
                    isLight ? .white : .black,
                    atX: x,
                    y: y
                )
            }
        }

        guard let data = bitmap.representation(
            using: format.bitmapType,
            properties: format == .jpeg ? [.compressionFactor: 0.9] : [:]
        ) else {
            throw TestFixtureError.encodingFailed
        }

        let url = directory
            .appendingPathComponent(name)
            .appendingPathExtension(format.fileExtension)
        try data.write(to: url, options: .atomic)
        return url
    }
}

enum TestFixtureError: Error {
    case bitmapCreationFailed
    case encodingFailed
}
