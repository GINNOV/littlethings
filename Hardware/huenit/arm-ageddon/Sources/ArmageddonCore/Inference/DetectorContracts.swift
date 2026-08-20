import Foundation

public enum DetectorKind: String, Codable, Equatable, Sendable {
    case objectDetection
}

public enum DetectorInputKind: String, Codable, Equatable, Sendable {
    case image
}

public struct DetectorInputContract: Codable, Equatable, Sendable {
    public let kind: DetectorInputKind
    public let width: Int
    public let height: Int

    public init(kind: DetectorInputKind = .image, width: Int, height: Int) {
        self.kind = kind
        self.width = width
        self.height = height
    }
}

public enum DetectorOutputKind: String, Codable, Equatable, Sendable {
    case visionObjects
    case multiArray
}

public struct DetectorOutputContract: Codable, Equatable, Sendable {
    public let kind: DetectorOutputKind
    public let coordinatesKey: String?
    public let confidenceKey: String?
    public let labelIndexKey: String?

    public init(
        kind: DetectorOutputKind,
        coordinatesKey: String? = nil,
        confidenceKey: String? = nil,
        labelIndexKey: String? = nil
    ) {
        self.kind = kind
        self.coordinatesKey = coordinatesKey
        self.confidenceKey = confidenceKey
        self.labelIndexKey = labelIndexKey
    }
}

public enum DetectorManifestError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion
    case emptyIdentifier
    case invalidHash
    case unsupportedDetectorKind
    case unsupportedInput
    case invalidInputDimensions
    case invalidOutputContract
    case emptyLabels
    case duplicateLabel
    case invalidThreshold
}

public struct DetectorManifest: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let identifier: String
    public let sha256: String
    public let kind: DetectorKind
    public let input: DetectorInputContract
    public let output: DetectorOutputContract
    public let labels: [String]
    public let confidenceThreshold: Double
    public let nmsIoUThreshold: Double

    public init(
        schemaVersion: Int = 1,
        identifier: String,
        sha256: String,
        kind: DetectorKind = .objectDetection,
        input: DetectorInputContract,
        output: DetectorOutputContract,
        labels: [String],
        confidenceThreshold: Double = 0.5,
        nmsIoUThreshold: Double = 0.5
    ) throws {
        self.schemaVersion = schemaVersion
        self.identifier = identifier
        self.sha256 = sha256
        self.kind = kind
        self.input = input
        self.output = output
        self.labels = labels
        self.confidenceThreshold = confidenceThreshold
        self.nmsIoUThreshold = nmsIoUThreshold
        try validate()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            schemaVersion: container.decode(Int.self, forKey: .schemaVersion),
            identifier: container.decode(String.self, forKey: .identifier),
            sha256: container.decode(String.self, forKey: .sha256),
            kind: container.decode(DetectorKind.self, forKey: .kind),
            input: container.decode(DetectorInputContract.self, forKey: .input),
            output: container.decode(DetectorOutputContract.self, forKey: .output),
            labels: container.decode([String].self, forKey: .labels),
            confidenceThreshold: container.decodeIfPresent(Double.self, forKey: .confidenceThreshold) ?? 0.5,
            nmsIoUThreshold: container.decodeIfPresent(Double.self, forKey: .nmsIoUThreshold) ?? 0.5
        )
    }

    public func validate() throws {
        guard schemaVersion == 1 else { throw DetectorManifestError.unsupportedSchemaVersion }
        guard !identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DetectorManifestError.emptyIdentifier
        }
        let hash = sha256.lowercased()
        guard hash.count == 64,
              hash.allSatisfy({ $0.isHexDigit }) else {
            throw DetectorManifestError.invalidHash
        }
        guard kind == .objectDetection else { throw DetectorManifestError.unsupportedDetectorKind }
        guard input.kind == .image else { throw DetectorManifestError.unsupportedInput }
        guard input.width > 0, input.height > 0 else {
            throw DetectorManifestError.invalidInputDimensions
        }
        switch output.kind {
        case .visionObjects:
            guard output.coordinatesKey == nil,
                  output.confidenceKey == nil,
                  output.labelIndexKey == nil else {
                throw DetectorManifestError.invalidOutputContract
            }
        case .multiArray:
            guard let coordinatesKey = output.coordinatesKey,
                  let confidenceKey = output.confidenceKey,
                  !coordinatesKey.isEmpty,
                  !confidenceKey.isEmpty else {
                throw DetectorManifestError.invalidOutputContract
            }
        }
        guard !labels.isEmpty,
              labels.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }),
              Set(labels).count == labels.count else {
            throw labels.isEmpty ? DetectorManifestError.emptyLabels : DetectorManifestError.duplicateLabel
        }
        guard confidenceThreshold.isFinite, (0...1).contains(confidenceThreshold),
              nmsIoUThreshold.isFinite, (0...1).contains(nmsIoUThreshold) else {
            throw DetectorManifestError.invalidThreshold
        }
    }
}

public struct NormalizedRect: Codable, Equatable, Sendable {
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

    public var isUnitBounded: Bool {
        isFinite && x >= 0 && y >= 0 && width >= 0 && height >= 0 && maxX <= 1 && maxY <= 1
    }

    public func intersectionOverUnion(with other: Self) -> Double {
        let left = max(x, other.x)
        let top = max(y, other.y)
        let right = min(maxX, other.maxX)
        let bottom = min(maxY, other.maxY)
        let intersection = max(0, right - left) * max(0, bottom - top)
        let union = width * height + other.width * other.height - intersection
        return union > 0 ? intersection / union : 0
    }
}

public struct DetectionObservation: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let frameID: UInt64
    public let generation: UInt64
    public let captureInstant: MonotonicInstant
    public let label: String
    public let confidence: Double
    public let boundingBox: NormalizedRect

    public init(
        id: String,
        frameID: UInt64,
        generation: UInt64,
        captureInstant: MonotonicInstant,
        label: String,
        confidence: Double,
        boundingBox: NormalizedRect
    ) {
        self.id = id
        self.frameID = frameID
        self.generation = generation
        self.captureInstant = captureInstant
        self.label = label
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

public struct VisionDetectionOutput: Sendable, Equatable {
    public let label: String
    public let confidence: Double
    public let boundingBox: NormalizedRect

    public init(label: String, confidence: Double, boundingBox: NormalizedRect) {
        self.label = label
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

public struct MultiArrayDetectionOutput: Sendable, Equatable {
    public let coordinates: [[Double]]
    public let confidences: [Double]
    public let labelIndices: [Int]

    public init(coordinates: [[Double]], confidences: [Double], labelIndices: [Int]) {
        self.coordinates = coordinates
        self.confidences = confidences
        self.labelIndices = labelIndices
    }
}

public enum DetectorRawOutput: Sendable, Equatable {
    case visionObjects([VisionDetectionOutput])
    case multiArray(MultiArrayDetectionOutput)
    case classification
    case segmentation
    case unknown
}

public enum DetectionValidationError: Error, Equatable, Sendable {
    case unsupportedOutputContract
    case malformedMultiArray
    case unknownLabel
    case invalidCoordinates
    case invalidConfidence
    case staleFrame
    case staleGeneration
    case timestampMismatch
    case futureCapture
    case negativeAge
}

public protocol InferenceEngine: Sendable {
    func infer(
        frame: CameraFrameMetadata,
        manifest: DetectorManifest,
        generation: UInt64
    ) async throws -> DetectorRawOutput
}

public struct DetectorOutputNormalizer: Sendable {
    public let manifest: DetectorManifest

    public init(manifest: DetectorManifest) {
        self.manifest = manifest
    }

    public func normalize(
        _ rawOutput: DetectorRawOutput,
        frame: CameraFrameMetadata,
        now: MonotonicInstant,
        generation: UInt64
    ) throws -> [DetectionObservation] {
        guard frame.captureInstant <= now else { throw DetectionValidationError.futureCapture }
        let observations: [DetectionObservation]
        switch rawOutput {
        case let .visionObjects(outputs):
            guard manifest.output.kind == .visionObjects else {
                throw DetectionValidationError.unsupportedOutputContract
            }
            observations = outputs.enumerated().map { index, output in
                DetectionObservation(
                    id: "\(frame.id)-\(index)",
                    frameID: frame.id,
                    generation: generation,
                    captureInstant: frame.captureInstant,
                    label: output.label,
                    confidence: output.confidence,
                    boundingBox: output.boundingBox
                )
            }
        case let .multiArray(output):
            guard manifest.output.kind == .multiArray,
                  output.coordinates.count == output.confidences.count,
                  output.coordinates.count == output.labelIndices.count else {
                throw DetectionValidationError.malformedMultiArray
            }
            observations = try output.coordinates.enumerated().map { index, coordinates in
                guard coordinates.count == 4,
                      coordinates.allSatisfy(\.isFinite) else {
                    throw DetectionValidationError.invalidCoordinates
                }
                return DetectionObservation(
                    id: "\(frame.id)-\(index)",
                    frameID: frame.id,
                    generation: generation,
                    captureInstant: frame.captureInstant,
                    label: try label(at: output.labelIndices[index]),
                    confidence: output.confidences[index],
                    boundingBox: NormalizedRect(
                        x: coordinates[0],
                        y: coordinates[1],
                        width: coordinates[2],
                        height: coordinates[3]
                    )
                )
            }
        case .classification, .segmentation, .unknown:
            throw DetectionValidationError.unsupportedOutputContract
        }

        for observation in observations {
            try validate(observation, frame: frame, now: now, generation: generation)
        }
        return observations
    }

    public func validate(
        _ observation: DetectionObservation,
        frame: CameraFrameMetadata,
        now: MonotonicInstant,
        generation: UInt64
    ) throws {
        guard observation.frameID == frame.id else { throw DetectionValidationError.staleFrame }
        guard observation.generation == generation else { throw DetectionValidationError.staleGeneration }
        guard observation.captureInstant == frame.captureInstant else {
            throw DetectionValidationError.timestampMismatch
        }
        guard observation.captureInstant <= now else { throw DetectionValidationError.negativeAge }
        guard manifest.labels.contains(observation.label) else { throw DetectionValidationError.unknownLabel }
        guard observation.confidence.isFinite,
              (0...1).contains(observation.confidence) else {
            throw DetectionValidationError.invalidConfidence
        }
        guard observation.boundingBox.isUnitBounded else {
            throw DetectionValidationError.invalidCoordinates
        }
    }

    private func label(at index: Int) throws -> String {
        guard manifest.labels.indices.contains(index) else {
            throw DetectionValidationError.unknownLabel
        }
        return manifest.labels[index]
    }
}

public actor DetectorPipeline {
    private let manifest: DetectorManifest
    private let engine: any InferenceEngine
    private let normalizer: DetectorOutputNormalizer
    private var lastFrameID: UInt64?

    public init(manifest: DetectorManifest, engine: any InferenceEngine) {
        self.manifest = manifest
        self.engine = engine
        normalizer = DetectorOutputNormalizer(manifest: manifest)
    }

    public func process(
        frame: CameraFrameMetadata,
        now: MonotonicInstant,
        generation: UInt64
    ) async throws -> [DetectionObservation] {
        if let lastFrameID, frame.id <= lastFrameID {
            throw DetectionValidationError.staleFrame
        }
        let rawOutput = try await engine.infer(frame: frame, manifest: manifest, generation: generation)
        let observations = try normalizer.normalize(
            rawOutput,
            frame: frame,
            now: now,
            generation: generation
        )
        lastFrameID = frame.id
        return observations
    }

    public func reset() {
        lastFrameID = nil
    }
}

public struct FakeDetection: Sendable, Equatable {
    public let label: String
    public let confidence: Double
    public let boundingBox: NormalizedRect

    public init(label: String, confidence: Double, boundingBox: NormalizedRect) {
        self.label = label
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

public struct DeterministicFakeInferenceEngine: InferenceEngine {
    public let detections: [FakeDetection]

    public init(detections: [FakeDetection]) {
        self.detections = detections
    }

    public func infer(
        frame: CameraFrameMetadata,
        manifest: DetectorManifest,
        generation: UInt64
    ) async throws -> DetectorRawOutput {
        switch manifest.output.kind {
        case .visionObjects:
            return .visionObjects(detections.map {
                VisionDetectionOutput(label: $0.label, confidence: $0.confidence, boundingBox: $0.boundingBox)
            })
        case .multiArray:
            return .multiArray(MultiArrayDetectionOutput(
                coordinates: detections.map { [$0.boundingBox.x, $0.boundingBox.y, $0.boundingBox.width, $0.boundingBox.height] },
                confidences: detections.map(\.confidence),
                labelIndices: detections.map { manifest.labels.firstIndex(of: $0.label) ?? -1 }
            ))
        }
    }
}

public struct NMSPolicy: Codable, Equatable, Sendable {
    public let confidenceThreshold: Double
    public let iouThreshold: Double

    public init(confidenceThreshold: Double, iouThreshold: Double) throws {
        guard confidenceThreshold.isFinite, (0...1).contains(confidenceThreshold),
              iouThreshold.isFinite, (0...1).contains(iouThreshold) else {
            throw DetectorManifestError.invalidThreshold
        }
        self.confidenceThreshold = confidenceThreshold
        self.iouThreshold = iouThreshold
    }
}

public enum DetectionFiltering {
    public static func thresholdAndSuppress(
        _ observations: [DetectionObservation],
        policy: NMSPolicy
    ) -> [DetectionObservation] {
        let candidates = observations
            .filter { $0.confidence >= policy.confidenceThreshold }
            .sorted {
                if $0.confidence == $1.confidence { return $0.id < $1.id }
                return $0.confidence > $1.confidence
            }
        var kept: [DetectionObservation] = []
        for candidate in candidates {
            let overlapsSameLabel = kept.contains {
                $0.label == candidate.label
                    && $0.boundingBox.intersectionOverUnion(with: candidate.boundingBox) > policy.iouThreshold
            }
            if !overlapsSameLabel { kept.append(candidate) }
        }
        return kept
    }
}
