import Foundation

public enum DiagnosticCategory: String, Codable, CaseIterable, Sendable {
    case device
    case capture
    case inference
    case calibration
    case safety
    case arm
    case storage
    case run
}

public enum DiagnosticSeverity: String, Codable, CaseIterable, Sendable {
    case info
    case warning
    case error
}

public struct DiagnosticEvent: Codable, Equatable, Sendable, Identifiable {
    public let id: UInt64
    public let occurredAt: MonotonicInstant
    public let generation: UInt64
    public let category: DiagnosticCategory
    public let severity: DiagnosticSeverity
    public let code: String
    public let message: String
    public let metadata: [String: String]

    public init(
        id: UInt64,
        occurredAt: MonotonicInstant,
        generation: UInt64,
        category: DiagnosticCategory,
        severity: DiagnosticSeverity,
        code: String,
        message: String,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.occurredAt = occurredAt
        self.generation = generation
        self.category = category
        self.severity = severity
        self.code = Self.safeText(code)
        self.message = Self.safeText(message)
        self.metadata = Self.allowlistedMetadata(metadata)
    }

    private static let allowedMetadataKeys: Set<String> = [
        "state", "source", "modelID", "modelHash", "count", "ageMilliseconds", "reason", "pathKind"
    ]

    private static func allowlistedMetadata(_ metadata: [String: String]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: metadata.compactMap { key, value in
            guard allowedMetadataKeys.contains(key) else { return nil }
            return (key, safeText(value))
        })
    }

    private static func safeText(_ value: String) -> String {
        let normalized = value.replacingOccurrences(of: "\n", with: " ")
        guard !normalized.contains("/") && !normalized.contains("\\") else { return "redacted" }
        return normalized.count > 256 ? String(normalized.prefix(256)) : normalized
    }
}

public struct DiagnosticSnapshot: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let generatedAt: MonotonicInstant
    public let states: [String: String]
    public let metrics: [String: Double]
    public let modelHashes: [String]

    public init(
        schemaVersion: Int = 1,
        generatedAt: MonotonicInstant,
        states: [String: String] = [:],
        metrics: [String: Double] = [:],
        modelHashes: [String] = []
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.states = states.filter { $0.key.count <= 64 && $0.value.count <= 256 }
        self.metrics = metrics.filter { $0.value.isFinite }
        self.modelHashes = modelHashes.filter { $0.count == 64 && $0.allSatisfy(\.isHexDigit) }
    }
}

public struct SupportBundleMember: Codable, Equatable, Sendable {
    public let filename: String
    public let sha256: String
    public let byteCount: Int

    public init(filename: String, sha256: String, byteCount: Int) {
        self.filename = filename
        self.sha256 = sha256
        self.byteCount = byteCount
    }
}

public struct SupportBundleManifest: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let appVersion: String
    public let toolVersion: String
    public let members: [SupportBundleMember]

    public init(
        schemaVersion: Int = 1,
        appVersion: String,
        toolVersion: String,
        members: [SupportBundleMember]
    ) {
        self.schemaVersion = schemaVersion
        self.appVersion = appVersion
        self.toolVersion = toolVersion
        self.members = members
    }
}

public enum DiagnosticsError: Error, Equatable, Sendable {
    case invalidLimit
    case outputExists(String)
    case invalidMember(String)
    case exportFailed(String)
}
