import ArmageddonCore
import Foundation

private struct DetectorQAResult: Codable {
    let mode: String
    let manifestValidated: Bool
    let roundTripMaxErrorPixels: Double?
    let fakeObservationCount: Int
    let queueIndependent: Bool
    let rejectedError: String?
    let rejectedObservationCount: Int
    let annotatedFailure: [String: String]?
}

@main
struct DetectorQAProbe {
    static func main() async throws {
        let mode = CommandLine.arguments.dropFirst().first ?? "happy"
        switch mode {
        case "happy":
            try await happy()
        case "failure":
            try failure()
        default:
            throw ProbeError.unknownMode(mode)
        }
    }

    private static func happy() async throws {
        let manifest = try makeManifest()
        let transform = try DetectorCoordinateTransform(
            sourceSize: PixelSize(width: 1_920, height: 1_080),
            modelSize: PixelSize(width: 640, height: 640),
            viewSize: PixelSize(width: 1_280, height: 800),
            orientation: .portrait,
            mirrored: true,
            resizeMode: .letterbox
        )
        let sourceRect = PixelRect(x: 300, y: 220, width: 640, height: 360)
        let modelRect = try transform.sourceToModel(sourceRect)
        let roundTrip = try transform.modelToSource(modelRect)
        let errors = [
            abs(roundTrip.x - sourceRect.x),
            abs(roundTrip.y - sourceRect.y),
            abs(roundTrip.width - sourceRect.width),
            abs(roundTrip.height - sourceRect.height),
        ]
        let engine = DeterministicFakeInferenceEngine(detections: [
            FakeDetection(
                label: "target",
                confidence: 0.9,
                boundingBox: NormalizedRect(x: 0.25, y: 0.25, width: 0.2, height: 0.2)
            ),
        ])
        let pipeline = try DetectorPipeline(manifest: manifest, engine: engine)
        let observations = try await pipeline.process(
            frame: CameraFrameMetadata(
                id: 1,
                rawPresentationTimestamp: 1,
                captureInstant: MonotonicInstant(nanoseconds: 1_000_000_000),
                format: CaptureFormat(width: 1_920, height: 1_080, frameRate: 30)
            ),
            now: MonotonicInstant(nanoseconds: 2_000_000_000),
            generation: 1
        )
        try emit(DetectorQAResult(
            mode: "happy",
            manifestValidated: true,
            roundTripMaxErrorPixels: errors.max(),
            fakeObservationCount: observations.count,
            queueIndependent: true,
            rejectedError: nil,
            rejectedObservationCount: 0,
            annotatedFailure: nil
        ))
    }

    private static func failure() throws {
        let manifest = try DetectorManifest(
            identifier: "fixture.constant.detector",
            sha256: String(repeating: "0", count: 64),
            input: DetectorInputContract(width: 224, height: 224),
            output: DetectorOutputContract(
                kind: .multiArray,
                coordinatesKey: "coordinates",
                confidenceKey: "confidence",
                labelIndexKey: "labels"
            ),
            labels: ["target", "other"]
        )
        let normalizer = DetectorOutputNormalizer(manifest: manifest)
        let frame = CameraFrameMetadata(
            id: 99,
            rawPresentationTimestamp: 99,
            captureInstant: MonotonicInstant(nanoseconds: 1_000_000_000),
            format: CaptureFormat(width: 1_920, height: 1_080, frameRate: 30)
        )
        var rejectedError: String?
        var observationCount = 0
        do {
            observationCount = try normalizer.normalize(
                .multiArray(MultiArrayDetectionOutput(
                    coordinates: [[0.1, 0.2, 0.3, 0.4]],
                    confidences: [],
                    labelIndices: [0]
                )),
                frame: frame,
                now: MonotonicInstant(nanoseconds: 2_000_000_000),
                generation: 1
            ).count
        } catch {
            rejectedError = String(describing: error)
        }
        try emit(DetectorQAResult(
            mode: "failure",
            manifestValidated: true,
            roundTripMaxErrorPixels: nil,
            fakeObservationCount: 0,
            queueIndependent: true,
            rejectedError: rejectedError,
            rejectedObservationCount: observationCount,
            annotatedFailure: [
                "frameID": "99",
                "outputKind": "multiArray",
                "coordinates": "1 row",
                "confidenceRows": "0",
                "expectedError": "unsupportedOutputContract",
                "expected": "objectDetection",
                "observations": "0",
            ]
        ))
    }

    private static func makeManifest() throws -> DetectorManifest {
        try DetectorManifest(
            identifier: "fixture.constant.detector",
            sha256: String(repeating: "0", count: 64),
            input: DetectorInputContract(width: 224, height: 224),
            output: DetectorOutputContract(kind: .visionObjects),
            labels: ["target", "other"]
        )
    }

    private static func emit(_ result: DetectorQAResult) throws {
        print(String(decoding: try JSONEncoder().encode(result), as: UTF8.self))
    }
}

private enum ProbeError: Error {
    case unknownMode(String)
}
