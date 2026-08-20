import Darwin
import Foundation

public protocol CaptureIndexStore: Sendable {
    func open() async throws
    func all() async throws -> [CaptureRecord]
    func insert(_ record: CaptureRecord) async throws
    func replace(_ record: CaptureRecord) async throws
}

public actor InMemoryCaptureIndexStore: CaptureIndexStore {
    private var records: [CaptureRecord] = []

    public init() {}

    public func open() async throws {}
    public func all() async throws -> [CaptureRecord] { records }

    public func insert(_ record: CaptureRecord) async throws {
        guard records.contains(where: { $0.id == record.id }) == false else { throw CaptureError.duplicateID }
        records.append(record)
    }

    public func replace(_ record: CaptureRecord) async throws {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else {
            throw CaptureError.missingRecord(record.id)
        }
        records[index] = record
    }
}

public actor FileCaptureIndexStore: CaptureIndexStore {
    private let fileURL: URL
    private var records: [CaptureRecord] = []
    private var loaded = false

    public init(fileURL: URL) { self.fileURL = fileURL.standardizedFileURL }

    public func open() async throws {
        guard !loaded else { return }
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        if FileManager.default.fileExists(atPath: fileURL.path) {
            records = try JSONDecoder().decode([CaptureRecord].self, from: Data(contentsOf: fileURL))
        }
        loaded = true
    }

    public func all() async throws -> [CaptureRecord] { records }

    public func insert(_ record: CaptureRecord) async throws {
        guard records.contains(where: { $0.id == record.id }) == false else { throw CaptureError.duplicateID }
        records.append(record)
        try persist()
    }

    public func replace(_ record: CaptureRecord) async throws {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else {
            throw CaptureError.missingRecord(record.id)
        }
        records[index] = record
        try persist()
    }

    private func persist() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(records)
        let temporary = fileURL.deletingPathExtension()
            .appendingPathExtension("\(UUID().uuidString).tmp")
        let descriptor = Darwin.open(temporary.path, O_WRONLY | O_CREAT | O_EXCL, mode_t(0o600))
        guard descriptor >= 0 else { throw CaptureError.invalidExport("index create") }
        var closeRequired = true
        defer { if closeRequired { _ = Darwin.close(descriptor) } }
        try data.withUnsafeBytes { buffer in
            var offset = 0
            while offset < buffer.count {
                let written = Darwin.write(descriptor, buffer.baseAddress!.advanced(by: offset), buffer.count - offset)
                guard written > 0 else { throw CaptureError.invalidExport("index write") }
                offset += written
            }
        }
        guard Darwin.fsync(descriptor) == 0 else { throw CaptureError.invalidExport("index fsync") }
        guard Darwin.close(descriptor) == 0 else { throw CaptureError.invalidExport("index close") }
        closeRequired = false
        guard Darwin.rename(temporary.path, fileURL.path) == 0 else {
            throw CaptureError.invalidExport("index rename")
        }
        let parent = Darwin.open(fileURL.deletingLastPathComponent().path, O_RDONLY | O_DIRECTORY)
        guard parent >= 0 else { throw CaptureError.invalidExport("index parent") }
        defer { _ = Darwin.close(parent) }
        guard Darwin.fsync(parent) == 0 else { throw CaptureError.invalidExport("index directory fsync") }
    }
}

public actor CaptureSessionStore {
    private let artifacts: LocalArtifactStorage
    private let index: any CaptureIndexStore

    public init(artifacts: LocalArtifactStorage, index: any CaptureIndexStore) {
        self.artifacts = artifacts
        self.index = index
    }

    public func open() async throws {
        try await artifacts.open()
        try await index.open()
    }

    public func capture(
        image: Data,
        thumbnail: Data?,
        provenance: CaptureProvenance,
        name: String
    ) async throws -> CaptureRecord {
        try Self.validateCaptureName(name)
        let id = UUID().uuidString.lowercased()
        let imageID = "capture-\(id)-image"
        let thumbnailID = thumbnail.map { _ in "capture-\(id)-thumbnail" }
        do {
            let imageRecord = try await artifacts.create(id: imageID, bytes: image)
            if let thumbnail, let thumbnailID {
                _ = try await artifacts.create(id: thumbnailID, bytes: thumbnail)
            }
            let record = CaptureRecord(
                id: id,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                provenance: provenance,
                imageArtifactID: imageID,
                thumbnailArtifactID: thumbnailID,
                imageHash: imageRecord.contentHash,
                imageByteCount: image.count
            )
            try await index.insert(record)
            return record
        } catch {
            try? await artifacts.trash(id: imageID)
            try? await artifacts.purge(id: imageID)
            if let thumbnailID {
                try? await artifacts.trash(id: thumbnailID)
                try? await artifacts.purge(id: thumbnailID)
            }
            throw error
        }
    }

    public func query(search: String = "", includeTrashed: Bool = false) async throws -> [CaptureRecord] {
        let normalized = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return try await index.all()
            .filter { includeTrashed || !$0.isTrashed }
            .filter { normalized.isEmpty || $0.name.localizedStandardContains(normalized) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func record(id: String) async throws -> CaptureRecord? {
        try await index.all().first { $0.id == id }
    }

    public func review(id: String, as review: CaptureReview) async throws {
        let record = try await required(id: id)
        try await index.replace(record.reviewed(as: review))
    }

    public func trash(id: String) async throws {
        let record = try await required(id: id)
        try await artifacts.trash(id: record.imageArtifactID)
        if let thumbnailID = record.thumbnailArtifactID { try await artifacts.trash(id: thumbnailID) }
        try await index.replace(record.movedToTrash(true))
    }

    public func restore(id: String) async throws {
        let record = try await required(id: id)
        try await artifacts.restore(id: record.imageArtifactID)
        if let thumbnailID = record.thumbnailArtifactID { try await artifacts.restore(id: thumbnailID) }
        try await index.replace(record.movedToTrash(false))
    }

    public func export(id: String, to directory: URL) async throws -> URL {
        let record = try await required(id: id)
        guard !FileManager.default.fileExists(atPath: directory.path) else {
            throw CaptureError.outputExists(directory.path)
        }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
        let image = try await artifacts.bytes(id: record.imageArtifactID)
        let imageFilename = "capture.\(record.provenance.imageFormat.fileExtension)"
        try ExclusiveCaptureFile.write(image, to: directory.appending(path: imageFilename))
        var thumbnailFilename: String?
        var thumbnailHash: String?
        if let thumbnailID = record.thumbnailArtifactID {
            let thumbnail = try await artifacts.bytes(id: thumbnailID)
            thumbnailFilename = "thumbnail.jpg"
            thumbnailHash = CaptureHashing.sha256(thumbnail)
            try ExclusiveCaptureFile.write(thumbnail, to: directory.appending(path: thumbnailFilename!))
        }
        let recordHash = try CaptureHashing.sha256(record)
        let manifest = CaptureExportManifest(
            captureID: record.id,
            imageFilename: imageFilename,
            imageSHA256: CaptureHashing.sha256(image),
            thumbnailFilename: thumbnailFilename,
            thumbnailSHA256: thumbnailHash,
            recordSHA256: recordHash
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let manifestURL = directory.appending(path: "manifest.json")
        try ExclusiveCaptureFile.write(try encoder.encode(manifest), to: manifestURL)
        try ExclusiveCaptureFile.write(try encoder.encode(record), to: directory.appending(path: "capture.json"))
        return manifestURL
    }

    public static func validateCaptureName(_ name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains("/"), !trimmed.contains("\\"), trimmed != ".", trimmed != ".." else {
            throw CaptureError.invalidName
        }
    }

    private func required(id: String) async throws -> CaptureRecord {
        guard let record = try await record(id: id) else { throw CaptureError.missingRecord(id) }
        return record
    }
}

private enum ExclusiveCaptureFile {
    static func write(_ data: Data, to url: URL) throws {
        let descriptor = Darwin.open(url.path, O_WRONLY | O_CREAT | O_EXCL, mode_t(0o600))
        guard descriptor >= 0 else { throw CaptureError.outputExists(url.path) }
        var closeRequired = true
        defer { if closeRequired { _ = Darwin.close(descriptor) } }
        try data.withUnsafeBytes { buffer in
            var offset = 0
            while offset < buffer.count {
                let written = Darwin.write(descriptor, buffer.baseAddress!.advanced(by: offset), buffer.count - offset)
                guard written > 0 else { throw CaptureError.invalidExport("write") }
                offset += written
            }
        }
        guard Darwin.fsync(descriptor) == 0 else { throw CaptureError.invalidExport("fsync") }
        guard Darwin.close(descriptor) == 0 else { throw CaptureError.invalidExport("close") }
        closeRequired = false
    }
}
