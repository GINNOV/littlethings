import Testing
@testable import ArmageddonCore

struct TargetProposalTests {
    @Test("selected detection produces an auditable XY-only dry-run proposal")
    func dryRun() throws {
        let now = MonotonicInstant(nanoseconds: 1_000_000_000)
        let profile = try makeProfile()
        let observation = DetectionObservation(
            id: "target-1",
            frameID: 7,
            generation: 2,
            captureInstant: now,
            label: "target",
            confidence: 0.9,
            boundingBox: NormalizedRect(x: 0.45, y: 0.45, width: 0.1, height: 0.1)
        )
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
        #expect(proposal.policyState == .eligible)
        #expect(abs(proposal.deltaXY.x - 1) < 0.001)
        #expect(abs(proposal.deltaXY.y) < 0.001)
        #expect(proposal.proposalHash.count == 64)
    }

    @Test("confirmation expires and cannot be reused")
    func oneUseConfirmation() async throws {
        let now = MonotonicInstant(nanoseconds: 1_000_000_000)
        let profile = try makeProfile()
        let observation = DetectionObservation(
            id: "target-1", frameID: 7, generation: 2, captureInstant: now,
            label: "target", confidence: 0.9,
            boundingBox: NormalizedRect(x: 0.45, y: 0.45, width: 0.1, height: 0.1)
        )
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
        let store = TargetProposalStore()
        await store.insert(proposal)
        let confirmation = try proposal.confirmation(now: now)
        _ = try await store.consume(confirmation, now: now)
        do {
            _ = try await store.consume(confirmation, now: now)
            Issue.record("A consumed confirmation was accepted a second time.")
        } catch let error as TargetProposalError {
            #expect(error == .confirmationAlreadyConsumed)
        }
        #expect(throws: TargetProposalError.confirmationExpired) {
            _ = try proposal.confirmation(now: MonotonicInstant(nanoseconds: 7_000_000_001))
        }
    }

    private func makeProfile() throws -> PlanarCalibrationProfile {
        let correspondences = [
            point(0, 0, 10, 20), point(1280, 0, 30, 20), point(1280, 720, 30, 50), point(0, 720, 10, 50),
            point(320, 180, 15, 27.5, validation: true), point(960, 540, 25, 42.5, validation: true)
        ]
        return try PlanarCalibrationProfile(
            deviceID: "camera",
            format: CaptureFormat(width: 1280, height: 720, frameRate: 30),
            toolID: "tool",
            polygon: try CalibrationPolygon(vertices: [
                CalibrationPoint(x: 0, y: 0), CalibrationPoint(x: 40, y: 0),
                CalibrationPoint(x: 40, y: 60), CalibrationPoint(x: 0, y: 60)
            ]),
            safeZBand: try CalibrationSafeZBand(minimum: 0, maximum: 10),
            correspondences: correspondences
        )
    }

    private func point(_ x: Double, _ y: Double, _ wx: Double, _ wy: Double, validation: Bool = false) -> CalibrationCorrespondence {
        CalibrationCorrespondence(
            source: CalibrationPoint(x: x, y: y),
            workspace: CalibrationPoint(x: wx, y: wy),
            isValidation: validation
        )
    }
}
