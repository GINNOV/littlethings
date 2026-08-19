import Testing
@testable import ArmageddonCore

struct DeviceCapabilityTests {
    @Test("No cameras produces an empty catalog")
    func catalogIsEmptyWhenNoCamerasAreDiscovered() async {
        // Given
        let cameras = DeterministicNativeCameraDiscovery(cameras: [])
        let serialDevices = DeterministicSerialDeviceDiscovery(devices: [])
        let catalog = DeviceCatalog(nativeCameraDiscovery: cameras, serialDeviceDiscovery: serialDevices)

        // When
        let events = await catalog.refresh()

        // Then
        #expect(await catalog.devices() == [])
        #expect(events == [])
    }

    @Test("One native camera receives only video frame capability")
    func nativeCameraHasExactVideoFrameCapability() async {
        // Given
        let camera = NativeCameraDevice(stableIdentifier: "camera-1", permission: .authorized)
        let catalog = DeviceCatalog(
            nativeCameraDiscovery: DeterministicNativeCameraDiscovery(cameras: [camera]),
            serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [])
        )

        // When
        _ = await catalog.refresh()

        // Then
        #expect(await catalog.devices().map(\.capabilities) == [[.videoFrames]])
    }

    @Test("Multiple native cameras keep distinct identities")
    func nativeCamerasHaveDistinctIdentities() async {
        // Given
        let catalog = DeviceCatalog(
            nativeCameraDiscovery: DeterministicNativeCameraDiscovery(cameras: [
                NativeCameraDevice(stableIdentifier: "camera-1", permission: .authorized),
                NativeCameraDevice(stableIdentifier: "camera-2", permission: .authorized),
            ]),
            serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [])
        )

        // When
        _ = await catalog.refresh()

        // Then
        #expect(Set(await catalog.devices().map(\.identity)).count == 2)
    }

    @Test("Arm and HUENIT_CAM serial camera coexist without an identity collision")
    func armAndSerialCameraCoexist() async {
        // Given
        let arm = SerialDevice(registryPath: "/dev/cu.arm", serialNumber: "same-token", role: .arm)
        let camera = SerialDevice(
            registryPath: "/dev/cu.HUENIT_CAM",
            serialNumber: "same-token",
            role: .camera,
            productName: "HUENIT_CAM"
        )
        let catalog = DeviceCatalog(
            nativeCameraDiscovery: DeterministicNativeCameraDiscovery(cameras: []),
            serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [arm, camera])
        )

        // When
        _ = await catalog.refresh()

        // Then
        let devices = await catalog.devices()
        #expect(Set(devices.map(\.identity)).count == 2)
        #expect(devices.first { $0.identity == .serialCamera("same-token") }?.capabilities == [.serialTelemetry, .artifactInventory])
        #expect(devices.first { $0.identity == .arm("same-token") }?.capabilities == [.serialTelemetry, .artifactInventory, .armMotion])
    }

    @Test("HUENIT_CAM naming does not grant video frame capability")
    func serialCameraDoesNotInferVideoFramesFromItsName() async {
        // Given
        let serialCamera = SerialDevice(
            registryPath: "/dev/cu.HUENIT_CAM",
            serialNumber: "cam-serial",
            role: .camera,
            productName: "HUENIT_CAM"
        )
        let catalog = DeviceCatalog(
            nativeCameraDiscovery: DeterministicNativeCameraDiscovery(cameras: []),
            serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [serialCamera])
        )

        // When
        _ = await catalog.refresh()

        // Then
        #expect(await catalog.devices().map(\.capabilities) == [[.serialTelemetry, .artifactInventory]])
    }

    @Test("Unplugging then replugging a camera with a new stable identity emits hot-plug events")
    func replugWithNewIdentityEmitsRemovalAndAddition() async {
        // Given
        let cameras = DeterministicNativeCameraDiscovery(cameras: [
            NativeCameraDevice(stableIdentifier: "camera-old", permission: .authorized),
        ])
        let catalog = DeviceCatalog(
            nativeCameraDiscovery: cameras,
            serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [])
        )
        _ = await catalog.refresh()
        await cameras.setCameras([
            NativeCameraDevice(stableIdentifier: "camera-new", permission: .authorized),
        ])

        // When
        let events = await catalog.refresh()

        // Then
        #expect(events == [
            .removed(.nativeCamera("camera-old")),
            .added(DeviceRecord.nativeCamera(stableIdentifier: "camera-new", permission: .authorized)),
        ])
    }

    @Test("A selection becomes stale when its device is unplugged")
    func selectionBecomesStaleAfterUnplug() async throws {
        // Given
        let camera = NativeCameraDevice(stableIdentifier: "camera-1", permission: .authorized)
        let cameras = DeterministicNativeCameraDiscovery(cameras: [camera])
        let catalog = DeviceCatalog(
            nativeCameraDiscovery: cameras,
            serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [])
        )
        _ = await catalog.refresh()
        try await catalog.select(.nativeCamera("camera-1"))
        await cameras.setCameras([])

        // When
        let events = await catalog.refresh()

        // Then
        #expect(await catalog.selection() == .stale(.nativeCamera("camera-1")))
        #expect(events.contains(.selectionBecameStale(.nativeCamera("camera-1"))))
    }

    @Test("A camera-only serial presence does not create an arm")
    func serialCameraAloneDoesNotCreateArm() async {
        // Given
        let catalog = DeviceCatalog(
            nativeCameraDiscovery: DeterministicNativeCameraDiscovery(cameras: []),
            serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [
                SerialDevice(
                    registryPath: "/dev/cu.HUENIT_CAM",
                    serialNumber: "camera-only",
                    role: .camera,
                    productName: "HUENIT_CAM"
                ),
            ])
        )

        // When
        _ = await catalog.refresh()

        // Then
        #expect(await catalog.devices().map(\.kind) == [.camera])
        #expect(await catalog.devices().map(\.identity) == [.serialCamera("camera-only")])
    }

    @Test("Display and diagnostics redact serial numbers and registry paths")
    func diagnosticsAreRedacted() {
        // Given
        let device = DeviceRecord.arm(
            serialNumber: "SENSITIVE-SERIAL",
            registryPath: "/dev/cu.SENSITIVE-PATH"
        )

        // When
        let display = device.redactedDisplay
        let diagnostics = device.redactedDiagnostics

        // Then
        #expect(display.contains("SENSITIVE-SERIAL") == false)
        #expect(diagnostics.contains("SENSITIVE-SERIAL") == false)
        #expect(diagnostics.contains("SENSITIVE-PATH") == false)
    }

    @Test("Lifecycle rejects impossible disconnected to connected transition")
    func lifecycleRejectsImpossibleTransition() {
        // Given
        let lifecycle = DeviceConnectionLifecycle.disconnected

        // When
        let transition = { try lifecycle.transitioning(to: .connected) }

        // Then
        #expect(throws: DeviceLifecycleTransitionError.impossible(from: .disconnected, to: .connected), performing: transition)
    }
}
