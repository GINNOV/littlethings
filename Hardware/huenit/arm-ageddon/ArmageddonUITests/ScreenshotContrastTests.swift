import AppKit
import XCTest

final class ScreenshotContrastTests: XCTestCase {
    func testLightMarksOnDarkCanvasPass() throws {
        let png = try render(width: 240, height: 120, fill: NSColor(white: 0.12, alpha: 1), marks: NSColor(white: 0.82, alpha: 1))
        try ScreenshotContrast.assertLightOnDarkCanvas(png)
    }

    func testDarkMarksOnDarkCanvasFailLightFraction() throws {
        let png = try render(width: 240, height: 120, fill: NSColor(white: 0.12, alpha: 1), marks: NSColor(white: 0.16, alpha: 1))
        let values = try ScreenshotContrast.metrics(png: png)
        XCTAssertGreaterThan(values.darkFraction, 0.20)
        XCTAssertLessThan(values.lightFraction, 0.008, "dark-on-dark labels must not count as readable")
    }

    private func render(width: Int, height: Int, fill: NSColor, marks: NSColor) throws -> Data {
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            throw CocoaError(.fileWriteUnknown)
        }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        fill.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()
        if width > 8, height > 8 {
            marks.setFill()
            NSBezierPath(rect: NSRect(x: 8, y: height / 3, width: width - 16, height: 10)).fill()
            NSBezierPath(rect: NSRect(x: 8, y: (2 * height) / 3, width: (width - 16) / 2, height: 8)).fill()
        }
        NSGraphicsContext.restoreGraphicsState()
        return try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
    }
}
