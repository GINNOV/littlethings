import Foundation

public struct K210ArtifactManifest: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let identifier: String
    public let modelFilename: String
    public let scriptFilename: String
    public let labels: [String]
    public let anchors: [Double]
    public let provenance: String
    public let modelSHA256: String?
    public let scriptSHA256: String?

    public init(
        schemaVersion: Int = 1,
        identifier: String,
        modelFilename: String,
        scriptFilename: String,
        labels: [String],
        anchors: [Double],
        provenance: String,
        modelSHA256: String? = nil,
        scriptSHA256: String? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.identifier = identifier
        self.modelFilename = modelFilename
        self.scriptFilename = scriptFilename
        self.labels = labels
        self.anchors = anchors
        self.provenance = provenance
        self.modelSHA256 = modelSHA256
        self.scriptSHA256 = scriptSHA256
    }

    public func validated(modelFilename: String, scriptFilename: String) throws -> Self {
        guard schemaVersion == 1, !identifier.isEmpty,
              self.modelFilename == modelFilename, self.scriptFilename == scriptFilename else {
            throw K210InventoryError.invalidFilename
        }
        guard Self.isSafeFilename(modelFilename), Self.isSafeFilename(scriptFilename) else {
            throw K210InventoryError.invalidFilename
        }
        guard !labels.isEmpty, labels.allSatisfy({ !$0.isEmpty }), Set(labels).count == labels.count else {
            throw K210InventoryError.missingLabels
        }
        guard anchors.count >= 2, anchors.allSatisfy(\.isFinite) else {
            throw K210InventoryError.invalidAnchors
        }
        return self
    }

    private static func isSafeFilename(_ filename: String) -> Bool {
        !filename.isEmpty && filename == URL(fileURLWithPath: filename).lastPathComponent
            && !filename.contains("/") && !filename.contains("\\")
    }
}

public enum K210InventoryError: Error, Equatable, Sendable {
    case invalidFilename
    case missingLabels
    case invalidAnchors
    case missingArtifact(String)
    case hashMismatch(String)
    case destinationExists
    case uploadUnsupported
}

public struct K210ArtifactRecord: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let manifest: K210ArtifactManifest
    public let modelSHA256: String
    public let scriptSHA256: String
    public let directoryName: String
    public let uploadAvailable: Bool

    public init(
        id: String,
        manifest: K210ArtifactManifest,
        modelSHA256: String,
        scriptSHA256: String,
        directoryName: String,
        uploadAvailable: Bool
    ) {
        self.id = id
        self.manifest = manifest
        self.modelSHA256 = modelSHA256
        self.scriptSHA256 = scriptSHA256
        self.directoryName = directoryName
        self.uploadAvailable = uploadAvailable
    }
}

public actor K210ArtifactInventory {
    private let root: URL
    private let decision: HuenitCameraCapabilityDecision
    private var records: [K210ArtifactRecord] = []

    public init(root: URL, decision: HuenitCameraCapabilityDecision) {
        self.root = root.standardizedFileURL
        self.decision = decision
    }

    public func importBundle(manifestURL: URL, modelURL: URL, scriptURL: URL) throws -> K210ArtifactRecord {
        let manifest = try JSONDecoder().decode(K210ArtifactManifest.self, from: Data(contentsOf: manifestURL))
        let validated = try manifest.validated(modelFilename: modelURL.lastPathComponent, scriptFilename: scriptURL.lastPathComponent)
        let modelData = try Data(contentsOf: modelURL)
        let scriptData = try Data(contentsOf: scriptURL)
        let modelHash = CaptureHashing.sha256(modelData)
        let scriptHash = CaptureHashing.sha256(scriptData)
        if let expected = validated.modelSHA256, expected.lowercased() != modelHash { throw K210InventoryError.hashMismatch("model") }
        if let expected = validated.scriptSHA256, expected.lowercased() != scriptHash { throw K210InventoryError.hashMismatch("script") }
        let directoryName = validated.identifier.replacing("/", with: "_")
        let destination = root.appending(path: directoryName)
        guard !FileManager.default.fileExists(atPath: destination.path) else { throw K210InventoryError.destinationExists }
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        try FileManager.default.copyItem(at: manifestURL, to: destination.appending(path: "manifest.armk210.json"))
        try FileManager.default.copyItem(at: modelURL, to: destination.appending(path: validated.modelFilename))
        try FileManager.default.copyItem(at: scriptURL, to: destination.appending(path: validated.scriptFilename))
        let record = K210ArtifactRecord(
            id: validated.identifier,
            manifest: validated,
            modelSHA256: modelHash,
            scriptSHA256: scriptHash,
            directoryName: directoryName,
            uploadAvailable: decision.canUploadArtifacts
        )
        records.append(record)
        return record
    }

    public func all() -> [K210ArtifactRecord] { records }

    public func deploymentInstruction(for record: K210ArtifactRecord) -> String {
        record.uploadAvailable
            ? "Upload is enabled by the measured protocol capability."
            : "Copy the verified bundle through the documented HUENIT workflow; in-app upload is unsupported."
    }
}
