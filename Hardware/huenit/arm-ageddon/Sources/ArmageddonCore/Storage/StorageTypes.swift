import Foundation

public struct ArtifactRecord: Codable, Hashable, Sendable {
    public let id: String
    public let relativePath: String
    public let contentHash: String
    public let byteCount: Int
    public let isTrashed: Bool

    public init(id: String, relativePath: String, contentHash: String, byteCount: Int, isTrashed: Bool) {
        self.id = id
        self.relativePath = relativePath
        self.contentHash = contentHash
        self.byteCount = byteCount
        self.isTrashed = isTrashed
    }
}

public enum StorageOperation: String, Codable, CaseIterable, Sendable {
    case create
    case replace
    case trash
    case restore
    case purge
}

public enum MetadataMutation: Codable, Sendable {
    case upsert(ArtifactRecord)
    case remove(id: String)
}

public enum DurabilityEvent: Codable, Equatable, Sendable {
    case exists(String)
    case mkdir(String, mode: UInt16)
    case open(String, flags: Int32, mode: UInt16)
    case write(String, bytes: Int)
    case fileSync(String)
    case rename(String, String)
    case unlink(String)
    case directorySync(String)
    case metadataApply(String)
    case metadataSave
    case metadataRefetch(String)
}

public actor DurabilityRecorder {
    private var events: [DurabilityEvent] = []
    private var crashAfterEvent: Int?

    public init(crashAfterEvent: Int? = nil) {
        self.crashAfterEvent = crashAfterEvent
    }

    public func append(_ event: DurabilityEvent) {
        events.append(event)
    }

    public func appendReturningIndex(_ event: DurabilityEvent) -> Int {
        events.append(event)
        return events.count - 1
    }

    public func beginOperation(crashAfterEvent: Int?) {
        events.removeAll(keepingCapacity: true)
        self.crashAfterEvent = crashAfterEvent
    }

    public func crashIfRequested(after index: Int) throws {
        if crashAfterEvent == index { throw SimulatedPowerLoss(index: index) }
    }

    public func snapshot() -> [DurabilityEvent] {
        events
    }
}

public struct SimulatedPowerLoss: Error, Equatable, Sendable {
    public let index: Int

    public init(index: Int) {
        self.index = index
    }
}

public enum StorageError: Error, Equatable {
    case invalidIdentifier(String)
    case invalidRelativePath(String)
    case artifactAlreadyExists(String)
    case artifactNotFound(String)
    case artifactNotTrashed(String)
    case artifactAlreadyTrashed(String)
    case concurrentOperation
    case corruptJournal(String)
    case hashMismatch(String)
    case posix(operation: String, path: String, code: Int32)
}
