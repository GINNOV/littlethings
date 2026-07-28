import Cocoa
import QuickLookThumbnailing

final class ThumbnailProvider: QLThumbnailProvider {
    override func provideThumbnail(
        for request: QLFileThumbnailRequest,
        _ handler: @escaping (QLThumbnailReply?, Error?) -> Void
    ) {
        do {
            let data = try Data(contentsOf: request.fileURL, options: .mappedIfSafe)
            let image: CGImage? = data.withUnsafeBytes { buffer in
                guard let baseAddress = buffer.baseAddress else { return nil }
                return iff_createSafeImageFromData(
                    baseAddress.assumingMemoryBound(to: UInt8.self),
                    data.count,
                    true
                )
            }
            guard let image else {
                handler(nil, CocoaError(.fileReadCorruptFile))
                return
            }

            let sourceSize = CGSize(width: image.width, height: image.height)
            let scale = min(
                request.maximumSize.width / sourceSize.width,
                request.maximumSize.height / sourceSize.height,
                1
            )
            let thumbnailSize = CGSize(
                width: max(1, floor(sourceSize.width * scale)),
                height: max(1, floor(sourceSize.height * scale))
            )
            handler(QLThumbnailReply(contextSize: thumbnailSize) { context in
                context.interpolationQuality = .high
                context.draw(image, in: CGRect(origin: .zero, size: thumbnailSize))
                return true
            }, nil)
        } catch {
            handler(nil, error)
        }
    }
}
