import Foundation

public enum DetectorCoordinateError: Error, Equatable, Sendable {
    case invalidImageSize
    case invalidRectangle
    case nonInvertibleTransform
}

public struct PixelSize: Codable, Equatable, Sendable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    public var isValid: Bool {
        width.isFinite && height.isFinite && width > 0 && height > 0
    }
}

public struct PixelRect: Codable, Equatable, Sendable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var maxX: Double { x + width }
    public var maxY: Double { y + height }

    public var isFinite: Bool {
        [x, y, width, height].allSatisfy(\.isFinite)
    }

    fileprivate var corners: [(Double, Double)] {
        [(x, y), (maxX, y), (x, maxY), (maxX, maxY)]
    }

    fileprivate init(corners: [(Double, Double)]) {
        let xs = corners.map(\.0)
        let ys = corners.map(\.1)
        x = xs.min() ?? 0
        y = ys.min() ?? 0
        width = (xs.max() ?? 0) - x
        height = (ys.max() ?? 0) - y
    }
}

public enum DetectorResizeMode: String, Codable, Equatable, Sendable {
    case stretch
    case letterbox
    case centerCrop
}

public struct DetectorCoordinateTransform: Sendable, Equatable {
    public let sourceSize: PixelSize
    public let modelSize: PixelSize
    public let viewSize: PixelSize
    public let orientation: CaptureVideoOrientation
    public let mirrored: Bool
    public let resizeMode: DetectorResizeMode

    public init(
        sourceSize: PixelSize,
        modelSize: PixelSize,
        viewSize: PixelSize,
        orientation: CaptureVideoOrientation = .landscapeRight,
        mirrored: Bool = false,
        resizeMode: DetectorResizeMode = .letterbox
    ) throws {
        guard sourceSize.isValid, modelSize.isValid, viewSize.isValid else {
            throw DetectorCoordinateError.invalidImageSize
        }
        self.sourceSize = sourceSize
        self.modelSize = modelSize
        self.viewSize = viewSize
        self.orientation = orientation
        self.mirrored = mirrored
        self.resizeMode = resizeMode
    }

    public func sourceToModel(_ rect: PixelRect) throws -> PixelRect {
        try validate(rect)
        let oriented = transformRect(rect, using: sourcePointToOriented)
        return transformRect(oriented, using: orientedPointToModel)
    }

    public func modelToSource(_ rect: PixelRect) throws -> PixelRect {
        try validate(rect)
        let oriented = transformRect(rect, using: modelPointToOriented)
        return transformRect(oriented, using: orientedPointToSource)
    }

    public func modelToView(_ rect: PixelRect) throws -> PixelRect {
        try validate(rect)
        let oriented = transformRect(rect, using: modelPointToOriented)
        return transformRect(oriented, using: orientedPointToView)
    }

    public func sourceToView(_ rect: PixelRect) throws -> PixelRect {
        try modelToView(sourceToModel(rect))
    }

    public func normalizedSourceRect(_ rect: PixelRect) throws -> NormalizedRect {
        try validate(rect)
        return NormalizedRect(
            x: rect.x / sourceSize.width,
            y: rect.y / sourceSize.height,
            width: rect.width / sourceSize.width,
            height: rect.height / sourceSize.height
        )
    }

    public func sourcePixels(from normalized: NormalizedRect) throws -> PixelRect {
        guard normalized.isUnitBounded else { throw DetectorCoordinateError.invalidRectangle }
        return PixelRect(
            x: normalized.x * sourceSize.width,
            y: normalized.y * sourceSize.height,
            width: normalized.width * sourceSize.width,
            height: normalized.height * sourceSize.height
        )
    }

    private var orientedSize: PixelSize {
        switch orientation {
        case .portrait, .landscapeLeft:
            PixelSize(width: sourceSize.height, height: sourceSize.width)
        case .portraitUpsideDown, .landscapeRight, .unknown:
            sourceSize
        }
    }

    private func validate(_ rect: PixelRect) throws {
        guard rect.isFinite, rect.width >= 0, rect.height >= 0 else {
            throw DetectorCoordinateError.invalidRectangle
        }
    }

    private func sourcePointToOriented(_ point: (Double, Double)) -> (Double, Double) {
        let normalized = (point.0 / sourceSize.width, point.1 / sourceSize.height)
        let oriented: (Double, Double) = switch orientation {
        case .portrait: (1 - normalized.1, normalized.0)
        case .portraitUpsideDown: (1 - normalized.0, 1 - normalized.1)
        case .landscapeLeft: (normalized.1, 1 - normalized.0)
        case .landscapeRight, .unknown: normalized
        }
        let mirroredPoint = mirrored ? (1 - oriented.0, oriented.1) : oriented
        return (mirroredPoint.0 * orientedSize.width, mirroredPoint.1 * orientedSize.height)
    }

    private func orientedPointToSource(_ point: (Double, Double)) -> (Double, Double) {
        let normalized = (point.0 / orientedSize.width, point.1 / orientedSize.height)
        let unmirrored = mirrored ? (1 - normalized.0, normalized.1) : normalized
        let source: (Double, Double) = switch orientation {
        case .portrait: (unmirrored.1, 1 - unmirrored.0)
        case .portraitUpsideDown: (1 - unmirrored.0, 1 - unmirrored.1)
        case .landscapeLeft: (1 - unmirrored.1, unmirrored.0)
        case .landscapeRight, .unknown: unmirrored
        }
        return (source.0 * sourceSize.width, source.1 * sourceSize.height)
    }

    private func orientedPointToModel(_ point: (Double, Double)) -> (Double, Double) {
        let fit = fitParameters(from: orientedSize, to: modelSize, mode: resizeMode)
        return (point.0 * fit.scaleX + fit.offsetX, point.1 * fit.scaleY + fit.offsetY)
    }

    private func modelPointToOriented(_ point: (Double, Double)) -> (Double, Double) {
        let fit = fitParameters(from: orientedSize, to: modelSize, mode: resizeMode)
        return ((point.0 - fit.offsetX) / fit.scaleX, (point.1 - fit.offsetY) / fit.scaleY)
    }

    private func orientedPointToView(_ point: (Double, Double)) -> (Double, Double) {
        let fit = fitParameters(from: orientedSize, to: viewSize, mode: .letterbox)
        return (point.0 * fit.scaleX + fit.offsetX, point.1 * fit.scaleY + fit.offsetY)
    }

    private func transformRect(
        _ rect: PixelRect,
        using transform: ((Double, Double)) -> (Double, Double)
    ) -> PixelRect {
        PixelRect(corners: rect.corners.map(transform))
    }

    private func fitParameters(
        from source: PixelSize,
        to destination: PixelSize,
        mode: DetectorResizeMode
    ) -> (scaleX: Double, scaleY: Double, offsetX: Double, offsetY: Double) {
        switch mode {
        case .stretch:
            return (
                destination.width / source.width,
                destination.height / source.height,
                0,
                0
            )
        case .letterbox, .centerCrop:
            let scale = mode == .letterbox
                ? min(destination.width / source.width, destination.height / source.height)
                : max(destination.width / source.width, destination.height / source.height)
            return (
                scale,
                scale,
                (destination.width - source.width * scale) / 2,
                (destination.height - source.height * scale) / 2
            )
        }
    }
}
