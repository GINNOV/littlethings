import CoreGraphics
import Foundation
import ImageIO
import Testing
@testable import ArmageddonCore

struct RecordedFixtureFrameImageTests {
    @Test("Recorded fixture JPEG is large enough to preview")
    func fixtureJPEGIsDisplayable() throws {
        let observations = [
            DetectionObservation(
                id: "target",
                frameID: 1,
                generation: 1,
                captureInstant: MonotonicInstant(nanoseconds: 1),
                label: "target",
                confidence: 0.9,
                boundingBox: NormalizedRect(x: 0.25, y: 0.25, width: 0.2, height: 0.2)
            ),
        ]
        let data = try #require(RecordedFixtureFrameImage.jpeg(width: 1_920, height: 1_080, observations: observations))
        #expect(RecordedFixtureFrameImage.isDisplayableFrame(data))
        let size = try #require(RecordedFixtureFrameImage.pixelSize(of: data))
        #expect(size.width >= 1_280)
        #expect(size.height >= 720)
    }

    @Test("One-pixel JPEG is not a displayable capture frame")
    func onePixelJPEGIsRejected() throws {
        let tiny = try #require(jpeg(width: 1, height: 1))
        #expect(RecordedFixtureFrameImage.isDisplayableFrame(tiny) == false)
        let tinySize = try #require(RecordedFixtureFrameImage.pixelSize(of: tiny))
        #expect(tinySize.width == 1)
        #expect(tinySize.height == 1)
        #expect(RecordedFixtureFrameImage.isDisplayableFrame(Data("not-an-image".utf8)) == false)
    }

    @Test("Persisted capture image bytes round-trip for preview")
    func captureStoreImageDataRoundTrips() async throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "armageddon-preview-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let artifactRoot = root.appending(path: "artifacts")
        let fileSystem = POSIXDurableFileSystem(root: artifactRoot)
        let metadata = try SwiftDataArtifactMetadataStore(storeURL: artifactRoot.appending(path: "Metadata/metadata.store"))
        let store = CaptureSessionStore(
            artifacts: LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata),
            index: FileCaptureIndexStore(fileURL: root.appending(path: "captures/index.json"))
        )
        try await store.open()
        let frame = try #require(RecordedFixtureFrameImage.jpeg())
        let provenance = CaptureProvenance(
            sourceID: "recordedFixture",
            frameID: 1,
            modelID: "fixture.constant.detector",
            modelHash: String(repeating: "0", count: 64),
            observations: [],
            selectedObservationID: nil,
            calibrationID: nil,
            armPose: nil,
            runID: nil,
            captureInstant: MonotonicInstant(nanoseconds: 1_000_000_000),
            imageSize: PixelSize(width: 1_920, height: 1_080)
        )
        let record = try await store.capture(image: frame, thumbnail: nil, provenance: provenance, name: "Preview")
        let loaded = try await store.imageData(for: record)
        #expect(RecordedFixtureFrameImage.isDisplayableFrame(loaded))
        #expect(CaptureHashing.sha256(loaded) == record.imageHash)
    }

    @Test("Native camera JPEG persists as a displayable capture frame")
    func nativeCameraJPEGPersistsAsDisplayableFrame() async throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "armageddon-native-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let artifactRoot = root.appending(path: "artifacts")
        let fileSystem = POSIXDurableFileSystem(root: artifactRoot)
        let metadata = try SwiftDataArtifactMetadataStore(storeURL: artifactRoot.appending(path: "Metadata/metadata.store"))
        let store = CaptureSessionStore(
            artifacts: LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata),
            index: FileCaptureIndexStore(fileURL: root.appending(path: "captures/index.json"))
        )
        try await store.open()
        let frame = try #require(RecordedFixtureFrameImage.jpeg())
        let provenance = CaptureProvenance(
            sourceID: "nativeCamera",
            frameID: 7,
            modelID: "fixture.constant.detector",
            modelHash: String(repeating: "0", count: 64),
            observations: [],
            selectedObservationID: nil,
            calibrationID: nil,
            armPose: nil,
            runID: nil,
            captureInstant: MonotonicInstant(nanoseconds: 1_000_000_000),
            imageSize: PixelSize(width: 1_920, height: 1_080)
        )
        let record = try await store.capture(image: frame, thumbnail: nil, provenance: provenance, name: "Native")
        #expect(record.provenance.sourceID == "nativeCamera")
        let loaded = try await store.imageData(for: record)
        #expect(RecordedFixtureFrameImage.isDisplayableFrame(loaded))
    }

    private func jpeg(width: Int, height: Int) -> Data? {
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ), let image = context.makeImage() else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, "public.jpeg" as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
