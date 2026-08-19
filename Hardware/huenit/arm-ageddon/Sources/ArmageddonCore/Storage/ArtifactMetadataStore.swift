import CryptoKit
import Foundation
import SwiftData

public protocol ArtifactMetadataStore: Sendable {
    var durableStorePaths: [String] { get async }
    func applyAndSave(_ mutation: MetadataMutation) async throws
    func artifact(id: String) async throws -> ArtifactRecord?
    func allArtifacts() async throws -> [ArtifactRecord]
    func stableHash(id: String) async throws -> String
}

public enum ArtifactMetadataSchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)
    public static var models: [any PersistentModel.Type] { [Artifact.self] }

    @Model
    public final class Artifact {
        @Attribute(.unique) public var artifactID: String
        public var relativePath: String
        public var contentHash: String
        public var byteCount: Int
        public var isTrashed: Bool

        public init(artifactID: String, relativePath: String, contentHash: String, byteCount: Int, isTrashed: Bool) {
            self.artifactID = artifactID
            self.relativePath = relativePath
            self.contentHash = contentHash
            self.byteCount = byteCount
            self.isTrashed = isTrashed
        }
    }
}

public enum ArtifactMetadataSchemaV2: VersionedSchema {
    public static let versionIdentifier = Schema.Version(2, 0, 0)
    public static var models: [any PersistentModel.Type] { [Artifact.self] }

    @Model
    public final class Artifact {
        @Attribute(.unique) public var artifactID: String
        public var relativePath: String
        public var contentHash: String
        public var byteCount: Int
        public var isTrashed: Bool

        public init(artifactID: String, relativePath: String, contentHash: String, byteCount: Int, isTrashed: Bool) {
            self.artifactID = artifactID
            self.relativePath = relativePath
            self.contentHash = contentHash
            self.byteCount = byteCount
            self.isTrashed = isTrashed
        }
    }
}

public enum ArtifactMetadataMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [ArtifactMetadataSchemaV1.self, ArtifactMetadataSchemaV2.self]
    }

    public static var stages: [MigrationStage] {
        [.lightweight(fromVersion: ArtifactMetadataSchemaV1.self, toVersion: ArtifactMetadataSchemaV2.self)]
    }
}

public actor SwiftDataArtifactMetadataStore: ArtifactMetadataStore {
    public let durableStorePaths: [String]
    private let container: ModelContainer
    private let recorder: DurabilityRecorder?

    public init(
        storeURL: URL,
        durableStorePaths: [String] = ["Metadata/metadata.store", "Metadata/metadata.store-wal"],
        recorder: DurabilityRecorder? = nil
    ) throws {
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        let schema = Schema(versionedSchema: ArtifactMetadataSchemaV2.self)
        let configuration = ModelConfiguration("ArmageddonMetadata", schema: schema, url: storeURL)
        container = try ModelContainer(
            for: schema,
            migrationPlan: ArtifactMetadataMigrationPlan.self,
            configurations: [configuration]
        )
        self.durableStorePaths = durableStorePaths
        self.recorder = recorder
    }

    public func applyAndSave(_ mutation: MetadataMutation) async throws {
        let context = ModelContext(container)
        switch mutation {
        case let .upsert(artifactRecord):
            if let model = try fetchModel(id: artifactRecord.id, context: context) {
                model.relativePath = artifactRecord.relativePath
                model.contentHash = artifactRecord.contentHash
                model.byteCount = artifactRecord.byteCount
                model.isTrashed = artifactRecord.isTrashed
            } else {
                context.insert(ArtifactMetadataSchemaV2.Artifact(
                    artifactID: artifactRecord.id,
                    relativePath: artifactRecord.relativePath,
                    contentHash: artifactRecord.contentHash,
                    byteCount: artifactRecord.byteCount,
                    isTrashed: artifactRecord.isTrashed
                ))
            }
            try await record(.metadataApply(artifactRecord.id))
        case let .remove(id):
            if let model = try fetchModel(id: id, context: context) {
                context.delete(model)
            }
            try await record(.metadataApply(id))
        }
        try context.save()
        try await record(.metadataSave)
    }

    public func artifact(id: String) async throws -> ArtifactRecord? {
        let context = ModelContext(container)
        return try fetchModel(id: id, context: context).map(Self.record)
    }

    public func allArtifacts() async throws -> [ArtifactRecord] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ArtifactMetadataSchemaV2.Artifact>(
            sortBy: [SortDescriptor(\.artifactID)]
        )
        return try context.fetch(descriptor).map(Self.record)
    }

    public func stableHash(id: String) async throws -> String {
        try await record(.metadataRefetch(id))
        guard let artifactRecord = try await artifact(id: id) else {
            return Self.sha256(Data("removed:\(id)".utf8))
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return Self.sha256(try encoder.encode(artifactRecord))
    }

    private func fetchModel(id: String, context: ModelContext) throws -> ArtifactMetadataSchemaV2.Artifact? {
        let identifier = id
        var descriptor = FetchDescriptor<ArtifactMetadataSchemaV2.Artifact>(
            predicate: #Predicate { $0.artifactID == identifier }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private static func record(_ model: ArtifactMetadataSchemaV2.Artifact) -> ArtifactRecord {
        ArtifactRecord(
            id: model.artifactID,
            relativePath: model.relativePath,
            contentHash: model.contentHash,
            byteCount: model.byteCount,
            isTrashed: model.isTrashed
        )
    }

    static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func record(_ event: DurabilityEvent) async throws {
        guard let recorder else { return }
        let index = await recorder.appendReturningIndex(event)
        try await recorder.crashIfRequested(after: index)
    }
}
