import CoreML
import CoreVideo
import Foundation
import ImageIO
import Vision

public enum VisionComputeUnits: String, Codable, CaseIterable, Equatable, Sendable {
    case all
    case cpuOnly
    case cpuAndGPU
    case cpuAndNeuralEngine

    fileprivate var coreMLValue: MLComputeUnits {
        switch self {
        case .all: .all
        case .cpuOnly: .cpuOnly
        case .cpuAndGPU: .cpuAndGPU
        case .cpuAndNeuralEngine: .cpuAndNeuralEngine
        }
    }
}

public enum VisionInferenceError: Error, Equatable, Sendable {
    case modelUnavailable
    case staleGeneration
    case invalidFrame
    case unsupportedInput
    case unsupportedOutput
    case predictionFailed
    case malformedOutput
}

public struct VisionInferenceFrame: @unchecked Sendable {
    public let metadata: CameraFrameMetadata
    public let pixelBuffer: CVPixelBuffer

    public init(metadata: CameraFrameMetadata, pixelBuffer: CVPixelBuffer) {
        self.metadata = metadata
        self.pixelBuffer = pixelBuffer
    }
}

public protocol VisionInferenceExecutor: Sendable {
    func infer(
        frame: VisionInferenceFrame,
        manifest: DetectorManifest,
        generation: UInt64
    ) async throws -> DetectorRawOutput
}

public struct VisionInferenceResult: Sendable, Equatable {
    public let frameID: UInt64
    public let generation: UInt64
    public let output: DetectorRawOutput

    public init(frameID: UInt64, generation: UInt64, output: DetectorRawOutput) {
        self.frameID = frameID
        self.generation = generation
        self.output = output
    }
}

public actor VisionCoreMLInferenceEngine: VisionInferenceExecutor {
    private var model: MLModel?
    private var modelIdentifier: String?
    private var modelGeneration: UInt64 = 0
    private let computeUnits: VisionComputeUnits

    public init(computeUnits: VisionComputeUnits = .all) {
        self.computeUnits = computeUnits
    }

    @discardableResult
    public func load(modelURL: URL, identifier: String) throws -> UInt64 {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = computeUnits.coreMLValue
        model = try MLModel(contentsOf: modelURL, configuration: configuration)
        modelIdentifier = identifier
        modelGeneration &+= 1
        return modelGeneration
    }

    @discardableResult
    public func unloadModel() -> UInt64 {
        model = nil
        modelIdentifier = nil
        modelGeneration &+= 1
        return modelGeneration
    }

    public func loadedModelIdentifier() -> String? {
        modelIdentifier
    }

    public func generation() -> UInt64 {
        modelGeneration
    }

    public func infer(
        frame: VisionInferenceFrame,
        manifest: DetectorManifest,
        generation: UInt64
    ) async throws -> DetectorRawOutput {
        try Task.checkCancellation()
        guard let model else { throw VisionInferenceError.modelUnavailable }
        guard generation == modelGeneration else { throw VisionInferenceError.staleGeneration }
        let format = frame.metadata.format
        guard format.isValid,
              CVPixelBufferGetWidth(frame.pixelBuffer) == format.width,
              CVPixelBufferGetHeight(frame.pixelBuffer) == format.height else {
            throw VisionInferenceError.invalidFrame
        }
        guard manifest.input.kind == .image else { throw VisionInferenceError.unsupportedInput }

        do {
            let visionModel = try VNCoreMLModel(for: model)
            var output: DetectorRawOutput?
            var outputError: VisionInferenceError?
            let request = VNCoreMLRequest(model: visionModel) { request, requestError in
                if requestError != nil {
                    outputError = .predictionFailed
                    return
                }
                do {
                    output = try Self.rawOutput(from: request, manifest: manifest, frame: frame.metadata)
                } catch let error as VisionInferenceError {
                    outputError = error
                } catch {
                    outputError = .malformedOutput
                }
            }
            request.imageCropAndScaleOption = .scaleFill
            let handler = VNImageRequestHandler(
                cvPixelBuffer: frame.pixelBuffer,
                orientation: Self.imageOrientation(for: format),
                options: [:]
            )
            try handler.perform([request])
            try Task.checkCancellation()
            guard generation == modelGeneration else { throw VisionInferenceError.staleGeneration }
            if let outputError { throw outputError }
            guard let output else { throw VisionInferenceError.malformedOutput }
            return output
        } catch let error as VisionInferenceError {
            throw error
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw VisionInferenceError.predictionFailed
        }
    }

    private static func rawOutput(
        from request: VNRequest,
        manifest: DetectorManifest,
        frame: CameraFrameMetadata
    ) throws -> DetectorRawOutput {
        switch manifest.output.kind {
        case .visionObjects:
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                throw VisionInferenceError.unsupportedOutput
            }
            let outputs = results.enumerated().compactMap { index, observation -> VisionDetectionOutput? in
                guard let label = observation.labels.first else { return nil }
                let box = observation.boundingBox
                return VisionDetectionOutput(
                    label: label.identifier,
                    confidence: Double(label.confidence),
                    boundingBox: NormalizedRect(
                        x: box.origin.x,
                        y: 1 - box.origin.y - box.height,
                        width: box.width,
                        height: box.height
                    )
                )
            }
            return .visionObjects(outputs)
        case .multiArray:
            guard let results = request.results as? [VNCoreMLFeatureValueObservation] else {
                throw VisionInferenceError.unsupportedOutput
            }
            let features = Dictionary(uniqueKeysWithValues: results.compactMap { result in
                result.featureValue.multiArrayValue.map { (result.featureName, $0) }
            })
            guard let coordinatesKey = manifest.output.coordinatesKey,
                  let confidenceKey = manifest.output.confidenceKey,
                  let coordinates = features[coordinatesKey],
                  let confidences = features[confidenceKey] else {
                throw VisionInferenceError.malformedOutput
            }
            let coordinateValues = scalarValues(coordinates)
            guard coordinates.shape.count == 2,
                  coordinates.shape[1].intValue == 4,
                  coordinateValues.count % 4 == 0 else {
                throw VisionInferenceError.malformedOutput
            }
            let rows = stride(from: 0, to: coordinateValues.count, by: 4).map {
                Array(coordinateValues[$0..<$0 + 4])
            }
            let confidenceValues = scalarValues(confidences)
            guard confidenceValues.count == rows.count else { throw VisionInferenceError.malformedOutput }
            let labelIndices: [Int]
            if let labelKey = manifest.output.labelIndexKey, let labels = features[labelKey] {
                labelIndices = scalarValues(labels).map(Int.init)
            } else {
                labelIndices = Array(repeating: 0, count: rows.count)
            }
            guard labelIndices.count == rows.count else { throw VisionInferenceError.malformedOutput }
            return .multiArray(
                MultiArrayDetectionOutput(
                    coordinates: rows,
                    confidences: confidenceValues,
                    labelIndices: labelIndices
                )
            )
        }
    }

    private static func scalarValues(_ array: MLMultiArray) -> [Double] {
        (0..<array.count).map { array[$0].doubleValue }
    }

    private static func imageOrientation(for format: CaptureFormat) -> CGImagePropertyOrientation {
        let base: CGImagePropertyOrientation = switch format.orientation {
        case .portrait: .right
        case .portraitUpsideDown: .left
        case .landscapeLeft: .down
        case .landscapeRight, .unknown: .up
        }
        guard format.mirrored else { return base }
        let mirrored: CGImagePropertyOrientation = switch base {
        case .up: .upMirrored
        case .down: .downMirrored
        case .left: .leftMirrored
        case .right: .rightMirrored
        default: base
        }
        return mirrored
    }
}

public actor VisionDetectorPipeline {
    private let manifest: DetectorManifest
    private let engine: any VisionInferenceExecutor
    private let normalizer: DetectorOutputNormalizer
    private let nmsPolicy: NMSPolicy
    private var lastFrameID: UInt64?

    public init(manifest: DetectorManifest, engine: any VisionInferenceExecutor) throws {
        self.manifest = manifest
        self.engine = engine
        normalizer = DetectorOutputNormalizer(manifest: manifest)
        nmsPolicy = try NMSPolicy(
            confidenceThreshold: manifest.confidenceThreshold,
            iouThreshold: manifest.nmsIoUThreshold
        )
    }

    public func process(
        frame: VisionInferenceFrame,
        now: MonotonicInstant,
        generation: UInt64
    ) async throws -> [DetectionObservation] {
        if let lastFrameID, frame.metadata.id <= lastFrameID {
            throw DetectionValidationError.staleFrame
        }
        let rawOutput = try await engine.infer(
            frame: frame,
            manifest: manifest,
            generation: generation
        )
        let observations = try normalizer.normalize(
            rawOutput,
            frame: frame.metadata,
            now: now,
            generation: generation
        )
        lastFrameID = frame.metadata.id
        return DetectionFiltering.thresholdAndSuppress(observations, policy: nmsPolicy)
    }

    public func reset() {
        lastFrameID = nil
    }
}

public actor LatestVisionInferenceScheduler {
    private let executor: any VisionInferenceExecutor
    private var currentTask: Task<VisionInferenceResult, Error>?
    private var currentGeneration: UInt64 = 0

    public init(executor: any VisionInferenceExecutor) {
        self.executor = executor
    }

    public func submit(
        frame: VisionInferenceFrame,
        manifest: DetectorManifest
    ) -> Task<VisionInferenceResult, Error> {
        currentTask?.cancel()
        currentGeneration &+= 1
        let generation = currentGeneration
        let executor = self.executor
        let task = Task.detached {
            try Task.checkCancellation()
            let output = try await executor.infer(frame: frame, manifest: manifest, generation: generation)
            try Task.checkCancellation()
            return VisionInferenceResult(frameID: frame.metadata.id, generation: generation, output: output)
        }
        currentTask = task
        return task
    }

    public func cancel() {
        currentTask?.cancel()
        currentTask = nil
        currentGeneration &+= 1
    }

    public func switchSourceOrModel() {
        cancel()
    }

    public func generation() -> UInt64 {
        currentGeneration
    }

    public func queueDepth() -> Int {
        currentTask == nil ? 0 : 1
    }
}
