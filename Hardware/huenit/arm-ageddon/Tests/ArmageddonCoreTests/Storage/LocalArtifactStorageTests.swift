import Darwin
import Foundation
import SwiftData
import Testing
@testable import ArmageddonCore

@Suite(.serialized)
struct LocalArtifactStorageTests {
    @Test("Create persists bytes and metadata across reopen")
    func createPersistsAcrossReopen() async throws {
        let root = FileManager.default.temporaryDirectory
            .appending(path: "armageddon-storage-red-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let recorder = DurabilityRecorder()
        let fileSystem = POSIXDurableFileSystem(root: root, recorder: recorder)
        let metadata = try SwiftDataArtifactMetadataStore(
            storeURL: root.appending(path: "Metadata/metadata.store"),
            recorder: recorder
        )
        let storage = LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata)

        try await storage.open()
        let record = try await storage.create(id: "fixture", bytes: Data("camera".utf8))
        let reopened = LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata)
        try await reopened.open()

        #expect(try await reopened.artifact(id: "fixture") == record)
        #expect(try await reopened.bytes(id: "fixture") == Data("camera".utf8))
    }

    @Test("Versioned metadata migrates V1 records to V2")
    func metadataMigration() async throws {
        let root = FileManager.default.temporaryDirectory
            .appending(path: "armageddon-storage-migration-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let storeURL = root.appending(path: "Metadata/metadata.store")
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        let v1Schema = Schema(versionedSchema: ArtifactMetadataSchemaV1.self)
        let v1Configuration = ModelConfiguration("ArmageddonMetadata", schema: v1Schema, url: storeURL)
        let v1Container = try ModelContainer(for: v1Schema, configurations: [v1Configuration])
        let v1Context = ModelContext(v1Container)
        v1Context.insert(ArtifactMetadataSchemaV1.Artifact(
            artifactID: "legacy",
            relativePath: "Blobs/legacy.blob",
            contentHash: String(repeating: "a", count: 64),
            byteCount: 6,
            isTrashed: false
        ))
        try v1Context.save()

        let migrated = try SwiftDataArtifactMetadataStore(storeURL: storeURL)
        #expect(try await migrated.artifact(id: "legacy") == ArtifactRecord(
            id: "legacy",
            relativePath: "Blobs/legacy.blob",
            contentHash: String(repeating: "a", count: 64),
            byteCount: 6,
            isTrashed: false
        ))
    }

    @Test("Lifecycle supports replace, trash, restore, purge, and query")
    func lifecycleOperations() async throws {
        let root = FileManager.default.temporaryDirectory
            .appending(path: "armageddon-storage-lifecycle-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }

        let fileSystem = POSIXDurableFileSystem(root: root)
        let metadata = try SwiftDataArtifactMetadataStore(
            storeURL: root.appending(path: "Metadata/metadata.store")
        )
        let storage = LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata)
        try await storage.open()

        let created = try await storage.create(id: "fixture", bytes: Data("camera".utf8))
        let replaced = try await storage.replace(id: created.id, bytes: Data("arm".utf8))
        #expect(try await storage.bytes(id: created.id) == Data("arm".utf8))
        #expect(replaced.byteCount == 3)

        try await storage.trash(id: created.id)
        #expect(try await storage.query() == [])
        #expect((try await storage.query(includeTrashed: true)).map(\.isTrashed) == [true])

        try await storage.restore(id: created.id)
        #expect(try await storage.query().map(\.id) == [created.id])
        #expect(try await storage.bytes(id: created.id) == Data("arm".utf8))

        try await storage.trash(id: created.id)
        try await storage.purge(id: created.id)
        #expect(try await storage.artifact(id: created.id) == nil)
        #expect(try await storage.query(includeTrashed: true) == [])
        #expect(try await storage.unresolvedTransactionCount() == 0)
    }

    @Test("Create trace proves exclusive creation and durability ordering")
    func createTraceIsDurable() async throws {
        let root = FileManager.default.temporaryDirectory
            .appending(path: "armageddon-storage-trace-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let recorder = DurabilityRecorder()
        let fileSystem = POSIXDurableFileSystem(root: root, recorder: recorder)
        let metadata = try SwiftDataArtifactMetadataStore(
            storeURL: root.appending(path: "Metadata/metadata.store"),
            recorder: recorder
        )
        let storage = LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata)

        try await storage.open()
        _ = try await storage.create(id: "fixture", bytes: Data("camera".utf8))
        try DurabilityTraceValidator.validate(await recorder.snapshot(), operation: .create)
    }

    @Test("Mutation traces preserve operation-specific durability ordering")
    func mutationTracesAreDurable() async throws {
        for operation in [StorageOperation.replace, .trash, .restore, .purge] {
            let root = FileManager.default.temporaryDirectory
                .appending(path: "armageddon-storage-\(operation.rawValue)-\(UUID().uuidString)")
            defer { try? FileManager.default.removeItem(at: root) }

            let recorder = DurabilityRecorder()
            let fileSystem = POSIXDurableFileSystem(root: root, recorder: recorder)
            let metadata = try SwiftDataArtifactMetadataStore(
                storeURL: root.appending(path: "Metadata/metadata.store"),
                recorder: recorder
            )
            let storage = LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata)
            try await storage.open()
            _ = try await storage.create(id: "fixture", bytes: Data("camera".utf8))
            if operation == .restore || operation == .purge {
                try await storage.trash(id: "fixture")
            }
            let start = await recorder.snapshot().count
            switch operation {
            case .replace:
                _ = try await storage.replace(id: "fixture", bytes: Data("arm".utf8))
            case .trash:
                try await storage.trash(id: "fixture")
            case .restore:
                try await storage.restore(id: "fixture")
            case .purge:
                try await storage.purge(id: "fixture")
            case .create:
                Issue.record("unexpected create operation")
            }
            let events = await recorder.snapshot()
            try DurabilityTraceValidator.validate(Array(events.dropFirst(start)), operation: operation)
        }
    }

    @Test("Trace validator rejects prechecks and incomplete exclusive flags")
    func unsafeTraceMutationsAreRejected() throws {
        let prechecked: [DurabilityEvent] = [
            .exists("Temp/blob"),
            .open("Temp/blob", flags: Int32(O_WRONLY | O_CREAT | O_EXCL), mode: 0o600)
        ]
        do {
            try DurabilityTraceValidator.validate(prechecked, operation: .create)
            Issue.record("precheck mutation was accepted")
        } catch DurabilityTraceViolation.racyPrecheck {
        }

        let missingExclusive: [DurabilityEvent] = [
            .open("Temp/blob", flags: Int32(O_WRONLY | O_CREAT), mode: 0o600)
        ]
        do {
            try DurabilityTraceValidator.validate(missingExclusive, operation: .create)
            Issue.record("incomplete exclusive flags were accepted")
        } catch DurabilityTraceViolation.invalidExclusiveOpen {
        }
    }

    @Test("Recovery after each create durability event leaves no unresolved journal")
    func createPowerLossMatrixRecovers() async throws {
        let baselineRoot = FileManager.default.temporaryDirectory
            .appending(path: "armageddon-storage-baseline-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: baselineRoot) }
        let baselineRecorder = DurabilityRecorder()
        let baselineFS = POSIXDurableFileSystem(root: baselineRoot, recorder: baselineRecorder)
        let baselineMetadata = try SwiftDataArtifactMetadataStore(
            storeURL: baselineRoot.appending(path: "Metadata/metadata.store"),
            recorder: baselineRecorder
        )
        let baselineStorage = LocalArtifactStorage(fileSystem: baselineFS, metadata: baselineMetadata)
        try await baselineStorage.open()
        _ = try await baselineStorage.create(id: "fixture", bytes: Data("camera".utf8))
        let baselineEvents = await baselineRecorder.snapshot()
        let operationStart = baselineEvents.firstIndex { event in
            if case .mkdir(let path, _) = event { return path.contains("Transactions/") }
            return false
        } ?? baselineEvents.count

        for crashIndex in operationStart..<baselineEvents.count {
            let root = FileManager.default.temporaryDirectory
                .appending(path: "armageddon-storage-crash-\(UUID().uuidString)")
            defer { try? FileManager.default.removeItem(at: root) }
            let recorder = DurabilityRecorder(crashAfterEvent: crashIndex)
            let fileSystem = POSIXDurableFileSystem(root: root, recorder: recorder)
            let metadata = try SwiftDataArtifactMetadataStore(
                storeURL: root.appending(path: "Metadata/metadata.store"),
                recorder: recorder
            )
            let storage = LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata)
            do {
                try await storage.open()
                _ = try await storage.create(id: "fixture", bytes: Data("camera".utf8))
            } catch is SimulatedPowerLoss {
            }

            let recoveryFS = POSIXDurableFileSystem(root: root)
            let recoveryMetadata = try SwiftDataArtifactMetadataStore(
                storeURL: root.appending(path: "Metadata/metadata.store")
            )
            let recovery = LocalArtifactStorage(fileSystem: recoveryFS, metadata: recoveryMetadata)
            try await recovery.open()
            #expect(try await recovery.unresolvedTransactionCount() == 0)
            if let record = try await recovery.artifact(id: "fixture") {
                #expect(try await recovery.bytes(id: record.id) == Data("camera".utf8))
            }
            try await recovery.open()
            #expect(try await recovery.unresolvedTransactionCount() == 0)
        }
    }

    @Test("Recovery after each mutation durability event converges for all mutations")
    func mutationPowerLossMatrixRecovers() async throws {
        func seed(_ root: URL, operation: StorageOperation) async throws {
            let fileSystem = POSIXDurableFileSystem(root: root)
            let metadata = try SwiftDataArtifactMetadataStore(
                storeURL: root.appending(path: "Metadata/metadata.store")
            )
            let storage = LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata)
            try await storage.open()
            _ = try await storage.create(id: "fixture", bytes: Data("camera".utf8))
            if operation == .restore || operation == .purge {
                try await storage.trash(id: "fixture")
            }
        }

        func perform(_ operation: StorageOperation, on storage: LocalArtifactStorage) async throws {
            switch operation {
            case .replace:
                _ = try await storage.replace(id: "fixture", bytes: Data("arm".utf8))
            case .trash:
                try await storage.trash(id: "fixture")
            case .restore:
                try await storage.restore(id: "fixture")
            case .purge:
                try await storage.purge(id: "fixture")
            case .create:
                Issue.record("unexpected create operation")
            }
        }

        for operation in [StorageOperation.replace, .trash, .restore, .purge] {
            let baselineRoot = FileManager.default.temporaryDirectory
                .appending(path: "armageddon-storage-mutation-baseline-\(UUID().uuidString)")
            defer { try? FileManager.default.removeItem(at: baselineRoot) }
            try await seed(baselineRoot, operation: operation)
            let baselineRecorder = DurabilityRecorder()
            let baselineFileSystem = POSIXDurableFileSystem(root: baselineRoot, recorder: baselineRecorder)
            let baselineMetadata = try SwiftDataArtifactMetadataStore(
                storeURL: baselineRoot.appending(path: "Metadata/metadata.store"),
                recorder: baselineRecorder
            )
            let baselineStorage = LocalArtifactStorage(fileSystem: baselineFileSystem, metadata: baselineMetadata)
            try await baselineStorage.open()
            await baselineRecorder.beginOperation(crashAfterEvent: nil)
            try await perform(operation, on: baselineStorage)
            let baselineEvents = await baselineRecorder.snapshot()
            for crashIndex in 0..<baselineEvents.count {
                let root = FileManager.default.temporaryDirectory
                    .appending(path: "armageddon-storage-mutation-crash-\(UUID().uuidString)")
                defer { try? FileManager.default.removeItem(at: root) }
                try await seed(root, operation: operation)
                do {
                    let recorder = DurabilityRecorder()
                    let fileSystem = POSIXDurableFileSystem(root: root, recorder: recorder)
                    let metadata = try SwiftDataArtifactMetadataStore(
                        storeURL: root.appending(path: "Metadata/metadata.store"),
                        recorder: recorder
                    )
                    let storage = LocalArtifactStorage(fileSystem: fileSystem, metadata: metadata)
                    try await storage.open()
                    await recorder.beginOperation(crashAfterEvent: crashIndex)
                    do {
                        try await perform(operation, on: storage)
                    } catch is SimulatedPowerLoss {
                    }
                }

                let recoveryFileSystem = POSIXDurableFileSystem(root: root)
                let recoveryMetadata = try SwiftDataArtifactMetadataStore(
                    storeURL: root.appending(path: "Metadata/metadata.store")
                )
                let recovery = LocalArtifactStorage(fileSystem: recoveryFileSystem, metadata: recoveryMetadata)
                try await recovery.open()
                #expect(try await recovery.unresolvedTransactionCount() == 0)
                if let record = try await recovery.artifact(id: "fixture") {
                    let recoveredBytes = try await recovery.bytes(id: record.id)
                    #expect([Data("camera".utf8), Data("arm".utf8)].contains(recoveredBytes))
                }
                try await recovery.open()
                #expect(try await recovery.unresolvedTransactionCount() == 0)
            }
        }
    }
}
