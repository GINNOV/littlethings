import ArmageddonCore
import Foundation

private struct FixedCaptureClock: CaptureHostClock {
    let instant: MonotonicInstant

    func now() -> MonotonicInstant { instant }
}

private struct CaptureQAResult: Codable {
    let mode: String
    let logicalSeconds: Int
    let produced: UInt64
    let delivered: UInt64
    let dropped: UInt64
    let maxQueueDepth: Int
    let stopElapsedNanoseconds: UInt64?
    let postStopFrameRejections: Int
    let previewCycles: Int
}

@main
struct CaptureQAProbe {
    static func main() async throws {
        let mode = CommandLine.arguments.dropFirst().first ?? "happy"
        switch mode {
        case "happy":
            try await runHappy()
        case "failure":
            try await runFailure()
        default:
            throw ProbeError.unknownMode(mode)
        }
    }

    private static func runHappy() async throws {
        let format = CaptureFormat(width: 1_280, height: 720, frameRate: 30)
        let session = NativeCaptureSession(
            clock: FixedCaptureClock(instant: MonotonicInstant(nanoseconds: 60_000_000_000))
        )
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
        let metrics = (await session.snapshot()).metrics
        try emit(CaptureQAResult(
            mode: "happy",
            logicalSeconds: 60,
            produced: metrics.produced,
            delivered: metrics.delivered,
            dropped: metrics.dropped,
            maxQueueDepth: metrics.maxQueueDepth,
            stopElapsedNanoseconds: nil,
            postStopFrameRejections: 0,
            previewCycles: 0
        ))
    }

    private static func runFailure() async throws {
        let format = CaptureFormat(width: 1_280, height: 720, frameRate: 30)
        let session = NativeCaptureSession(
            clock: FixedCaptureClock(instant: MonotonicInstant(nanoseconds: 1_000_000))
        )
        let source = try await session.start(configuration: format)
        let clock = ContinuousClock()
        let started = clock.now
        await session.stop()
        let elapsed = started.duration(to: clock.now)
        var postStopFrameRejections = 0
        do {
            try await session.ingest(
                CameraFrameMetadata(
                    id: 1,
                    rawPresentationTimestamp: 1,
                    captureInstant: MonotonicInstant(nanoseconds: 1),
                    format: format
                ),
                source: source
            )
        } catch {
            postStopFrameRejections += 1
        }

        for _ in 0..<20 {
            _ = try await session.start(configuration: format)
            await session.stop()
        }
        let metrics = (await session.snapshot()).metrics
        try emit(CaptureQAResult(
            mode: "failure",
            logicalSeconds: 0,
            produced: metrics.produced,
            delivered: metrics.delivered,
            dropped: metrics.dropped,
            maxQueueDepth: metrics.maxQueueDepth,
            stopElapsedNanoseconds: durationNanoseconds(elapsed),
            postStopFrameRejections: postStopFrameRejections,
            previewCycles: 20
        ))
    }

    private static func durationNanoseconds(_ duration: Duration) -> UInt64 {
        let components = duration.components
        return UInt64(max(0, components.seconds)) * 1_000_000_000
            + UInt64(max(0, components.attoseconds / 1_000_000_000))
    }

    private static func emit(_ result: CaptureQAResult) throws {
        let data = try JSONEncoder().encode(result)
        print(String(decoding: data, as: UTF8.self))
    }
}

private enum ProbeError: Error {
    case unknownMode(String)
}
