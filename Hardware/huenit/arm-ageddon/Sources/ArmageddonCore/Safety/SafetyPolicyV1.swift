import Foundation

public enum SafetyState: String, Codable, CaseIterable, Sendable {
    case disconnected
    case detectionOnly
    case eligible
    case armed
    case proposed
    case executing
    case stopping
    case faulted
}

public enum SafetyInhibitionReason: String, Codable, CaseIterable, Sendable {
    case noNativeObservation
    case untrustedCaptureTime
    case staleDetection
    case invalidConfidence
    case formatMismatch
    case modelMismatch
    case noPose
    case stalePose
    case invalidPose
    case noCalibration
    case invalidCalibration
    case targetOutsideWorkspace
    case segmentOutsideWorkspace
    case deltaTooLarge
    case unsafeZ
    case invalidFeed
    case armExpired
    case confirmationExpired
    case stateChanged
}

public struct SafetyObservation: Codable, Equatable, Sendable {
    public let detectionID: String
    public let frameID: UInt64
    public let generation: UInt64
    public let captureInstant: MonotonicInstant
    public let formatIdentity: String
    public let modelHash: String
    public let confidence: Double
    public let targetXY: CalibrationPoint

    public init(
        detectionID: String,
        frameID: UInt64,
        generation: UInt64,
        captureInstant: MonotonicInstant,
        formatIdentity: String,
        modelHash: String,
        confidence: Double,
        targetXY: CalibrationPoint
    ) {
        self.detectionID = detectionID
        self.frameID = frameID
        self.generation = generation
        self.captureInstant = captureInstant
        self.formatIdentity = formatIdentity
        self.modelHash = modelHash
        self.confidence = confidence
        self.targetXY = targetXY
    }

    public init(
        nativeObservation: DetectionObservation,
        format: CaptureFormat,
        modelHash: String,
        targetXY: CalibrationPoint
    ) {
        self.init(
            detectionID: nativeObservation.id,
            frameID: nativeObservation.frameID,
            generation: nativeObservation.generation,
            captureInstant: nativeObservation.captureInstant,
            formatIdentity: "\(format.width)x\(format.height)@\(format.frameRate)-\(format.orientation.rawValue)-\(format.mirrored)",
            modelHash: modelHash,
            confidence: nativeObservation.confidence,
            targetXY: targetXY
        )
    }
}

public struct SafetyPoseReceipt: Codable, Equatable, Sendable {
    public let x: Double
    public let y: Double
    public let z: Double
    public let receivedAt: MonotonicInstant

    public init(x: Double, y: Double, z: Double, receivedAt: MonotonicInstant) {
        self.x = x
        self.y = y
        self.z = z
        self.receivedAt = receivedAt
    }

    public var xy: CalibrationPoint { CalibrationPoint(x: x, y: y) }
}

public struct SafetyProfile: Codable, Equatable, Sendable {
    public let calibrationID: String
    public let deviceID: String
    public let formatIdentity: String
    public let toolID: String
    public let modelHash: String
    public let computationalWorkspace: CalibrationPolygon
    public let safeZBand: CalibrationSafeZBand
    public let feedMillimetersPerMinute: Double

    public init(
        calibrationID: String,
        deviceID: String,
        formatIdentity: String,
        toolID: String,
        modelHash: String,
        computationalWorkspace: CalibrationPolygon,
        safeZBand: CalibrationSafeZBand,
        feedMillimetersPerMinute: Double
    ) {
        self.calibrationID = calibrationID
        self.deviceID = deviceID
        self.formatIdentity = formatIdentity
        self.toolID = toolID
        self.modelHash = modelHash
        self.computationalWorkspace = computationalWorkspace
        self.safeZBand = safeZBand
        self.feedMillimetersPerMinute = feedMillimetersPerMinute
    }
}

public struct SafetySnapshot: Codable, Equatable, Sendable {
    public let state: SafetyState
    public let observation: SafetyObservation?
    public let pose: SafetyPoseReceipt?
    public let profile: SafetyProfile?
    public let armedAt: MonotonicInstant?
    public let confirmedAt: MonotonicInstant?

    public init(
        state: SafetyState = .detectionOnly,
        observation: SafetyObservation? = nil,
        pose: SafetyPoseReceipt? = nil,
        profile: SafetyProfile? = nil,
        armedAt: MonotonicInstant? = nil,
        confirmedAt: MonotonicInstant? = nil
    ) {
        self.state = state
        self.observation = observation
        self.pose = pose
        self.profile = profile
        self.armedAt = armedAt
        self.confirmedAt = confirmedAt
    }
}

public struct SafetyVerdict: Codable, Equatable, Sendable {
    public let state: SafetyState
    public let reasons: [SafetyInhibitionReason]

    public var isEligible: Bool { reasons.isEmpty && state == .eligible }

    public init(state: SafetyState, reasons: [SafetyInhibitionReason]) {
        self.state = state
        self.reasons = Array(Set(reasons)).sorted { $0.rawValue < $1.rawValue }
    }
}

public enum SafetyPolicyV1 {
    public static let maxDetectionAgeNanoseconds: UInt64 = 500_000_000
    public static let maxPoseAgeNanoseconds: UInt64 = 750_000_000
    public static let maxMoveMillimeters = 19.99
    public static let maxFeedMillimetersPerMinute = 300.0
    public static let armLifetimeNanoseconds: UInt64 = 30_000_000_000
    public static let confirmationLifetimeNanoseconds: UInt64 = 5_000_000_000
    public static let computationalInsetMillimeters = 10.1

    public static func evaluate(_ snapshot: SafetySnapshot, now: MonotonicInstant) -> SafetyVerdict {
        var reasons: [SafetyInhibitionReason] = []
        guard snapshot.state != .disconnected else { return SafetyVerdict(state: .disconnected, reasons: [.noNativeObservation]) }
        guard let observation = snapshot.observation else {
            return SafetyVerdict(state: .detectionOnly, reasons: [.noNativeObservation])
        }
        guard observation.captureInstant <= now else { reasons.append(.untrustedCaptureTime); return verdict(reasons) }
        let detectionAge = now.nanoseconds - observation.captureInstant.nanoseconds
        if detectionAge > maxDetectionAgeNanoseconds { reasons.append(.staleDetection) }
        if !observation.confidence.isFinite || !(0...1).contains(observation.confidence) {
            reasons.append(.invalidConfidence)
        }
        if !observation.targetXY.isFinite { reasons.append(.targetOutsideWorkspace) }
        guard let profile = snapshot.profile else { reasons.append(.noCalibration); return verdict(reasons) }
        if observation.formatIdentity != profile.formatIdentity { reasons.append(.formatMismatch) }
        if observation.modelHash != profile.modelHash { reasons.append(.modelMismatch) }
        guard let pose = snapshot.pose else { reasons.append(.noPose); return verdict(reasons) }
        guard pose.receivedAt <= now else { reasons.append(.invalidPose); return verdict(reasons) }
        if now.nanoseconds - pose.receivedAt.nanoseconds > maxPoseAgeNanoseconds { reasons.append(.stalePose) }
        if ![pose.x, pose.y, pose.z].allSatisfy(\.isFinite) { reasons.append(.invalidPose) }
        guard profile.feedMillimetersPerMinute.isFinite,
              profile.feedMillimetersPerMinute > 0,
              profile.feedMillimetersPerMinute <= maxFeedMillimetersPerMinute else {
            reasons.append(.invalidFeed)
            return verdict(reasons)
        }
        if !(profile.safeZBand.minimum + 0.1 < profile.safeZBand.maximum - 0.1
            && pose.z > profile.safeZBand.minimum + 0.1
            && pose.z < profile.safeZBand.maximum - 0.1) {
            reasons.append(.unsafeZ)
        }
        if !containsStrictlyInset(profile.computationalWorkspace, pose.xy)
            || !containsStrictlyInset(profile.computationalWorkspace, observation.targetXY) {
            reasons.append(.targetOutsideWorkspace)
        }
        let delta = hypot(observation.targetXY.x - pose.x, observation.targetXY.y - pose.y)
        if !delta.isFinite || delta > maxMoveMillimeters { reasons.append(.deltaTooLarge) }
        if !segmentIsStrictlyInsideInset(profile.computationalWorkspace, from: pose.xy, to: observation.targetXY) {
            reasons.append(.segmentOutsideWorkspace)
        }
        return verdict(reasons)
    }

    private static func verdict(_ reasons: [SafetyInhibitionReason]) -> SafetyVerdict {
        SafetyVerdict(state: reasons.isEmpty ? .eligible : .detectionOnly, reasons: reasons)
    }

    private static func containsStrictly(_ polygon: CalibrationPolygon, _ point: CalibrationPoint) -> Bool {
        var inside = false
        for index in polygon.vertices.indices {
            let next = (index + 1) % polygon.vertices.count
            let a = polygon.vertices[index]
            let b = polygon.vertices[next]
            let edge = (b.x - a.x) * (point.y - a.y) - (b.y - a.y) * (point.x - a.x)
            let along = (point.x - a.x) * (point.x - b.x) + (point.y - a.y) * (point.y - b.y)
            if abs(edge) < 0.000_001, along <= 0 { return false }
            let crosses = (a.y > point.y) != (b.y > point.y)
                && point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x
            if crosses { inside.toggle() }
        }
        return inside
    }

    private static func segmentIsStrictlyInside(
        _ polygon: CalibrationPolygon,
        from: CalibrationPoint,
        to: CalibrationPoint
    ) -> Bool {
        guard containsStrictly(polygon, from), containsStrictly(polygon, to) else { return false }
        for step in 1...256 {
            let t = Double(step) / 256
            let point = CalibrationPoint(
                x: from.x + (to.x - from.x) * t,
                y: from.y + (to.y - from.y) * t
            )
            if !containsStrictly(polygon, point) { return false }
        }
        return true
    }

    private static func containsStrictlyInset(_ polygon: CalibrationPolygon, _ point: CalibrationPoint) -> Bool {
        guard containsStrictly(polygon, point) else { return false }
        return polygon.vertices.indices.allSatisfy { index in
            let next = (index + 1) % polygon.vertices.count
            return distance(from: point, to: polygon.vertices[index], and: polygon.vertices[next]) > computationalInsetMillimeters
        }
    }

    private static func segmentIsStrictlyInsideInset(
        _ polygon: CalibrationPolygon,
        from: CalibrationPoint,
        to: CalibrationPoint
    ) -> Bool {
        guard containsStrictlyInset(polygon, from), containsStrictlyInset(polygon, to) else { return false }
        for step in 1...256 {
            let t = Double(step) / 256
            let point = CalibrationPoint(
                x: from.x + (to.x - from.x) * t,
                y: from.y + (to.y - from.y) * t
            )
            if !containsStrictlyInset(polygon, point) { return false }
        }
        return true
    }

    private static func distance(
        from point: CalibrationPoint,
        to start: CalibrationPoint,
        and end: CalibrationPoint
    ) -> Double {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 0 else { return hypot(point.x - start.x, point.y - start.y) }
        let projection = max(0, min(1, ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared))
        return hypot(point.x - (start.x + projection * dx), point.y - (start.y + projection * dy))
    }
}

private func pointsMatch(_ lhs: CalibrationPoint, _ rhs: CalibrationPoint?) -> Bool {
    guard let rhs else { return false }
    return abs(lhs.x - rhs.x) <= 0.000_001 && abs(lhs.y - rhs.y) <= 0.000_001
}

public struct SafetyPermit: Sendable, Equatable {
    fileprivate let id: UUID
    let proposalHash: String
    fileprivate init(id: UUID, proposalHash: String) {
        self.id = id
        self.proposalHash = proposalHash
    }
}

public final class MotionExecutionPermit: @unchecked Sendable {
    private let lock = NSLock()
    private let id: UUID
    private let proposal: TargetProposal
    private let snapshot: SafetySnapshot
    private var active = true
    private var consumed = false

    fileprivate init(id: UUID, proposal: TargetProposal, snapshot: SafetySnapshot) {
        self.id = id
        self.proposal = proposal
        self.snapshot = snapshot
    }

    public func consume(now: MonotonicInstant) -> MonotonicInstant? {
        lock.lock()
        defer { lock.unlock() }
        guard active, !consumed,
              SafetyPolicyV1.evaluate(snapshot, now: now).isEligible,
              proposal.policyState == .eligible,
              pointsMatch(proposal.fromXY, snapshot.pose?.xy) else { return nil }
        consumed = true
        return now
    }

    fileprivate func invalidate() {
        lock.lock()
        active = false
        lock.unlock()
    }

    fileprivate var proposalHash: String { proposal.proposalHash }
    fileprivate var idValue: UUID { id }
}

public protocol SupervisedXYMotionWriter: Sendable {
    func writeXY(
        delta: CalibrationPoint,
        feedMillimetersPerMinute: Double,
        executionPermit: MotionExecutionPermit,
        now: @escaping @Sendable () -> MonotonicInstant
    ) async throws -> MonotonicInstant
}

public actor SafetyController {
    private var snapshot = SafetySnapshot()
    private var permitID: UUID?
    private var executionPermit: MotionExecutionPermit?

    public init() {}

    public func update(_ snapshot: SafetySnapshot) {
        executionPermit?.invalidate()
        executionPermit = nil
        self.snapshot = snapshot
        if snapshot.state != .armed { permitID = nil }
    }

    public func current() -> SafetySnapshot { snapshot }

    public func arm(now: MonotonicInstant) throws {
        let verdict = SafetyPolicyV1.evaluate(snapshot, now: now)
        guard verdict.isEligible else { throw SafetyControllerError.inhibited(verdict.reasons) }
        snapshot = SafetySnapshot(
            state: .armed,
            observation: snapshot.observation,
            pose: snapshot.pose,
            profile: snapshot.profile,
            armedAt: now,
            confirmedAt: nil
        )
        permitID = UUID()
        executionPermit = nil
    }

    public func revoke(state: SafetyState = .detectionOnly) {
        executionPermit?.invalidate()
        executionPermit = nil
        snapshot = SafetySnapshot(state: state, observation: snapshot.observation, pose: snapshot.pose, profile: snapshot.profile)
        permitID = nil
    }

    func reserveExecutionPermit(proposal: TargetProposal) throws -> MotionExecutionPermit {
        guard snapshot.state == .armed,
              permitID != nil,
              executionPermit == nil,
              proposal.policyState == .eligible,
              proposal.armedAt == snapshot.armedAt,
              proposal.frameID == snapshot.observation?.frameID,
              proposal.generation == snapshot.observation?.generation,
              proposal.detectionID == snapshot.observation?.detectionID,
              proposal.captureInstant == snapshot.observation?.captureInstant,
              proposal.formatIdentity == snapshot.observation?.formatIdentity,
              proposal.modelHash == snapshot.observation?.modelHash,
              pointsMatch(proposal.fromXY, snapshot.pose?.xy),
              proposal.calibrationID == snapshot.profile?.calibrationID,
              proposal.modelHash == snapshot.profile?.modelHash else {
            permitID = nil
            throw SafetyControllerError.inhibited([.stateChanged])
        }
        let permit = MotionExecutionPermit(id: permitID!, proposal: proposal, snapshot: snapshot)
        executionPermit = permit
        permitID = nil
        snapshot = SafetySnapshot(
            state: .executing,
            observation: snapshot.observation,
            pose: snapshot.pose,
            profile: snapshot.profile,
            armedAt: snapshot.armedAt,
            confirmedAt: snapshot.confirmedAt
        )
        return permit
    }

    public func consumePermit(now: MonotonicInstant, proposal: TargetProposal) throws -> SafetyPermit {
        if let executionPermit {
            guard executionPermit.proposalHash == proposal.proposalHash,
                  executionPermit.consume(now: now) != nil else {
                self.executionPermit = nil
                throw SafetyControllerError.inhibited([.stateChanged])
            }
            self.executionPermit = nil
            return SafetyPermit(id: executionPermit.idValue, proposalHash: proposal.proposalHash)
        }
        guard let armedAt = snapshot.armedAt,
              now.nanoseconds >= armedAt.nanoseconds,
              now.nanoseconds - armedAt.nanoseconds <= SafetyPolicyV1.armLifetimeNanoseconds,
              let permit = self.permitID,
              let observation = snapshot.observation,
              let pose = snapshot.pose,
              let profile = snapshot.profile,
              proposal.policyState == .eligible,
              proposal.armedAt == armedAt,
              proposal.frameID == observation.frameID,
              proposal.generation == observation.generation,
              proposal.detectionID == observation.detectionID,
              proposal.captureInstant == observation.captureInstant,
              proposal.formatIdentity == observation.formatIdentity,
              proposal.modelHash == observation.modelHash,
              pointsMatch(proposal.targetXY, observation.targetXY),
              pointsMatch(proposal.fromXY, pose.xy),
              proposal.calibrationID == profile.calibrationID,
              proposal.modelHash == profile.modelHash,
              SafetyPolicyV1.evaluate(snapshot, now: now).isEligible else {
            self.permitID = nil
            throw SafetyControllerError.inhibited([.armExpired])
        }
        self.permitID = nil
        snapshot = SafetySnapshot(
            state: .executing,
            observation: snapshot.observation,
            pose: snapshot.pose,
            profile: snapshot.profile,
            armedAt: armedAt,
            confirmedAt: nil
        )
        return SafetyPermit(id: permit, proposalHash: proposal.proposalHash)
    }
}

public enum SafetyControllerError: Error, Equatable, Sendable {
    case inhibited([SafetyInhibitionReason])
}
