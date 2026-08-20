import Darwin
import CoreVideo
import CoreML
import Foundation
import ArmageddonCore

@main
struct VisionInferenceQAProbe {
    private struct ObservationReceipt: Codable {
        let label: String
        let confidence: Double
        let frameID: UInt64
        let generation: UInt64
        let coordinateSpace: String
        let boundingBox: [String: Double]
    }

    private struct SchedulerReceipt: Codable {
        let submittedFrames: Int
        let cancellations: Int
        let maximumActiveRequests: Int
        let maximumPendingRequests: Int
        let stalePublications: Int
        let discardedStaleResults: Int
        let finalQueueDepth: Int
    }

    private struct Receipt: Codable {
        let mode: String
        let modelExecutedThroughVision: Bool
        let observations: [ObservationReceipt]
        let cancellationObserved: Bool
        let scheduler: SchedulerReceipt
    }

    static func main() async {
        do {
            let arguments = CommandLine.arguments
            guard arguments.count == 3, arguments[2] == "happy" || arguments[2] == "failure" else {
                throw ProbeError.usage
            }
            let receipt = try await run(
                modelURL: URL(fileURLWithPath: arguments[1]),
                mode: arguments[2]
            )
            let data = try JSONEncoder.sorted.encode(receipt)
            print(String(decoding: data, as: UTF8.self))
        } catch {
            let message = String(describing: error).replacingOccurrences(of: "\"", with: "'")
            print("{\"error\":\"\(message)\"}")
            exit(1)
        }
    }

    private static func run(modelURL: URL, mode: String) async throws -> Receipt {
        let manifest = try fixtureManifest()
        let compiledModelURL = try await MLModel.compileModel(at: modelURL)
        let engine = VisionCoreMLInferenceEngine(computeUnits: .cpuOnly)
        _ = try await engine.load(modelURL: compiledModelURL, identifier: manifest.identifier)
        let frame = try fixtureFrame(id: 41)

        let observations: [ObservationReceipt]
        let cancellationObserved: Bool
        if mode == "happy" {
            let pipeline = try VisionDetectorPipeline(manifest: manifest, engine: engine)
            let values = try await pipeline.process(
                frame: frame,
                now: MonotonicInstant(nanoseconds: 3_000_000_000),
                generation: await engine.currentModelGeneration()
            )
            observations = values.map {
                ObservationReceipt(
                    label: $0.label,
                    confidence: $0.confidence,
                    frameID: $0.frameID,
                    generation: $0.generation,
                    coordinateSpace: $0.coordinateSpace.rawValue,
                    boundingBox: [
                        "x": $0.boundingBox.x,
                        "y": $0.boundingBox.y,
                        "width": $0.boundingBox.width,
                        "height": $0.boundingBox.height,
                    ]
                )
            }
            cancellationObserved = false
        } else {
            let scheduler = LatestVisionInferenceScheduler(
                executor: DelayedEngineExecutor(engine: engine)
            )
            let pending = await scheduler.submit(frame: frame, manifest: manifest)
            try await Task.sleep(nanoseconds: 10_000_000)
            _ = await engine.unloadModel()
            await scheduler.switchSourceOrModel()
            do {
                _ = try await pending.value
                cancellationObserved = false
            } catch is CancellationError {
                cancellationObserved = true
            }
            observations = []
            try await waitForIdle(scheduler)
            let metrics = await scheduler.metrics()
            return Receipt(
                mode: mode,
                modelExecutedThroughVision: true,
                observations: observations,
                cancellationObserved: cancellationObserved,
                scheduler: schedulerReceipt(metrics: metrics, queueDepth: await scheduler.queueDepth())
            )
        }

        let stressScheduler = LatestVisionInferenceScheduler(executor: ImmediateVisionExecutor())
        for id in 1...10_000 {
            let stressFrame = VisionInferenceFrame(
                metadata: CameraFrameMetadata(
                    id: UInt64(id),
                    rawPresentationTimestamp: Double(id),
                    captureInstant: MonotonicInstant(nanoseconds: UInt64(id)),
                    format: frame.metadata.format
                ),
                pixelBuffer: frame.pixelBuffer
            )
            _ = await stressScheduler.submit(frame: stressFrame, manifest: manifest)
        }
        await stressScheduler.cancel()
        try await waitForIdle(stressScheduler)
        let metrics = await stressScheduler.metrics()
        return Receipt(
            mode: mode,
            modelExecutedThroughVision: true,
            observations: observations,
            cancellationObserved: cancellationObserved,
            scheduler: schedulerReceipt(metrics: metrics, queueDepth: await stressScheduler.queueDepth())
        )
    }

    private static func schedulerReceipt(
        metrics: VisionInferenceSchedulerMetrics,
        queueDepth: Int
    ) -> SchedulerReceipt {
        SchedulerReceipt(
            submittedFrames: metrics.submittedFrames,
            cancellations: metrics.cancellations,
            maximumActiveRequests: metrics.maximumActiveRequests,
            maximumPendingRequests: metrics.maximumPendingRequests,
            stalePublications: metrics.stalePublications,
            discardedStaleResults: metrics.discardedStaleResults,
            finalQueueDepth: queueDepth
        )
    }

    private static func waitForIdle(_ scheduler: LatestVisionInferenceScheduler) async throws {
        for _ in 0..<500 {
            if await scheduler.queueDepth() == 0 { return }
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        throw ProbeError.schedulerDidNotDrain
    }

    private static func fixtureManifest() throws -> DetectorManifest {
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

    private static func fixtureFrame(id: UInt64) throws -> VisionInferenceFrame {
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

private enum ProbeError: Error {
    case usage
    case schedulerDidNotDrain
}

private struct ImmediateVisionExecutor: VisionInferenceExecutor {
    func currentModelGeneration() async -> UInt64 { 1 }

    func infer(
        frame: VisionInferenceFrame,
        manifest: DetectorManifest,
        generation: UInt64
    ) async throws -> DetectorRawOutput {
        try Task.checkCancellation()
        return .visionObjects([])
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

private extension JSONEncoder {
    static var sorted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}
