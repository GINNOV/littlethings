import Foundation
import Testing
@testable import ArmageddonCore

struct CaptureSessionTests {
    @Test("Explicit capture persists provenance and supports review export restore")
    func explicitCaptureRoundTrips() async throws {
        let root = FileManager.default.temporaryDirectory
            .appending(path: "armageddon-capture-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }

        let artifactRoot = root.appending(path: "artifacts")
        let fileSystem = POSIXDurableFileSystem(root: artifactRoot)
        let metadata = try SwiftDataArtifactMetadataStore(
            storeURL: artifactRoot.appending(path: "Metadata/metadata.store")
        )
        let artifacts = LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata)
        let index = FileCaptureIndexStore(fileURL: root.appending(path: "captures/index.json"))
        let store = CaptureSessionStore(artifacts: artifacts, index: index)
        try await store.open()

        let record = try await store.capture(
            image: Data("frame-bytes".utf8),
            thumbnail: Data("thumbnail".utf8),
            provenance: CaptureProvenance.fixture,
            name: "First capture"
        )
        #expect(record.provenance.frameID == 42)
        #expect(record.review == .pending)
        try await store.review(id: record.id, as: .accepted)
        #expect(try await store.record(id: record.id)?.review == .accepted)
        #expect(try await store.query(search: "first").map(\.id) == [record.id])

        let exportURL = root.appending(path: "export")
        let manifestURL = try await store.export(id: record.id, to: exportURL)
        let manifest = try CaptureExportValidator.validate(directory: exportURL)
        #expect(manifestURL.lastPathComponent == "manifest.json")
        #expect(manifest.imageSHA256 == record.imageHash)

        try await store.trash(id: record.id)
        #expect(try await store.query().isEmpty)
        try await store.restore(id: record.id)
        #expect(try await store.query().map(\.id) == [record.id])

        let reopened = CaptureSessionStore(
            artifacts: LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata),
            index: FileCaptureIndexStore(fileURL: root.appending(path: "captures/index.json"))
        )
        try await reopened.open()
        #expect(try await reopened.record(id: record.id)?.id == record.id)
        #expect(try await reopened.record(id: record.id)?.review == .accepted)
    }

    @Test("Capture index rejects path-like names and duplicate identifiers")
    func captureIndexRejectsUnsafeMutation() async throws {
        let index = InMemoryCaptureIndexStore()
        try await index.open()
        let first = CaptureRecord.fixture
        try await index.insert(first)
        do {
            try await index.insert(first)
            Issue.record("duplicate capture was accepted")
        } catch CaptureError.duplicateID {
        }
        do {
            _ = try CaptureSessionStore.validateCaptureName("../escape")
            Issue.record("path-like capture name was accepted")
        } catch CaptureError.invalidName {
        }
    }
}

private extension CaptureProvenance {
    static let fixture = CaptureProvenance(
        sourceID: "native-camera-redacted",
        frameID: 42,
        modelID: "fixture.detector",
        modelHash: String(repeating: "a", count: 64),
        observations: [],
        selectedObservationID: nil,
        calibrationID: nil,
        armPose: ArmPoseSnapshot(x: 10, y: 20, z: 30, ageNanoseconds: 20_000_000),
        runID: nil,
        captureInstant: MonotonicInstant(nanoseconds: 1_000_000_000),
        imageSize: PixelSize(width: 1280, height: 720)
    )
}

private extension CaptureRecord {
    static let fixture = CaptureRecord(
        id: "capture-fixture",
        name: "Fixture",
        createdAt: Date(timeIntervalSince1970: 1),
        provenance: .fixture,
        imageArtifactID: "capture-fixture-image",
        thumbnailArtifactID: nil,
        imageHash: String(repeating: "b", count: 64),
        imageByteCount: 1,
        review: .accepted
    )
}
