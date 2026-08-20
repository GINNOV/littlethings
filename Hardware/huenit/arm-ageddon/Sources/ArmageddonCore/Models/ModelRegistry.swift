import CryptoKit
import Foundation
#if canImport(CoreML)
import CoreML
#endif

public enum ModelArtifactKind: String, Codable, Equatable, Sendable {
    case mlmodel
    case mlpackage
    case mlmodelc
    case fixture
}

public struct ModelArtifactDescriptor: Codable, Equatable, Sendable {
    public let fileName: String
    public let sha256: String
    public let kind: ModelArtifactKind

    public init(fileName: String, sha256: String, kind: ModelArtifactKind) {
        self.fileName = fileName
        self.sha256 = sha256
        self.kind = kind
    }
}

public struct ModelMinimumOS: Codable, Equatable, Sendable, Comparable {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(major: Int, minor: Int = 0, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public init(string: String) throws {
        let parts = string.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...3).contains(parts.count), parts.allSatisfy({ Int($0) != nil }) else {
            throw ModelRegistryError.invalidMinimumOS
        }
        self.init(
            major: Int(parts[0]) ?? 0,
            minor: parts.count > 1 ? Int(parts[1]) ?? 0 : 0,
            patch: parts.count > 2 ? Int(parts[2]) ?? 0 : 0
        )
        guard major >= 0, minor >= 0, patch >= 0 else {
            throw ModelRegistryError.invalidMinimumOS
        }
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }

    public var stringValue: String { "\(major).\(minor).\(patch)" }

    public static var current: Self {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return Self(major: version.majorVersion, minor: version.minorVersion, patch: version.patchVersion)
    }
}

public struct ModelBundleManifest: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let identifier: String
    public let displayName: String
    public let minimumOS: String
    public let artifact: ModelArtifactDescriptor
    public let detector: DetectorManifest
    public let smokeFrameCount: Int

    public init(
        schemaVersion: Int = 1,
        identifier: String,
        displayName: String,
        minimumOS: String,
        artifact: ModelArtifactDescriptor,
        detector: DetectorManifest,
        smokeFrameCount: Int = 30
    ) {
        self.schemaVersion = schemaVersion
        self.identifier = identifier
        self.displayName = displayName
        self.minimumOS = minimumOS
        self.artifact = artifact
        self.detector = detector
        self.smokeFrameCount = smokeFrameCount
    }

    public func validate(on operatingSystem: ModelMinimumOS = .current) throws {
        guard schemaVersion == 1 else { throw ModelRegistryError.unsupportedManifestSchema }
        guard !identifier.isEmpty,
              identifier != ".",
              !identifier.contains("/"),
              !identifier.contains("\\"),
              !identifier.contains("..") else {
            throw ModelRegistryError.invalidIdentifier
        }
        guard !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ModelRegistryError.invalidDisplayName
        }
        let requiredOS = try ModelMinimumOS(string: minimumOS)
        guard requiredOS <= operatingSystem else { throw ModelRegistryError.unsupportedMinimumOS }
        guard !artifact.fileName.isEmpty,
              artifact.fileName == URL(fileURLWithPath: artifact.fileName).lastPathComponent,
              !artifact.fileName.contains(".."),
              artifact.fileName.first != "." else {
            throw ModelRegistryError.unsafeArtifactPath
        }
        let hash = artifact.sha256.lowercased()
        guard hash.count == 64, hash.allSatisfy(\.isHexDigit) else {
            throw ModelRegistryError.invalidArtifactHash
        }
        guard detector.sha256.lowercased() == hash else {
            throw ModelRegistryError.manifestHashMismatch
        }
        try detector.validate()
        guard smokeFrameCount >= 30 else { throw ModelRegistryError.invalidSmokeConfiguration }
        let extensionName = URL(fileURLWithPath: artifact.fileName).pathExtension.lowercased()
        let expectedExtension: String = switch artifact.kind {
        case .mlmodel: "mlmodel"
        case .mlpackage: "mlpackage"
        case .mlmodelc: "mlmodelc"
        case .fixture: extensionName
        }
        guard artifact.kind == .fixture || extensionName == expectedExtension else {
            throw ModelRegistryError.unsupportedArtifact
        }
    }
}

public struct ModelRecord: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let displayName: String
    public let artifactHash: String
    public let artifactKind: ModelArtifactKind
    public let detector: DetectorManifest
    public let installedRelativePath: String
    public let compiledRelativePath: String
    public let compiledHash: String
    public let availability: ModelAvailability
    public let availabilityReason: String?
    public let benchmarkP95Milliseconds: Double

    public init(
        id: String,
        displayName: String,
        artifactHash: String,
        artifactKind: ModelArtifactKind,
        detector: DetectorManifest,
        installedRelativePath: String,
        compiledRelativePath: String,
        compiledHash: String,
        availability: ModelAvailability = .ready,
        availabilityReason: String? = nil,
        benchmarkP95Milliseconds: Double = 0
    ) {
        self.id = id
        self.displayName = displayName
        self.artifactHash = artifactHash
        self.artifactKind = artifactKind
        self.detector = detector
        self.installedRelativePath = installedRelativePath
        self.compiledRelativePath = compiledRelativePath
        self.compiledHash = compiledHash
        self.availability = availability
        self.availabilityReason = availabilityReason
        self.benchmarkP95Milliseconds = benchmarkP95Milliseconds
    }

    private enum CodingKeys: String, CodingKey {
        case id, displayName, artifactHash, artifactKind, detector
        case installedRelativePath, compiledRelativePath, compiledHash
        case availability, availabilityReason, benchmarkP95Milliseconds
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(String.self, forKey: .id),
            displayName: try container.decode(String.self, forKey: .displayName),
            artifactHash: try container.decode(String.self, forKey: .artifactHash),
            artifactKind: try container.decode(ModelArtifactKind.self, forKey: .artifactKind),
            detector: try container.decode(DetectorManifest.self, forKey: .detector),
            installedRelativePath: try container.decode(String.self, forKey: .installedRelativePath),
            compiledRelativePath: try container.decode(String.self, forKey: .compiledRelativePath),
            compiledHash: try container.decode(String.self, forKey: .compiledHash),
            availability: try container.decodeIfPresent(ModelAvailability.self, forKey: .availability) ?? .ready,
            availabilityReason: try container.decodeIfPresent(String.self, forKey: .availabilityReason),
            benchmarkP95Milliseconds: try container.decodeIfPresent(Double.self, forKey: .benchmarkP95Milliseconds) ?? 0
        )
    }
}

public enum ModelAvailability: String, Codable, Equatable, Sendable {
    case ready
    case slow
    case unsupported
}

public struct ModelRegistrySnapshot: Codable, Equatable, Sendable {
    public let activeModelID: String?
    public let activeModelHash: String?
    public let models: [ModelRecord]

    public init(activeModelID: String?, activeModelHash: String?, models: [ModelRecord]) {
        self.activeModelID = activeModelID
        self.activeModelHash = activeModelHash
        self.models = models
    }

    public static let empty = Self(activeModelID: nil, activeModelHash: nil, models: [])
}

public enum ModelRegistryError: Error, Equatable, Sendable {
    case unsupportedManifestSchema
    case invalidIdentifier
    case invalidDisplayName
    case invalidMinimumOS
    case unsupportedMinimumOS
    case unsafeArtifactPath
    case invalidArtifactHash
    case manifestHashMismatch
    case unsupportedArtifact
    case invalidSmokeConfiguration
    case symlinkNotAllowed
    case artifactNotFound
    case hashMismatch
    case compilerFailed
    case smokeTestFailed(frame: Int)
    case modelNotFound(String)
    case noActiveModel
    case corruptRegistry
    case activeModelCorrupt
    case activationFailed

    public var reason: String {
        switch self {
        case .unsupportedManifestSchema: "The model manifest schema is not supported."
        case .invalidIdentifier: "The model identifier is unsafe."
        case .invalidDisplayName: "The model name is empty."
        case .invalidMinimumOS: "The minimum macOS version is malformed."
        case .unsupportedMinimumOS: "This model requires a newer macOS version."
        case .unsafeArtifactPath, .symlinkNotAllowed: "The model references an unsafe file path."
        case .invalidArtifactHash, .manifestHashMismatch, .hashMismatch: "The model hash does not match its manifest."
        case .unsupportedArtifact: "This model artifact format is unsupported."
        case .invalidSmokeConfiguration: "The model smoke-test configuration is invalid."
        case .artifactNotFound: "The model artifact could not be found."
        case .compilerFailed: "Core ML could not compile the model."
        case .smokeTestFailed: "The model failed its 30-frame smoke test."
        case .modelNotFound: "The selected model is no longer installed."
        case .noActiveModel: "No model is active."
        case .corruptRegistry, .activeModelCorrupt: "The local model registry is corrupt."
        case .activationFailed: "The model activation transaction could not be committed."
        }
    }
}

public protocol ModelCompiler: Sendable {
    func compile(artifactURL: URL, kind: ModelArtifactKind, destinationURL: URL) throws
}

public protocol ModelRegistryStateWriter: Sendable {
    func replace(data: Data, at destinationURL: URL) throws
}

public struct AtomicModelRegistryStateWriter: ModelRegistryStateWriter {
    public init() {}

    public func replace(data: Data, at destinationURL: URL) throws {
        let temporaryURL = destinationURL.deletingLastPathComponent()
            .appendingPathComponent(".registry-\(UUID().uuidString).tmp")
        try data.write(to: temporaryURL, options: [.atomic])
        _ = try FileManager.default.replaceItemAt(
            destinationURL,
            withItemAt: temporaryURL,
            backupItemName: nil,
            options: .usingNewMetadataOnly
        )
    }
}

public protocol ModelSmokeTester: Sendable {
    func run(
        compiledModelURL: URL,
        manifest: ModelBundleManifest,
        fixtureFrame: Data,
        frameIndex: Int
    ) throws
}

public struct CoreMLModelCompiler: ModelCompiler {
    public init() {}

    public func compile(artifactURL: URL, kind: ModelArtifactKind, destinationURL: URL) throws {
        switch kind {
        case .fixture:
            try FileManager.default.copyItem(at: artifactURL, to: destinationURL)
        case .mlmodelc:
            try FileManager.default.copyItem(at: artifactURL, to: destinationURL)
        case .mlmodel, .mlpackage:
#if canImport(CoreML)
            let compiledURL = try MLModel.compileModel(at: artifactURL)
            try FileManager.default.copyItem(at: compiledURL, to: destinationURL)
#else
            throw ModelRegistryError.compilerFailed
#endif
        }
    }
}

public struct CoreMLModelSmokeTester: ModelSmokeTester {
    public init() {}

    public func run(
        compiledModelURL: URL,
        manifest: ModelBundleManifest,
        fixtureFrame: Data,
        frameIndex: Int
    ) throws {
        guard FileManager.default.fileExists(atPath: compiledModelURL.path) else {
            throw ModelRegistryError.compilerFailed
        }
        guard fixtureFrame.count == manifest.detector.input.width * manifest.detector.input.height else {
            throw ModelRegistryError.smokeTestFailed(frame: frameIndex)
        }
        if manifest.artifact.kind == .fixture {
            guard try Data(contentsOf: compiledModelURL).range(of: Data("constant-output-detector".utf8)) != nil else {
                throw ModelRegistryError.smokeTestFailed(frame: frameIndex)
            }
            return
        }
#if canImport(CoreML)
        let model = try MLModel(contentsOf: compiledModelURL)
        guard let input = model.modelDescription.inputDescriptionsByName.first,
              input.value.type == .image,
              input.value.imageConstraint?.pixelsWide == manifest.detector.input.width,
              input.value.imageConstraint?.pixelsHigh == manifest.detector.input.height else {
            throw ModelRegistryError.smokeTestFailed(frame: frameIndex)
        }
        let pixelBuffer = try makeFixturePixelBuffer(
            width: manifest.detector.input.width,
            height: manifest.detector.input.height,
            bytes: fixtureFrame
        )
        let provider = try MLDictionaryFeatureProvider(dictionary: [
            input.key: MLFeatureValue(pixelBuffer: pixelBuffer)
        ])
        let output = try model.prediction(from: provider)
        switch manifest.detector.output.kind {
        case .visionObjects:
            guard !output.featureNames.isEmpty else { throw ModelRegistryError.smokeTestFailed(frame: frameIndex) }
        case .multiArray:
            guard let coordinatesKey = manifest.detector.output.coordinatesKey,
                  let confidenceKey = manifest.detector.output.confidenceKey,
                  output.featureValue(for: coordinatesKey)?.multiArrayValue != nil,
                  output.featureValue(for: confidenceKey)?.multiArrayValue != nil else {
                throw ModelRegistryError.smokeTestFailed(frame: frameIndex)
            }
        }
#else
        throw ModelRegistryError.smokeTestFailed(frame: frameIndex)
#endif
    }

#if canImport(CoreML)
    private func makeFixturePixelBuffer(width: Int, height: Int, bytes: Data) throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw ModelRegistryError.smokeTestFailed(frame: 0)
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw ModelRegistryError.smokeTestFailed(frame: 0)
        }
        memset(baseAddress, 0, CVPixelBufferGetDataSize(pixelBuffer))
        return pixelBuffer
    }
#endif
}

public actor ModelRegistry {
    private struct State: Codable, Equatable, Sendable {
        var activeModelID: String?
        var activeModelHash: String?
        var models: [ModelRecord]
    }

    private let root: URL
    private let compiler: any ModelCompiler
    private let smokeTester: any ModelSmokeTester
    private let stateWriter: any ModelRegistryStateWriter
    private let operatingSystem: ModelMinimumOS
    private var state = State(activeModelID: nil, activeModelHash: nil, models: [])
    private var isOpen = false

    public init(
        root: URL,
        compiler: any ModelCompiler = CoreMLModelCompiler(),
        smokeTester: any ModelSmokeTester = CoreMLModelSmokeTester(),
        stateWriter: any ModelRegistryStateWriter = AtomicModelRegistryStateWriter(),
        operatingSystem: ModelMinimumOS = .current
    ) {
        self.root = root.standardizedFileURL
        self.compiler = compiler
        self.smokeTester = smokeTester
        self.stateWriter = stateWriter
        self.operatingSystem = operatingSystem
    }

    public func open() throws {
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        try FileManager.default.createDirectory(at: quarantineURL, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        try FileManager.default.createDirectory(at: installedURL, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        guard FileManager.default.fileExists(atPath: registryURL.path) else {
            state = State(activeModelID: nil, activeModelHash: nil, models: [])
            isOpen = true
            return
        }
        let data = try Data(contentsOf: registryURL)
        guard let decoded = try? JSONDecoder().decode(State.self, from: data) else {
            throw ModelRegistryError.corruptRegistry
        }
        state = decoded
        try validateActiveState()
        isOpen = true
    }

    public func snapshot() throws -> ModelRegistrySnapshot {
        try requireOpen()
        return ModelRegistrySnapshot(
            activeModelID: state.activeModelID,
            activeModelHash: state.activeModelHash,
            models: state.models.sorted { $0.id < $1.id }
        )
    }

    public func activeModel() throws -> ModelRecord {
        try requireOpen()
        guard let activeID = state.activeModelID,
              let record = state.models.first(where: { $0.id == activeID }) else {
            throw ModelRegistryError.noActiveModel
        }
        return record
    }

    @discardableResult
    public func importAndActivate(manifestURL: URL) throws -> ModelRecord {
        try requireOpen()
        let manifest = try decodeManifest(at: manifestURL)
        try manifest.validate(on: operatingSystem)
        let sourceArtifact = manifestURL.deletingLastPathComponent().appendingPathComponent(manifest.artifact.fileName)
        try validateSource(sourceArtifact)
        let transactionID = UUID().uuidString.lowercased()
        let quarantineRoot = quarantineURL.appendingPathComponent(transactionID, isDirectory: true)
        try FileManager.default.createDirectory(at: quarantineRoot, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let quarantinedArtifact = quarantineRoot.appendingPathComponent(manifest.artifact.fileName, isDirectory: manifest.artifact.kind == .mlpackage || manifest.artifact.kind == .mlmodelc)
        let quarantinedManifest = quarantineRoot.appendingPathComponent("model.armmodel.json")
        try copySecure(sourceArtifact, to: quarantinedArtifact)
        try copySecure(manifestURL, to: quarantinedManifest)
        guard try artifactHash(at: quarantinedArtifact, kind: manifest.artifact.kind) == manifest.artifact.sha256.lowercased() else {
            throw ModelRegistryError.hashMismatch
        }

        let compiledName = manifest.artifact.kind == .fixture ? "compiled.fixture" : "compiled.mlmodelc"
        let compiledURL = quarantineRoot.appendingPathComponent(compiledName, isDirectory: manifest.artifact.kind != .fixture)
        do {
            try compiler.compile(artifactURL: quarantinedArtifact, kind: manifest.artifact.kind, destinationURL: compiledURL)
        } catch let error as ModelRegistryError {
            throw error
        } catch {
            throw ModelRegistryError.compilerFailed
        }
        let fixtureFrame = Data(repeating: 0, count: manifest.detector.input.width * manifest.detector.input.height)
        var frameDurations: [Double] = []
        for frameIndex in 0..<30 {
            let started = ContinuousClock.now
            do {
                try smokeTester.run(
                    compiledModelURL: compiledURL,
                    manifest: manifest,
                    fixtureFrame: fixtureFrame,
                    frameIndex: frameIndex
                )
            } catch let error as ModelRegistryError {
                throw error
            } catch {
                throw ModelRegistryError.smokeTestFailed(frame: frameIndex)
            }
            frameDurations.append(milliseconds(since: started))
        }

        let installedName = "\(safeComponent(manifest.identifier))-\(manifest.artifact.sha256.prefix(12))-\(transactionID)"
        let installedRoot = installedURL.appendingPathComponent(installedName, isDirectory: true)
        if FileManager.default.fileExists(atPath: installedRoot.path) {
            try FileManager.default.removeItem(at: installedRoot)
        }
        try FileManager.default.createDirectory(at: installedRoot, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let installedManifest = installedRoot.appendingPathComponent("model.armmodel.json")
        let installedCompiled = installedRoot.appendingPathComponent(compiledName, isDirectory: manifest.artifact.kind != .fixture)
        try copySecure(quarantinedManifest, to: installedManifest)
        try copySecure(compiledURL, to: installedCompiled)
        let relativeRoot = relativePath(installedRoot)
        let relativeCompiled = relativePath(installedCompiled)
        let p95 = percentile95(frameDurations)
        let availability: ModelAvailability = p95 > 250 ? .slow : .ready
        let availabilityReason = availability == .slow ? "30-frame smoke p95 exceeded 250 ms." : nil
        let record = ModelRecord(
            id: manifest.identifier,
            displayName: manifest.displayName,
            artifactHash: manifest.artifact.sha256.lowercased(),
            artifactKind: manifest.artifact.kind,
            detector: manifest.detector,
            installedRelativePath: relativeRoot,
            compiledRelativePath: relativeCompiled,
            compiledHash: try artifactHash(at: installedCompiled, kind: manifest.artifact.kind == .fixture ? .fixture : .mlmodelc),
            availability: availability,
            availabilityReason: availabilityReason,
            benchmarkP95Milliseconds: p95
        )
        var next = state
        next.models.removeAll { $0.id == record.id }
        next.models.append(record)
        next.activeModelID = record.id
        next.activeModelHash = record.artifactHash
        try writeState(next)
        state = next
        return record
    }

    @discardableResult
    public func activate(identifier: String) throws -> ModelRecord {
        try requireOpen()
        guard let record = state.models.first(where: { $0.id == identifier }) else {
            throw ModelRegistryError.modelNotFound(identifier)
        }
        let compiledURL = root.appendingPathComponent(record.compiledRelativePath)
        try validateSource(compiledURL)
        guard try artifactHash(at: compiledURL, kind: record.artifactKind == .fixture ? .fixture : .mlmodelc) == record.compiledHash else {
            throw ModelRegistryError.activeModelCorrupt
        }
        var next = state
        next.activeModelID = record.id
        next.activeModelHash = record.artifactHash
        try writeState(next)
        state = next
        return record
    }

    @discardableResult
    public func rollback(to identifier: String) throws -> ModelRecord {
        try activate(identifier: identifier)
    }

    private var quarantineURL: URL { root.appendingPathComponent("Quarantine", isDirectory: true) }
    private var installedURL: URL { root.appendingPathComponent("Installed", isDirectory: true) }
    private var registryURL: URL { root.appendingPathComponent("registry.json") }

    private func requireOpen() throws {
        guard isOpen else { throw ModelRegistryError.corruptRegistry }
    }

    private func decodeManifest(at url: URL) throws -> ModelBundleManifest {
        guard url.pathExtension.lowercased() == "json", url.lastPathComponent.hasSuffix(".armmodel.json") else {
            throw ModelRegistryError.unsupportedArtifact
        }
        guard try isRegularFileWithoutSymlink(url) else { throw ModelRegistryError.symlinkNotAllowed }
        do {
            return try JSONDecoder().decode(ModelBundleManifest.self, from: Data(contentsOf: url))
        } catch let error as ModelRegistryError {
            throw error
        } catch {
            throw ModelRegistryError.corruptRegistry
        }
    }

    private func validateSource(_ url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { throw ModelRegistryError.artifactNotFound }
        try rejectSymlinkAncestors(of: url)
        try rejectSymlinksRecursively(at: url)
    }

    private func isRegularFileWithoutSymlink(_ url: URL) throws -> Bool {
        var directory = ObjCBool(false)
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &directory), !directory.boolValue else { return false }
        let values = try url.resourceValues(forKeys: [.isSymbolicLinkKey])
        return values.isSymbolicLink != true
    }

    private func rejectSymlinksRecursively(at url: URL) throws {
        let values = try url.resourceValues(forKeys: [.isSymbolicLinkKey, .isDirectoryKey])
        guard values.isSymbolicLink != true else { throw ModelRegistryError.symlinkNotAllowed }
        guard values.isDirectory == true else { return }
        for child in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isSymbolicLinkKey, .isDirectoryKey]) {
            try rejectSymlinksRecursively(at: child)
        }
    }

    private func rejectSymlinkAncestors(of url: URL) throws {
        var current = URL(fileURLWithPath: "/")
        for component in url.standardizedFileURL.pathComponents.dropFirst() {
            current.appendPathComponent(component)
            let values = try current.resourceValues(forKeys: [.isSymbolicLinkKey])
            let allowedSystemAlias = current.path == "/var" || current.path == "/tmp"
            guard values.isSymbolicLink != true || allowedSystemAlias else {
                throw ModelRegistryError.symlinkNotAllowed
            }
        }
    }

    private func copySecure(_ source: URL, to destination: URL) throws {
        try rejectSymlinksRecursively(at: source)
        try FileManager.default.copyItem(at: source, to: destination)
    }

    private func artifactHash(at url: URL, kind: ModelArtifactKind) throws -> String {
        if kind == .fixture || kind == .mlmodel {
            return Self.sha256(try Data(contentsOf: url))
        }
        var digest = SHA256()
        let base = url.standardizedFileURL
        var files: [URL] = []
        func collectFiles(_ directory: URL) throws {
            let children = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey]
            ).sorted { $0.path < $1.path }
            for child in children {
                let values = try child.resourceValues(forKeys: [.isDirectoryKey])
                if values.isDirectory == true {
                    try collectFiles(child)
                } else {
                    files.append(child)
                }
            }
        }
        try collectFiles(base)
        for child in files {
            let relative = child.path.replacingOccurrences(of: base.path + "/", with: "")
            digest.update(data: Data(relative.utf8))
            digest.update(data: try Data(contentsOf: child))
        }
        return digest.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func writeState(_ next: State) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        do {
            try stateWriter.replace(data: try encoder.encode(next), at: registryURL)
        } catch {
            throw ModelRegistryError.activationFailed
        }
    }

    private func validateActiveState() throws {
        guard let activeID = state.activeModelID else {
            guard state.activeModelHash == nil else { throw ModelRegistryError.activeModelCorrupt }
            return
        }
        guard let record = state.models.first(where: { $0.id == activeID }), record.artifactHash == state.activeModelHash else {
            throw ModelRegistryError.activeModelCorrupt
        }
        let compiledURL = root.appendingPathComponent(record.compiledRelativePath)
        guard FileManager.default.fileExists(atPath: compiledURL.path),
              (try? artifactHash(at: compiledURL, kind: record.artifactKind == .fixture ? .fixture : .mlmodelc)) == record.compiledHash else {
            throw ModelRegistryError.activeModelCorrupt
        }
    }

    private func relativePath(_ url: URL) -> String {
        url.path.replacingOccurrences(of: root.path + "/", with: "")
    }

    private func safeComponent(_ value: String) -> String {
        value.map { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "_" ? String($0) : "-" }.joined()
    }

    private func milliseconds(since start: ContinuousClock.Instant) -> Double {
        let duration = start.duration(to: .now)
        return Double(duration.components.seconds) * 1_000
            + Double(duration.components.attoseconds) / 1_000_000_000_000_000
    }

    private func percentile95(_ values: [Double]) -> Double {
        guard let maximum = values.max(), !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let index = min(sorted.count - 1, Int(ceil(Double(sorted.count) * 0.95)) - 1)
        return max(0, min(maximum, sorted[index]))
    }

    public static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
