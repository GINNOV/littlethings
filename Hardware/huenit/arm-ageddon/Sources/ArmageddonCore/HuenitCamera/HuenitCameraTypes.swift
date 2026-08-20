import Foundation

public enum HuenitCameraCapability: String, Codable, CaseIterable, Hashable, Sendable {
    case serialTelemetry
    case preview
    case artifactUpload
}

public enum HuenitCapabilityStatus: String, Codable, Sendable {
    case notMeasured
    case measured
}

public enum HuenitUnsupportedCapability: String, Codable, Hashable, Sendable {
    case preview
    case artifactUpload
}

public struct HuenitCameraCapabilityDecision: Codable, Equatable, Sendable {
    public let status: HuenitCapabilityStatus
    public let supported: Set<HuenitCameraCapability>
    public let unsupportedReasons: [HuenitUnsupportedCapability: String]
    public let profile: HuenitTelemetryProfile?

    public init(
        status: HuenitCapabilityStatus,
        supported: Set<HuenitCameraCapability>,
        unsupportedReasons: [HuenitUnsupportedCapability: String],
        profile: HuenitTelemetryProfile?
    ) {
        self.status = status
        self.supported = supported
        self.unsupportedReasons = unsupportedReasons
        self.profile = profile
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case supported
        case unsupportedReasons
        case profile
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(HuenitCapabilityStatus.self, forKey: .status)
        supported = try container.decode(Set<HuenitCameraCapability>.self, forKey: .supported)
        let reasons = try container.decode([String: String].self, forKey: .unsupportedReasons)
        unsupportedReasons = Dictionary(uniqueKeysWithValues: reasons.compactMap { key, value in
            guard let capability = HuenitUnsupportedCapability(rawValue: key) else { return nil }
            return (capability, value)
        })
        profile = try container.decodeIfPresent(HuenitTelemetryProfile.self, forKey: .profile)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        try container.encode(supported, forKey: .supported)
        try container.encode(
            Dictionary(uniqueKeysWithValues: unsupportedReasons.map { ($0.key.rawValue, $0.value) }),
            forKey: .unsupportedReasons
        )
        try container.encodeIfPresent(profile, forKey: .profile)
    }

    public var canUploadArtifacts: Bool { supported.contains(.artifactUpload) }
    public var canPreview: Bool { supported.contains(.preview) }
}

public struct HuenitTelemetryProfile: Codable, Equatable, Sendable {
    public let name: String
    public let baudRate: Int
    public let imageSize: PixelSize
    public let delimiter: String

    public init(
        name: String = "k210-rect-v1",
        baudRate: Int = 115_200,
        imageSize: PixelSize = PixelSize(width: 1280, height: 720),
        delimiter: String = "newline"
    ) {
        self.name = name
        self.baudRate = baudRate
        self.imageSize = imageSize
        self.delimiter = delimiter
    }
}

public struct HuenitTelemetryDetection: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let label: String
    public let boundingBox: NormalizedRect
    public let receivedAt: MonotonicInstant
    public let captureInstant: MonotonicInstant?
    public let generation: UInt64

    public init(
        id: UUID = UUID(),
        label: String,
        boundingBox: NormalizedRect,
        receivedAt: MonotonicInstant,
        captureInstant: MonotonicInstant? = nil,
        generation: UInt64
    ) {
        self.id = id
        self.label = label
        self.boundingBox = boundingBox
        self.receivedAt = receivedAt
        self.captureInstant = captureInstant
        self.generation = generation
    }
}

public enum HuenitTelemetryError: Error, Equatable, Sendable {
    case invalidImageSize
    case invalidEncoding
}

public struct HuenitTelemetryLineDecoder: Sendable {
    private let imageSize: PixelSize
    private let maxLineBytes: Int
    private var buffer: [UInt8] = []
    private var lineStart: MonotonicInstant?
    private var discardingOversizedLine = false

    public private(set) var generation: UInt64 = 0
    public private(set) var malformedLineCount = 0
    public private(set) var oversizedLineCount = 0
    public private(set) var detectionCount = 0

    public init(imageSize: PixelSize, maxLineBytes: Int = 4096) {
        self.imageSize = imageSize
        self.maxLineBytes = max(64, maxLineBytes)
    }

    public var bufferedByteCount: Int { buffer.count }

    public mutating func reconnect() {
        generation += 1
        buffer.removeAll(keepingCapacity: true)
        lineStart = nil
        discardingOversizedLine = false
    }

    public mutating func append(
        _ bytes: Data,
        receivedAt: MonotonicInstant
    ) throws -> [HuenitTelemetryDetection] {
        guard imageSize.isValid else { throw HuenitTelemetryError.invalidImageSize }
        var detections: [HuenitTelemetryDetection] = []
        for byte in bytes {
            if byte == 10 {
                if !discardingOversizedLine, !buffer.isEmpty,
                   let detection = parseLine(receivedAt: lineStart ?? receivedAt) {
                    detections.append(detection)
                    detectionCount += 1
                } else if !buffer.isEmpty, !discardingOversizedLine {
                    malformedLineCount += 1
                }
                buffer.removeAll(keepingCapacity: true)
                lineStart = nil
                discardingOversizedLine = false
                continue
            }
            guard !discardingOversizedLine else { continue }
            if lineStart == nil { lineStart = receivedAt }
            if buffer.count >= maxLineBytes {
                oversizedLineCount += 1
                buffer.removeAll(keepingCapacity: true)
                discardingOversizedLine = true
            } else {
                buffer.append(byte)
            }
        }
        return detections
    }

    private mutating func parseLine(receivedAt: MonotonicInstant) -> HuenitTelemetryDetection? {
        guard let line = String(bytes: buffer, encoding: .utf8) else { return nil }
        let fields = line.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
        guard fields.count == 5,
              !fields[0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let x = Double(fields[1]), let y = Double(fields[2]),
              let width = Double(fields[3]), let height = Double(fields[4]),
              [x, y, width, height].allSatisfy(\.isFinite),
              x >= 0, y >= 0, width > 0, height > 0,
              x + width <= imageSize.width,
              y + height <= imageSize.height else { return nil }
        return HuenitTelemetryDetection(
            label: fields[0].trimmingCharacters(in: .whitespacesAndNewlines),
            boundingBox: NormalizedRect(
                x: x / imageSize.width,
                y: y / imageSize.height,
                width: width / imageSize.width,
                height: height / imageSize.height
            ),
            receivedAt: receivedAt,
            generation: generation
        )
    }
}

public struct HuenitCameraProbeResult: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let source: String
    public let sourceHash: String
    public let measuredAt: String
    public let identityObserved: Bool
    public let baudObserved: Int?
    public let decision: HuenitCameraCapabilityDecision
    public let detectionLineCount: Int

    public init(
        schemaVersion: Int = 1,
        source: String,
        sourceHash: String,
        measuredAt: String,
        identityObserved: Bool,
        baudObserved: Int?,
        decision: HuenitCameraCapabilityDecision,
        detectionLineCount: Int
    ) {
        self.schemaVersion = schemaVersion
        self.source = source
        self.sourceHash = sourceHash
        self.measuredAt = measuredAt
        self.identityObserved = identityObserved
        self.baudObserved = baudObserved
        self.decision = decision
        self.detectionLineCount = detectionLineCount
    }

    public static func parse(transcript: String, sourceHash: String, measuredAt: String) throws -> Self {
        guard sourceHash.count == 64, sourceHash.allSatisfy(\.isHexDigit) else {
            throw HuenitTelemetryError.invalidEncoding
        }
        let lines = transcript.split(whereSeparator: \.isNewline).map(String.init)
        let identity = lines.contains { $0.localizedCaseInsensitiveContains("identity=HUENIT_CAM") }
        let baud = lines.compactMap { line -> Int? in
            guard line.lowercased().hasPrefix("baud=") else { return nil }
            return Int(line.dropFirst(5))
        }.first
        guard identity, baud == 115_200 else {
            throw HuenitTelemetryError.invalidEncoding
        }
        let detections = lines.count { $0.lowercased().hasPrefix("frame=") }
        let profile = HuenitTelemetryProfile(baudRate: 115_200)
        return Self(
            source: "recorded-transcript",
            sourceHash: sourceHash.lowercased(),
            measuredAt: measuredAt,
            identityObserved: true,
            baudObserved: baud,
            decision: HuenitCameraCapabilityDecision(
                status: .measured,
                supported: [.serialTelemetry],
                unsupportedReasons: [
                    .preview: "No reproducible framed preview observed in the read-only probes.",
                    .artifactUpload: "No documented and verified upload handshake was observed."
                ],
                profile: profile
            ),
            detectionLineCount: detections
        )
    }

    public static var notMeasured: Self {
        Self(
            source: "not-measured",
            sourceHash: String(repeating: "0", count: 64),
            measuredAt: "not-measured",
            identityObserved: false,
            baudObserved: nil,
            decision: HuenitCameraCapabilityDecision(
                status: .notMeasured,
                supported: [],
                unsupportedReasons: [
                    .preview: "Hardware probe has not been run.",
                    .artifactUpload: "Hardware probe has not been run."
                ],
                profile: nil
            ),
            detectionLineCount: 0
        )
    }
}
