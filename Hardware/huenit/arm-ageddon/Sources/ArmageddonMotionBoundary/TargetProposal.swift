import ArmageddonCore
import CryptoKit
import Foundation

public struct TargetProposal: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let proposalHash: String
    public let frameID: UInt64
    public let generation: UInt64
    public let detectionID: String
    public let calibrationID: String
    public let modelHash: String
    public let captureInstant: MonotonicInstant
    public let poseInstant: MonotonicInstant
    public let proposedAt: MonotonicInstant
    public let armedAt: MonotonicInstant
    public let fromXY: CalibrationPoint
    public let targetXY: CalibrationPoint
    public let deltaXY: CalibrationPoint
    public let feedMillimetersPerMinute: Double
    public let policyState: SafetyState
    public let policyReasons: [SafetyInhibitionReason]

    public init(
        id: UUID = UUID(),
        frameID: UInt64,
        generation: UInt64,
        detectionID: String,
        calibrationID: String,
        modelHash: String,
        captureInstant: MonotonicInstant,
        poseInstant: MonotonicInstant,
        proposedAt: MonotonicInstant,
        armedAt: MonotonicInstant,
        fromXY: CalibrationPoint,
        targetXY: CalibrationPoint,
        feedMillimetersPerMinute: Double,
        policyState: SafetyState,
        policyReasons: [SafetyInhibitionReason] = []
    ) throws {
        guard [fromXY.x, fromXY.y, targetXY.x, targetXY.y, feedMillimetersPerMinute].allSatisfy(\.isFinite),
              feedMillimetersPerMinute > 0,
              feedMillimetersPerMinute <= SafetyPolicyV1.maxFeedMillimetersPerMinute else {
            throw TargetProposalError.invalidGeometry
        }
        self.id = id
        self.frameID = frameID
        self.generation = generation
        self.detectionID = detectionID
        self.calibrationID = calibrationID
        self.modelHash = modelHash
        self.captureInstant = captureInstant
        self.poseInstant = poseInstant
        self.proposedAt = proposedAt
        self.armedAt = armedAt
        self.fromXY = fromXY
        self.targetXY = targetXY
        deltaXY = CalibrationPoint(x: targetXY.x - fromXY.x, y: targetXY.y - fromXY.y)
        self.feedMillimetersPerMinute = feedMillimetersPerMinute
        self.policyState = policyState
        self.policyReasons = policyReasons
        proposalHash = try Self.hash(
            ProposalHashPayload(
                id: id,
                frameID: frameID,
                generation: generation,
                detectionID: detectionID,
                calibrationID: calibrationID,
                modelHash: modelHash,
                captureInstant: captureInstant,
                poseInstant: poseInstant,
                proposedAt: proposedAt,
                armedAt: armedAt,
                fromXY: fromXY,
                targetXY: targetXY,
                feedMillimetersPerMinute: feedMillimetersPerMinute,
                policyState: policyState,
                policyReasons: policyReasons
            )
        )
    }

    public func confirmation(now: MonotonicInstant) throws -> ProposalConfirmation {
        guard now >= proposedAt,
              now.nanoseconds - proposedAt.nanoseconds <= SafetyPolicyV1.confirmationLifetimeNanoseconds else {
            throw TargetProposalError.confirmationExpired
        }
        return ProposalConfirmation(
            proposalID: id,
            proposalHash: proposalHash,
            expiresAt: now.adding(nanoseconds: Int64(SafetyPolicyV1.confirmationLifetimeNanoseconds)) ?? now
        )
    }

    private struct ProposalHashPayload: Codable, Sendable {
        let id: UUID
        let frameID: UInt64
        let generation: UInt64
        let detectionID: String
        let calibrationID: String
        let modelHash: String
        let captureInstant: MonotonicInstant
        let poseInstant: MonotonicInstant
        let proposedAt: MonotonicInstant
        let armedAt: MonotonicInstant
        let fromXY: CalibrationPoint
        let targetXY: CalibrationPoint
        let feedMillimetersPerMinute: Double
        let policyState: SafetyState
        let policyReasons: [SafetyInhibitionReason]
    }

    private static func hash(_ payload: ProposalHashPayload) throws -> String {
        try CaptureHashing.sha256(payload)
    }
}

public struct ProposalConfirmation: Sendable, Equatable {
    fileprivate let proposalID: UUID
    fileprivate let proposalHash: String
    fileprivate let expiresAt: MonotonicInstant

    fileprivate init(proposalID: UUID, proposalHash: String, expiresAt: MonotonicInstant) {
        self.proposalID = proposalID
        self.proposalHash = proposalHash
        self.expiresAt = expiresAt
    }
}

public enum TargetProposalError: Error, Equatable, Sendable {
    case noSelectedObservation
    case staleObservation
    case policyInhibited([SafetyInhibitionReason])
    case invalidGeometry
    case confirmationExpired
    case forgedConfirmation
    case confirmationAlreadyConsumed
}

public enum TargetProposalBuilder {
    public static func build(
        selected observation: DetectionObservation?,
        selectedObservationID: String,
        format: CaptureFormat,
        modelHash: String,
        profile: PlanarCalibrationProfile,
        pose: SafetyPoseReceipt,
        armedAt: MonotonicInstant,
        now: MonotonicInstant
    ) throws -> TargetProposal {
        guard let observation, observation.id == selectedObservationID else {
            throw TargetProposalError.noSelectedObservation
        }
        guard observation.captureInstant <= now,
              now.nanoseconds - observation.captureInstant.nanoseconds <= SafetyPolicyV1.maxDetectionAgeNanoseconds else {
            throw TargetProposalError.staleObservation
        }
        let sourceCenter = CalibrationPoint(
            x: observation.boundingBox.x + observation.boundingBox.width / 2,
            y: observation.boundingBox.y + observation.boundingBox.height / 2
        )
        let target = try profile.transform(sourceCenter)
        let formatIdentity = "\(format.width)x\(format.height)@\(format.frameRate)-\(format.orientation.rawValue)-\(format.mirrored)"
        let safetyObservation = SafetyObservation(
            nativeObservation: observation,
            format: format,
            modelHash: modelHash,
            targetXY: target
        )
        let snapshot = SafetySnapshot(
            state: .eligible,
            observation: safetyObservation,
            pose: pose,
            profile: SafetyProfile(
                calibrationID: profile.id.uuidString,
                deviceID: profile.deviceID,
                formatIdentity: formatIdentity,
                toolID: profile.toolID,
                modelHash: modelHash,
                computationalWorkspace: profile.polygon,
                safeZBand: profile.safeZBand,
                feedMillimetersPerMinute: min(300, 300)
            ),
            armedAt: armedAt
        )
        let verdict = SafetyPolicyV1.evaluate(snapshot, now: now)
        guard verdict.isEligible else { throw TargetProposalError.policyInhibited(verdict.reasons) }
        return try TargetProposal(
            frameID: observation.frameID,
            generation: observation.generation,
            detectionID: observation.id,
            calibrationID: profile.id.uuidString,
            modelHash: modelHash,
            captureInstant: observation.captureInstant,
            poseInstant: pose.receivedAt,
            proposedAt: now,
            armedAt: armedAt,
            fromXY: pose.xy,
            targetXY: target,
            feedMillimetersPerMinute: 300,
            policyState: verdict.state,
            policyReasons: verdict.reasons
        )
    }
}

public actor TargetProposalStore {
    private var proposals: [UUID: TargetProposal] = [:]
    private var consumed: Set<UUID> = []
    private var generation: UInt64 = 0

    public init() {}

    public func insert(_ proposal: TargetProposal) {
        proposals[proposal.id] = proposal
        generation &+= 1
    }

    public func invalidateAll() {
        proposals.removeAll()
        generation &+= 1
    }

    public func consume(_ confirmation: ProposalConfirmation, now: MonotonicInstant) throws -> TargetProposal {
        guard now <= confirmation.expiresAt else { throw TargetProposalError.confirmationExpired }
        guard let proposal = proposals[confirmation.proposalID], proposal.proposalHash == confirmation.proposalHash else {
            throw TargetProposalError.forgedConfirmation
        }
        guard !consumed.contains(proposal.id) else { throw TargetProposalError.confirmationAlreadyConsumed }
        consumed.insert(proposal.id)
        return proposal
    }
}
