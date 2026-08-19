import Testing
@testable import ArmageddonCore

struct AppStateRestorationTests {
    @Test("Safe selections restore without unsafe motion state")
    func safeSelections() {
        let snapshot = AppStateSnapshot(
            destination: "capture.library",
            selectedDevice: .nativeCamera("camera-1"),
            selectedModelID: "detector-v1",
            armed: false,
            moving: false
        )

        let restored = AppStateRestorer.restore(snapshot)

        #expect(restored.destination == "capture.library")
        #expect(restored.selectedDevice == .nativeCamera("camera-1"))
        #expect(restored.selectedModelID == "detector-v1")
        #expect(restored.armed == false)
        #expect(restored.moving == false)
        #expect(restored.notice == nil)
    }

    @Test("Unsafe state is discarded on restoration")
    func unsafeStateIsDiscarded() {
        let snapshot = AppStateSnapshot(
            destination: "live.workspace",
            selectedDevice: .nativeCamera("camera-1"),
            selectedModelID: "detector-v1",
            armed: true,
            moving: true
        )

        let restored = AppStateRestorer.restore(snapshot)

        #expect(restored.armed == false)
        #expect(restored.moving == false)
        #expect(restored.notice == .unsafeStateDiscarded)
    }

    @Test("Invalid destinations recover to Live")
    func invalidDestinationRecovers() {
        let snapshot = AppStateSnapshot(
            destination: "unknown.destination",
            selectedDevice: nil,
            selectedModelID: nil,
            armed: false,
            moving: false
        )

        let restored = AppStateRestorer.restore(snapshot)

        #expect(restored.destination == "live.workspace")
        #expect(restored.notice == .navigationRecovered)
    }

    @Test("Repository composition is deterministic")
    func repositoryComposition() async throws {
        let repository = InMemoryAppStateRepository(snapshot: AppStateSnapshot(
            destination: "models.library",
            selectedDevice: nil,
            selectedModelID: "detector-v2",
            armed: true,
            moving: false
        ))
        let coordinator = AppStateCoordinator(repository: repository)

        let restored = try await coordinator.restore()

        #expect(restored.destination == "models.library")
        #expect(restored.selectedModelID == "detector-v2")
        #expect(restored.armed == false)
        #expect(restored.notice == .unsafeStateDiscarded)
    }
}
