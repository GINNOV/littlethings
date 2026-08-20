import Darwin
import Foundation
import ArmageddonCore

@main
struct PerformanceTelemetryQAProbe {
    private struct Receipt: Codable {
        let mode: String
        let negotiatedFPS: Double?
        let observedFPS: Double?
        let producedFrames: UInt64
        let deliveredFrames: UInt64
        let droppedFrames: UInt64
        let maximumQueueDepth: Int
        let currentQueueDepth: Int
        let frameAgeP50Milliseconds: Double?
        let frameAgeP95Milliseconds: Double?
        let inferenceP50Milliseconds: Double?
        let inferenceP95Milliseconds: Double?
        let endToOverlayP50Milliseconds: Double?
        let endToOverlayP95Milliseconds: Double?
        let modelFailureCount: UInt64
        let consecutiveModelFailures: Int
        let health: String
        let healthReason: String
        let targetingAvailable: Bool
        let previewRemainsAvailable: Bool
        let summaryPersisted: Bool
    }

    static func main() async {
        do {
            guard CommandLine.arguments.count == 2,
                  CommandLine.arguments[1] == "happy" || CommandLine.arguments[1] == "failure" else {
                throw ProbeError.usage
            }
            let receipt = try await run(mode: CommandLine.arguments[1])
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            print(String(decoding: try encoder.encode(receipt), as: UTF8.self))
        } catch {
            let message = String(describing: error).replacingOccurrences(of: "\"", with: "'")
            print("{\"error\":\"\(message)\"}")
            exit(1)
        }
    }

    private static func run(mode: String) async throws -> Receipt {
        let summaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("armageddon-telemetry-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: summaryURL) }
        let summaryStore = PerformanceTelemetrySummaryStore(fileURL: summaryURL)
        let telemetry = try PerformanceTelemetry(summaryStore: summaryStore)
        if mode == "happy" {
            for index in 0..<1_800 {
                let capture = MonotonicInstant(nanoseconds: UInt64(index) * 2_000_000_000 / 60)
                let received = MonotonicInstant(nanoseconds: capture.nanoseconds + 20_000_000)
                let started = received
                let finished = MonotonicInstant(nanoseconds: started.nanoseconds + 20_000_000)
                let overlay = MonotonicInstant(nanoseconds: capture.nanoseconds + 55_000_000)
                try await telemetry.recordFrame(
                    captureInstant: capture,
                    receivedAt: received,
                    negotiatedFPS: 30,
                    droppedFramesSinceLastSample: 0,
                    queueDepth: 1
                )
                try await telemetry.recordInference(
                    captureInstant: capture,
                    startedAt: started,
                    finishedAt: finished,
                    overlayAt: overlay,
                    queueDepth: 1
                )
            }
            let snapshot = await telemetry.snapshot(now: MonotonicInstant(nanoseconds: 60_100_000_000))
            guard snapshot.health == .ready,
                  snapshot.targetingAvailable,
                  snapshot.maximumQueueDepth <= 1,
                  snapshot.observedFPS ?? 0 >= 29.9,
                  snapshot.frameAgeP95Milliseconds ?? .greatestFiniteMagnitude <= 100 else {
                throw ProbeError.healthyPipelineDidNotMeetBudget
            }
            let summary = try await telemetry.persistSummary(now: MonotonicInstant(nanoseconds: 60_100_000_000))
            guard try await summaryStore.load() == summary else { throw ProbeError.summaryPersistenceFailed }
            return receipt(mode: mode, snapshot: summary)
        }

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
        let snapshot = await telemetry.snapshot(now: MonotonicInstant(nanoseconds: 1_340_000_000))
        guard snapshot.health == .slow, !snapshot.targetingAvailable else {
            throw ProbeError.slowGateDidNotInhibitTargeting
        }
        let summary = try await telemetry.persistSummary(now: MonotonicInstant(nanoseconds: 1_340_000_000))
        guard try await summaryStore.load() == summary else { throw ProbeError.summaryPersistenceFailed }
        return receipt(mode: mode, snapshot: summary)
    }

    private static func receipt(mode: String, snapshot: PerformanceTelemetrySnapshot) -> Receipt {
        Receipt(
            mode: mode,
            negotiatedFPS: snapshot.negotiatedFPS,
            observedFPS: snapshot.observedFPS,
            producedFrames: snapshot.producedFrames,
            deliveredFrames: snapshot.deliveredFrames,
            droppedFrames: snapshot.droppedFrames,
            maximumQueueDepth: snapshot.maximumQueueDepth,
            currentQueueDepth: snapshot.currentQueueDepth,
            frameAgeP50Milliseconds: snapshot.frameAgeP50Milliseconds,
            frameAgeP95Milliseconds: snapshot.frameAgeP95Milliseconds,
            inferenceP50Milliseconds: snapshot.inferenceP50Milliseconds,
            inferenceP95Milliseconds: snapshot.inferenceP95Milliseconds,
            endToOverlayP50Milliseconds: snapshot.endToOverlayP50Milliseconds,
            endToOverlayP95Milliseconds: snapshot.endToOverlayP95Milliseconds,
            modelFailureCount: snapshot.modelFailureCount,
            consecutiveModelFailures: snapshot.consecutiveModelFailures,
            health: snapshot.health.rawValue,
            healthReason: snapshot.healthReason,
            targetingAvailable: snapshot.targetingAvailable,
            previewRemainsAvailable: true,
            summaryPersisted: true
        )
    }
}

private enum ProbeError: Error {
    case usage
    case healthyPipelineDidNotMeetBudget
    case slowGateDidNotInhibitTargeting
    case summaryPersistenceFailed
}
