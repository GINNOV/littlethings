import CoreVideo
import Foundation
import Testing
@testable import ArmageddonCore

@Suite(.serialized)
struct VisionInferenceSchedulerTests {
    @Test("Latest-frame scheduler cancels superseded work and publishes only the newest generation")
    func latestFrameWins() async throws {
        let scheduler = LatestVisionInferenceScheduler(executor: DelayedVisionExecutor(delayNanoseconds: 40_000_000))
        let manifest = try fixtureManifest()
        let first = await scheduler.submit(frame: try fixtureFrame(id: 1), manifest: manifest)
        let second = await scheduler.submit(frame: try fixtureFrame(id: 2), manifest: manifest)
        let result = try await second.value

        #expect(result.frameID == 2)
        #expect(result.generation == 2)
        #expect(result.output == .visionObjects([]))
        await expectCancellation(first)
        #expect(await scheduler.generation() == 2)
    }

    @Test("Source or model changes cancel the pending request and advance generation")
    func sourceSwitchCancels() async throws {
        let scheduler = LatestVisionInferenceScheduler(executor: DelayedVisionExecutor(delayNanoseconds: 200_000_000))
        let manifest = try fixtureManifest()
        let pending = await scheduler.submit(frame: try fixtureFrame(id: 7), manifest: manifest)
        await scheduler.switchSourceOrModel()
        await expectCancellation(pending)
        #expect(await scheduler.generation() == 2)
    }

    @Test("10,000 submitted frames never create a request queue deeper than one")
    func tenThousandFramesKeepQueueDepthOne() async throws {
        let scheduler = LatestVisionInferenceScheduler(
            executor: DelayedVisionExecutor(delayNanoseconds: 1_000_000)
        )
        let manifest = try fixtureManifest()
        let template = try fixtureFrame(id: 0)
        var maximumDepth = 0

        for id in 1...10_000 {
            let frame = VisionInferenceFrame(
                metadata: CameraFrameMetadata(
                    id: UInt64(id),
                    rawPresentationTimestamp: Double(id),
                    captureInstant: MonotonicInstant(nanoseconds: UInt64(id)),
                    format: template.metadata.format
                ),
                pixelBuffer: template.pixelBuffer
            )
            _ = await scheduler.submit(frame: frame, manifest: manifest)
            maximumDepth = max(maximumDepth, await scheduler.queueDepth())
        }

        await scheduler.cancel()
        while await scheduler.queueDepth() > 0 {
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        let metrics = await scheduler.metrics()
        #expect(maximumDepth == 1)
        #expect(await scheduler.queueDepth() == 0)
        #expect(await scheduler.generation() == 10_001)
        #expect(metrics.submittedFrames == 10_000)
        #expect(metrics.maximumActiveRequests == 1)
        #expect(metrics.maximumPendingRequests == 1)
        #expect(metrics.stalePublications == 0)
    }

    private func fixtureManifest() throws -> DetectorManifest {
        try DetectorManifest(
            identifier: "fixture.detector",
            sha256: String(repeating: "a", count: 64),
            input: DetectorInputContract(width: 16, height: 16),
            output: DetectorOutputContract(kind: .visionObjects),
            labels: ["target"]
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
                captureInstant: MonotonicInstant(nanoseconds: id),
                format: CaptureFormat(width: 16, height: 16, frameRate: 30)
            ),
            pixelBuffer: pixelBuffer
        )
    }

    private func expectCancellation(_ task: Task<VisionInferenceResult, Error>) async {
        do {
            _ = try await task.value
            Issue.record("Expected the superseded inference task to cancel")
        } catch is CancellationError {
        } catch {
            Issue.record("Expected cancellation, got \(error)")
        }
    }
}

private struct DelayedVisionExecutor: VisionInferenceExecutor {
    let delayNanoseconds: UInt64

    func currentModelGeneration() async -> UInt64 { 1 }

    func infer(
        frame: VisionInferenceFrame,
        manifest: DetectorManifest,
        generation: UInt64
    ) async throws -> DetectorRawOutput {
        try await Task.sleep(nanoseconds: delayNanoseconds)
        try Task.checkCancellation()
        return .visionObjects([])
    }
}
