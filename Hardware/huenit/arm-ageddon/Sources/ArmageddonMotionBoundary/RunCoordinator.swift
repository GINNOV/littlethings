import ArmageddonCore
import Darwin
import Foundation

public protocol RunPoseReader: Sendable {
    func readPose() async throws -> SafetyPoseReceipt
}

public enum RunEventKind: String, Codable, Sendable {
    case reservation
    case intentDurable
    case poseRead
    case writerAcquired
    case permitConsumed
    case firstByte
    case completed
    case indeterminate
    case noWrite
}

public struct RunTimelineEvent: Codable, Equatable, Sendable {
    public let kind: RunEventKind
    public let at: MonotonicInstant
    public let executionID: UUID
    public let detail: String

    public init(kind: RunEventKind, at: MonotonicInstant, executionID: UUID, detail: String) {
        self.kind = kind
        self.at = at
        self.executionID = executionID
        self.detail = detail
    }
}

public struct RunResult: Codable, Equatable, Sendable {
    public let executionID: UUID
    public let wroteMotion: Bool
    public let timeline: [RunTimelineEvent]

    public init(executionID: UUID, wroteMotion: Bool, timeline: [RunTimelineEvent]) {
        self.executionID = executionID
        self.wroteMotion = wroteMotion
        self.timeline = timeline
    }
}

public enum RunCoordinatorError: Error, Equatable, Sendable {
    case concurrentSubmission
    case journalCollision
    case journalFailure(String)
    case poseFailure
    case writerFailure
    case safetyFailure
}

public actor RunCoordinator {
    private let safety: SafetyController
    private let proposals: TargetProposalStore
    private let poseReader: any RunPoseReader
    private let writer: any SupervisedXYMotionWriter
    private let journalRoot: URL
    private let clock: @Sendable () -> MonotonicInstant
    private var activeExecutionID: UUID?
    private var timeline: [RunTimelineEvent] = []

    public init(
        safety: SafetyController,
        proposals: TargetProposalStore,
        poseReader: any RunPoseReader,
        writer: any SupervisedXYMotionWriter,
        journalRoot: URL,
        clock: @escaping @Sendable () -> MonotonicInstant
    ) {
        self.safety = safety
        self.proposals = proposals
        self.poseReader = poseReader
        self.writer = writer
        self.journalRoot = journalRoot.standardizedFileURL
        self.clock = clock
    }

    public func submit(_ confirmation: ProposalConfirmation) async throws -> RunResult {
        guard activeExecutionID == nil else { throw RunCoordinatorError.concurrentSubmission }
        let executionID = UUID()
        activeExecutionID = executionID
        timeline = [RunTimelineEvent(kind: .reservation, at: clock(), executionID: executionID, detail: "reserved")]
        var motionStarted = false
        do {
            let proposal = try await proposals.consume(confirmation, now: clock())
            try DurableRunJournal.prepare(root: journalRoot, executionID: executionID, proposal: proposal)
            append(.intentDurable, executionID: executionID, detail: "intent fsync")
            let pose = try await poseReader.readPose()
            append(.poseRead, executionID: executionID, detail: "pose receipt")
            var safetySnapshot = await safety.current()
            safetySnapshot = SafetySnapshot(
                state: safetySnapshot.state,
                observation: safetySnapshot.observation,
                pose: pose,
                profile: safetySnapshot.profile,
                armedAt: safetySnapshot.armedAt,
                confirmedAt: safetySnapshot.confirmedAt
            )
            await safety.update(safetySnapshot)
            append(.writerAcquired, executionID: executionID, detail: "writer actor")
            let permit = try await safety.reserveExecutionPermit(proposal: proposal)
            let permitConsumedAt = try await writer.writeXY(
                delta: proposal.deltaXY,
                feedMillimetersPerMinute: proposal.feedMillimetersPerMinute,
                executionPermit: permit,
                now: clock
            )
            append(.permitConsumed, executionID: executionID, at: permitConsumedAt, detail: "private permit")
            motionStarted = true
            append(.firstByte, executionID: executionID, detail: "XY writer accepted one move")
            append(.completed, executionID: executionID, detail: "completed")
            try DurableRunJournal.writeTerminal(root: journalRoot, executionID: executionID, kind: .completed, timeline: timeline)
            await safety.revoke()
            return RunResult(executionID: executionID, wroteMotion: true, timeline: timeline)
        } catch let error as RunCoordinatorError {
            await safety.revoke(state: .faulted)
            recordTerminal(kind: motionStarted ? .indeterminate : .noWrite, executionID: executionID, detail: error.localizedDescription)
            throw error
        } catch let error as SafetyControllerError {
            await safety.revoke(state: .faulted)
            recordTerminal(kind: motionStarted ? .indeterminate : .noWrite, executionID: executionID, detail: "safety inhibited: \(error)")
            throw RunCoordinatorError.safetyFailure
        } catch {
            await safety.revoke(state: .faulted)
            recordTerminal(kind: motionStarted ? .indeterminate : .noWrite, executionID: executionID, detail: "no write")
            throw RunCoordinatorError.writerFailure
        }
    }

    public func currentTimeline() -> [RunTimelineEvent] { timeline }

    private func append(_ kind: RunEventKind, executionID: UUID, detail: String) {
        append(kind, executionID: executionID, at: clock(), detail: detail)
    }

    private func append(_ kind: RunEventKind, executionID: UUID, at: MonotonicInstant, detail: String) {
        timeline.append(RunTimelineEvent(kind: kind, at: at, executionID: executionID, detail: detail))
        if kind == .completed || kind == .indeterminate || kind == .noWrite { activeExecutionID = nil }
    }

    private func recordTerminal(kind: RunEventKind, executionID: UUID, detail: String) {
        append(kind, executionID: executionID, detail: detail)
        try? DurableRunJournal.writeTerminal(root: journalRoot, executionID: executionID, kind: kind, timeline: timeline)
    }
}

private enum DurableRunJournal {
    static func prepare(root: URL, executionID: UUID, proposal: TargetProposal) throws {
        try makeDirectory(root)
        let executions = root.appendingPathComponent("Executions", isDirectory: true)
        try makeDirectory(executions)
        let execution = executions.appendingPathComponent(executionID.uuidString, isDirectory: true)
        try makeDirectory(execution)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(proposal) + Data("\n".utf8)
        try writeExclusive(data, to: execution.appendingPathComponent("intent.json"))
    }

    static func writeTerminal(
        root: URL,
        executionID: UUID,
        kind: RunEventKind,
        timeline: [RunTimelineEvent]
    ) throws {
        let execution = root.appendingPathComponent("Executions", isDirectory: true)
            .appendingPathComponent(executionID.uuidString, isDirectory: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(RunResult(executionID: executionID, wroteMotion: kind == .completed, timeline: timeline)) + Data("\n".utf8)
        try writeExclusive(data, to: execution.appendingPathComponent("\(kind.rawValue).json"))
    }

    private static func makeDirectory(_ url: URL) throws {
        let result = Darwin.mkdir(url.path, 0o700)
        if result != 0 {
            guard errno == EEXIST else { throw RunCoordinatorError.journalFailure("mkdir") }
            var info = stat()
            guard Darwin.lstat(url.path, &info) == 0,
                  (info.st_mode & S_IFMT) == S_IFDIR else {
                throw RunCoordinatorError.journalFailure("existing journal path is not a directory")
            }
        }
        let parent = Darwin.open(url.deletingLastPathComponent().path, O_RDONLY | O_DIRECTORY)
        guard parent >= 0 else { throw RunCoordinatorError.journalFailure("parent fsync") }
        defer { _ = Darwin.close(parent) }
        guard Darwin.fsync(parent) == 0 else { throw RunCoordinatorError.journalFailure("parent fsync") }
    }

    private static func writeExclusive(_ data: Data, to url: URL) throws {
        let descriptor = Darwin.open(url.path, O_WRONLY | O_CREAT | O_EXCL, mode_t(0o600))
        guard descriptor >= 0 else {
            if errno == EEXIST { throw RunCoordinatorError.journalCollision }
            throw RunCoordinatorError.journalFailure("open")
        }
        var closeRequired = true
        defer { if closeRequired { _ = Darwin.close(descriptor) } }
        try data.withUnsafeBytes { buffer in
            var offset = 0
            while offset < buffer.count {
                let written = Darwin.write(descriptor, buffer.baseAddress!.advanced(by: offset), buffer.count - offset)
                guard written > 0 else { throw RunCoordinatorError.journalFailure("write") }
                offset += written
            }
        }
        guard Darwin.fsync(descriptor) == 0, Darwin.close(descriptor) == 0 else {
            throw RunCoordinatorError.journalFailure("intent fsync")
        }
        closeRequired = false
        let parent = Darwin.open(url.deletingLastPathComponent().path, O_RDONLY | O_DIRECTORY)
        guard parent >= 0 else { throw RunCoordinatorError.journalFailure("directory fsync") }
        defer { _ = Darwin.close(parent) }
        guard Darwin.fsync(parent) == 0 else { throw RunCoordinatorError.journalFailure("directory fsync") }
    }
}
