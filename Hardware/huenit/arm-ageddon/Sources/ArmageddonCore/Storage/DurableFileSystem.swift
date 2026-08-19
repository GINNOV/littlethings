import Darwin
import Foundation

public protocol DurableFileSystem: Sendable {
    func ensureRoot() async throws
    func ensureDirectory(_ relativePath: String) async throws
    func createDirectoryExclusive(_ relativePath: String) async throws
    func createExclusive(_ relativePath: String, data: Data) async throws
    func syncFile(_ relativePath: String) async throws
    func syncFileIfPresent(_ relativePath: String) async throws
    func syncDirectory(_ relativePath: String) async throws
    func rename(_ source: String, _ destination: String) async throws
    func unlink(_ relativePath: String) async throws
    func exists(_ relativePath: String) async throws -> Bool
    func read(_ relativePath: String) async throws -> Data
    func children(_ relativePath: String) async throws -> [String]
}

public actor POSIXDurableFileSystem: DurableFileSystem {
    public static let exclusiveCreateFlags = Int32(O_WRONLY | O_CREAT | O_EXCL)
    public static let privateFileMode = UInt16(0o600)

    private let root: URL
    private let recorder: DurabilityRecorder?

    public init(root: URL, recorder: DurabilityRecorder? = nil) {
        self.root = root.standardizedFileURL
        self.recorder = recorder
    }

    public func ensureRoot() async throws {
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
    }

    public func ensureDirectory(_ relativePath: String) async throws {
        if try await exists(relativePath) { return }
        try await createDirectoryExclusive(relativePath)
        try await syncDirectory(parent(of: relativePath))
    }

    public func createDirectoryExclusive(_ relativePath: String) async throws {
        let path = try resolved(relativePath)
        guard Darwin.mkdir(path.path, 0o700) == 0 else {
            throw posix("mkdir", relativePath)
        }
        try await record(.mkdir(relativePath, mode: 0o700))
    }

    public func createExclusive(_ relativePath: String, data: Data) async throws {
        let path = try resolved(relativePath)
        let flags = Self.exclusiveCreateFlags
        let descriptor = Darwin.open(path.path, flags, mode_t(Self.privateFileMode))
        guard descriptor >= 0 else { throw posix("open", relativePath) }
        var shouldClose = true
        defer { if shouldClose { _ = Darwin.close(descriptor) } }
        try await record(.open(relativePath, flags: flags, mode: Self.privateFileMode))
        try data.withUnsafeBytes { buffer in
            var written = 0
            while written < buffer.count {
                let result = Darwin.write(descriptor, buffer.baseAddress?.advanced(by: written), buffer.count - written)
                guard result > 0 else { throw posix("write", relativePath) }
                written += result
            }
        }
        try await record(.write(relativePath, bytes: data.count))
        guard Darwin.close(descriptor) == 0 else { throw posix("close", relativePath) }
        shouldClose = false
    }

    public func syncFile(_ relativePath: String) async throws {
        try await sync(relativePath, flags: O_RDONLY, event: .fileSync(relativePath))
    }

    public func syncFileIfPresent(_ relativePath: String) async throws {
        guard try await exists(relativePath) else { return }
        try await syncFile(relativePath)
    }

    public func syncDirectory(_ relativePath: String) async throws {
        try await sync(relativePath, flags: O_RDONLY | O_DIRECTORY, event: .directorySync(relativePath))
    }

    public func rename(_ source: String, _ destination: String) async throws {
        let sourceURL = try resolved(source)
        let destinationURL = try resolved(destination)
        guard Darwin.rename(sourceURL.path, destinationURL.path) == 0 else {
            throw posix("rename", "\(source)->\(destination)")
        }
        try await record(.rename(source, destination))
    }

    public func unlink(_ relativePath: String) async throws {
        let path = try resolved(relativePath)
        guard Darwin.unlink(path.path) == 0 else { throw posix("unlink", relativePath) }
        try await record(.unlink(relativePath))
    }

    public func exists(_ relativePath: String) async throws -> Bool {
        let result = FileManager.default.fileExists(atPath: try resolved(relativePath).path)
        try await record(.exists(relativePath))
        return result
    }

    public func read(_ relativePath: String) async throws -> Data {
        try Data(contentsOf: resolved(relativePath), options: [.mappedIfSafe])
    }

    public func children(_ relativePath: String) async throws -> [String] {
        let names = try FileManager.default.contentsOfDirectory(atPath: resolved(relativePath).path)
        return names.sorted()
    }

    private func sync(_ relativePath: String, flags: Int32, event: DurabilityEvent) async throws {
        let path = try resolved(relativePath)
        let descriptor = Darwin.open(path.path, flags)
        guard descriptor >= 0 else { throw posix("open-for-fsync", relativePath) }
        defer { _ = Darwin.close(descriptor) }
        guard Darwin.fsync(descriptor) == 0 else { throw posix("fsync", relativePath) }
        try await record(event)
    }

    private func resolved(_ relativePath: String) throws -> URL {
        guard !relativePath.hasPrefix("/") else { throw StorageError.invalidRelativePath(relativePath) }
        if relativePath == "." { return root }
        let candidate = root.appending(path: relativePath).standardizedFileURL
        let rootPath = root.path.hasSuffix("/") ? root.path : root.path + "/"
        guard candidate == root || candidate.path.hasPrefix(rootPath) else {
            throw StorageError.invalidRelativePath(relativePath)
        }
        return candidate
    }

    private func parent(of relativePath: String) -> String {
        let parent = (relativePath as NSString).deletingLastPathComponent
        return parent.isEmpty ? "." : parent
    }

    private func posix(_ operation: String, _ path: String) -> StorageError {
        .posix(operation: operation, path: path, code: errno)
    }

    private func record(_ event: DurabilityEvent) async throws {
        guard let recorder else { return }
        let index = await recorder.appendReturningIndex(event)
        try await recorder.crashIfRequested(after: index)
    }
}
