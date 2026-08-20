import Foundation
import Testing
@testable import ArmageddonCore
@testable import ArmageddonMotionBoundary

struct RunCoordinatorTests {
    @Test("durable intent precedes writer entry and one proposal writes once")
    func durableExecutionOrder() async throws {
        let now = MonotonicInstant(nanoseconds: 1_000_000_000)
        let profile = try makeProfile()
        let observation = makeObservation(now: now)
        let proposal = try TargetProposalBuilder.build(
            selected: observation,
            selectedObservationID: observation.id,
            format: profile.format,
            modelHash: "model-hash",
            profile: profile,
            pose: SafetyPoseReceipt(x: 19, y: 35, z: 5, receivedAt: now),
            armedAt: now,
            now: now
        )
        let proposals = TargetProposalStore()
        await proposals.insert(proposal)
        let safety = SafetyController()
        await safety.update(makeSafetySnapshot(profile: profile, observation: observation, now: now))
        try await safety.arm(now: now)
        let writer = RecordingWriter()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("armageddon-run-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let coordinator = RunCoordinator(
            safety: safety,
            proposals: proposals,
            poseReader: FixedPoseReader(pose: SafetyPoseReceipt(x: 19, y: 35, z: 5, receivedAt: now)),
            writer: writer,
            journalRoot: root,
            clock: { now }
        )
        let confirmation = try proposal.confirmation(now: now)
        let result = try await coordinator.submit(confirmation)
        #expect(result.wroteMotion)
        let writeCount = await writer.count()
        #expect(writeCount == 1)
        #expect(result.timeline.map(\.kind).first == .reservation)
        #expect(result.timeline.map(\.kind).contains(.intentDurable))
        #expect(result.timeline.map(\.kind).last == .completed)
        #expect(FileManager.default.fileExists(atPath: root.appendingPathComponent("Executions/\(result.executionID.uuidString)/intent.json").path))
        #expect(FileManager.default.fileExists(atPath: root.appendingPathComponent("Executions/\(result.executionID.uuidString)/completed.json").path))
    }

    @Test("entry revalidation revokes and writes no bytes when pose is stale")
    func staleEntryNoWrite() async throws {
        let now = MonotonicInstant(nanoseconds: 1_000_000_000)
        let profile = try makeProfile()
        let observation = makeObservation(now: now)
        let proposal = try TargetProposalBuilder.build(
            selected: observation,
            selectedObservationID: observation.id,
            format: profile.format,
            modelHash: "model-hash",
            profile: profile,
            pose: SafetyPoseReceipt(x: 19, y: 35, z: 5, receivedAt: now),
            armedAt: now,
            now: now
        )
        let proposals = TargetProposalStore()
        await proposals.insert(proposal)
        let safety = SafetyController()
        await safety.update(makeSafetySnapshot(profile: profile, observation: observation, now: now))
        try await safety.arm(now: now)
        let writer = RecordingWriter()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("armageddon-run-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let coordinator = RunCoordinator(
            safety: safety,
            proposals: proposals,
            poseReader: FixedPoseReader(pose: SafetyPoseReceipt(x: 19, y: 35, z: 5, receivedAt: MonotonicInstant(nanoseconds: 0))),
            writer: writer,
            journalRoot: root,
            clock: { now }
        )
        do {
            _ = try await coordinator.submit(try proposal.confirmation(now: now))
            Issue.record("Stale pose was allowed to reach the writer.")
        } catch {
            let writeCount = await writer.count()
            #expect(writeCount == 0)
        }
    }

    private func makeObservation(now: MonotonicInstant) -> DetectionObservation {
        DetectionObservation(
            id: "target-1", frameID: 7, generation: 2, captureInstant: now,
            label: "target", confidence: 0.9,
            boundingBox: NormalizedRect(x: 0.45, y: 0.45, width: 0.1, height: 0.1)
        )
    }

    private func makeSafetySnapshot(profile: PlanarCalibrationProfile, observation: DetectionObservation, now: MonotonicInstant) -> SafetySnapshot {
        let formatIdentity = "1280x720@30.0-landscapeRight-false"
        return SafetySnapshot(
            state: .eligible,
            observation: SafetyObservation(nativeObservation: observation, format: profile.format, modelHash: "model-hash", targetXY: CalibrationPoint(x: 20, y: 35)),
            pose: SafetyPoseReceipt(x: 19, y: 35, z: 5, receivedAt: now),
            profile: SafetyProfile(
                calibrationID: profile.id.uuidString, deviceID: profile.deviceID,
                formatIdentity: formatIdentity, toolID: profile.toolID, modelHash: "model-hash",
                computationalWorkspace: profile.polygon, safeZBand: profile.safeZBand, feedMillimetersPerMinute: 300
            )
        )
    }

    private func makeProfile() throws -> PlanarCalibrationProfile {
        try PlanarCalibrationProfile(
            deviceID: "camera", format: CaptureFormat(width: 1280, height: 720, frameRate: 30), toolID: "tool",
            polygon: try CalibrationPolygon(vertices: [
                CalibrationPoint(x: 0, y: 0), CalibrationPoint(x: 40, y: 0), CalibrationPoint(x: 40, y: 60), CalibrationPoint(x: 0, y: 60)
            ]),
            safeZBand: try CalibrationSafeZBand(minimum: 0, maximum: 10),
            correspondences: [
                point(0, 0, 10, 20), point(1, 0, 30, 20), point(1, 1, 30, 50), point(0, 1, 10, 50),
                point(0.25, 0.25, 15, 27.5, validation: true), point(0.75, 0.75, 25, 42.5, validation: true)
            ]
        )
    }

    private func point(_ x: Double, _ y: Double, _ wx: Double, _ wy: Double, validation: Bool = false) -> CalibrationCorrespondence {
        CalibrationCorrespondence(source: CalibrationPoint(x: x, y: y), workspace: CalibrationPoint(x: wx, y: wy), isValidation: validation)
    }
}

private struct FixedPoseReader: RunPoseReader {
    let pose: SafetyPoseReceipt
    func readPose() async throws -> SafetyPoseReceipt { pose }
}

private actor RecordingWriter: XYMotionWriter {
    private(set) var writes = 0
    func writeXY(delta: CalibrationPoint, feedMillimetersPerMinute: Double) async throws { writes += 1 }
    func count() -> Int { writes }
}
