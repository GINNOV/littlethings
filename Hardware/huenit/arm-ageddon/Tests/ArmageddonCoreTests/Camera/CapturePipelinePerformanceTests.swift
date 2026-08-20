import Testing
@testable import ArmageddonCore

struct CapturePipelinePerformanceTests {
    private struct FixedCaptureClock: CaptureHostClock {
        let instant: MonotonicInstant

        func now() -> MonotonicInstant { instant }
    }

    @Test("sixtySeconds")
    func sixtySeconds() async throws {
        let format = CaptureFormat(width: 1_280, height: 720, frameRate: 30)
        let session = NativeCaptureSession(
            clock: FixedCaptureClock(instant: MonotonicInstant(nanoseconds: 60_000_000_000))
        )
        let source = try await session.start(configuration: format)
        let firstTimestamp = 0.0
        let lastTimestamp = Double(1_799) / format.frameRate

        for id in 0..<1_800 {
            try await session.ingest(
                CameraFrameMetadata(
                    id: UInt64(id),
                    rawPresentationTimestamp: Double(id) / format.frameRate,
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
        let measuredDuration = lastTimestamp - firstTimestamp + (1 / format.frameRate)
        let effectiveFrameRate = Double(snapshot.metrics.produced) / measuredDuration

        #expect(measuredDuration == 60)
        #expect(effectiveFrameRate >= 30)
        #expect(snapshot.metrics.maxQueueDepth <= 1)
        #expect(snapshot.metrics.produced == 1_800)
        #expect(snapshot.metrics.dropped == 1_740)
    }
}
