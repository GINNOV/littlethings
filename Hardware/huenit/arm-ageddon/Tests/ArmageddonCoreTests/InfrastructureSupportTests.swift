import Foundation
import Testing

struct InfrastructureSupportTests {
    @Test("Deterministic providers emit only injected values")
    func deterministicProvidersEmitInjectedValues() throws {
        let firstUUID = try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000001"))
        let secondUUID = try #require(UUID(uuidString: "00000000-0000-0000-0000-000000000002"))
        var clock = DeterministicMonotonicClock(nanoseconds: [10, 20])
        var uuids = DeterministicUUIDProvider(values: [firstUUID, secondUUID])

        let observedInstants = [try clock.now(), try clock.now()]
        let observedUUIDs = [try uuids.next(), try uuids.next()]

        #expect(observedInstants == [MonotonicInstant(nanoseconds: 10), MonotonicInstant(nanoseconds: 20)])
        #expect(observedUUIDs == [firstUUID, secondUUID])
    }

    @Test("Fixture loader rejects a path escape")
    func fixtureLoaderRejectsPathEscape() throws {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appending(path: "Tests/Fixtures")
        let loader = FixtureLoader(root: root)

        let action = { try loader.data(at: "../Package.swift") }

        #expect(throws: FixtureLoaderError.pathEscape("../Package.swift"), performing: action)
    }
}
