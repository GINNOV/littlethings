@preconcurrency import AVFoundation
import ArmageddonCore
import CoreImage
import CoreMedia
import Foundation

@MainActor
public final class AVFoundationNativeCaptureSession {
    private let captureSession = AVCaptureSession()
    private let nativeSession: NativeCaptureSession
    private let clock: any CaptureHostClock
    private let callbackQueue = DispatchQueue(label: "com.huenit.armageddon.capture", qos: .userInitiated)
    private var input: AVCaptureDeviceInput?
    private var output: AVCaptureVideoDataOutput?
    private var delegate: SampleBufferDelegate?
    private var source: CaptureSourceToken?
    private var correlation: CaptureTimestampCorrelation?
    private let latestImageStore = LatestImageStore()

    public init(
        nativeSession: NativeCaptureSession = NativeCaptureSession(),
        clock: any CaptureHostClock = ContinuousCaptureHostClock()
    ) {
        self.nativeSession = nativeSession
        self.clock = clock
    }

    public func previewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspect
        return layer
    }

    public func start(
        device: AVCaptureDevice,
        requestedFormat: CaptureFormat = CaptureFormat(width: 1_280, height: 720, frameRate: 30)
    ) async throws -> CaptureFormat {
        await stop()
        latestImageStore.clear()
        let configuredRequestedFormat = try configure(device: device, requested: requestedFormat)
        let input = try AVCaptureDeviceInput(device: device)
        let actualFormat = negotiatedFormat(
            for: device,
            requested: requestedFormat,
            configuredRequestedFormat: configuredRequestedFormat
        )
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true

        captureSession.beginConfiguration()
        guard captureSession.canAddInput(input), captureSession.canAddOutput(videoOutput) else {
            captureSession.commitConfiguration()
            throw AVFoundationCaptureError.configurationUnavailable
        }

        captureSession.addInput(input)
        captureSession.addOutput(videoOutput)
        self.input = input
        self.output = videoOutput
        configure(connection: videoOutput.connection(with: .video), for: actualFormat)
        captureSession.commitConfiguration()

        let anchorPTS = CMTimeGetSeconds(CMClockGetTime(CMClockGetHostTimeClock()))
        correlation = try CaptureTimestampCorrelation(
            anchorPresentationTimestamp: anchorPTS,
            anchorInstant: clock.now()
        )
        do {
            let source = try await nativeSession.start(configuration: actualFormat)
            self.source = source
            let delegate = SampleBufferDelegate(
                session: nativeSession,
                source: source,
                format: actualFormat,
                correlation: correlation!,
                clock: clock,
                imageStore: latestImageStore
            )
            self.delegate = delegate
            videoOutput.setSampleBufferDelegate(delegate, queue: callbackQueue)
            captureSession.startRunning()
            return actualFormat
        } catch {
            await stop()
            throw error
        }
    }

    public var isRunning: Bool {
        captureSession.isRunning
    }

    public var attachedResourceCount: Int {
        captureSession.inputs.count + captureSession.outputs.count
    }

    public func stop() async {
        output?.setSampleBufferDelegate(nil, queue: nil)
        delegate = nil
        captureSession.stopRunning()
        captureSession.beginConfiguration()
        if let output, captureSession.outputs.contains(output) {
            captureSession.removeOutput(output)
        }
        if let input, captureSession.inputs.contains(input) {
            captureSession.removeInput(input)
        }
        captureSession.commitConfiguration()
        output = nil
        input = nil
        source = nil
        correlation = nil
        latestImageStore.clear()
        await nativeSession.stop()
    }

    func consumeLatestFrame() async -> CameraFrameMetadata? {
        await nativeSession.consumeLatest()
    }

    func consumeLatestImageData() -> Data? {
        latestImageStore.value
    }

    func snapshot() async -> NativeCaptureSessionSnapshot {
        await nativeSession.snapshot()
    }

    private func negotiatedFormat(
        for device: AVCaptureDevice,
        requested: CaptureFormat,
        configuredRequestedFormat: Bool
    ) -> CaptureFormat {
        let dimensions = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
        let configuredDuration = CMTimeGetSeconds(device.activeVideoMinFrameDuration)
        let frameRate = configuredRequestedFormat
            ? requested.frameRate
            : configuredDuration.isFinite && configuredDuration > 0
            ? 1 / configuredDuration
            : device.activeFormat.videoSupportedFrameRateRanges.first?.maxFrameRate ?? requested.frameRate
        return CaptureFormat(
            width: Int(dimensions.width),
            height: Int(dimensions.height),
            frameRate: frameRate,
            orientation: requested.orientation,
            mirrored: requested.mirrored
        )
    }

    private func configure(connection: AVCaptureConnection?, for format: CaptureFormat) {
        guard let connection else { return }
        let rotationAngle: CGFloat = switch format.orientation {
        case .portrait: 90
        case .portraitUpsideDown: 270
        case .landscapeLeft: 180
        case .landscapeRight: 0
        case .unknown: connection.videoRotationAngle
        }
        if connection.isVideoRotationAngleSupported(rotationAngle) {
            connection.videoRotationAngle = rotationAngle
        }
        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = format.mirrored
        }
    }

    private func configure(device: AVCaptureDevice, requested: CaptureFormat) throws -> Bool {
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

        let activeFormatSupportsRequestedRate = device.activeFormat.videoSupportedFrameRateRanges.contains {
            $0.minFrameRate <= requested.frameRate && requested.frameRate <= $0.maxFrameRate
        }
        guard selectedFormat != nil ||
                (requestedDimensions.width == Int32(requested.width) &&
                 requestedDimensions.height == Int32(requested.height) &&
                 activeFormatSupportsRequestedRate) else {
            return false
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
        return true
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
    private let imageStore: LatestImageStore
    private let imageContext = CIContext()
    private var nextFrameID: UInt64 = 0

    init(
        session: NativeCaptureSession,
        source: CaptureSourceToken,
        format: CaptureFormat,
        correlation: CaptureTimestampCorrelation,
        clock: any CaptureHostClock,
        imageStore: LatestImageStore
    ) {
        self.session = session
        self.source = source
        self.format = format
        self.correlation = correlation
        self.clock = clock
        self.imageStore = imageStore
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
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
           let jpeg = imageContext.jpegRepresentation(
               of: CIImage(cvPixelBuffer: pixelBuffer),
               colorSpace: CGColorSpaceCreateDeviceRGB(),
               options: [:]
           ) {
            imageStore.store(jpeg)
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

private final class LatestImageStore: @unchecked Sendable {
    private let lock = NSLock()
    private var data: Data?

    var value: Data? {
        lock.lock()
        defer { lock.unlock() }
        return data
    }

    func store(_ data: Data) {
        lock.lock()
        self.data = data
        lock.unlock()
    }

    func clear() {
        lock.lock()
        data = nil
        lock.unlock()
    }
}
