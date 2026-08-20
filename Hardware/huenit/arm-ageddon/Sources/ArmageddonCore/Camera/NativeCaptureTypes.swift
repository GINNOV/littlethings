import Foundation

public struct MonotonicInstant: Codable, Comparable, Equatable, Hashable, Sendable {
    public let nanoseconds: UInt64

    public init(nanoseconds: UInt64) {
        self.nanoseconds = nanoseconds
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.nanoseconds < rhs.nanoseconds
    }

    public func adding(nanoseconds: Int64) -> Self? {
        if nanoseconds >= 0 {
            let (value, overflow) = self.nanoseconds.addingReportingOverflow(UInt64(nanoseconds))
            return overflow ? nil : Self(nanoseconds: value)
        }

        let magnitude = UInt64(nanoseconds.magnitude)
        guard self.nanoseconds >= magnitude else { return nil }
        return Self(nanoseconds: self.nanoseconds - magnitude)
    }
}

public protocol CaptureHostClock: Sendable {
    func now() -> MonotonicInstant
}

public struct ContinuousCaptureHostClock: CaptureHostClock, Sendable {
    private let clock: ContinuousClock
    private let origin: ContinuousClock.Instant

    public init() {
        let clock = ContinuousClock()
        self.clock = clock
        origin = clock.now
    }

    public func now() -> MonotonicInstant {
        let components = origin.duration(to: clock.now).components
        let seconds = max(0, components.seconds)
        let attoseconds = max(0, components.attoseconds)
        let nanoseconds = UInt64(seconds) * 1_000_000_000
            + UInt64(attoseconds / 1_000_000_000)
        return MonotonicInstant(nanoseconds: nanoseconds)
    }
}

public enum CaptureVideoOrientation: String, Codable, Equatable, Sendable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    case unknown
}

public struct CaptureFormat: Codable, Equatable, Sendable {
    public let width: Int
    public let height: Int
    public let frameRate: Double
    public let orientation: CaptureVideoOrientation
    public let mirrored: Bool

    public init(
        width: Int,
        height: Int,
        frameRate: Double,
        orientation: CaptureVideoOrientation = .landscapeRight,
        mirrored: Bool = false
    ) {
        self.width = width
        self.height = height
        self.frameRate = frameRate
        self.orientation = orientation
        self.mirrored = mirrored
    }

    public var isValid: Bool {
        width > 0 && height > 0 && frameRate.isFinite && frameRate > 0
    }
}

public struct CameraFrameMetadata: Codable, Equatable, Sendable, Identifiable {
    public let id: UInt64
    public let rawPresentationTimestamp: Double
    public let captureInstant: MonotonicInstant
    public let format: CaptureFormat

    public init(
        id: UInt64,
        rawPresentationTimestamp: Double,
        captureInstant: MonotonicInstant,
        format: CaptureFormat
    ) {
        self.id = id
        self.rawPresentationTimestamp = rawPresentationTimestamp
        self.captureInstant = captureInstant
        self.format = format
    }
}

public enum CaptureTimestampMappingError: Error, Equatable, Sendable {
    case invalidPresentationTimestamp
    case discontinuity
    case overflow
    case futureCapture
}

public struct CaptureTimestampCorrelation: Codable, Equatable, Sendable {
    public let anchorPresentationTimestamp: Double
    public let anchorInstant: MonotonicInstant

    public init(anchorPresentationTimestamp: Double, anchorInstant: MonotonicInstant) throws {
        guard anchorPresentationTimestamp.isFinite else {
            throw CaptureTimestampMappingError.invalidPresentationTimestamp
        }
        self.anchorPresentationTimestamp = anchorPresentationTimestamp
        self.anchorInstant = anchorInstant
    }

    public func map(
        presentationTimestamp: Double,
        now: MonotonicInstant
    ) throws -> MonotonicInstant {
        guard presentationTimestamp.isFinite else {
            throw CaptureTimestampMappingError.invalidPresentationTimestamp
        }
        guard presentationTimestamp >= anchorPresentationTimestamp else {
            throw CaptureTimestampMappingError.discontinuity
        }

        let deltaNanoseconds = (presentationTimestamp - anchorPresentationTimestamp) * 1_000_000_000
        guard deltaNanoseconds.isFinite,
              deltaNanoseconds >= 0,
              deltaNanoseconds <= Double(Int64.max) else {
            throw CaptureTimestampMappingError.overflow
        }
        guard let mapped = anchorInstant.adding(nanoseconds: Int64(deltaNanoseconds.rounded())) else {
            throw CaptureTimestampMappingError.overflow
        }
        guard mapped <= now else {
            throw CaptureTimestampMappingError.futureCapture
        }
        return mapped
    }
}

public struct LatestFrameQueueMetrics: Codable, Equatable, Sendable {
    public let enqueued: UInt64
    public let dropped: UInt64
    public let maxDepth: Int
    public let depth: Int

    public init(enqueued: UInt64 = 0, dropped: UInt64 = 0, maxDepth: Int = 0, depth: Int = 0) {
        self.enqueued = enqueued
        self.dropped = dropped
        self.maxDepth = maxDepth
        self.depth = depth
    }
}

public actor LatestFrameQueue<Element: Sendable> {
    private var latest: Element?
    private var enqueued = 0 as UInt64
    private var dropped = 0 as UInt64
    private var maxDepth = 0

    public init() {}

    @discardableResult
    public func push(_ element: Element) -> LatestFrameQueueMetrics {
        enqueued += 1
        if latest != nil { dropped += 1 }
        latest = element
        maxDepth = max(maxDepth, 1)
        return metrics()
    }

    public func takeLatest() -> Element? {
        defer { latest = nil }
        return latest
    }

    public func clear() {
        latest = nil
    }

    public func metrics() -> LatestFrameQueueMetrics {
        LatestFrameQueueMetrics(
            enqueued: enqueued,
            dropped: dropped,
            maxDepth: maxDepth,
            depth: latest == nil ? 0 : 1
        )
    }
}

public enum NativeCaptureSessionState: String, Codable, Equatable, Sendable {
    case idle
    case running
    case stopped
}

public struct CaptureSourceToken: Codable, Equatable, Sendable {
    public let generation: UInt64

    public init(generation: UInt64) {
        self.generation = generation
    }
}

public enum NativeCaptureSessionError: Error, Equatable, Sendable {
    case invalidFormat
    case notRunning
    case cancelledSource
}

public struct NativeCaptureSessionMetrics: Codable, Equatable, Sendable {
    public let produced: UInt64
    public let delivered: UInt64
    public let dropped: UInt64
    public let maxQueueDepth: Int
    public let latestFrameAgeNanoseconds: UInt64?

    public init(
        produced: UInt64 = 0,
        delivered: UInt64 = 0,
        dropped: UInt64 = 0,
        maxQueueDepth: Int = 0,
        latestFrameAgeNanoseconds: UInt64? = nil
    ) {
        self.produced = produced
        self.delivered = delivered
        self.dropped = dropped
        self.maxQueueDepth = maxQueueDepth
        self.latestFrameAgeNanoseconds = latestFrameAgeNanoseconds
    }
}

public struct NativeCaptureSessionSnapshot: Codable, Equatable, Sendable {
    public let state: NativeCaptureSessionState
    public let configuration: CaptureFormat?
    public let source: CaptureSourceToken?
    public let metrics: NativeCaptureSessionMetrics

    public init(
        state: NativeCaptureSessionState,
        configuration: CaptureFormat?,
        source: CaptureSourceToken?,
        metrics: NativeCaptureSessionMetrics
    ) {
        self.state = state
        self.configuration = configuration
        self.source = source
        self.metrics = metrics
    }
}
