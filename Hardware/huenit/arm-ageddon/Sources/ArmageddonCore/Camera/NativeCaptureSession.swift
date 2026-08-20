public actor NativeCaptureSession {
    private let queue = LatestFrameQueue<CameraFrameMetadata>()
    private let clock: any CaptureHostClock
    private var state = NativeCaptureSessionState.idle
    private var configuration: CaptureFormat?
    private var source: CaptureSourceToken?
    private var generation: UInt64 = 0
    private var produced: UInt64 = 0
    private var delivered: UInt64 = 0
    private var latestFrameAgeNanoseconds: UInt64?

    public init(clock: any CaptureHostClock = ContinuousCaptureHostClock()) {
        self.clock = clock
    }

    @discardableResult
    public func start(configuration: CaptureFormat) async throws -> CaptureSourceToken {
        guard configuration.isValid else { throw NativeCaptureSessionError.invalidFormat }
        generation += 1
        let token = CaptureSourceToken(generation: generation)
        self.configuration = configuration
        source = token
        state = .running
        await queue.clear()
        return token
    }

    public func stop() async {
        generation += 1
        state = .stopped
        source = nil
        await queue.clear()
    }

    public func ingest(_ frame: CameraFrameMetadata, source token: CaptureSourceToken) async throws {
        guard state == .running else { throw NativeCaptureSessionError.notRunning }
        guard source == token else { throw NativeCaptureSessionError.cancelledSource }
        produced += 1
        _ = await queue.push(frame)
    }

    public func consumeLatest() async -> CameraFrameMetadata? {
        guard state == .running, let frame = await queue.takeLatest() else { return nil }
        delivered += 1
        let now = clock.now()
        latestFrameAgeNanoseconds = now.nanoseconds >= frame.captureInstant.nanoseconds
            ? now.nanoseconds - frame.captureInstant.nanoseconds
            : nil
        return frame
    }

    public func snapshot() async -> NativeCaptureSessionSnapshot {
        let queueMetrics = await queue.metrics()
        return NativeCaptureSessionSnapshot(
            state: state,
            configuration: configuration,
            source: source,
            metrics: NativeCaptureSessionMetrics(
                produced: produced,
                delivered: delivered,
                dropped: queueMetrics.dropped,
                maxQueueDepth: queueMetrics.maxDepth,
                latestFrameAgeNanoseconds: latestFrameAgeNanoseconds
            )
        )
    }
}
