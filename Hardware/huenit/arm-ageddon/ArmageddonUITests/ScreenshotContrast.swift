import AppKit
import XCTest

enum ScreenshotContrast {
    struct Metrics {
        let darkFraction: Double
        let lightFraction: Double
        let meanLuma: Double
    }

    static func metrics(png: Data, file: StaticString = #filePath, line: UInt = #line) throws -> Metrics {
        guard let image = NSImage(data: png),
              let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let bytes = bitmap.bitmapData else {
            XCTFail("screenshot PNG could not be decoded", file: file, line: line)
            throw CocoaError(.fileReadCorruptFile)
        }
        let width = bitmap.pixelsWide
        let height = bitmap.pixelsHigh
        let samples = max(bitmap.samplesPerPixel, 3)
        XCTAssertGreaterThan(width, 8, file: file, line: line)
        XCTAssertGreaterThan(height, 8, file: file, line: line)
        var dark = 0
        var light = 0
        var sum = 0.0
        let count = width * height
        for index in 0..<count {
            let offset = index * samples
            let red = Double(bytes[offset]) / 255
            let green = Double(bytes[offset + 1]) / 255
            let blue = Double(bytes[offset + 2]) / 255
            let luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            sum += luma
            if luma < 0.28 { dark += 1 }
            // Secondary type on a dark canvas sits around 0.55–0.85 luma; true black
            // Light-mode `.primary` on the same canvas sits under 0.20.
            if luma > 0.55 { light += 1 }
        }
        return Metrics(
            darkFraction: Double(dark) / Double(count),
            lightFraction: Double(light) / Double(count),
            meanLuma: sum / Double(count)
        )
    }

    static func assertLightOnDarkCanvas(_ png: Data, file: StaticString = #filePath, line: UInt = #line) throws {
        let values = try metrics(png: png, file: file, line: line)
        XCTAssertGreaterThan(values.darkFraction, 0.20, "expected a dark canvas background", file: file, line: line)
        XCTAssertGreaterThan(values.lightFraction, 0.008, "expected light labels on the dark canvas", file: file, line: line)
    }
}
