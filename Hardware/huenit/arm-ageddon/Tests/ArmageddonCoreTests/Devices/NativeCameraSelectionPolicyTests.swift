import Testing
@testable import ArmageddonCore

struct NativeCameraSelectionPolicyTests {
    @Test("A single discovered camera is auto-selected")
    func singleCameraIsPreferred() {
        let cameras = [
            NativeCameraDevice(stableIdentifier: "camera-a", permission: .authorized, displayName: "Camera A"),
        ]
        #expect(
            NativeCameraSelectionPolicy.preferredUniqueID(
                discovered: cameras,
                restored: nil,
                current: .none
            ) == "camera-a"
        )
    }

    @Test("Two cameras are not auto-selected")
    func twoCamerasRequireExplicitChoice() {
        let cameras = [
            NativeCameraDevice(stableIdentifier: "camera-a", permission: .authorized, displayName: "Camera A"),
            NativeCameraDevice(stableIdentifier: "camera-b", permission: .authorized, displayName: "Camera B"),
        ]
        #expect(
            NativeCameraSelectionPolicy.preferredUniqueID(
                discovered: cameras,
                restored: nil,
                current: .none
            ) == nil
        )
    }

    @Test("Restored identity wins when still present")
    func restoredCameraIsPreferred() {
        let cameras = [
            NativeCameraDevice(stableIdentifier: "camera-a", permission: .authorized, displayName: "Camera A"),
            NativeCameraDevice(stableIdentifier: "camera-b", permission: .authorized, displayName: "Camera B"),
        ]
        #expect(
            NativeCameraSelectionPolicy.preferredUniqueID(
                discovered: cameras,
                restored: .nativeCamera("camera-b"),
                current: .none
            ) == "camera-b"
        )
    }

    @Test("Current selection is kept when the device is still present")
    func currentSelectionIsSticky() {
        let cameras = [
            NativeCameraDevice(stableIdentifier: "camera-a", permission: .authorized, displayName: "Camera A"),
            NativeCameraDevice(stableIdentifier: "camera-b", permission: .authorized, displayName: "Camera B"),
        ]
        #expect(
            NativeCameraSelectionPolicy.preferredUniqueID(
                discovered: cameras,
                restored: .nativeCamera("camera-a"),
                current: .selected(.nativeCamera("camera-b"))
            ) == "camera-b"
        )
    }

    @Test("Stale selection does not jump to another camera")
    func staleSelectionDoesNotAutoPick() {
        let cameras = [
            NativeCameraDevice(stableIdentifier: "camera-b", permission: .authorized, displayName: "Camera B"),
        ]
        #expect(
            NativeCameraSelectionPolicy.preferredUniqueID(
                discovered: cameras,
                restored: .nativeCamera("camera-a"),
                current: .stale(.nativeCamera("camera-a"))
            ) == nil
        )
    }

    @Test("Catalog preserves native camera display names")
    func catalogPreservesDisplayNames() async {
        let catalog = DeviceCatalog(
            nativeCameraDiscovery: DeterministicNativeCameraDiscovery(cameras: [
                NativeCameraDevice(stableIdentifier: "camera-b", permission: .authorized, displayName: "USB Camera"),
                NativeCameraDevice(stableIdentifier: "camera-a", permission: .authorized, displayName: "FaceTime HD"),
            ]),
            serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [])
        )
        _ = await catalog.refresh()
        let names = await catalog.devices().map(\.displayName)
        #expect(names.contains("USB Camera"))
        #expect(names.contains("FaceTime HD"))
    }
}
