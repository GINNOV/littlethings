import AppKit
import ArmageddonCore

enum RecordedFixtureFrameImage {
    static func jpeg(
        width: Int = 1_920,
        height: Int = 1_080,
        observations: [DetectionObservation] = []
    ) -> Data? {
        let pixelWidth = max(width, 1_280)
        let pixelHeight = max(height, 720)
        let size = NSSize(width: pixelWidth, height: pixelHeight)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor(calibratedRed: 0.10, green: 0.14, blue: 0.20, alpha: 1).setFill()
        NSRect(origin: .zero, size: size).fill()

        NSColor(calibratedWhite: 0.28, alpha: 1).setStroke()
        let grid = NSBezierPath()
        grid.lineWidth = 1
        let step = 80.0
        for x in stride(from: 0.0, through: size.width, by: step) {
            grid.move(to: NSPoint(x: x, y: 0))
            grid.line(to: NSPoint(x: x, y: size.height))
        }
        for y in stride(from: 0.0, through: size.height, by: step) {
            grid.move(to: NSPoint(x: 0, y: y))
            grid.line(to: NSPoint(x: size.width, y: y))
        }
        grid.stroke()

        for observation in observations {
            let box = observation.boundingBox
            let rect = NSRect(
                x: box.x * size.width,
                y: (1 - box.y - box.height) * size.height,
                width: box.width * size.width,
                height: box.height * size.height
            )
            let color: NSColor = observation.label == "target"
                ? NSColor.systemGreen
                : NSColor.systemOrange
            color.setStroke()
            let path = NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6)
            path.lineWidth = 5
            path.stroke()
            let caption = "\(observation.label) \(Int((observation.confidence * 100).rounded()))%" as NSString
            caption.draw(
                at: NSPoint(x: rect.minX + 8, y: rect.maxY - 32),
                withAttributes: [
                    .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
                    .foregroundColor: NSColor.white,
                ]
            )
        }

        ("Recorded fixture" as NSString).draw(
            at: NSPoint(x: 28, y: 24),
            withAttributes: [
                .font: NSFont.systemFont(ofSize: 28, weight: .medium),
                .foregroundColor: NSColor.white.withAlphaComponent(0.92),
            ]
        )
        image.unlockFocus()
        guard let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff) else { return nil }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.85])
    }

    static func isDisplayableFrame(_ data: Data) -> Bool {
        guard let image = NSImage(data: data) else { return false }
        return image.size.width >= 16 && image.size.height >= 16
    }
}
