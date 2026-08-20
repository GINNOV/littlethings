import Testing
@testable import ArmageddonCore

struct NativeCaptureSessionTests {
    private struct FixedCaptureClock: CaptureHostClock {
        let instant: MonotonicInstant

        func now() -> MonotonicInstant { instant }
    }

    @Test("Latest frame capture keeps queue depth at one and drops older frames")
    func latestFrameQueueIsBounded() async throws {
        let session = NativeCaptureSession(clock: FixedCaptureClock(instant: .init(nanoseconds: 2_000_000_000)))
        let format = CaptureFormat(width: 1_280, height: 720, frameRate: 30)
        let source = try await session.start(configuration: format)

        for id in 0..<1_800 {
            let frame = CameraFrameMetadata(
                id: UInt64(id),
                rawPresentationTimestamp: Double(id) / 30,
                captureInstant: MonotonicInstant(nanoseconds: UInt64(id) * 1_000_000),
                format: format
            )
            try await session.ingest(frame, source: source)
        }

        let latest = await session.consumeLatest()
        let snapshot = await session.snapshot()

        #expect(latest?.id == 1_799)
        #expect(snapshot.metrics.produced == 1_800)
        #expect(snapshot.metrics.delivered == 1)
        #expect(snapshot.metrics.dropped == 1_799)
        #expect(snapshot.metrics.maxQueueDepth == 1)
        #expect(snapshot.metrics.latestFrameAgeNanoseconds == 201_000_000)
    }

    @Test("Stopping a source rejects late frames and clears pending work")
    func stopCancelsSourceGeneration() async throws {
        let session = NativeCaptureSession(clock: FixedCaptureClock(instant: .init(nanoseconds: 100)))
        let source = try await session.start(configuration: CaptureFormat(width: 640, height: 480, frameRate: 30))
        await session.stop()

        let frame = CameraFrameMetadata(
            id: 1,
            rawPresentationTimestamp: 1,
            captureInstant: MonotonicInstant(nanoseconds: 1),
            format: CaptureFormat(width: 640, height: 480, frameRate: 30)
        )
        await #expect(throws: NativeCaptureSessionError.notRunning) {
            try await session.ingest(frame, source: source)
        }
        #expect(await session.consumeLatest() == nil)
        #expect((await session.snapshot()).state == .stopped)
    }

    @Test("A new source generation cancels the previous source")
    func sourceSwitchRejectsOldGeneration() async throws {
        let session = NativeCaptureSession(clock: FixedCaptureClock(instant: .init(nanoseconds: 10_000)))
        let oldSource = try await session.start(configuration: CaptureFormat(width: 640, height: 480, frameRate: 30))
        let newSource = try await session.start(configuration: CaptureFormat(width: 1_280, height: 720, frameRate: 30))
        let frame = CameraFrameMetadata(
            id: 1,
            rawPresentationTimestamp: 1,
            captureInstant: MonotonicInstant(nanoseconds: 1),
            format: CaptureFormat(width: 640, height: 480, frameRate: 30)
        )

        await #expect(throws: NativeCaptureSessionError.cancelledSource) {
            try await session.ingest(frame, source: oldSource)
        }
        let newFrame = CameraFrameMetadata(
            id: 2,
            rawPresentationTimestamp: 2,
            captureInstant: MonotonicInstant(nanoseconds: 2),
            format: CaptureFormat(width: 1_280, height: 720, frameRate: 30)
        )
        try await session.ingest(newFrame, source: newSource)
        #expect((await session.consumeLatest())?.id == 2)
    }

    @Test("Timestamp correlation rejects invalid, discontinuous, and future frames")
    func timestampMappingFailsClosed() throws {
        let correlation = try CaptureTimestampCorrelation(
            anchorPresentationTimestamp: 10,
            anchorInstant: MonotonicInstant(nanoseconds: 1_000_000_000)
        )
        #expect(try correlation.map(
            presentationTimestamp: 10.25,
            now: MonotonicInstant(nanoseconds: 1_500_000_000)
        ) == MonotonicInstant(nanoseconds: 1_250_000_000))
        #expect(throws: CaptureTimestampMappingError.invalidPresentationTimestamp) {
            try correlation.map(
                presentationTimestamp: Double.infinity,
                now: MonotonicInstant(nanoseconds: 2_000_000_000)
            )
        }
        #expect(throws: CaptureTimestampMappingError.discontinuity) {
            try correlation.map(
                presentationTimestamp: 9.9,
                now: MonotonicInstant(nanoseconds: 2_000_000_000)
            )
        }
        #expect(throws: CaptureTimestampMappingError.futureCapture) {
            try correlation.map(
                presentationTimestamp: 11,
                now: MonotonicInstant(nanoseconds: 1_500_000_000)
            )
        }
        #expect(throws: CaptureTimestampMappingError.negativeAge) {
            try correlation.map(
                presentationTimestamp: 10,
                now: MonotonicInstant(nanoseconds: 500_000_000)
            )
        }
    }

    @Test("Sixty seconds of 30 FPS capture keeps the latest-frame queue bounded")
    func sixtySecondsOfCaptureMaintainsBoundedQueue() async throws {
        let session = NativeCaptureSession(clock: FixedCaptureClock(instant: .init(nanoseconds: 60_000_000_000)))
        let format = CaptureFormat(width: 1_280, height: 720, frameRate: 30)
        let source = try await session.start(configuration: format)

        for id in 0..<1_800 {
            try await session.ingest(
                CameraFrameMetadata(
                    id: UInt64(id),
                    rawPresentationTimestamp: Double(id) / 30,
                    captureInstant: MonotonicInstant(nanoseconds: UInt64(id) * 33_333_333),
                    format: format
                ),
                source: source
            )
            if id.isMultiple(of: 30) && id > 0 {
                _ = await session.consumeLatest()
            }
        }

        let snapshot = await session.snapshot()
        #expect(snapshot.metrics.produced == 1_800)
        #expect(snapshot.metrics.delivered == 59)
        #expect(snapshot.metrics.maxQueueDepth == 1)
        #expect(snapshot.metrics.dropped == 1_740)
    }

    @Test("Twenty preview start-stop cycles leave no pending frame")
    func previewLifecycleReleasesPendingFramesAcrossTwentyCycles() async throws {
        let session = NativeCaptureSession(clock: FixedCaptureClock(instant: .init(nanoseconds: 1_000_000)))
        let format = CaptureFormat(width: 1_280, height: 720, frameRate: 30)

        for id in 0..<20 {
            let source = try await session.start(configuration: format)
            try await session.ingest(
                CameraFrameMetadata(
                    id: UInt64(id),
                    rawPresentationTimestamp: Double(id),
                    captureInstant: MonotonicInstant(nanoseconds: 1),
                    format: format
                ),
                source: source
            )
            await session.stop()
            #expect(await session.consumeLatest() == nil)
        }

        let snapshot = await session.snapshot()
        #expect(snapshot.state == .stopped)
        #expect(snapshot.metrics.maxQueueDepth == 1)
    }

    @Test("Frame metadata preserves negotiated orientation and mirroring")
    func frameMetadataPreservesGeometry() {
        let format = CaptureFormat(
            width: 1_280,
            height: 720,
            frameRate: 30,
            orientation: .portrait,
            mirrored: true
        )
        let frame = CameraFrameMetadata(
            id: 4,
            rawPresentationTimestamp: 4,
            captureInstant: MonotonicInstant(nanoseconds: 4),
            format: format
        )

        #expect(frame.format.orientation == .portrait)
        #expect(frame.format.mirrored)
        #expect(frame.format.width == 1_280)
        #expect(frame.format.height == 720)
    }
}
