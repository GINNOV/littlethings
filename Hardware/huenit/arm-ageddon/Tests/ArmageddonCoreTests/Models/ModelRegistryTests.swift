import Foundation
import Testing
@testable import ArmageddonCore

@Suite(.serialized)
struct ModelRegistryTests {
    @Test("Models activate, survive relaunch, and roll back by hash")
    func activateRollback() async throws {
        let root = try temporaryRoot("model-registry-rollback")
        defer { try? FileManager.default.removeItem(at: root) }
        let registry = ModelRegistry(root: root)
        try await registry.open()

        let v1 = try writeFixture(in: root.appendingPathComponent("incoming-v1"), id: "fixture.v1", contents: "constant-v1")
        let v2 = try writeFixture(in: root.appendingPathComponent("incoming-v2"), id: "fixture.v2", contents: "constant-v2")
        let first = try await registry.importAndActivate(manifestURL: v1)
        #expect(first.artifactHash == ModelRegistry.sha256(Data("constant-v1".utf8)))
        let second = try await registry.importAndActivate(manifestURL: v2)
        #expect(second.artifactHash == ModelRegistry.sha256(Data("constant-v2".utf8)))
        #expect(try await registry.snapshot().activeModelID == "fixture.v2")

        _ = try await registry.rollback(to: "fixture.v1")
        let reopened = ModelRegistry(root: root)
        try await reopened.open()
        let snapshot = try await reopened.snapshot()
        #expect(snapshot.activeModelID == "fixture.v1")
        #expect(snapshot.activeModelHash == first.artifactHash)
        #expect(snapshot.models.count == 2)
        #expect(snapshot.models.allSatisfy { !$0.installedRelativePath.contains("SwiftData") })
        #expect(FileManager.default.fileExists(atPath: root.appendingPathComponent("registry.json").path))
    }

    @Test("Corrupted v3 remains quarantined and leaves v2 active")
    func corruptedV3KeepsPreviousActive() async throws {
        let root = try temporaryRoot("model-registry-corrupt")
        defer { try? FileManager.default.removeItem(at: root) }
        let registry = ModelRegistry(root: root)
        try await registry.open()
        _ = try await registry.importAndActivate(
            manifestURL: try writeFixture(in: root.appendingPathComponent("incoming-v2"), id: "fixture.v2", contents: "constant-v2")
        )
        let before = try await registry.snapshot()

        let incoming = root.appendingPathComponent("incoming-v3")
        let manifestURL = try writeFixture(in: incoming, id: "fixture.v3", contents: "declared-v3")
        try Data("corrupted-v3".utf8).write(to: incoming.appendingPathComponent("fixture.v3.fixture"))
        await expectError(.hashMismatch) {
            try await registry.importAndActivate(manifestURL: manifestURL)
        }
        let after = try await registry.snapshot()
        #expect(after == before)
        #expect(try await registry.activeModel().id == "fixture.v2")
        let quarantineChildren = try FileManager.default.contentsOfDirectory(
            at: root.appendingPathComponent("Quarantine"),
            includingPropertiesForKeys: nil
        )
        #expect(quarantineChildren.count == 2)
    }

    @Test("Malformed manifests, symlinks, compiler failures, and smoke failures fail closed")
    func validationFailuresKeepLastKnownGood() async throws {
        let root = try temporaryRoot("model-registry-failures")
        defer { try? FileManager.default.removeItem(at: root) }
        let registry = ModelRegistry(root: root)
        try await registry.open()
        _ = try await registry.importAndActivate(
            manifestURL: try writeFixture(in: root.appendingPathComponent("incoming-good"), id: "fixture.good", contents: "good")
        )
        let baseline = try await registry.snapshot()

        let malformed = root.appendingPathComponent("malformed.armmodel.json")
        try Data("{}".utf8).write(to: malformed)
        await expectError(.corruptRegistry) {
            try await registry.importAndActivate(manifestURL: malformed)
        }
        #expect(try await registry.snapshot() == baseline)

        let incompatible = try writeFixture(
            in: root.appendingPathComponent("incoming-incompatible"),
            id: "fixture.incompatible",
            contents: "future",
            minimumOS: "99.0"
        )
        await expectError(.unsupportedMinimumOS) {
            try await registry.importAndActivate(manifestURL: incompatible)
        }
        #expect(try await registry.snapshot() == baseline)

        let compilerFailing = ModelRegistry(
            root: root,
            compiler: FailingCompiler(),
            smokeTester: FixtureSmokeTester()
        )
        try await compilerFailing.open()
        let compilerFixture = try writeFixture(in: root.appendingPathComponent("incoming-compiler"), id: "fixture.compiler", contents: "compiler")
        await expectError(.compilerFailed) {
            try await compilerFailing.importAndActivate(manifestURL: compilerFixture)
        }
        #expect(try await compilerFailing.snapshot() == baseline)

        let smokeFailing = ModelRegistry(
            root: root,
            compiler: CoreMLModelCompiler(),
            smokeTester: FailingSmokeTester(failureFrame: 4)
        )
        try await smokeFailing.open()
        let smokeFixture = try writeFixture(in: root.appendingPathComponent("incoming-smoke"), id: "fixture.smoke", contents: "smoke")
        await expectError(.smokeTestFailed(frame: 4)) {
            try await smokeFailing.importAndActivate(manifestURL: smokeFixture)
        }
        #expect(try await smokeFailing.snapshot() == baseline)

        let external = root.appendingPathComponent("outside.fixture")
        try Data("outside".utf8).write(to: external)
        let symlinkIncoming = root.appendingPathComponent("incoming-symlink")
        try FileManager.default.createDirectory(at: symlinkIncoming, withIntermediateDirectories: true)
        let symlink = symlinkIncoming.appendingPathComponent("fixture.symlink.fixture")
        try FileManager.default.createSymbolicLink(at: symlink, withDestinationURL: external)
        let hash = ModelRegistry.sha256(Data("outside".utf8))
        let detector = try DetectorManifest(
            identifier: "fixture.symlink",
            sha256: hash,
            input: DetectorInputContract(width: 8, height: 8),
            output: DetectorOutputContract(kind: .visionObjects),
            labels: ["target"]
        )
        let symlinkManifest = try writeManifest(
            in: symlinkIncoming,
            id: "fixture.symlink",
            artifactName: symlink.lastPathComponent,
            hash: hash,
            detector: detector
        )
        await expectError(.symlinkNotAllowed) {
            try await registry.importAndActivate(manifestURL: symlinkManifest)
        }
        #expect(try await registry.snapshot() == baseline)
    }

    private func expectError(
        _ expected: ModelRegistryError,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            Issue.record("Expected \(expected), but the operation succeeded")
        } catch let error as ModelRegistryError {
            #expect(error == expected)
        } catch {
            Issue.record("Expected \(expected), got \(error)")
        }
    }

    private func temporaryRoot(_ name: String) throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("armageddon-\(name)-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        return root
    }

    private func writeFixture(
        in directory: URL,
        id: String,
        contents: String,
        minimumOS: String = "15.0"
    ) throws -> URL {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let bytes = Data(contents.utf8)
        let hash = ModelRegistry.sha256(bytes)
        let artifactName = "\(id).fixture"
        try bytes.write(to: directory.appendingPathComponent(artifactName), options: [.atomic])
        let detector = try DetectorManifest(
            identifier: id,
            sha256: hash,
            input: DetectorInputContract(width: 8, height: 8),
            output: DetectorOutputContract(kind: .visionObjects),
            labels: ["target"]
        )
        return try writeManifest(
            in: directory,
            id: id,
            artifactName: artifactName,
            hash: hash,
            detector: detector,
            minimumOS: minimumOS
        )
    }

    private func writeManifest(
        in directory: URL,
        id: String,
        artifactName: String,
        hash: String,
        detector: DetectorManifest,
        minimumOS: String = "15.0"
    ) throws -> URL {
        let manifest = ModelBundleManifest(
            identifier: id,
            displayName: id,
            minimumOS: minimumOS,
            artifact: ModelArtifactDescriptor(fileName: artifactName, sha256: hash, kind: .fixture),
            detector: detector
        )
        let url = directory.appendingPathComponent("\(id).armmodel.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        try encoder.encode(manifest).write(to: url, options: [.atomic])
        return url
    }
}

private struct FailingCompiler: ModelCompiler {
    func compile(artifactURL: URL, kind: ModelArtifactKind, destinationURL: URL) throws {
        throw ModelRegistryError.compilerFailed
    }
}

private struct FixtureSmokeTester: ModelSmokeTester {
    func run(compiledModelURL: URL, manifest: ModelBundleManifest, fixtureFrame: Data, frameIndex: Int) throws {}
}

private struct FailingSmokeTester: ModelSmokeTester {
    let failureFrame: Int

    func run(compiledModelURL: URL, manifest: ModelBundleManifest, fixtureFrame: Data, frameIndex: Int) throws {
        if frameIndex == failureFrame { throw ModelRegistryError.smokeTestFailed(frame: frameIndex) }
    }
}
