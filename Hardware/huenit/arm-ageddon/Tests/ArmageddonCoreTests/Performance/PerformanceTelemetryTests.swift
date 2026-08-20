import Foundation
import Testing
@testable import ArmageddonCore

struct PerformanceTelemetryTests {
    @Test("60 seconds of 30 FPS telemetry stays bounded and reports healthy freshness")
    func sixtySecondsAtThirtyFPS() async throws {
        let telemetry = try PerformanceTelemetry(windowCapacity: 120)
        let frameInterval: UInt64 = 33_333_333

        for index in 0..<1_800 {
            let capture = MonotonicInstant(nanoseconds: UInt64(index) * frameInterval)
            let received = MonotonicInstant(nanoseconds: capture.nanoseconds + 20_000_000)
            try await telemetry.recordFrame(
                captureInstant: capture,
                receivedAt: received,
                negotiatedFPS: 30,
                droppedFramesSinceLastSample: 0,
                queueDepth: 1
            )
            try await telemetry.recordInference(
                captureInstant: capture,
                startedAt: MonotonicInstant(nanoseconds: received.nanoseconds + 5_000_000),
                finishedAt: MonotonicInstant(nanoseconds: received.nanoseconds + 25_000_000),
                overlayAt: MonotonicInstant(nanoseconds: received.nanoseconds + 35_000_000),
                queueDepth: 1
            )
        }

        let snapshot = await telemetry.snapshot(now: MonotonicInstant(nanoseconds: 60_000_000_000))
        #expect(snapshot.negotiatedFPS == 30)
        #expect((snapshot.observedFPS ?? 0) >= 29.9)
        #expect(snapshot.producedFrames == 1_800)
        #expect(snapshot.deliveredFrames == 1_800)
        #expect(snapshot.maximumQueueDepth == 1)
        #expect((snapshot.frameAgeP95Milliseconds ?? .greatestFiniteMagnitude) <= 100)
        #expect((snapshot.inferenceP95Milliseconds ?? .greatestFiniteMagnitude) == 20)
        #expect(snapshot.health == .ready)
        #expect(snapshot.targetingAvailable)
    }

    @Test("inference becomes Slow only above 250 ms and recovers after a successful sample")
    func slowInferenceGate() async throws {
        let telemetry = try PerformanceTelemetry(windowCapacity: 4)
        let capture = MonotonicInstant(nanoseconds: 1_000_000_000)
        try await telemetry.recordFrame(
            captureInstant: capture,
            receivedAt: MonotonicInstant(nanoseconds: 1_020_000_000),
            negotiatedFPS: 30,
            droppedFramesSinceLastSample: 0,
            queueDepth: 1
        )
        try await telemetry.recordInference(
            captureInstant: capture,
            startedAt: MonotonicInstant(nanoseconds: 1_020_000_000),
            finishedAt: MonotonicInstant(nanoseconds: 1_320_000_000),
            overlayAt: MonotonicInstant(nanoseconds: 1_330_000_000),
            queueDepth: 1
        )
        let slow = await telemetry.snapshot(now: MonotonicInstant(nanoseconds: 1_340_000_000))
        #expect(slow.health == .slow)
        #expect(!slow.targetingAvailable)
        #expect(slow.healthReason.contains("250"))

        for index in 0..<4 {
            let start = MonotonicInstant(nanoseconds: 1_400_000_000 + UInt64(index) * 20_000_000)
            try await telemetry.recordInference(
                captureInstant: capture,
                startedAt: start,
                finishedAt: MonotonicInstant(nanoseconds: start.nanoseconds + 10_000_000),
                overlayAt: MonotonicInstant(nanoseconds: start.nanoseconds + 20_000_000),
                queueDepth: 1
            )
        }
        let recovered = await telemetry.snapshot(now: MonotonicInstant(nanoseconds: 1_500_000_000))
        #expect(recovered.health == .ready)
        #expect(recovered.targetingAvailable)
    }

    @Test("stale observations and repeated model failures independently inhibit targeting")
    func staleAndModelFailureGates() async throws {
        let telemetry = try PerformanceTelemetry()
        let capture = MonotonicInstant(nanoseconds: 1_000_000_000)
        try await telemetry.recordFrame(
            captureInstant: capture,
            receivedAt: MonotonicInstant(nanoseconds: 1_010_000_000),
            negotiatedFPS: 30,
            droppedFramesSinceLastSample: 0,
            queueDepth: 1
        )
        try await telemetry.recordInference(
            captureInstant: capture,
            startedAt: MonotonicInstant(nanoseconds: 1_010_000_000),
            finishedAt: MonotonicInstant(nanoseconds: 1_020_000_000),
            overlayAt: MonotonicInstant(nanoseconds: 1_030_000_000),
            queueDepth: 1
        )
        let stale = await telemetry.snapshot(now: MonotonicInstant(nanoseconds: 1_531_000_000))
        #expect(stale.health == .stale)
        #expect(!stale.targetingAvailable)

        let delayedPublication = try PerformanceTelemetry()
        try await delayedPublication.recordFrame(
            captureInstant: capture,
            receivedAt: MonotonicInstant(nanoseconds: 1_020_000_000),
            negotiatedFPS: 30,
            droppedFramesSinceLastSample: 0,
            queueDepth: 1
        )
        try await delayedPublication.recordInference(
            captureInstant: capture,
            startedAt: MonotonicInstant(nanoseconds: 1_020_000_000),
            finishedAt: MonotonicInstant(nanoseconds: 1_030_000_000),
            overlayAt: MonotonicInstant(nanoseconds: 1_690_000_000),
            queueDepth: 1
        )
        let delayed = await delayedPublication.snapshot(now: MonotonicInstant(nanoseconds: 1_700_000_000))
        #expect(delayed.health == .stale)
        #expect(!delayed.targetingAvailable)

        await telemetry.recordModelFailure()
        await telemetry.recordModelFailure()
        await telemetry.recordModelFailure()
        let failed = await telemetry.snapshot(now: MonotonicInstant(nanoseconds: 1_100_000_000))
        #expect(failed.health == .modelFailed)
        #expect(failed.consecutiveModelFailures == 3)
        #expect(!failed.targetingAvailable)
    }

    @Test("observed FPS follows the bounded recent frame window")
    func observedFPSUsesRollingWindow() async throws {
        let telemetry = try PerformanceTelemetry(windowCapacity: 4)
        for index in 0..<4 {
            let instant = MonotonicInstant(nanoseconds: UInt64(index) * 1_000_000_000)
            try await telemetry.recordFrame(
                captureInstant: instant,
                receivedAt: instant,
                negotiatedFPS: 30,
                droppedFramesSinceLastSample: 0,
                queueDepth: 1
            )
        }
        for index in 0..<4 {
            let instant = MonotonicInstant(nanoseconds: 3_000_000_000 + UInt64(index) * 33_333_333)
            try await telemetry.recordFrame(
                captureInstant: instant,
                receivedAt: instant,
                negotiatedFPS: 30,
                droppedFramesSinceLastSample: 0,
                queueDepth: 1
            )
        }

        let snapshot = await telemetry.snapshot(now: MonotonicInstant(nanoseconds: 3_200_000_000))
        #expect((snapshot.observedFPS ?? 0) >= 29.9)
        #expect((snapshot.observedFPS ?? .greatestFiniteMagnitude) <= 30.1)
    }

    @Test("persists a summary snapshot without raw sample arrays")
    func persistsSummarySnapshot() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("armageddon-telemetry-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let store = PerformanceTelemetrySummaryStore(fileURL: fileURL)
        let telemetry = try PerformanceTelemetry(summaryStore: store)
        let capture = MonotonicInstant(nanoseconds: 1_000_000_000)
        try await telemetry.recordFrame(
            captureInstant: capture,
            receivedAt: MonotonicInstant(nanoseconds: 1_020_000_000),
            negotiatedFPS: 30,
            droppedFramesSinceLastSample: 0,
            queueDepth: 1
        )
        try await telemetry.recordInference(
            captureInstant: capture,
            startedAt: MonotonicInstant(nanoseconds: 1_020_000_000),
            finishedAt: MonotonicInstant(nanoseconds: 1_040_000_000),
            overlayAt: MonotonicInstant(nanoseconds: 1_055_000_000),
            queueDepth: 1
        )
        let summary = try await telemetry.persistSummary(now: MonotonicInstant(nanoseconds: 1_060_000_000))
        let loaded = try await store.load()
        #expect(loaded == summary)
        let persistedJSON = try String(contentsOf: fileURL, encoding: .utf8)
        #expect(!persistedJSON.contains("frameAges"))
        #expect(!persistedJSON.contains("inferenceDurations"))
    }

    @Test("invalid samples and zero-capacity windows fail closed")
    func invalidInputsFailClosed() async throws {
        #expect(throws: PerformanceTelemetryError.invalidCapacity) {
            _ = try PerformanceTelemetry(windowCapacity: 0)
        }
        let telemetry = try PerformanceTelemetry()
        do {
            try await telemetry.recordFrame(
                captureInstant: MonotonicInstant(nanoseconds: 2),
                receivedAt: MonotonicInstant(nanoseconds: 1),
                negotiatedFPS: 30,
                droppedFramesSinceLastSample: 0,
                queueDepth: 1
            )
            Issue.record("Expected a frame received before capture to fail")
        } catch PerformanceTelemetryError.invalidSample {
        } catch {
            Issue.record("Expected invalidSample, got \(error)")
        }
    }
}
