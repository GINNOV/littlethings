import Testing
@testable import ArmageddonCore

struct DetectorContractTests {
    private let hash = String(repeating: "a", count: 64)

    private func manifest(output: DetectorOutputContract = DetectorOutputContract(kind: .visionObjects)) throws -> DetectorManifest {
        try DetectorManifest(
            identifier: "fixture.constant.detector",
            sha256: hash,
            input: DetectorInputContract(width: 224, height: 224),
            output: output,
            labels: ["target", "other"],
            confidenceThreshold: 0.5,
            nmsIoUThreshold: 0.5
        )
    }

    private func frame(
        id: UInt64 = 1,
        instant: UInt64 = 1_000_000_000,
        format: CaptureFormat = CaptureFormat(width: 1_920, height: 1_080, frameRate: 30)
    ) -> CameraFrameMetadata {
        CameraFrameMetadata(
            id: id,
            rawPresentationTimestamp: Double(id),
            captureInstant: MonotonicInstant(nanoseconds: instant),
            format: format
        )
    }

    @Test("Valid detector manifests accept image object-detection contracts")
    func validManifest() throws {
        let value = try manifest()
        #expect(value.kind == .objectDetection)
        #expect(value.input.kind == .image)
        #expect(value.labels == ["target", "other"])
    }

    @Test("Malformed detector manifests fail closed")
    func malformedManifest() {
        #expect(throws: DetectorManifestError.invalidHash) {
            try DetectorManifest(
                identifier: "fixture",
                sha256: "not-a-hash",
                input: DetectorInputContract(width: 224, height: 224),
                output: DetectorOutputContract(kind: .visionObjects),
                labels: ["target"]
            )
        }
        #expect(throws: DetectorManifestError.invalidOutputContract) {
            try DetectorManifest(
                identifier: "fixture",
                sha256: hash,
                input: DetectorInputContract(width: 224, height: 224),
                output: DetectorOutputContract(
                    kind: .multiArray,
                    coordinatesKey: nil,
                    confidenceKey: "confidence"
                ),
                labels: ["target"]
            )
        }
        #expect(throws: DetectorManifestError.duplicateLabel) {
            try DetectorManifest(
                identifier: "fixture",
                sha256: hash,
                input: DetectorInputContract(width: 224, height: 224),
                output: DetectorOutputContract(kind: .visionObjects),
                labels: ["target", "target"]
            )
        }
    }

    @Test("Letterboxed mirrored coordinates round-trip through source, model, and view spaces")
    func letterboxedMirrored() throws {
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
        let viewRect = try transform.modelToView(modelRect)
        let roundTrip = try transform.modelToSource(modelRect)

        #expect(abs(roundTrip.x - sourceRect.x) < 0.5)
        #expect(abs(roundTrip.y - sourceRect.y) < 0.5)
        #expect(abs(roundTrip.width - sourceRect.width) < 0.5)
        #expect(abs(roundTrip.height - sourceRect.height) < 0.5)
        #expect(viewRect.width > 0)
        #expect(viewRect.height > 0)
        #expect(try transform.normalizedSourceRect(sourceRect) == NormalizedRect(
            x: 300.0 / 1_920.0,
            y: 220.0 / 1_080.0,
            width: 640.0 / 1_920.0,
            height: 360.0 / 1_080.0
        ))
    }

    @Test("All orientations and resize policies preserve pixel geometry")
    func parameterizedCoordinateFixtures() throws {
        let orientations: [CaptureVideoOrientation] = [
            .portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight, .unknown,
        ]
        let resizeModes: [DetectorResizeMode] = [.stretch, .letterbox, .centerCrop]
        let sourceRect = PixelRect(x: 310, y: 190, width: 520, height: 330)

        for orientation in orientations {
            for resizeMode in resizeModes {
                let transform = try DetectorCoordinateTransform(
                    sourceSize: PixelSize(width: 1_920, height: 1_080),
                    modelSize: PixelSize(width: 640, height: 640),
                    viewSize: PixelSize(width: 1_280, height: 800),
                    orientation: orientation,
                    mirrored: true,
                    resizeMode: resizeMode
                )
                let modelRect = try transform.sourceToModel(sourceRect)
                let roundTrip = try transform.modelToSource(modelRect)
                let actualView = try transform.modelToView(modelRect)
                let expectedView = try transform.sourceToView(sourceRect)

                #expect(abs(roundTrip.x - sourceRect.x) < 0.5)
                #expect(abs(roundTrip.y - sourceRect.y) < 0.5)
                #expect(abs(roundTrip.width - sourceRect.width) < 0.5)
                #expect(abs(roundTrip.height - sourceRect.height) < 0.5)
                #expect(abs(actualView.x - expectedView.x) < 0.5)
                #expect(abs(actualView.y - expectedView.y) < 0.5)
                #expect(abs(actualView.width - expectedView.width) < 0.5)
                #expect(abs(actualView.height - expectedView.height) < 0.5)
            }
        }
    }

    @Test("Independent orientation fixtures match expected model pixels")
    func independentOrientationFixtures() throws {
        let sourceRect = PixelRect(x: 310, y: 190, width: 520, height: 330)
        let fixtures: [(CaptureVideoOrientation, PixelRect)] = [
            (.portrait, PixelRect(x: 203.333333333, y: 103.333333333, width: 110, height: 173.333333333)),
            (.portraitUpsideDown, PixelRect(x: 326.666666667, y: 363.333333333, width: 110, height: 173.333333333)),
            (.landscapeLeft, PixelRect(x: 103.333333333, y: 326.666666667, width: 173.333333333, height: 110)),
            (.landscapeRight, PixelRect(x: 363.333333333, y: 203.333333333, width: 173.333333333, height: 110)),
        ]

        for (orientation, expected) in fixtures {
            let transform = try DetectorCoordinateTransform(
                sourceSize: PixelSize(width: 1_920, height: 1_080),
                modelSize: PixelSize(width: 640, height: 640),
                viewSize: PixelSize(width: 1_280, height: 800),
                orientation: orientation,
                mirrored: true,
                resizeMode: .letterbox
            )
            let actual = try transform.sourceToModel(sourceRect)
            #expect(abs(actual.x - expected.x) < 0.5)
            #expect(abs(actual.y - expected.y) < 0.5)
            #expect(abs(actual.width - expected.width) < 0.5)
            #expect(abs(actual.height - expected.height) < 0.5)
        }
    }

    @Test("Thresholding and NMS are deterministic and label scoped")
    func thresholdAndNMS() throws {
        let instant = MonotonicInstant(nanoseconds: 1_000_000_000)
        let observations = [
            DetectionObservation(
                id: "high", frameID: 1, generation: 1, captureInstant: instant,
                label: "target", confidence: 0.95,
                boundingBox: NormalizedRect(x: 0.1, y: 0.1, width: 0.4, height: 0.4)
            ),
            DetectionObservation(
                id: "overlap", frameID: 1, generation: 1, captureInstant: instant,
                label: "target", confidence: 0.9,
                boundingBox: NormalizedRect(x: 0.12, y: 0.12, width: 0.4, height: 0.4)
            ),
            DetectionObservation(
                id: "other-label", frameID: 1, generation: 1, captureInstant: instant,
                label: "other", confidence: 0.8,
                boundingBox: NormalizedRect(x: 0.12, y: 0.12, width: 0.4, height: 0.4)
            ),
            DetectionObservation(
                id: "below-threshold", frameID: 1, generation: 1, captureInstant: instant,
                label: "target", confidence: 0.49,
                boundingBox: NormalizedRect(x: 0.7, y: 0.7, width: 0.1, height: 0.1)
            ),
        ]
        let policy = try NMSPolicy(confidenceThreshold: 0.5, iouThreshold: 0.5)
        let kept = DetectionFiltering.thresholdAndSuppress(observations, policy: policy)

        #expect(kept.map(\.id) == ["high", "other-label"])
    }

    @Test("Normalizer inherits frame timestamp and rejects unsupported or malformed output")
    func normalizerContracts() throws {
        let value = try manifest()
        let normalizer = DetectorOutputNormalizer(manifest: value)
        let sourceFrame = frame()
        let output = DetectorRawOutput.visionObjects([
            VisionDetectionOutput(
                label: "target",
                confidence: 0.8,
                boundingBox: NormalizedRect(x: 0.1, y: 0.2, width: 0.3, height: 0.4)
            ),
        ])
        let observations = try normalizer.normalize(
            output,
            frame: sourceFrame,
            now: MonotonicInstant(nanoseconds: 2_000_000_000),
            generation: 4
        )
        #expect(observations.count == 1)
        #expect(observations[0].frameID == sourceFrame.id)
        #expect(observations[0].captureInstant == sourceFrame.captureInstant)
        #expect(observations[0].generation == 4)

        #expect(throws: DetectionValidationError.unsupportedOutputContract) {
            try normalizer.normalize(
                .classification,
                frame: sourceFrame,
                now: MonotonicInstant(nanoseconds: 2_000_000_000),
                generation: 4
            )
        }
        #expect(throws: DetectionValidationError.invalidConfidence) {
            try normalizer.normalize(
                .visionObjects([
                    VisionDetectionOutput(
                        label: "target",
                        confidence: 1.1,
                        boundingBox: NormalizedRect(x: 0, y: 0, width: 0.2, height: 0.2)
                    ),
                ]),
                frame: sourceFrame,
                now: MonotonicInstant(nanoseconds: 2_000_000_000),
                generation: 4
            )
        }

        let mismatchedTimestamp = DetectionObservation(
            id: "mismatch",
            frameID: sourceFrame.id,
            generation: 4,
            captureInstant: MonotonicInstant(nanoseconds: 1_500_000_000),
            label: "target",
            confidence: 0.8,
            boundingBox: NormalizedRect(x: 0, y: 0, width: 0.2, height: 0.2)
        )
        #expect(throws: DetectionValidationError.timestampMismatch) {
            try normalizer.validate(
                mismatchedTimestamp,
                frame: sourceFrame,
                now: MonotonicInstant(nanoseconds: 2_000_000_000),
                generation: 4
            )
        }
    }

    @Test("Pipeline rejects stale frame IDs and fake inference is deterministic")
    func pipelineRejectsStaleFrame() async throws {
        let value = try manifest()
        let engine = DeterministicFakeInferenceEngine(detections: [
            FakeDetection(
                label: "target",
                confidence: 0.9,
                boundingBox: NormalizedRect(x: 0.25, y: 0.25, width: 0.2, height: 0.2)
            ),
            FakeDetection(
                label: "target",
                confidence: 0.8,
                boundingBox: NormalizedRect(x: 0.26, y: 0.26, width: 0.2, height: 0.2)
            ),
            FakeDetection(
                label: "target",
                confidence: 0.2,
                boundingBox: NormalizedRect(x: 0.7, y: 0.7, width: 0.1, height: 0.1)
            ),
        ])
        let pipeline = try DetectorPipeline(manifest: value, engine: engine)
        let first = frame(id: 10)
        let now = MonotonicInstant(nanoseconds: 2_000_000_000)
        let observations = try await pipeline.process(frame: first, now: now, generation: 1)
        #expect(observations.count == 1)
        #expect(observations[0].boundingBox == NormalizedRect(x: 0.25, y: 0.25, width: 0.2, height: 0.2))

        await #expect(throws: DetectionValidationError.staleFrame) {
            _ = try await pipeline.process(frame: first, now: now, generation: 1)
        }

        let futureFrame = frame(id: 11, instant: 3_000_000_000)
        await #expect(throws: DetectionValidationError.futureCapture) {
            _ = try await pipeline.process(
                frame: futureFrame,
                now: MonotonicInstant(nanoseconds: 2_000_000_000),
                generation: 1
            )
        }
    }

    @Test("Multi-array normalizer maps labels and rejects shape mismatches")
    func multiArrayContract() throws {
        let value = try manifest(output: DetectorOutputContract(
            kind: .multiArray,
            coordinatesKey: "coordinates",
            confidenceKey: "confidence",
            labelIndexKey: "labels"
        ))
        let normalizer = DetectorOutputNormalizer(manifest: value)
        let sourceFrame = frame()
        let output = MultiArrayDetectionOutput(
            coordinates: [[0.1, 0.2, 0.3, 0.4]],
            confidences: [0.75],
            labelIndices: [1]
        )
        let observations = try normalizer.normalize(
            .multiArray(output),
            frame: sourceFrame,
            now: MonotonicInstant(nanoseconds: 2_000_000_000),
            generation: 1
        )
        #expect(observations[0].label == "other")

        #expect(throws: DetectionValidationError.unsupportedOutputContract) {
            try normalizer.normalize(
                .multiArray(MultiArrayDetectionOutput(
                    coordinates: [[0.1, 0.2, 0.3, 0.4]],
                    confidences: [],
                    labelIndices: [0]
                )),
                frame: sourceFrame,
                now: MonotonicInstant(nanoseconds: 2_000_000_000),
                generation: 1
            )
        }
    }
}
