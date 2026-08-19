import Darwin
import Foundation

public enum DurabilityTraceViolation: Error, Equatable, Sendable {
    case missing(String)
    case invalidExclusiveOpen(String)
    case racyPrecheck(String)
    case outOfOrder(String)
}

public enum DurabilityTraceValidator {
    public static func validate(_ events: [DurabilityEvent], operation: StorageOperation) throws {
        for (index, event) in events.enumerated() {
            guard case let .open(path, flags, mode) = event else { continue }
            let required = Int32(O_WRONLY | O_CREAT | O_EXCL)
            guard flags & required == required, mode == 0o600 else {
                throw DurabilityTraceViolation.invalidExclusiveOpen(path)
            }
            if events[..<index].contains(where: { if case .exists(path) = $0 { true } else { false } }) {
                throw DurabilityTraceViolation.racyPrecheck(path)
            }
        }

        let preparedOpen = try index(of: events, matching: { $0.isOpen(suffix: "/00-prepared.json") }, "prepared open")
        let preparedFileSync = try index(of: events, matching: { $0.isFileSync(suffix: "/00-prepared.json") }, "prepared file fsync")
        let transactionSync = try index(after: preparedFileSync, of: events, matching: { $0.isTransactionDirectorySync }, "prepared directory fsync")
        let dataMutation = try index(of: events, matching: { event in
            switch event {
            case .rename, .unlink: true
            default: false
            }
        }, "data mutation")
        try ordered(preparedOpen, preparedFileSync, transactionSync, dataMutation, reason: "prepared durability before data mutation")

        if operation == .replace {
            let tempOpen = try index(of: events, matching: { $0.isOpen(prefix: "Temp/") }, "replace temp open")
            let tempFileSync = try index(of: events, matching: { $0.isFileSync(prefix: "Temp/") }, "replace temp fsync")
            let tempParentSync = try index(after: tempFileSync, of: events, matching: { $0 == .directorySync("Temp") }, "replace temp parent fsync")
            let quarantineRename = try index(of: events, matching: { $0.isRename(destinationPrefix: "Quarantine/") }, "replace quarantine rename")
            try ordered(tempOpen, tempFileSync, tempParentSync, quarantineRename, reason: "new temp durability before quarantine")
            let stage09Open = try index(after: quarantineRename, of: events, matching: { $0.isOpen(suffix: "/09-oldQuarantined.json") }, "stage 09 open")
            for directory in ["Blobs", "Quarantine"] {
                _ = try index(after: quarantineRename, before: stage09Open, of: events, matching: {
                    $0 == .directorySync(directory)
                }, "\(directory) quarantine fsync")
            }
        }

        let stage10Suffix = operation == .purge ? "/10-fileRemoved.json" : "/10-fileRenamed.json"
        let stage10Open = try index(of: events, matching: { $0.isOpen(suffix: stage10Suffix) }, "stage 10 open")
        let lastDataMutation = try lastIndex(of: events, matching: { event in
            switch event {
            case .rename, .unlink: true
            default: false
            }
        }, before: stage10Open, "data mutation before stage 10")
        let parentSync = try index(after: lastDataMutation, before: stage10Open, of: events, matching: {
            if case .directorySync = $0 { true } else { false }
        }, "post-mutation directory fsync")
        guard parentSync < stage10Open else { throw DurabilityTraceViolation.outOfOrder("stage 10 before directory fsync") }
        let requiredParents: [String] = switch operation {
        case .create, .replace: ["Temp", "Blobs"]
        case .trash: ["Blobs", "Trash"]
        case .restore: ["Trash", "Blobs"]
        case .purge: ["Trash"]
        }
        for directory in requiredParents {
            _ = try index(after: lastDataMutation, before: stage10Open, of: events, matching: {
                $0 == .directorySync(directory)
            }, "\(directory) post-mutation fsync")
        }

        let stage10FileSync = try index(of: events, matching: { $0.isFileSync(suffix: stage10Suffix) }, "stage 10 fsync")
        let stage10DirectorySync = try index(after: stage10FileSync, of: events, matching: { $0.isTransactionDirectorySync }, "stage 10 directory fsync")
        let metadataApply = try index(after: stage10DirectorySync, of: events, matching: {
            if case .metadataApply = $0 { true } else { false }
        }, "metadata apply")
        try ordered(stage10Open, stage10FileSync, stage10DirectorySync, metadataApply, reason: "durable stage 10 before metadata")

        let metadataSave = try index(after: metadataApply, of: events, matching: { $0 == .metadataSave }, "metadata save")
        let storeSync = try index(after: metadataSave, of: events, matching: { $0.isFileSync(prefix: "Metadata/") }, "metadata store fsync")
        let metadataParentSync = try index(after: storeSync, of: events, matching: { $0 == .directorySync("Metadata") }, "metadata parent fsync")
        let metadataRefetch = try index(after: metadataParentSync, of: events, matching: {
            if case .metadataRefetch = $0 { true } else { false }
        }, "metadata refetch")
        let stage20Open = try index(after: metadataRefetch, of: events, matching: { $0.isOpen(suffix: "/20-metadataCommitted.json") }, "stage 20 open")
        try ordered(metadataSave, storeSync, metadataParentSync, metadataRefetch, stage20Open, reason: "store barrier and re-fetch before stage 20")

        let stage20Sync = try index(after: stage20Open, of: events, matching: { $0.isFileSync(suffix: "/20-metadataCommitted.json") }, "stage 20 fsync")
        let stage20DirectorySync = try index(after: stage20Sync, of: events, matching: { $0.isTransactionDirectorySync }, "stage 20 directory fsync")
        let stage30Open = try index(after: stage20DirectorySync, of: events, matching: { $0.isOpen(suffix: "/30-complete.json") }, "stage 30 open")
        let stage30Sync = try index(after: stage30Open, of: events, matching: { $0.isFileSync(suffix: "/30-complete.json") }, "stage 30 fsync")
        _ = try index(after: stage30Sync, of: events, matching: { $0.isTransactionDirectorySync }, "stage 30 directory fsync")
    }

    private static func ordered(_ values: Int..., reason: String) throws {
        guard zip(values, values.dropFirst()).allSatisfy(<) else {
            throw DurabilityTraceViolation.outOfOrder(reason)
        }
    }

    private static func index(
        after lower: Int = -1,
        before upper: Int = .max,
        of events: [DurabilityEvent],
        matching predicate: (DurabilityEvent) -> Bool,
        _ label: String
    ) throws -> Int {
        guard let result = events.indices.first(where: { $0 > lower && $0 < upper && predicate(events[$0]) }) else {
            throw DurabilityTraceViolation.missing(label)
        }
        return result
    }

    private static func lastIndex(
        of events: [DurabilityEvent],
        matching predicate: (DurabilityEvent) -> Bool,
        before upper: Int,
        _ label: String
    ) throws -> Int {
        guard let result = events.indices.last(where: { $0 < upper && predicate(events[$0]) }) else {
            throw DurabilityTraceViolation.missing(label)
        }
        return result
    }
}

private extension DurabilityEvent {
    func isOpen(prefix: String? = nil, suffix: String? = nil) -> Bool {
        guard case let .open(path, _, _) = self else { return false }
        return (prefix.map(path.hasPrefix) ?? true) && (suffix.map(path.hasSuffix) ?? true)
    }

    func isFileSync(prefix: String? = nil, suffix: String? = nil) -> Bool {
        guard case let .fileSync(path) = self else { return false }
        return (prefix.map(path.hasPrefix) ?? true) && (suffix.map(path.hasSuffix) ?? true)
    }

    var isTransactionDirectorySync: Bool {
        guard case let .directorySync(path) = self else { return false }
        return path.hasPrefix("Transactions/")
    }

    func isRename(destinationPrefix: String) -> Bool {
        guard case let .rename(_, destination) = self else { return false }
        return destination.hasPrefix(destinationPrefix)
    }
}
