import Foundation

public struct PerformanceThresholds: Codable, Equatable, Sendable {
    public let maximumInferenceP95Milliseconds: Double
    public let maximumObservationAgeMilliseconds: Double
    public let captureStallMilliseconds: Double
    public let repeatedModelFailureLimit: Int

    public init(
        maximumInferenceP95Milliseconds: Double = 250,
        maximumObservationAgeMilliseconds: Double = 500,
        captureStallMilliseconds: Double = 1_000,
        repeatedModelFailureLimit: Int = 3
    ) {
        self.maximumInferenceP95Milliseconds = maximumInferenceP95Milliseconds
        self.maximumObservationAgeMilliseconds = maximumObservationAgeMilliseconds
        self.captureStallMilliseconds = captureStallMilliseconds
        self.repeatedModelFailureLimit = repeatedModelFailureLimit
    }
}

public enum PerformanceHealth: String, Codable, Equatable, Sendable {
    case insufficientData
    case ready
    case slow
    case stale
    case stalled
    case modelFailed

    public var label: String {
        switch self {
        case .insufficientData: "Telemetry warming up"
        case .ready: "Ready"
        case .slow: "Slow inference"
        case .stale: "Observation stale"
        case .stalled: "Capture stalled"
        case .modelFailed: "Model unavailable"
        }
    }

    public var symbolName: String {
        switch self {
        case .insufficientData: "chart.bar.xaxis"
        case .ready: "checkmark.circle"
        case .slow: "tortoise"
        case .stale: "clock.badge.exclamationmark"
        case .stalled: "video.slash"
        case .modelFailed: "exclamationmark.triangle"
        }
    }
}

public enum PerformanceTelemetryError: Error, Equatable, Sendable {
    case invalidSample
    case invalidCapacity
}

public struct PerformanceTelemetrySnapshot: Codable, Equatable, Sendable {
    public let negotiatedFPS: Double?
    public let observedFPS: Double?
    public let producedFrames: UInt64
    public let deliveredFrames: UInt64
    public let droppedFrames: UInt64
    public let maximumQueueDepth: Int
    public let currentQueueDepth: Int
    public let frameAgeP50Milliseconds: Double?
    public let frameAgeP95Milliseconds: Double?
    public let inferenceP50Milliseconds: Double?
    public let inferenceP95Milliseconds: Double?
    public let endToOverlayP50Milliseconds: Double?
    public let endToOverlayP95Milliseconds: Double?
    public let modelFailureCount: UInt64
    public let consecutiveModelFailures: Int
    public let health: PerformanceHealth
    public let healthReason: String
    public let targetingAvailable: Bool

    public init(
        negotiatedFPS: Double? = nil,
        observedFPS: Double? = nil,
        producedFrames: UInt64 = 0,
        deliveredFrames: UInt64 = 0,
        droppedFrames: UInt64 = 0,
        maximumQueueDepth: Int = 0,
        currentQueueDepth: Int = 0,
        frameAgeP50Milliseconds: Double? = nil,
        frameAgeP95Milliseconds: Double? = nil,
        inferenceP50Milliseconds: Double? = nil,
        inferenceP95Milliseconds: Double? = nil,
        endToOverlayP50Milliseconds: Double? = nil,
        endToOverlayP95Milliseconds: Double? = nil,
        modelFailureCount: UInt64 = 0,
        consecutiveModelFailures: Int = 0,
        health: PerformanceHealth = .insufficientData,
        healthReason: String = "No capture telemetry has been recorded.",
        targetingAvailable: Bool = false
    ) {
        self.negotiatedFPS = negotiatedFPS
        self.observedFPS = observedFPS
        self.producedFrames = producedFrames
        self.deliveredFrames = deliveredFrames
        self.droppedFrames = droppedFrames
        self.maximumQueueDepth = maximumQueueDepth
        self.currentQueueDepth = currentQueueDepth
        self.frameAgeP50Milliseconds = frameAgeP50Milliseconds
        self.frameAgeP95Milliseconds = frameAgeP95Milliseconds
        self.inferenceP50Milliseconds = inferenceP50Milliseconds
        self.inferenceP95Milliseconds = inferenceP95Milliseconds
        self.endToOverlayP50Milliseconds = endToOverlayP50Milliseconds
        self.endToOverlayP95Milliseconds = endToOverlayP95Milliseconds
        self.modelFailureCount = modelFailureCount
        self.consecutiveModelFailures = consecutiveModelFailures
        self.health = health
        self.healthReason = healthReason
        self.targetingAvailable = targetingAvailable
    }
}

public actor PerformanceTelemetry {
    private let capacity: Int
    private let thresholds: PerformanceThresholds
    private var negotiatedFPS: Double?
    private var producedFrames: UInt64 = 0
    private var deliveredFrames: UInt64 = 0
    private var droppedFrames: UInt64 = 0
    private var maximumQueueDepth = 0
    private var currentQueueDepth = 0
    private var frameAges: [UInt64] = []
    private var inferenceDurations: [UInt64] = []
    private var endToOverlayAges: [UInt64] = []
    private var firstFrameReceivedAt: MonotonicInstant?
    private var latestFrameReceivedAt: MonotonicInstant?
    private var latestOverlayAt: MonotonicInstant?
    private var modelFailureCount: UInt64 = 0
    private var consecutiveModelFailures = 0

    public init(
        windowCapacity: Int = 120,
        thresholds: PerformanceThresholds = PerformanceThresholds()
    ) throws {
        guard windowCapacity > 0 else { throw PerformanceTelemetryError.invalidCapacity }
        guard thresholds.maximumInferenceP95Milliseconds.isFinite,
              thresholds.maximumInferenceP95Milliseconds > 0,
              thresholds.maximumObservationAgeMilliseconds.isFinite,
              thresholds.maximumObservationAgeMilliseconds > 0,
              thresholds.captureStallMilliseconds.isFinite,
              thresholds.captureStallMilliseconds > 0,
              thresholds.repeatedModelFailureLimit > 0 else {
            throw PerformanceTelemetryError.invalidSample
        }
        capacity = windowCapacity
        self.thresholds = thresholds
    }

    public func reset() {
        negotiatedFPS = nil
        producedFrames = 0
        deliveredFrames = 0
        droppedFrames = 0
        maximumQueueDepth = 0
        currentQueueDepth = 0
        frameAges.removeAll(keepingCapacity: true)
        inferenceDurations.removeAll(keepingCapacity: true)
        endToOverlayAges.removeAll(keepingCapacity: true)
        firstFrameReceivedAt = nil
        latestFrameReceivedAt = nil
        latestOverlayAt = nil
        modelFailureCount = 0
        consecutiveModelFailures = 0
    }

    public func recordFrame(
        captureInstant: MonotonicInstant,
        receivedAt: MonotonicInstant,
        negotiatedFPS: Double,
        droppedFramesSinceLastSample: UInt64,
        queueDepth: Int
    ) throws {
        guard negotiatedFPS.isFinite, negotiatedFPS > 0,
              receivedAt >= captureInstant,
              queueDepth >= 0 else { throw PerformanceTelemetryError.invalidSample }
        self.negotiatedFPS = negotiatedFPS
        producedFrames += 1 + droppedFramesSinceLastSample
        deliveredFrames += 1
        droppedFrames += droppedFramesSinceLastSample
        currentQueueDepth = queueDepth
        maximumQueueDepth = max(maximumQueueDepth, queueDepth)
        let frameAge = receivedAt.nanoseconds - captureInstant.nanoseconds
        append(frameAge, to: &frameAges)
        firstFrameReceivedAt = firstFrameReceivedAt ?? receivedAt
        latestFrameReceivedAt = receivedAt
    }

    public func recordInference(
        captureInstant: MonotonicInstant,
        startedAt: MonotonicInstant,
        finishedAt: MonotonicInstant,
        overlayAt: MonotonicInstant,
        queueDepth: Int
    ) throws {
        guard startedAt >= captureInstant,
              finishedAt >= startedAt,
              overlayAt >= captureInstant,
              queueDepth >= 0 else { throw PerformanceTelemetryError.invalidSample }
        currentQueueDepth = queueDepth
        maximumQueueDepth = max(maximumQueueDepth, queueDepth)
        append(finishedAt.nanoseconds - startedAt.nanoseconds, to: &inferenceDurations)
        append(overlayAt.nanoseconds - captureInstant.nanoseconds, to: &endToOverlayAges)
        latestOverlayAt = overlayAt
        consecutiveModelFailures = 0
    }

    public func recordModelFailure() {
        modelFailureCount += 1
        consecutiveModelFailures += 1
    }

    public func recordModelSuccess() {
        consecutiveModelFailures = 0
    }

    public func snapshot(now: MonotonicInstant) -> PerformanceTelemetrySnapshot {
        let health = evaluateHealth(now: now)
        let observedFPS: Double?
        if let firstFrameReceivedAt, let latestFrameReceivedAt,
           latestFrameReceivedAt > firstFrameReceivedAt {
            let elapsed = Double(latestFrameReceivedAt.nanoseconds - firstFrameReceivedAt.nanoseconds) / 1_000_000_000
            observedFPS = elapsed > 0 ? Double(max(0, deliveredFrames - 1)) / elapsed : nil
        } else {
            observedFPS = nil
        }
        return PerformanceTelemetrySnapshot(
            negotiatedFPS: negotiatedFPS,
            observedFPS: observedFPS,
            producedFrames: producedFrames,
            deliveredFrames: deliveredFrames,
            droppedFrames: droppedFrames,
            maximumQueueDepth: maximumQueueDepth,
            currentQueueDepth: currentQueueDepth,
            frameAgeP50Milliseconds: percentile(frameAges, fraction: 0.50),
            frameAgeP95Milliseconds: percentile(frameAges, fraction: 0.95),
            inferenceP50Milliseconds: percentile(inferenceDurations, fraction: 0.50),
            inferenceP95Milliseconds: percentile(inferenceDurations, fraction: 0.95),
            endToOverlayP50Milliseconds: percentile(endToOverlayAges, fraction: 0.50),
            endToOverlayP95Milliseconds: percentile(endToOverlayAges, fraction: 0.95),
            modelFailureCount: modelFailureCount,
            consecutiveModelFailures: consecutiveModelFailures,
            health: health,
            healthReason: reason(for: health),
            targetingAvailable: health == .ready
        )
    }

    private func evaluateHealth(now: MonotonicInstant) -> PerformanceHealth {
        guard deliveredFrames > 0 else { return .insufficientData }
        if consecutiveModelFailures >= thresholds.repeatedModelFailureLimit {
            return .modelFailed
        }
        if let p95 = percentile(inferenceDurations, fraction: 0.95),
           p95 > thresholds.maximumInferenceP95Milliseconds {
            return .slow
        }
        if let latestOverlayAt,
           millisecondsBetween(latestOverlayAt, now) > thresholds.maximumObservationAgeMilliseconds {
            return .stale
        }
        if let latestFrameReceivedAt,
           millisecondsBetween(latestFrameReceivedAt, now) > thresholds.captureStallMilliseconds {
            return .stalled
        }
        guard !frameAges.isEmpty, !inferenceDurations.isEmpty, !endToOverlayAges.isEmpty else {
            return .insufficientData
        }
        return .ready
    }

    private func reason(for health: PerformanceHealth) -> String {
        switch health {
        case .insufficientData: "Capture and inference telemetry is still warming up."
        case .ready: "Capture, inference, and observation freshness are within limits."
        case .slow: "Inference p95 exceeded \(Int(thresholds.maximumInferenceP95Milliseconds)) ms."
        case .stale: "The latest observation is older than \(Int(thresholds.maximumObservationAgeMilliseconds)) ms."
        case .stalled: "No new frame arrived within the capture stall limit."
        case .modelFailed: "The model has failed \(consecutiveModelFailures) times in a row."
        }
    }

    private func append(_ value: UInt64, to values: inout [UInt64]) {
        values.append(value)
        if values.count > capacity { values.removeFirst(values.count - capacity) }
    }

    private func percentile(_ values: [UInt64], fraction: Double) -> Double? {
        guard !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let index = min(sorted.count - 1, max(0, Int(ceil(Double(sorted.count) * fraction)) - 1))
        return Double(sorted[index]) / 1_000_000
    }

    private func millisecondsBetween(_ start: MonotonicInstant, _ end: MonotonicInstant) -> Double {
        guard end >= start else { return 0 }
        return Double(end.nanoseconds - start.nanoseconds) / 1_000_000
    }
}
