import Foundation
@testable import Joy1

actor LiveArmState {
    static let shared = LiveArmState()
    private(set) var discoveredJointFormat: String?

    func setDiscoveredJointFormat(_ format: String?) {
        discoveredJointFormat = format
    }
}

enum LiveArm {

    static func scanArm() -> SerialCandidate? {
        PortDetector.pickArm(from: PortDetector.scan())
    }

    /// Returns true when live tests should no-op (no HUEARM, or camera-only).
    static func skipIfNoArm() -> Bool {
        guard let port = scanArm() else {
            print("SKIP: no HUEARM")
            return true
        }
        if port.isCamera {
            print("SKIP: pickArm returned camera — refusing HUECAM")
            return true
        }
        return false
    }

    static func open() async throws -> HuenitArm {
        let ports = PortDetector.scan()
        guard let armPort = PortDetector.pickArm(from: ports) else {
            throw ArmError.connectFailed("no HUEARM")
        }
        if armPort.isCamera {
            throw ArmError.connectFailed("refused camera")
        }
        print("LiveArm.open path=\(armPort.path) product=\(armPort.product ?? "-") serial=\(armPort.serial ?? "-")")
        let transport = SerialPort(path: armPort.path)
        try await transport.open()
        // FTDI open often resets Marlin; wait out the banner, then drop it.
        try await Task.sleep(for: .seconds(2))
        await transport.discardInput()
        let arm = HuenitArm(transport: transport, commandTimeout: .seconds(10), settleAfterOpen: .zero)
        try await arm.connect()
        return arm
    }

    static func withOpen(_ body: (HuenitArm) async throws -> Void) async throws {
        if skipIfNoArm() { return }
        let arm = try await open()
        do {
            try await body(arm)
            await arm.disconnect()
        } catch {
            await arm.disconnect()
            throw error
        }
    }

    static func formatPose(_ pose: ArmPose) -> String {
        let c = pose.cartesian
        let j = pose.joints
        return String(
            format: "XYZ(%.3f, %.3f, %.3f) ABC(%.3f, %.3f, %.3f)",
            c.x, c.y, c.z, j.a, j.b, j.c
        )
    }
}

struct JointProbeCandidate: Sendable {
    let format: String
    let plusCommand: String
    let minusCommand: String
}

enum JointProbe {
    static let candidates: [JointProbeCandidate] = [
        JointProbeCandidate(format: "G1 {A}{delta} F{F}", plusCommand: "G1 A2 F300", minusCommand: "G1 A-2 F300"),
        JointProbeCandidate(format: "G1 I{delta} F{F}", plusCommand: "G1 I2 F300", minusCommand: "G1 I-2 F300"),
        JointProbeCandidate(format: "M1007 {A}{delta}", plusCommand: "M1007 A2", minusCommand: "M1007 A-2"),
    ]

    static func run(on arm: HuenitArm) async -> (format: String?, log: [String]) {
        var log: [String] = []
        let beforeAll = (try? await arm.queryPose())
        if let beforeAll {
            log.append("probe start \(LiveArm.formatPose(beforeAll))")
        }

        for candidate in candidates {
            guard await arm.isConnected else {
                log.append("disconnected before \(candidate.plusCommand)")
                break
            }
            do {
                let before = try await arm.queryPose()
                log.append("try \(candidate.plusCommand) before A=\(before.joints.a)")
                let reply = try await arm.send(candidate.plusCommand)
                log.append("  reply: \(reply.trimmingCharacters(in: .whitespacesAndNewlines))")
                try await arm.flush()
                let m114 = (try? await arm.send("M114")) ?? "(M114 failed)"
                log.append("  M114: \(m114.trimmingCharacters(in: .whitespacesAndNewlines))")
                let after = try await arm.queryPose()
                let deltaA = after.joints.a - before.joints.a
                log.append("  after \(LiveArm.formatPose(after)) dA=\(String(format: "%.3f", deltaA))")

                if abs(deltaA) > 0.5 {
                    log.append("WORKING format=\(candidate.format)")
                    if await arm.isConnected {
                        _ = try? await arm.send(candidate.minusCommand)
                        try? await arm.flush()
                        if let undone = try? await arm.queryPose() {
                            log.append("  undone \(LiveArm.formatPose(undone))")
                        }
                    }
                    return (candidate.format, log)
                }

                let movedElse =
                    abs(after.joints.b - before.joints.b) > 0.5
                    || abs(after.joints.c - before.joints.c) > 0.5
                    || abs(after.cartesian.x - before.cartesian.x) > 0.5
                    || abs(after.cartesian.y - before.cartesian.y) > 0.5
                    || abs(after.cartesian.z - before.cartesian.z) > 0.5
                if movedElse {
                    log.append("  unexpected motion — sending undo \(candidate.minusCommand)")
                    _ = try? await arm.send(candidate.minusCommand)
                    try? await arm.flush()
                }
            } catch {
                log.append("  error \(candidate.plusCommand): \(error)")
            }
        }
        return (nil, log)
    }
}
