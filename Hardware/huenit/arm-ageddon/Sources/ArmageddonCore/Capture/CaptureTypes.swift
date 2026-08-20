import CryptoKit
import Foundation

public struct ArmPoseSnapshot: Codable, Equatable, Sendable {
    public let x: Double
    public let y: Double
    public let z: Double
    public let ageNanoseconds: UInt64

    public init(x: Double, y: Double, z: Double, ageNanoseconds: UInt64) {
        self.x = x
        self.y = y
        self.z = z
        self.ageNanoseconds = ageNanoseconds
    }
}

public enum CaptureImageFormat: String, Codable, Equatable, Sendable {
    case jpeg
    case heic

    public var fileExtension: String { rawValue == "jpeg" ? "jpg" : rawValue }
}

public struct CaptureProvenance: Codable, Equatable, Sendable {
    public let sourceID: String
    public let frameID: UInt64
    public let modelID: String
    public let modelHash: String
    public let observations: [DetectionObservation]
    public let selectedObservationID: String?
    public let calibrationID: String?
    public let armPose: ArmPoseSnapshot?
    public let runID: UUID?
    public let captureInstant: MonotonicInstant
    public let imageSize: PixelSize
    public let imageFormat: CaptureImageFormat

    public init(
        sourceID: String,
        frameID: UInt64,
        modelID: String,
        modelHash: String,
        observations: [DetectionObservation],
        selectedObservationID: String?,
        calibrationID: String?,
        armPose: ArmPoseSnapshot?,
        runID: UUID?,
        captureInstant: MonotonicInstant,
        imageSize: PixelSize,
        imageFormat: CaptureImageFormat = .jpeg
    ) {
        self.sourceID = Self.redact(sourceID)
        self.frameID = frameID
        self.modelID = modelID
        self.modelHash = modelHash
        self.observations = observations
        self.selectedObservationID = selectedObservationID
        self.calibrationID = calibrationID
        self.armPose = armPose
        self.runID = runID
        self.captureInstant = captureInstant
        self.imageSize = imageSize
        self.imageFormat = imageFormat
    }

    private static func redact(_ value: String) -> String {
        let allowed = value.unicodeScalars.allSatisfy { scalar in
            let number = scalar.value
            return (48...57).contains(number) || (65...90).contains(number)
                || (97...122).contains(number) || number == 45 || number == 95
        }
        return allowed ? value : "redacted-\(CaptureHashing.sha256(Data(value.utf8)).prefix(12))"
    }
}

public enum CaptureReview: String, Codable, Equatable, Sendable {
    case pending
    case accepted
    case rejected
}

public struct CaptureRecord: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let createdAt: Date
    public let provenance: CaptureProvenance
    public let imageArtifactID: String
    public let thumbnailArtifactID: String?
    public let imageHash: String
    public let imageByteCount: Int
    public let review: CaptureReview
    public let isTrashed: Bool

    public init(
        id: String,
        name: String,
        createdAt: Date = .now,
        provenance: CaptureProvenance,
        imageArtifactID: String,
        thumbnailArtifactID: String?,
        imageHash: String,
        imageByteCount: Int,
        review: CaptureReview = .pending,
        isTrashed: Bool = false
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.provenance = provenance
        self.imageArtifactID = imageArtifactID
        self.thumbnailArtifactID = thumbnailArtifactID
        self.imageHash = imageHash
        self.imageByteCount = imageByteCount
        self.review = review
        self.isTrashed = isTrashed
    }

    public func reviewed(as review: CaptureReview) -> Self {
        Self(
            id: id,
            name: name,
            createdAt: createdAt,
            provenance: provenance,
            imageArtifactID: imageArtifactID,
            thumbnailArtifactID: thumbnailArtifactID,
            imageHash: imageHash,
            imageByteCount: imageByteCount,
            review: review,
            isTrashed: isTrashed
        )
    }

    public func movedToTrash(_ isTrashed: Bool) -> Self {
        Self(
            id: id,
            name: name,
            createdAt: createdAt,
            provenance: provenance,
            imageArtifactID: imageArtifactID,
            thumbnailArtifactID: thumbnailArtifactID,
            imageHash: imageHash,
            imageByteCount: imageByteCount,
            review: review,
            isTrashed: isTrashed
        )
    }
}

public struct CaptureExportManifest: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let captureID: String
    public let imageFilename: String
    public let imageSHA256: String
    public let thumbnailFilename: String?
    public let thumbnailSHA256: String?
    public let recordSHA256: String

    public init(
        schemaVersion: Int = 1,
        captureID: String,
        imageFilename: String,
        imageSHA256: String,
        thumbnailFilename: String?,
        thumbnailSHA256: String?,
        recordSHA256: String
    ) {
        self.schemaVersion = schemaVersion
        self.captureID = captureID
        self.imageFilename = imageFilename
        self.imageSHA256 = imageSHA256
        self.thumbnailFilename = thumbnailFilename
        self.thumbnailSHA256 = thumbnailSHA256
        self.recordSHA256 = recordSHA256
    }
}

public enum CaptureError: Error, Equatable, Sendable {
    case invalidName
    case duplicateID
    case missingRecord(String)
    case outputExists(String)
    case invalidExport(String)
    case invalidArtifact(String)
}

public enum CaptureHashing {
    public static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    public static func sha256<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return sha256(try encoder.encode(value))
    }
}

public enum CaptureExportValidator {
    public static func validate(directory: URL) throws -> CaptureExportManifest {
        let manifestURL = directory.appending(path: "manifest.json")
        let manifest = try JSONDecoder().decode(CaptureExportManifest.self, from: Data(contentsOf: manifestURL))
        guard manifest.schemaVersion == 1 else { throw CaptureError.invalidExport("schema") }
        let imageURL = directory.appending(path: manifest.imageFilename)
        guard CaptureHashing.sha256(try Data(contentsOf: imageURL)) == manifest.imageSHA256 else {
            throw CaptureError.invalidExport("image hash")
        }
        if let thumbnailFilename = manifest.thumbnailFilename {
            guard let thumbnailHash = manifest.thumbnailSHA256 else { throw CaptureError.invalidExport("thumbnail hash") }
            let thumbnailURL = directory.appending(path: thumbnailFilename)
            guard CaptureHashing.sha256(try Data(contentsOf: thumbnailURL)) == thumbnailHash else {
                throw CaptureError.invalidExport("thumbnail hash")
            }
        }
        return manifest
    }
}
