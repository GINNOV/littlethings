import ArmageddonCore
import ArmageddonMotionBoundary
import Foundation
import Observation

enum RunWorkspaceExecutionMode: Sendable, Equatable {
    case unavailable
    case deterministicFixture
}

enum RunWorkspaceStatus: String, Sendable, Equatable {
    case unavailable
    case ready
    case executing
    case completed
    case noWrite
    case indeterminate

    var label: String {
        switch self {
        case .unavailable: "Unavailable"
        case .ready: "Ready for confirmation"
        case .executing: "Executing"
        case .completed: "Completed"
        case .noWrite: "No write"
        case .indeterminate: "Indeterminate"
        }
    }
}

@MainActor
@Observable
final class RunsWorkspaceModel {
    private let mode: RunWorkspaceExecutionMode
    private let clock: any CaptureHostClock
    private let safety: SafetyController
    private let proposals: TargetProposalStore
    private let fixturePoseReader: FixturePoseReader?
    private let coordinator: RunCoordinator
    private var confirmation: ProposalConfirmation?

    private(set) var status: RunWorkspaceStatus
    private(set) var statusMessage: String
    private(set) var proposal: TargetProposal?
    private(set) var timeline: [RunTimelineEvent] = []
    private(set) var lastResult: RunResult?

    var isDeterministicFixture: Bool { mode == .deterministicFixture }
    var executionModeDescription: String {
        switch mode {
        case .unavailable:
            "A verified arm pose and writer runtime are not configured for this launch."
        case .deterministicFixture:
            "Deterministic supervised runtime; no serial transport is opened."
        }
    }

    var targetWorkspacePoint: CalibrationPoint? { proposal?.targetXY }
    var hasPreparedProposal: Bool { confirmation != nil }
    var canExecute: Bool { status == .ready && confirmation != nil }

    init(mode: RunWorkspaceExecutionMode, journalRoot: URL, clock: any CaptureHostClock) {
        self.mode = mode
        self.clock = clock
        let safety = SafetyController()
        self.safety = safety
        let proposals = TargetProposalStore()
        self.proposals = proposals

        let fixturePoseReader = mode == .deterministicFixture ? FixturePoseReader(clock: clock) : nil
        self.fixturePoseReader = fixturePoseReader
        let poseReader: any RunPoseReader = fixturePoseReader ?? UnavailablePoseReader()
        let writer: any SupervisedXYMotionWriter = mode == .deterministicFixture
            ? FixtureMotionWriter()
            : UnavailableMotionWriter()
        coordinator = RunCoordinator(
            safety: safety,
            proposals: proposals,
            poseReader: poseReader,
            writer: writer,
            journalRoot: journalRoot,
            clock: { clock.now() }
        )
        status = .unavailable
        statusMessage = mode == .deterministicFixture
            ? "Select a detection and active calibration to prepare a supervised proposal."
            : "Supervised execution is unavailable until a verified arm runtime is configured."
    }

    func prepare(
        observation: DetectionObservation?,
        selectedObservationID: String?,
        format: CaptureFormat?,
        modelHash: String,
        profile: PlanarCalibrationProfile?
    ) async {
        await clearPreparedRun()
        guard mode == .deterministicFixture else {
            statusMessage = "Supervised execution is fail-closed for this launch: no verified arm runtime is configured."
            return
        }
        guard let observation,
              let selectedObservationID,
              let format,
              let profile,
              observation.id == selectedObservationID else {
            statusMessage = "Select one fresh detection and an active calibration profile first."
            return
        }

        let now = clock.now()
        let sourceCenter = CalibrationPoint(
            x: (observation.boundingBox.x + observation.boundingBox.width / 2) * Double(format.width),
            y: (observation.boundingBox.y + observation.boundingBox.height / 2) * Double(format.height)
        )
        guard let target = try? profile.transform(sourceCenter) else {
            statusMessage = "The selected detection could not be transformed by the active calibration."
            return
        }
        let pose = SafetyPoseReceipt(
            x: target.x - 1,
            y: target.y,
            z: (profile.safeZBand.minimum + profile.safeZBand.maximum) / 2,
            receivedAt: now
        )
        await fixturePoseReader?.set(pose)

        do {
            let proposal = try TargetProposalBuilder.build(
                selected: observation,
                selectedObservationID: selectedObservationID,
                format: format,
                modelHash: modelHash,
                profile: profile,
                pose: pose,
                armedAt: now,
                now: now
            )
            let formatIdentity = "\(format.width)x\(format.height)@\(format.frameRate)-\(format.orientation.rawValue)-\(format.mirrored)"
            let safetySnapshot = SafetySnapshot(
                state: .eligible,
                observation: SafetyObservation(
                    nativeObservation: observation,
                    format: format,
                    modelHash: modelHash,
                    targetXY: proposal.targetXY
                ),
                pose: pose,
                profile: SafetyProfile(
                    calibrationID: profile.id.uuidString,
                    deviceID: profile.deviceID,
                    formatIdentity: formatIdentity,
                    toolID: profile.toolID,
                    modelHash: modelHash,
                    computationalWorkspace: profile.polygon,
                    safeZBand: profile.safeZBand,
                    feedMillimetersPerMinute: proposal.feedMillimetersPerMinute
                )
            )
            await safety.update(safetySnapshot)
            try await safety.arm(now: now)
            await proposals.insert(proposal)
            confirmation = try proposal.confirmation(now: now)
            self.proposal = proposal
            status = .ready
            statusMessage = "Proposal is armed in the typed boundary. Confirm once to execute exactly one XY move."
        } catch {
            status = .noWrite
            statusMessage = "Proposal preparation was refused; no motion was written (\(String(describing: error)))."
        }
    }

    func execute() async {
        guard let confirmation, status == .ready else { return }
        status = .executing
        statusMessage = "Durably reserving the proposal before final pose validation."
        do {
            let result = try await coordinator.submit(confirmation)
            lastResult = result
            timeline = result.timeline
            self.confirmation = nil
            status = .completed
            statusMessage = "One supervised XY move completed and the run timeline was persisted."
        } catch {
            timeline = await coordinator.currentTimeline()
            self.confirmation = nil
            status = timeline.last?.kind == .indeterminate ? .indeterminate : .noWrite
            statusMessage = status == .indeterminate
                ? "The write outcome is indeterminate; the boundary is disarmed and will not replay it."
                : "The boundary rejected the run and persisted a no-write terminal timeline."
        }
    }

    func stop() async {
        confirmation = nil
        await safety.revoke(state: .stopping)
        status = .noWrite
        statusMessage = "STOP revoked the pending run; no motion will be written."
    }

    private func clearPreparedRun() async {
        confirmation = nil
        proposal = nil
        timeline = []
        lastResult = nil
        await proposals.invalidateAll()
        await safety.revoke()
    }
}

private actor FixturePoseReader: RunPoseReader {
    private let clock: any CaptureHostClock
    private var pose: SafetyPoseReceipt?

    init(clock: any CaptureHostClock) {
        self.clock = clock
    }

    func set(_ pose: SafetyPoseReceipt) {
        self.pose = pose
    }

    func readPose() async throws -> SafetyPoseReceipt {
        guard let pose else { throw RunCoordinatorError.poseFailure }
        return SafetyPoseReceipt(x: pose.x, y: pose.y, z: pose.z, receivedAt: clock.now())
    }
}

private struct UnavailablePoseReader: RunPoseReader {
    func readPose() async throws -> SafetyPoseReceipt {
        throw RunCoordinatorError.poseFailure
    }
}

private actor FixtureMotionWriter: SupervisedXYMotionWriter {
    private(set) var writeCount = 0

    func writeXY(
        delta: CalibrationPoint,
        feedMillimetersPerMinute: Double,
        executionPermit: MotionExecutionPermit,
        now: @escaping @Sendable () -> MonotonicInstant
    ) async throws -> MonotonicInstant {
        _ = delta
        _ = feedMillimetersPerMinute
        guard let consumedAt = executionPermit.consume(now: now()) else {
            throw RunCoordinatorError.safetyFailure
        }
        writeCount += 1
        return consumedAt
    }
}

private struct UnavailableMotionWriter: SupervisedXYMotionWriter {
    func writeXY(
        delta: CalibrationPoint,
        feedMillimetersPerMinute: Double,
        executionPermit: MotionExecutionPermit,
        now: @escaping @Sendable () -> MonotonicInstant
    ) async throws -> MonotonicInstant {
        _ = delta
        _ = feedMillimetersPerMinute
        _ = executionPermit
        _ = now
        throw RunCoordinatorError.writerFailure
    }
}
