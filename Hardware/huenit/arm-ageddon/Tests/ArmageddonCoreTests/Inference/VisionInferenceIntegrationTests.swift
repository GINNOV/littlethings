import CoreVideo
import Foundation
import Testing
@testable import ArmageddonCore

@Suite(.serialized)
struct VisionInferenceIntegrationTests {
    @Test("constant model output is normalized, thresholded, and suppressed")
    func constantModel() async throws {
        let manifest = try fixtureManifest()
        let pipeline = try VisionDetectorPipeline(
            manifest: manifest,
            engine: ConstantVisionExecutor()
        )
        let frame = try fixtureFrame(id: 41)

        let observations = try await pipeline.process(
            frame: frame,
            now: MonotonicInstant(nanoseconds: 3_000_000_000),
            generation: 9
        )

        #expect(observations.count == 1)
        #expect(observations.first?.label == "target")
        #expect(observations.first?.confidence == 0.91)
        #expect(observations.first?.frameID == 41)
        #expect(observations.first?.generation == 9)
        #expect(observations.first?.coordinateSpace == .orientedImage)
    }

    @Test("unload or source change cancels in-flight inference without stale publication")
    func unloadMidRequest() async throws {
        let scheduler = LatestVisionInferenceScheduler(
            executor: CancellableVisionExecutor()
        )
        let manifest = try fixtureManifest()
        let pending = await scheduler.submit(
            frame: try fixtureFrame(id: 42),
            manifest: manifest
        )

        await scheduler.switchSourceOrModel()

        do {
            _ = try await pending.value
            Issue.record("Expected the unloaded model request to be cancelled")
        } catch is CancellationError {
        } catch {
            Issue.record("Expected cancellation, got \(error)")
        }
        #expect(await scheduler.generation() == 2)
    }

    private func fixtureManifest() throws -> DetectorManifest {
        try DetectorManifest(
            identifier: "constant.detector",
            sha256: String(repeating: "b", count: 64),
            input: DetectorInputContract(width: 16, height: 16),
            output: DetectorOutputContract(kind: .visionObjects),
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
                format: CaptureFormat(width: 16, height: 16, frameRate: 30)
            ),
            pixelBuffer: pixelBuffer
        )
    }
}

private struct ConstantVisionExecutor: VisionInferenceExecutor {
    func infer(
        frame: VisionInferenceFrame,
        manifest: DetectorManifest,
        generation: UInt64
    ) async throws -> DetectorRawOutput {
        .visionObjects([
            VisionDetectionOutput(
                label: "target",
                confidence: 0.91,
                boundingBox: NormalizedRect(x: 0.1, y: 0.1, width: 0.3, height: 0.3)
            ),
            VisionDetectionOutput(
                label: "target",
                confidence: 0.76,
                boundingBox: NormalizedRect(x: 0.12, y: 0.12, width: 0.3, height: 0.3)
            ),
            VisionDetectionOutput(
                label: "target",
                confidence: 0.24,
                boundingBox: NormalizedRect(x: 0.6, y: 0.6, width: 0.2, height: 0.2)
            )
        ])
    }
}

private struct CancellableVisionExecutor: VisionInferenceExecutor {
    func infer(
        frame: VisionInferenceFrame,
        manifest: DetectorManifest,
        generation: UInt64
    ) async throws -> DetectorRawOutput {
        try await Task.sleep(nanoseconds: 200_000_000)
        try Task.checkCancellation()
        return .visionObjects([])
    }
}
