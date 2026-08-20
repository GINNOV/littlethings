import Testing
@testable import ArmageddonCore
@testable import ArmageddonMotionBoundary

struct SafetyPolicyTests {
    @Test("valid native snapshot is eligible at conservative limits")
    func validSnapshot() throws {
        let now = MonotonicInstant(nanoseconds: 1_000_000_000)
        let snapshot = makeSnapshot(
            confidence: 1,
            target: CalibrationPoint(x: 39.98, y: 20),
            now: now
        )
        let verdict = SafetyPolicyV1.evaluate(snapshot, now: now)
        #expect(verdict.isEligible)
        #expect(verdict.reasons.isEmpty)
    }

    @Test("stale, mismatched, unsafe, and out-of-envelope inputs inhibit motion")
    func inhibitionMatrix() throws {
        let now = MonotonicInstant(nanoseconds: 1_000_000_000)
        let stale = makeSnapshot(now: MonotonicInstant(nanoseconds: 0))
        #expect(SafetyPolicyV1.evaluate(stale, now: now).reasons.contains(.staleDetection))

        let invalidConfidence = makeSnapshot(confidence: 1.01, now: now)
        #expect(SafetyPolicyV1.evaluate(invalidConfidence, now: now).reasons.contains(.invalidConfidence))

        let tooFar = makeSnapshot(target: CalibrationPoint(x: 80, y: 20), now: now)
        #expect(SafetyPolicyV1.evaluate(tooFar, now: now).reasons.contains(.deltaTooLarge))

        let unsafeZ = makeSnapshot(z: 0.05, now: now)
        #expect(SafetyPolicyV1.evaluate(unsafeZ, now: now).reasons.contains(.unsafeZ))
    }

    @Test("workspace inset rejects edge-adjacent targets")
    func workspaceInset() {
        let now = MonotonicInstant(nanoseconds: 1_000_000_000)
        let edgeTarget = makeSnapshot(target: CalibrationPoint(x: 5, y: 20), now: now)
        #expect(SafetyPolicyV1.evaluate(edgeTarget, now: now).reasons.contains(.targetOutsideWorkspace))
    }

    @Test("controller issues one private permit and consumes it once")
    func oneUsePermit() async throws {
        let controller = SafetyController()
        let now = MonotonicInstant(nanoseconds: 1_000_000_000)
        let snapshot = makeSnapshot(now: now)
        await controller.update(snapshot)
        try await controller.arm(now: now)
        let observation = snapshot.observation!
        let pose = snapshot.pose!
        let profile = snapshot.profile!
        let proposal = try TargetProposal(
            frameID: observation.frameID,
            generation: observation.generation,
            detectionID: observation.detectionID,
            calibrationID: profile.calibrationID,
            formatIdentity: observation.formatIdentity,
            modelHash: observation.modelHash,
            captureInstant: observation.captureInstant,
            poseInstant: pose.receivedAt,
            proposedAt: now,
            armedAt: now,
            fromXY: pose.xy,
            targetXY: observation.targetXY,
            feedMillimetersPerMinute: profile.feedMillimetersPerMinute,
            policyState: .eligible
        )
        _ = try await controller.consumePermit(now: now, proposal: proposal)
        do {
            _ = try await controller.consumePermit(now: now, proposal: proposal)
            Issue.record("A consumed permit was accepted a second time.")
        } catch let error as SafetyControllerError {
            #expect(error == .inhibited([.armExpired]))
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    private func makeSnapshot(
        confidence: Double = 0.9,
        target: CalibrationPoint = CalibrationPoint(x: 25, y: 20),
        z: Double = 5,
        now: MonotonicInstant
    ) -> SafetySnapshot {
        let polygon = try! CalibrationPolygon(vertices: [
            CalibrationPoint(x: 0, y: 0),
            CalibrationPoint(x: 100, y: 0),
            CalibrationPoint(x: 100, y: 100),
            CalibrationPoint(x: 0, y: 100)
        ])
        let profile = SafetyProfile(
            calibrationID: "calibration",
            deviceID: "camera",
            formatIdentity: "1280x720@30.0-landscapeRight-false",
            toolID: "tool",
            modelHash: "model-hash",
            computationalWorkspace: polygon,
            safeZBand: try! CalibrationSafeZBand(minimum: 0, maximum: 10),
            feedMillimetersPerMinute: 300
        )
        let observation = SafetyObservation(
            detectionID: "target",
            frameID: 1,
            generation: 1,
            captureInstant: now,
            formatIdentity: profile.formatIdentity,
            modelHash: profile.modelHash,
            confidence: confidence,
            targetXY: target
        )
        let pose = SafetyPoseReceipt(x: 20, y: 20, z: z, receivedAt: now)
        return SafetySnapshot(state: .eligible, observation: observation, pose: pose, profile: profile)
    }
}
