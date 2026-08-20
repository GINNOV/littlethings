import Foundation
import Testing
@testable import ArmageddonCore

struct HuenitCameraTests {
    @Test("Fragmented K210 telemetry lines become detection-only observations")
    func fragmentedRectangles() throws {
        var decoder = HuenitTelemetryLineDecoder(imageSize: PixelSize(width: 1280, height: 720))
        let first = try decoder.append(Data("raccoon,128,72,256,".utf8), receivedAt: MonotonicInstant(nanoseconds: 10))
        #expect(first.isEmpty)
        let second = try decoder.append(Data("144\ncat,640,360,64,72\n".utf8), receivedAt: MonotonicInstant(nanoseconds: 20))
        #expect(second.count == 2)
        #expect(second[0].label == "raccoon")
        #expect(second[0].captureInstant == nil)
        #expect(second[0].receivedAt == MonotonicInstant(nanoseconds: 10))
        #expect(second[0].boundingBox == NormalizedRect(x: 0.1, y: 0.1, width: 0.2, height: 0.2))
        #expect(decoder.malformedLineCount == 0)
    }

    @Test("Malformed and oversized telemetry is dropped without unbounded buffering")
    func malformedAndOversizedLines() throws {
        var decoder = HuenitTelemetryLineDecoder(imageSize: PixelSize(width: 100, height: 100), maxLineBytes: 32)
        let output = try decoder.append(
            Data(String(repeating: "x", count: 100).utf8),
            receivedAt: MonotonicInstant(nanoseconds: 0)
        )
        #expect(output.isEmpty)
        #expect(decoder.oversizedLineCount == 1)
        _ = try decoder.append(Data("bad\nvalid,0,0,10,10\n".utf8), receivedAt: MonotonicInstant(nanoseconds: 1))
        _ = try decoder.append(Data("bad\n".utf8), receivedAt: MonotonicInstant(nanoseconds: 2))
        #expect(decoder.malformedLineCount == 1)
        #expect(decoder.detectionCount == 1)
        #expect(decoder.bufferedByteCount == 0)
    }

    @Test("Protocol probe marks unsupported preview and upload when only telemetry is observed")
    func recordedProbeCapabilityDecision() throws {
        let result = try HuenitCameraProbeResult.parse(
            transcript: "identity=HUENIT_CAM\nbaud=115200\nframe=raccoon,1,2,3,4\n",
            sourceHash: String(repeating: "a", count: 64),
            measuredAt: "2026-08-20"
        )
        #expect(result.decision.status == .measured)
        #expect(result.decision.supported == [.serialTelemetry])
        #expect(result.decision.unsupportedReasons[.preview] != nil)
        #expect(result.decision.unsupportedReasons[.artifactUpload] != nil)
    }

    @Test("K210 inventory rejects missing labels and path traversal")
    func k210InventoryRejectsUnsafeBundle() throws {
        let manifest = K210ArtifactManifest(
            identifier: "fixture.k210",
            modelFilename: "model.kmodel",
            scriptFilename: "detector.py",
            labels: ["raccoon"],
            anchors: [1, 2, 3, 4],
            provenance: "recorded fixture"
        )
        #expect(throws: K210InventoryError.invalidFilename) {
            try manifest.validated(modelFilename: "../model.kmodel", scriptFilename: "detector.py")
        }
        #expect(throws: K210InventoryError.missingLabels) {
            try K210ArtifactManifest(
                identifier: "fixture.k210",
                modelFilename: "model.kmodel",
                scriptFilename: "detector.py",
                labels: [],
                anchors: [1, 2],
                provenance: "fixture"
            ).validated(modelFilename: "model.kmodel", scriptFilename: "detector.py")
        }
        #expect(manifest.labels == ["raccoon"])
    }

    @Test("K210 inventory exports a verified bundle without enabling upload")
    func k210InventoryImportsAndExportsBundle() async throws {
        let root = FileManager.default.temporaryDirectory.appending(path: "k210-inventory-\(UUID().uuidString)")
        let incoming = root.appending(path: "incoming")
        let exportRoot = root.appending(path: "export")
        try FileManager.default.createDirectory(at: incoming, withIntermediateDirectories: true)
        let modelURL = incoming.appending(path: "detector.kmodel")
        let scriptURL = incoming.appending(path: "detector.py")
        try Data("kmodel-fixture".utf8).write(to: modelURL)
        try Data("print('fixture')".utf8).write(to: scriptURL)
        let manifest = K210ArtifactManifest(
            identifier: "fixture-k210",
            modelFilename: modelURL.lastPathComponent,
            scriptFilename: scriptURL.lastPathComponent,
            labels: ["target"],
            anchors: [1, 2, 3, 4],
            provenance: "recorded fixture",
            modelSHA256: CaptureHashing.sha256(try Data(contentsOf: modelURL)),
            scriptSHA256: CaptureHashing.sha256(try Data(contentsOf: scriptURL))
        )
        let manifestURL = incoming.appending(path: "manifest.armk210.json")
        try JSONEncoder().encode(manifest).write(to: manifestURL)
        let decision = HuenitCameraCapabilityDecision(
            status: .notMeasured,
            supported: [],
            unsupportedReasons: [.artifactUpload: "Upload has not been measured."],
            profile: nil
        )
        let inventory = K210ArtifactInventory(root: root.appending(path: "installed"), decision: decision)

        let record = try await inventory.importBundle(manifestURL: manifestURL, modelURL: modelURL, scriptURL: scriptURL)
        #expect(record.modelSHA256 == manifest.modelSHA256)
        #expect(record.scriptSHA256 == manifest.scriptSHA256)
        #expect(record.uploadAvailable == false)
        let exported = try await inventory.exportBundle(identifier: record.id, to: exportRoot)
        #expect(try Data(contentsOf: exported.appending(path: record.manifest.modelFilename)) == Data("kmodel-fixture".utf8))
        #expect(try Data(contentsOf: exported.appending(path: record.manifest.scriptFilename)) == Data("print('fixture')".utf8))
        let instruction = await inventory.deploymentInstruction(for: record)
        #expect(instruction.contains("unsupported"))
        let reopened = K210ArtifactInventory(root: root.appending(path: "installed"), decision: decision)
        let restored = await reopened.all()
        #expect(restored.map(\.id) == [record.id])
    }

    @Test("unmeasured capability decisions never enable preview or upload")
    func unmeasuredCapabilitiesStayDisabled() {
        let decision = HuenitCameraCapabilityDecision(
            status: .notMeasured,
            supported: [.preview, .artifactUpload],
            unsupportedReasons: [:],
            profile: nil
        )
        #expect(!decision.canPreview)
        #expect(!decision.canUploadArtifacts)
    }
}
