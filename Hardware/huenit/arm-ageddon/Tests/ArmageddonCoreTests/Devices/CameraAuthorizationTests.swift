import Testing
@testable import ArmageddonCore

struct CameraAuthorizationTests {
    private func makeController(
        authorization: DeterministicCameraAuthorizationClient,
        cameras: DeterministicNativeCameraDiscovery
    ) -> NativeCameraLifecycleController {
        NativeCameraLifecycleController(
            authorizationClient: authorization,
            catalog: DeviceCatalog(
                nativeCameraDiscovery: cameras,
                serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [])
            )
        )
    }

    @Test("Authorization request transitions to authorized before camera selection")
    func requestThenSelect() async throws {
        let authorization = DeterministicCameraAuthorizationClient(
            status: .notDetermined,
            requestResult: .authorized
        )
        let cameras = DeterministicNativeCameraDiscovery(cameras: [
            NativeCameraDevice(stableIdentifier: "camera-1", permission: .authorized),
        ])
        let controller = makeController(authorization: authorization, cameras: cameras)

        #expect(await authorization.requestCount == 0)
        #expect((await controller.snapshot()).canRequestPermission)

        let requested = await controller.requestAuthorization()
        #expect(requested.authorization == .authorized)
        #expect(requested.selection == .none)
        #expect(requested.connection == .available)
        #expect(await authorization.requestCount == 1)

        try await controller.select(.nativeCamera("camera-1"))
        #expect((await controller.snapshot()).selection == .selected(.nativeCamera("camera-1")))
    }

    @Test("All authorization outcomes expose the correct recovery affordance")
    func authorizationRecoveryActions() async {
        let outcomes: [(CameraAuthorizationStatus, CameraAuthorizationRecoveryAction?)] = [
            (.notDetermined, .requestPermission),
            (.requesting, nil),
            (.authorized, .rescan),
            (.denied, .openSystemSettings),
            (.restricted, .openSystemSettings),
            (.unavailable, nil),
            (.failed, nil),
        ]

        for (status, expectedAction) in outcomes {
            let authorization = DeterministicCameraAuthorizationClient(status: status)
            let controller = makeController(
                authorization: authorization,
                cameras: DeterministicNativeCameraDiscovery(cameras: [])
            )
            _ = await controller.refresh()
            let snapshot = await controller.snapshot()
            #expect(snapshot.authorization == status)
            #expect(status.recoveryAction == expectedAction)
            #expect(snapshot.canRequestPermission == (status == .notDetermined))
            #expect(snapshot.canOpenSystemSettings == (status == .denied || status == .restricted))
        }
    }

    @Test("Denied permission never triggers discovery and offers system settings")
    func deniedPermissionFailsClosed() async {
        let authorization = DeterministicCameraAuthorizationClient(status: .denied)
        let cameras = DeterministicNativeCameraDiscovery(cameras: [
            NativeCameraDevice(stableIdentifier: "camera-should-not-appear", permission: .authorized),
        ])
        let controller = makeController(authorization: authorization, cameras: cameras)

        let events = await controller.refresh()

        #expect(events.isEmpty)
        #expect((await controller.snapshot()).connection == .unavailable)
        #expect((await controller.snapshot()).canOpenSystemSettings)
    }

    @Test("Unplugging a selected camera marks selection stale and disconnected")
    func unplugAndRecover() async throws {
        let authorization = DeterministicCameraAuthorizationClient(status: .authorized)
        let cameras = DeterministicNativeCameraDiscovery(cameras: [
            NativeCameraDevice(stableIdentifier: "camera-1", permission: .authorized),
        ])
        let controller = makeController(authorization: authorization, cameras: cameras)
        _ = await controller.refresh()
        try await controller.select(.nativeCamera("camera-1"))
        await controller.markConnected()

        await cameras.setCameras([])
        let events = await controller.refresh()

        #expect(events.contains(.selectionBecameStale(.nativeCamera("camera-1"))))
        #expect((await controller.snapshot()).selection == .stale(.nativeCamera("camera-1")))
        #expect((await controller.snapshot()).connection == .disconnected)

        await cameras.setCameras([
            NativeCameraDevice(stableIdentifier: "camera-2", permission: .authorized),
        ])
        _ = await controller.refresh()
        #expect((await controller.snapshot()).connection == .disconnected)
    }

    @Test("Interruptions and failures are explicit and recoverable by rescan")
    func interruptionsAndFailures() async {
        let authorization = DeterministicCameraAuthorizationClient(status: .authorized)
        let controller = makeController(
            authorization: authorization,
            cameras: DeterministicNativeCameraDiscovery(cameras: [])
        )
        _ = await controller.refresh()

        await controller.markConnecting()
        #expect((await controller.snapshot()).connection == .connecting)
        await controller.markConnected()
        await controller.markInterrupted()
        #expect((await controller.snapshot()).connection == .interrupted)
        await controller.markFailed()
        #expect((await controller.snapshot()).connection == .failed)
        #expect((await controller.snapshot()).canRescan)
    }

    @Test("Only native camera identities can be selected")
    func rejectsNonNativeSelection() async {
        let authorization = DeterministicCameraAuthorizationClient(status: .authorized)
        let controller = makeController(
            authorization: authorization,
            cameras: DeterministicNativeCameraDiscovery(cameras: [])
        )

        await #expect(throws: CameraLifecycleError.notNativeCamera) {
            try await controller.select(.arm("arm-1"))
        }
    }
}
