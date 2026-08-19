import Foundation
import Testing
@testable import ArmageddonCore

struct AppStateRestorationTests {
    @Test("Safe selections restore without unsafe motion state")
    func safeSelections() {
        let snapshot = AppStateSnapshot(
            destination: "capture.library",
            selectedDevice: .nativeCamera("camera-1"),
            selectedModelID: "detector-v1"
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
            selectedModelID: "detector-v1"
        )

        let restored = AppStateRestorer.restore(snapshot, unsafeState: .armed)

        #expect(restored.armed == false)
        #expect(restored.moving == false)
        #expect(restored.notice == .unsafeStateDiscarded)
    }

    @Test("Invalid destinations recover to Live")
    func invalidDestinationRecovers() {
        let snapshot = AppStateSnapshot(
            destination: "unknown.destination",
            selectedDevice: nil,
            selectedModelID: nil
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
            selectedModelID: "detector-v2"
        ))
        let coordinator = AppStateCoordinator(repository: repository)

        let restored = try await coordinator.restore()

        #expect(restored.destination == "models.library")
        #expect(restored.selectedModelID == "detector-v2")
        #expect(restored.armed == false)
        #expect(restored.notice == nil)
    }

    @Test("Persisted state contains no motion fields")
    func persistedStateContainsNoMotionFields() throws {
        let snapshot = AppStateSnapshot(
            destination: "live.workspace",
            selectedDevice: nil,
            selectedModelID: "detector-v1"
        )
        let encoded = try JSONEncoder().encode(snapshot)
        let json = String(decoding: encoded, as: UTF8.self)

        #expect(!json.contains("armed"))
        #expect(!json.contains("moving"))
    }
}
