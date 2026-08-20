@preconcurrency import AVFoundation
import ArmageddonCore
import CoreMedia
import Foundation

@MainActor
final class AVFoundationNativeCaptureSession {
    private let captureSession = AVCaptureSession()
    private let nativeSession: NativeCaptureSession
    private let clock: any CaptureHostClock
    private let callbackQueue = DispatchQueue(label: "com.huenit.armageddon.capture", qos: .userInitiated)
    private var output: AVCaptureVideoDataOutput?
    private var delegate: SampleBufferDelegate?
    private var source: CaptureSourceToken?
    private var correlation: CaptureTimestampCorrelation?

    init(
        nativeSession: NativeCaptureSession = NativeCaptureSession(),
        clock: any CaptureHostClock = ContinuousCaptureHostClock()
    ) {
        self.nativeSession = nativeSession
        self.clock = clock
    }

    func previewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspect
        return layer
    }

    func start(
        device: AVCaptureDevice,
        requestedFormat: CaptureFormat = CaptureFormat(width: 1_280, height: 720, frameRate: 30)
    ) async throws -> CaptureFormat {
        await stop()
        try configure(device: device, requested: requestedFormat)
        let input = try AVCaptureDeviceInput(device: device)
        let actualFormat = negotiatedFormat(for: device, requested: requestedFormat)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true

        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        guard captureSession.canAddInput(input), captureSession.canAddOutput(videoOutput) else {
            throw AVFoundationCaptureError.configurationUnavailable
        }

        captureSession.addInput(input)
        captureSession.addOutput(videoOutput)
        let anchorPTS = CMTimeGetSeconds(CMClockGetTime(CMClockGetHostTimeClock()))
        correlation = try CaptureTimestampCorrelation(
            anchorPresentationTimestamp: anchorPTS,
            anchorInstant: clock.now()
        )
        let source = try await nativeSession.start(configuration: actualFormat)
        self.source = source
        let delegate = SampleBufferDelegate(
            session: nativeSession,
            source: source,
            format: actualFormat,
            correlation: correlation!,
            clock: clock
        )
        self.delegate = delegate
        output = videoOutput
        videoOutput.setSampleBufferDelegate(delegate, queue: callbackQueue)
        captureSession.startRunning()
        return actualFormat
    }

    var isRunning: Bool {
        captureSession.isRunning
    }

    func stop() async {
        output?.setSampleBufferDelegate(nil, queue: nil)
        delegate = nil
        output = nil
        captureSession.stopRunning()
        source = nil
        correlation = nil
        await nativeSession.stop()
    }

    func consumeLatestFrame() async -> CameraFrameMetadata? {
        await nativeSession.consumeLatest()
    }

    func snapshot() async -> NativeCaptureSessionSnapshot {
        await nativeSession.snapshot()
    }

    private func negotiatedFormat(for device: AVCaptureDevice, requested: CaptureFormat) -> CaptureFormat {
        let dimensions = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
        let frameRate = device.activeFormat.videoSupportedFrameRateRanges.first?.maxFrameRate ?? requested.frameRate
        return CaptureFormat(
            width: Int(dimensions.width),
            height: Int(dimensions.height),
            frameRate: frameRate,
            orientation: requested.orientation,
            mirrored: requested.mirrored
        )
    }

    private func configure(device: AVCaptureDevice, requested: CaptureFormat) throws {
        let requestedDimensions = CMVideoFormatDescriptionGetDimensions(
            device.activeFormat.formatDescription
        )
        let selectedFormat = device.formats.first { format in
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            guard dimensions.width == Int32(requested.width), dimensions.height == Int32(requested.height) else {
                return false
            }
            return format.videoSupportedFrameRateRanges.contains {
                $0.minFrameRate <= requested.frameRate && requested.frameRate <= $0.maxFrameRate
            }
        }

        guard selectedFormat != nil ||
                (requestedDimensions.width == Int32(requested.width) &&
                 requestedDimensions.height == Int32(requested.height)) else {
            return
        }

        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }
        if let selectedFormat {
            device.activeFormat = selectedFormat
        }
        let timescale = CMTimeScale(max(1, Int32(requested.frameRate.rounded())))
        let frameDuration = CMTime(value: 1, timescale: timescale)
        device.activeVideoMinFrameDuration = frameDuration
        device.activeVideoMaxFrameDuration = frameDuration
    }
}

enum AVFoundationCaptureError: Error, Equatable, Sendable {
    case configurationUnavailable
}

private final class SampleBufferDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    private let session: NativeCaptureSession
    private let source: CaptureSourceToken
    private let format: CaptureFormat
    private let correlation: CaptureTimestampCorrelation
    private let clock: any CaptureHostClock
    private var nextFrameID: UInt64 = 0

    init(
        session: NativeCaptureSession,
        source: CaptureSourceToken,
        format: CaptureFormat,
        correlation: CaptureTimestampCorrelation,
        clock: any CaptureHostClock
    ) {
        self.session = session
        self.source = source
        self.format = format
        self.correlation = correlation
        self.clock = clock
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let rawPTS = CMTimeGetSeconds(sampleBuffer.presentationTimeStamp)
        let now = clock.now()
        guard let captureInstant = try? correlation.map(presentationTimestamp: rawPTS, now: now) else {
            return
        }
        let frame = CameraFrameMetadata(
            id: nextFrameID,
            rawPresentationTimestamp: rawPTS,
            captureInstant: captureInstant,
            format: format
        )
        nextFrameID &+= 1
        Task {
            try? await session.ingest(frame, source: source)
        }
    }
}
