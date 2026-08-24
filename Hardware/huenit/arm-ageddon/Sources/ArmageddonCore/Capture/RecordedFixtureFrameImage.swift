import CoreGraphics
import CoreText
import Foundation
import ImageIO

public enum RecordedFixtureFrameImage {
    public static func jpeg(
        width: Int = 1_920,
        height: Int = 1_080,
        observations: [DetectionObservation] = []
    ) -> Data? {
        let pixelWidth = max(width, 1_280)
        let pixelHeight = max(height, 720)
        guard let context = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.setFillColor(CGColor(red: 0.10, green: 0.14, blue: 0.20, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))

        context.setStrokeColor(CGColor(gray: 0.28, alpha: 1))
        context.setLineWidth(1)
        let step = 80.0
        var x = 0.0
        while x <= Double(pixelWidth) {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: Double(pixelHeight)))
            x += step
        }
        var y = 0.0
        while y <= Double(pixelHeight) {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: Double(pixelWidth), y: y))
            y += step
        }
        context.strokePath()

        let width = Double(pixelWidth)
        let height = Double(pixelHeight)
        for observation in observations {
            let box = observation.boundingBox
            let rect = CGRect(
                x: box.x * width,
                y: (1 - box.y - box.height) * height,
                width: box.width * width,
                height: box.height * height
            )
            let color = observation.label == "target"
                ? CGColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)
                : CGColor(red: 0.95, green: 0.55, blue: 0.15, alpha: 1)
            context.setStrokeColor(color)
            context.setLineWidth(5)
            context.stroke(rect)

            draw(
                "\(observation.label) \(Int((observation.confidence * 100).rounded()))%",
                at: CGPoint(x: rect.minX + 8, y: rect.maxY - 28),
                in: context,
                size: 22
            )
        }

        draw("Recorded fixture", at: CGPoint(x: 28, y: 24), in: context, size: 28)
        guard let image = context.makeImage() else { return nil }
        return jpegData(from: image)
    }

    public static func pixelSize(of data: Data) -> (width: Int, height: Int)? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int else {
            return nil
        }
        return (width, height)
    }

    public static func isDisplayableFrame(_ data: Data) -> Bool {
        guard let size = pixelSize(of: data) else { return false }
        return size.width >= 16 && size.height >= 16
    }

    private static func draw(_ text: String, at origin: CGPoint, in context: CGContext, size: CGFloat) {
        let font = CTFontCreateWithName("Helvetica" as CFString, size, nil)
        let attributes: [CFString: Any] = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: CGColor(gray: 1, alpha: 0.92),
        ]
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes as [NSAttributedString.Key: Any]))
        context.textPosition = origin
        CTLineDraw(line, context)
    }

    private static func jpegData(from image: CGImage) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, "public.jpeg" as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(
            destination,
            image,
            [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary
        )
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
