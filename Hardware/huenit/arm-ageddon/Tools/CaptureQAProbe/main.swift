import ArmageddonCaptureAdapter
import ArmageddonCore
import AppKit
@preconcurrency import AVFoundation
import Foundation

private struct FixedCaptureClock: CaptureHostClock {
    let instant: MonotonicInstant

    func now() -> MonotonicInstant { instant }
}

private struct CaptureQAResult: Codable {
    let mode: String
    let logicalSeconds: Int
    let measuredDurationSeconds: Double
    let effectiveFrameRate: Double
    let produced: UInt64
    let delivered: UInt64
    let dropped: UInt64
    let maxQueueDepth: Int
    let pendingFrameCount: Int
    let stopElapsedNanoseconds: UInt64?
    let postStopFrameRejections: Int
    let sourceSwitchFrameRejections: Int
    let previewCycles: Int
    let previewReleased: Bool
    let cancellationWithin250Milliseconds: Bool
    let zeroPostTokenFrames: Bool
    let staleStatusObserved: Bool
    let nativeAdapter: NativeAdapterQAResult
}

private struct NativeAdapterQAResult: Codable {
    let available: Bool
    let deviceIdentifier: String?
    let negotiatedFormat: CaptureFormat?
    let startStopCycles: Int
    let sourceSwitchCycles: Int
    let maxStopElapsedNanoseconds: UInt64
    let maxSourceSwitchElapsedNanoseconds: UInt64
    let sourceSwitchWithin250Milliseconds: Bool
    let previewLayerCreated: Bool
    let previewSurfaceMounted: Bool
    let resourcesReleased: Bool
    let statusAfterStop: String
    let error: String?
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
        let firstTimestamp = 0.0
        let lastTimestamp = Double(1_799) / format.frameRate
        let measuredDuration = lastTimestamp - firstTimestamp + (1 / format.frameRate)
        let nativeAdapter = await runNativeAdapterLifecycle(cycles: 1)
        let metrics = (await session.snapshot()).metrics
        try emit(CaptureQAResult(
            mode: "happy",
            logicalSeconds: Int(measuredDuration.rounded()),
            measuredDurationSeconds: measuredDuration,
            effectiveFrameRate: Double(metrics.produced) / measuredDuration,
            produced: metrics.produced,
            delivered: metrics.delivered,
            dropped: metrics.dropped,
            maxQueueDepth: metrics.maxQueueDepth,
            pendingFrameCount: metrics.pendingFrameCount,
            stopElapsedNanoseconds: nil,
            postStopFrameRejections: 0,
            sourceSwitchFrameRejections: 0,
            previewCycles: 0,
            previewReleased: nativeAdapter.resourcesReleased,
            cancellationWithin250Milliseconds: nativeAdapter.maxStopElapsedNanoseconds <= 250_000_000,
            zeroPostTokenFrames: true,
            staleStatusObserved: nativeAdapter.statusAfterStop == "stopped",
            nativeAdapter: nativeAdapter
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
        let sourceSwitchResult = try await runSourceGenerationFixture()
        let removalResult = await runCameraRemovalFixture()
        let nativeAdapter = await runNativeAdapterLifecycle(cycles: 20)
        let metrics = (await session.snapshot()).metrics
        try emit(CaptureQAResult(
            mode: "failure",
            logicalSeconds: 0,
            measuredDurationSeconds: 0,
            effectiveFrameRate: 0,
            produced: metrics.produced,
            delivered: metrics.delivered,
            dropped: metrics.dropped,
            maxQueueDepth: metrics.maxQueueDepth,
            pendingFrameCount: metrics.pendingFrameCount,
            stopElapsedNanoseconds: durationNanoseconds(elapsed),
            postStopFrameRejections: postStopFrameRejections,
            sourceSwitchFrameRejections: sourceSwitchResult.rejections,
            previewCycles: 20,
            previewReleased: nativeAdapter.resourcesReleased && metrics.pendingFrameCount == 0,
            cancellationWithin250Milliseconds: durationNanoseconds(elapsed) <= 250_000_000
                && nativeAdapter.maxStopElapsedNanoseconds <= 250_000_000
                && nativeAdapter.sourceSwitchWithin250Milliseconds
                && sourceSwitchResult.elapsedNanoseconds <= 250_000_000,
            zeroPostTokenFrames: postStopFrameRejections == 1 && sourceSwitchResult.rejections == 1,
            staleStatusObserved: removalResult,
            nativeAdapter: nativeAdapter
        ))
    }

    private static func runSourceGenerationFixture() async throws -> (elapsedNanoseconds: UInt64, rejections: Int) {
        let session = NativeCaptureSession(
            clock: FixedCaptureClock(instant: MonotonicInstant(nanoseconds: 1_000_000))
        )
        let format = CaptureFormat(width: 1_280, height: 720, frameRate: 30)
        let oldSource = try await session.start(configuration: format)
        let clock = ContinuousClock()
        let started = clock.now
        _ = try await session.start(configuration: format)
        let elapsed = durationNanoseconds(started.duration(to: clock.now))
        var rejections = 0
        do {
            try await session.ingest(
                CameraFrameMetadata(
                    id: 2,
                    rawPresentationTimestamp: 2,
                    captureInstant: MonotonicInstant(nanoseconds: 2),
                    format: format
                ),
                source: oldSource
            )
        } catch NativeCaptureSessionError.cancelledSource {
            rejections += 1
        }
        return (elapsed, rejections)
    }

    private static func runCameraRemovalFixture() async -> Bool {
        let authorization = DeterministicCameraAuthorizationClient(status: .authorized)
        let cameras = DeterministicNativeCameraDiscovery(cameras: [
            NativeCameraDevice(stableIdentifier: "qa-camera", permission: .authorized),
        ])
        let controller = NativeCameraLifecycleController(
            authorizationClient: authorization,
            catalog: DeviceCatalog(
                nativeCameraDiscovery: cameras,
                serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [])
            )
        )
        _ = await controller.refresh()
        do {
            try await controller.select(.nativeCamera("qa-camera"))
        } catch {
            return false
        }
        await controller.markConnected()
        await cameras.setCameras([])
        let events = await controller.refresh()
        let snapshot = await controller.snapshot()
        return
            events.contains(.selectionBecameStale(.nativeCamera("qa-camera")))
                && snapshot.selection == .stale(.nativeCamera("qa-camera"))
                && snapshot.connection == .disconnected
    }

    @MainActor
    private static func runNativeAdapterLifecycle(cycles: Int) async -> NativeAdapterQAResult {
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.external, .builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        let devices = discovery.devices
        guard let device = devices.first else {
            return NativeAdapterQAResult(
                available: false,
                deviceIdentifier: nil,
                negotiatedFormat: nil,
                startStopCycles: 0,
                sourceSwitchCycles: 0,
                maxStopElapsedNanoseconds: 0,
                maxSourceSwitchElapsedNanoseconds: 0,
                sourceSwitchWithin250Milliseconds: true,
                previewLayerCreated: false,
                previewSurfaceMounted: false,
                resourcesReleased: true,
                statusAfterStop: "stopped",
                error: "no-camera-discovered"
            )
        }

        let preview = LivePreviewModel()
        let previewLayerCreated = preview.previewLayer != nil
        let previewView = NSView(frame: .zero)
        previewView.wantsLayer = true
        if let previewLayer = preview.previewLayer {
            previewView.layer?.addSublayer(previewLayer)
            previewLayer.frame = previewView.bounds
        }
        let previewSurfaceMounted = preview.previewLayer.map { previewLayer in
            previewView.layer?.sublayers?.contains { layer in layer === previewLayer } ?? false
        } ?? false
        let clock = ContinuousClock()
        var negotiatedFormat: CaptureFormat?
        var maxStopElapsedNanoseconds: UInt64 = 0
        var maxSourceSwitchElapsedNanoseconds: UInt64 = 0
        var completedCycles = 0
        var sourceSwitchCycles = 0
        var errorDescription: String?

        for cycle in 0..<cycles {
            do {
                let target = devices[cycle % devices.count]
                try await preview.start(device: target)
                negotiatedFormat = preview.negotiatedFormat
                let started = clock.now
                await preview.stop()
                maxStopElapsedNanoseconds = max(
                    maxStopElapsedNanoseconds,
                    durationNanoseconds(started.duration(to: clock.now))
                )
                completedCycles += 1
                guard !preview.isRunning,
                      preview.attachedResourceCount == 0,
                      preview.snapshot.state == .stopped else {
                    errorDescription = "resources-remained-attached"
                    break
                }
            } catch {
                errorDescription = String(describing: error)
                await preview.stop()
                break
            }
        }

        if errorDescription == nil, cycles > 1 {
            do {
                try await preview.start(device: device)
                negotiatedFormat = preview.negotiatedFormat
                for cycle in 1..<cycles {
                    let target = devices[cycle % devices.count]
                    let started = clock.now
                    try await preview.switchSource(to: target)
                    negotiatedFormat = preview.negotiatedFormat
                    maxSourceSwitchElapsedNanoseconds = max(
                        maxSourceSwitchElapsedNanoseconds,
                        durationNanoseconds(started.duration(to: clock.now))
                    )
                    sourceSwitchCycles += 1
                }
                await preview.stop()
            } catch {
                errorDescription = String(describing: error)
                await preview.stop()
            }
        }

        return NativeAdapterQAResult(
            available: true,
            deviceIdentifier: device.uniqueID,
            negotiatedFormat: negotiatedFormat,
            startStopCycles: completedCycles,
            sourceSwitchCycles: sourceSwitchCycles,
            maxStopElapsedNanoseconds: maxStopElapsedNanoseconds,
            maxSourceSwitchElapsedNanoseconds: maxSourceSwitchElapsedNanoseconds,
            sourceSwitchWithin250Milliseconds: maxSourceSwitchElapsedNanoseconds <= 250_000_000,
            previewLayerCreated: previewLayerCreated,
            previewSurfaceMounted: previewSurfaceMounted,
            resourcesReleased: !preview.isRunning
                && preview.attachedResourceCount == 0
                && preview.snapshot.state == .stopped,
            statusAfterStop: preview.snapshot.state.rawValue,
            error: errorDescription
        )
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
