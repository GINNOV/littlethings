import CoreVideo
import CoreML
import Foundation
import Testing
@testable import ArmageddonCore

@Suite(.serialized)
struct VisionInferenceIntegrationTests {
    @Test("constant model output is normalized, thresholded, and suppressed")
    func constantModel() async throws {
        let manifest = try fixtureManifest()
        let modelURL = try #require(
            Bundle.module.url(
                forResource: "constant-detector",
                withExtension: "mlmodel",
                subdirectory: "Fixtures"
            )
        )
        let engine = VisionCoreMLInferenceEngine(computeUnits: .cpuOnly)
        let compiledModelURL = try await MLModel.compileModel(at: modelURL)
        let modelGeneration = try await engine.load(
            modelURL: compiledModelURL,
            identifier: manifest.identifier
        )
        let pipeline = try VisionDetectorPipeline(
            manifest: manifest,
            engine: engine
        )
        let frame = try fixtureFrame(id: 41)

        let observations = try await pipeline.process(
            frame: frame,
            now: MonotonicInstant(nanoseconds: 3_000_000_000),
            generation: modelGeneration
        )

        #expect(observations.count == 1)
        #expect(observations.first?.label == "target")
        #expect(abs((observations.first?.confidence ?? 0) - 0.91) < 0.001)
        #expect(observations.first?.frameID == 41)
        #expect(observations.first?.generation == modelGeneration)
        #expect(observations.first?.coordinateSpace == .modelImage)
        if let boundingBox = observations.first?.boundingBox {
            #expect(abs(boundingBox.x - 0.1) < 0.001)
            #expect(abs(boundingBox.y - 0.2) < 0.001)
            #expect(abs(boundingBox.width - 0.3) < 0.001)
            #expect(abs(boundingBox.height - 0.4) < 0.001)
        } else {
            Issue.record("Expected the constant model to publish a bounding box")
        }

        let scheduler = LatestVisionInferenceScheduler(executor: engine)
        let first = await scheduler.submit(frame: frame, manifest: manifest)
        let second = await scheduler.submit(frame: try fixtureFrame(id: 42), manifest: manifest)
        let secondResult = try await second.value
        #expect(secondResult.frameID == 42)
        #expect(secondResult.generation == 2)
        do {
            _ = try await first.value
        } catch is CancellationError {
        } catch {
            Issue.record("Expected the superseded production request to cancel, got \(error)")
        }
    }

    @Test("unload or source change cancels in-flight inference without stale publication")
    func unloadMidRequest() async throws {
        let manifest = try fixtureManifest()
        let modelURL = try #require(
            Bundle.module.url(
                forResource: "constant-detector",
                withExtension: "mlmodel",
                subdirectory: "Fixtures"
            )
        )
        let engine = VisionCoreMLInferenceEngine(computeUnits: .cpuOnly)
        let compiledModelURL = try await MLModel.compileModel(at: modelURL)
        _ = try await engine.load(modelURL: compiledModelURL, identifier: manifest.identifier)
        let scheduler = LatestVisionInferenceScheduler(
            executor: DelayedEngineExecutor(engine: engine)
        )
        let pending = await scheduler.submit(
            frame: try fixtureFrame(id: 42),
            manifest: manifest
        )

        try await Task.sleep(nanoseconds: 10_000_000)
        _ = await engine.unloadModel()
        await scheduler.switchSourceOrModel()

        var cancelled = false
        do {
            _ = try await pending.value
            Issue.record("Expected the unloaded model request to produce no result")
        } catch is CancellationError {
            cancelled = true
        } catch {
            Issue.record("Expected cancellation, got \(String(describing: error))")
        }
        while await scheduler.queueDepth() > 0 {
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        let metrics = await scheduler.metrics()
        #expect(cancelled)
        #expect(await scheduler.generation() == 2)
        #expect(metrics.maximumActiveRequests == 1)
        #expect(metrics.stalePublications == 0)
    }

    private func fixtureManifest() throws -> DetectorManifest {
        try DetectorManifest(
            identifier: "constant.detector",
            sha256: String(repeating: "b", count: 64),
            input: DetectorInputContract(width: 16, height: 16),
            output: DetectorOutputContract(
                kind: .multiArray,
                coordinatesKey: "coordinates",
                confidenceKey: "confidences",
                labelIndexKey: "labels"
            ),
            labels: ["target"],
            confidenceThreshold: 0.5,
            nmsIoUThreshold: 0.5
        )
    }

    private func fixtureFrame(id: UInt64) throws -> VisionInferenceFrame {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            16,
            16,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw VisionInferenceError.invalidFrame
        }
        return VisionInferenceFrame(
            metadata: CameraFrameMetadata(
                id: id,
                rawPresentationTimestamp: Double(id),
                captureInstant: MonotonicInstant(nanoseconds: 1_000_000_000),
                format: CaptureFormat(
                    width: 16,
                    height: 16,
                    frameRate: 30,
                    orientation: .portrait,
                    mirrored: true
                )
            ),
            pixelBuffer: pixelBuffer
        )
    }
}

private struct DelayedEngineExecutor: VisionInferenceExecutor {
    let engine: VisionCoreMLInferenceEngine

    func currentModelGeneration() async -> UInt64 {
        await engine.currentModelGeneration()
    }

    func infer(
        frame: VisionInferenceFrame,
        manifest: DetectorManifest,
        generation: UInt64
    ) async throws -> DetectorRawOutput {
        try await Task.sleep(nanoseconds: 200_000_000)
        return try await engine.infer(frame: frame, manifest: manifest, generation: generation)
    }
}
