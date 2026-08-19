import Foundation

private struct TransactionJournal: Codable, Sendable {
    let transactionID: UUID
    let operation: StorageOperation
    let record: ArtifactRecord
    let previousRecord: ArtifactRecord?
    let sourcePath: String?
    let destinationPath: String?
    let temporaryPath: String?
    let quarantinePath: String?
    let payload: Data?
}

private struct MetadataCheckpoint: Codable, Sendable {
    let transactionID: UUID
    let metadataHash: String
}

public actor LocalArtifactStorage {
    private let fileSystem: any DurableFileSystem
    private let metadata: any ArtifactMetadataStore
    private var operationInProgress = false

    public init(fileSystem: any DurableFileSystem, metadata: any ArtifactMetadataStore) {
        self.fileSystem = fileSystem
        self.metadata = metadata
    }

    public func open() async throws {
        try await withExclusiveOperation {
            try await prepareDirectories()
            for child in try await fileSystem.children("Transactions") where !child.hasPrefix(".") {
                try await reconcile(transactionPath: "Transactions/\(child)")
            }
        }
    }

    @discardableResult
    public func create(id: String, bytes: Data) async throws -> ArtifactRecord {
        try await withExclusiveOperation {
            try validate(id: id)
            guard try await metadata.artifact(id: id) == nil else {
                throw StorageError.artifactAlreadyExists(id)
            }
            let hash = SwiftDataArtifactMetadataStore.sha256(bytes)
            let record = ArtifactRecord(
                id: id,
                relativePath: "Blobs/\(id).blob",
                contentHash: hash,
                byteCount: bytes.count,
                isTrashed: false
            )
            let transactionID = UUID()
            let journal = TransactionJournal(
                transactionID: transactionID,
                operation: .create,
                record: record,
                previousRecord: nil,
                sourcePath: nil,
                destinationPath: record.relativePath,
                temporaryPath: "Temp/\(transactionID.uuidString).blob",
                quarantinePath: nil,
                payload: bytes
            )
            try await beginAndReconcile(journal)
            return record
        }
    }

    @discardableResult
    public func replace(id: String, bytes: Data) async throws -> ArtifactRecord {
        try await withExclusiveOperation {
            let previous = try await requiredArtifact(id: id)
            guard !previous.isTrashed else { throw StorageError.artifactAlreadyTrashed(id) }
            let transactionID = UUID()
            let record = ArtifactRecord(
                id: id,
                relativePath: previous.relativePath,
                contentHash: SwiftDataArtifactMetadataStore.sha256(bytes),
                byteCount: bytes.count,
                isTrashed: false
            )
            let journal = TransactionJournal(
                transactionID: transactionID,
                operation: .replace,
                record: record,
                previousRecord: previous,
                sourcePath: previous.relativePath,
                destinationPath: previous.relativePath,
                temporaryPath: "Temp/\(transactionID.uuidString).blob",
                quarantinePath: "Quarantine/.\(id)-\(transactionID.uuidString).blob",
                payload: bytes
            )
            try await beginAndReconcile(journal)
            return record
        }
    }

    public func trash(id: String) async throws {
        try await move(id: id, operation: .trash)
    }

    public func restore(id: String) async throws {
        try await move(id: id, operation: .restore)
    }

    public func purge(id: String) async throws {
        try await withExclusiveOperation {
            let previous = try await requiredArtifact(id: id)
            guard previous.isTrashed else { throw StorageError.artifactNotTrashed(id) }
            let journal = TransactionJournal(
                transactionID: UUID(),
                operation: .purge,
                record: previous,
                previousRecord: previous,
                sourcePath: previous.relativePath,
                destinationPath: nil,
                temporaryPath: nil,
                quarantinePath: nil,
                payload: nil
            )
            try await beginAndReconcile(journal)
        }
    }

    public func artifact(id: String) async throws -> ArtifactRecord? {
        try await metadata.artifact(id: id)
    }

    public func query(includeTrashed: Bool = false) async throws -> [ArtifactRecord] {
        try await metadata.allArtifacts().filter { includeTrashed || !$0.isTrashed }
    }

    public func bytes(id: String) async throws -> Data {
        let record = try await requiredArtifact(id: id)
        let data = try await fileSystem.read(record.relativePath)
        guard SwiftDataArtifactMetadataStore.sha256(data) == record.contentHash else {
            throw StorageError.hashMismatch(id)
        }
        return data
    }

    public func unresolvedTransactionCount() async throws -> Int {
        var count = 0
        for child in try await fileSystem.children("Transactions") where !child.hasPrefix(".") {
            if !(try await fileSystem.exists("Transactions/\(child)/40-checkpoint.json")) { count += 1 }
        }
        return count
    }

    private func move(id: String, operation: StorageOperation) async throws {
        try await withExclusiveOperation {
            let previous = try await requiredArtifact(id: id)
            if operation == .trash, previous.isTrashed { throw StorageError.artifactAlreadyTrashed(id) }
            if operation == .restore, !previous.isTrashed { throw StorageError.artifactNotTrashed(id) }
            let destination = operation == .trash ? "Trash/\(id).blob" : "Blobs/\(id).blob"
            let record = ArtifactRecord(
                id: id,
                relativePath: destination,
                contentHash: previous.contentHash,
                byteCount: previous.byteCount,
                isTrashed: operation == .trash
            )
            let journal = TransactionJournal(
                transactionID: UUID(),
                operation: operation,
                record: record,
                previousRecord: previous,
                sourcePath: previous.relativePath,
                destinationPath: destination,
                temporaryPath: nil,
                quarantinePath: nil,
                payload: nil
            )
            try await beginAndReconcile(journal)
        }
    }

    private func beginAndReconcile(_ journal: TransactionJournal) async throws {
        let transactionPath = "Transactions/\(journal.transactionID.uuidString)"
        try await fileSystem.createDirectoryExclusive(transactionPath)
        try await fileSystem.syncDirectory("Transactions")
        try await writeStage("00-prepared.json", data: encode(journal), transactionPath: transactionPath)
        try await reconcile(journal: journal, transactionPath: transactionPath, fresh: true)
    }

    private func reconcile(transactionPath: String) async throws {
        let preparedPath = "\(transactionPath)/00-prepared.json"
        guard try await fileSystem.exists(preparedPath) else {
            try await quarantineCorruptTransaction(transactionPath)
            return
        }
        let prepared = try await fileSystem.read(preparedPath)
        guard let journal = try? JSONDecoder().decode(TransactionJournal.self, from: prepared) else {
            try await quarantineCorruptTransaction(transactionPath)
            return
        }
        try await reconcile(journal: journal, transactionPath: transactionPath, fresh: false)
    }

    private func reconcile(journal: TransactionJournal, transactionPath: String, fresh: Bool) async throws {
        let stage10 = journal.operation == .purge ? "10-fileRemoved.json" : "10-fileRenamed.json"
        let stage10Exists = fresh ? false : try await fileSystem.exists("\(transactionPath)/\(stage10)")
        if fresh || !stage10Exists {
            try await makeDataDurable(journal, transactionPath: transactionPath, stage10: stage10, fresh: fresh)
        }

        let expectedMetadataHash: String
        switch journal.operation {
        case .purge:
            expectedMetadataHash = SwiftDataArtifactMetadataStore.sha256(Data("removed:\(journal.record.id)".utf8))
        case .create, .replace, .trash, .restore:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            expectedMetadataHash = SwiftDataArtifactMetadataStore.sha256(try encoder.encode(journal.record))
        }
        let stage20Path = "\(transactionPath)/20-metadataCommitted.json"
        let currentHash = fresh ? nil : try await metadata.stableHash(id: journal.record.id)
        let stage20Exists = fresh ? false : try await fileSystem.exists(stage20Path)
        if fresh || !stage20Exists {
            let verifiedHash: String
            if fresh || currentHash != expectedMetadataHash {
                let mutation: MetadataMutation = journal.operation == .purge
                    ? .remove(id: journal.record.id)
                    : .upsert(journal.record)
                try await metadata.applyAndSave(mutation)
                for path in await metadata.durableStorePaths {
                    try await fileSystem.syncFileIfPresent(path)
                }
                try await fileSystem.syncDirectory("Metadata")
                verifiedHash = try await metadata.stableHash(id: journal.record.id)
            } else {
                verifiedHash = try required(currentHash)
            }
            guard verifiedHash == expectedMetadataHash else { throw StorageError.hashMismatch(journal.record.id) }
            let checkpoint = MetadataCheckpoint(transactionID: journal.transactionID, metadataHash: verifiedHash)
            try await writeStage("20-metadataCommitted.json", data: encode(checkpoint), transactionPath: transactionPath)
        }
        let stage30Exists = fresh ? false : try await fileSystem.exists("\(transactionPath)/30-complete.json")
        if fresh || !stage30Exists {
            try await writeStage("30-complete.json", data: encode(journal), transactionPath: transactionPath)
            try await fileSystem.syncDirectory("Transactions")
        }
        let checkpointExists = fresh ? false : try await fileSystem.exists("\(transactionPath)/40-checkpoint.json")
        if fresh || !checkpointExists {
            try await writeStage("40-checkpoint.json", data: encode(journal), transactionPath: transactionPath)
            try await fileSystem.syncDirectory("Transactions")
        }
    }

    private func makeDataDurable(
        _ journal: TransactionJournal,
        transactionPath: String,
        stage10: String,
        fresh: Bool
    ) async throws {
        if fresh {
            try await makeFreshDataDurable(journal, transactionPath: transactionPath, stage10: stage10)
            return
        }
        switch journal.operation {
        case .create:
            let destination = try required(journal.destinationPath)
            if try await path(destination, hasHash: journal.record.contentHash) {
                try await fileSystem.syncDirectory(parent(of: try required(journal.temporaryPath)))
                try await fileSystem.syncDirectory(parent(of: destination))
            } else {
                try await materializeTemporary(journal)
                let temporary = try required(journal.temporaryPath)
                try await durableRename(temporary, destination)
            }
        case .replace:
            let destinationHasNewData = try await path(journal.destinationPath, hasHash: journal.record.contentHash)
            if !destinationHasNewData {
                try await materializeTemporary(journal)
                if let source = journal.sourcePath, let quarantine = journal.quarantinePath,
                   try await fileSystem.exists(source), !(try await fileSystem.exists(quarantine)) {
                    try await durableRename(source, quarantine)
                }
                if !(try await fileSystem.exists("\(transactionPath)/09-oldQuarantined.json")) {
                    try await syncRenameParents(journal.sourcePath, journal.quarantinePath)
                    try await writeStage("09-oldQuarantined.json", data: encode(journal), transactionPath: transactionPath)
                }
                if let temporary = journal.temporaryPath, let destination = journal.destinationPath {
                    try await durableRename(temporary, destination)
                }
            } else if !(try await fileSystem.exists("\(transactionPath)/09-oldQuarantined.json")) {
                try await syncRenameParents(journal.sourcePath, journal.quarantinePath)
                try await writeStage("09-oldQuarantined.json", data: encode(journal), transactionPath: transactionPath)
                try await syncRenameParents(journal.temporaryPath, journal.destinationPath)
            }
        case .trash, .restore:
            if let source = journal.sourcePath, let destination = journal.destinationPath,
               !(try await fileSystem.exists(destination)) {
                try await durableRename(source, destination)
            } else {
                try await syncRenameParents(journal.sourcePath, journal.destinationPath)
            }
        case .purge:
            if let source = journal.sourcePath, try await fileSystem.exists(source) {
                try await fileSystem.unlink(source)
                try await fileSystem.syncDirectory(parent(of: source))
            } else if let source = journal.sourcePath {
                try await fileSystem.syncDirectory(parent(of: source))
            }
        }
        try await writeStage(stage10, data: encode(journal), transactionPath: transactionPath)
    }

    private func makeFreshDataDurable(
        _ journal: TransactionJournal,
        transactionPath: String,
        stage10: String
    ) async throws {
        switch journal.operation {
        case .create:
            try await createTemporary(journal)
            try await durableRename(required(journal.temporaryPath), required(journal.destinationPath))
        case .replace:
            try await createTemporary(journal)
            try await durableRename(required(journal.sourcePath), required(journal.quarantinePath))
            try await writeStage("09-oldQuarantined.json", data: encode(journal), transactionPath: transactionPath)
            try await durableRename(required(journal.temporaryPath), required(journal.destinationPath))
        case .trash, .restore:
            try await durableRename(required(journal.sourcePath), required(journal.destinationPath))
        case .purge:
            let source = try required(journal.sourcePath)
            try await fileSystem.unlink(source)
            try await fileSystem.syncDirectory(parent(of: source))
        }
        try await writeStage(stage10, data: encode(journal), transactionPath: transactionPath)
    }

    private func materializeTemporary(_ journal: TransactionJournal) async throws {
        guard let temporary = journal.temporaryPath, let payload = journal.payload else {
            throw StorageError.corruptJournal(journal.transactionID.uuidString)
        }
        if try await fileSystem.exists(temporary) {
            if SwiftDataArtifactMetadataStore.sha256(try await fileSystem.read(temporary)) == journal.record.contentHash {
                try await fileSystem.syncFile(temporary)
                try await fileSystem.syncDirectory(parent(of: temporary))
                return
            }
            try await fileSystem.unlink(temporary)
            try await fileSystem.syncDirectory(parent(of: temporary))
        }
        if !(try await fileSystem.exists(temporary)) {
            try await fileSystem.createExclusive(temporary, data: payload)
            try await fileSystem.syncFile(temporary)
            try await fileSystem.syncDirectory(parent(of: temporary))
        }
    }

    private func createTemporary(_ journal: TransactionJournal) async throws {
        guard let temporary = journal.temporaryPath, let payload = journal.payload else {
            throw StorageError.corruptJournal(journal.transactionID.uuidString)
        }
        try await fileSystem.createExclusive(temporary, data: payload)
        try await fileSystem.syncFile(temporary)
        try await fileSystem.syncDirectory(parent(of: temporary))
    }

    private func durableRename(_ source: String, _ destination: String) async throws {
        try await fileSystem.rename(source, destination)
        let sourceParent = parent(of: source)
        let destinationParent = parent(of: destination)
        try await fileSystem.syncDirectory(sourceParent)
        if destinationParent != sourceParent {
            try await fileSystem.syncDirectory(destinationParent)
        }
    }

    private func syncRenameParents(_ source: String?, _ destination: String?) async throws {
        let sourceParent = parent(of: try required(source))
        let destinationParent = parent(of: try required(destination))
        try await fileSystem.syncDirectory(sourceParent)
        if destinationParent != sourceParent { try await fileSystem.syncDirectory(destinationParent) }
    }

    private func quarantineCorruptTransaction(_ transactionPath: String) async throws {
        let name = (transactionPath as NSString).lastPathComponent
        let destination = "Quarantine/.transaction-\(name)"
        try await durableRename(transactionPath, destination)
    }

    private func writeStage(_ name: String, data: Data, transactionPath: String) async throws {
        let path = "\(transactionPath)/\(name)"
        try await fileSystem.createExclusive(path, data: data)
        try await fileSystem.syncFile(path)
        try await fileSystem.syncDirectory(transactionPath)
    }

    private func prepareDirectories() async throws {
        try await fileSystem.ensureRoot()
        for path in ["Transactions", "Blobs", "Trash", "Temp", "Quarantine", "Metadata"] {
            try await fileSystem.ensureDirectory(path)
        }
    }

    private func path(_ relativePath: String?, hasHash hash: String) async throws -> Bool {
        guard let relativePath, try await fileSystem.exists(relativePath) else { return false }
        return SwiftDataArtifactMetadataStore.sha256(try await fileSystem.read(relativePath)) == hash
    }

    private func requiredArtifact(id: String) async throws -> ArtifactRecord {
        guard let record = try await metadata.artifact(id: id) else { throw StorageError.artifactNotFound(id) }
        return record
    }

    private func validate(id: String) throws {
        let allowed = id.unicodeScalars.allSatisfy { CharacterSet.alphanumerics.contains($0) || $0 == "-" || $0 == "_" }
        guard !id.isEmpty, allowed else { throw StorageError.invalidIdentifier(id) }
    }

    private func required(_ path: String?) throws -> String {
        guard let path else { throw StorageError.corruptJournal("missing path") }
        return path
    }

    private func parent(of path: String) -> String {
        let value = (path as NSString).deletingLastPathComponent
        return value.isEmpty ? "." : value
    }

    private func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }

    private func withExclusiveOperation<T: Sendable>(_ operation: () async throws -> T) async throws -> T {
        guard !operationInProgress else { throw StorageError.concurrentOperation }
        operationInProgress = true
        defer { operationInProgress = false }
        return try await operation()
    }
}
