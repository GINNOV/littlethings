import Foundation
import Observation

@MainActor
@Observable
public final class PendantModel {
    public private(set) var isConnected = false
    public private(set) var portPath: String?
    public private(set) var lastError: String?
    public private(set) var pose: ArmPose?
    public private(set) var vacuumOn = false
    public private(set) var speedMmPerSec: Double = 20
    public private(set) var held: [Axis: Sign] = [:]
    public private(set) var candidates: [SerialCandidate] = []

    private let arm: HuenitArm
    private let detector: @Sendable () -> [SerialCandidate]
    private let monitor: PoseMonitor
    private let jogState = MonitorState()
    private var engine: JogEngine

    public init(arm: HuenitArm, detector: @escaping @Sendable () -> [SerialCandidate]) {
        self.arm = arm
        self.detector = detector
        self.monitor = PoseMonitor(arm: arm)
        self.engine = JogEngine(speedMmPerSec: 20, speedDegPerSec: 20)
    }

    deinit {
        monitor.cancel()
        jogState.cancel()
    }

    public func refreshPorts() {
        candidates = detector()
        if let picked = PortDetector.pickArm(from: candidates) {
            portPath = picked.path
        }
    }

    public func connect(path: String) async {
        lastError = nil
        portPath = path
        await monitor.stop()
        jogState.cancel()

        do {
            try await arm.connect()
            isConnected = true
            do {
                pose = try await arm.queryPose()
            } catch {
                markPoseStale(error)
                if isTimeout(error) {
                    isConnected = false
                    return
                }
            }
            await monitor.start { [weak self] result in
                await self?.applyPoseResult(result)
            }
        } catch {
            isConnected = false
            lastError = describe(error)
        }
    }

    public func disconnect() async {
        await stop()
        await monitor.stop()
        await arm.disconnect()
        isConnected = false
    }

    public func setHeld(_ axis: Axis, _ sign: Sign, down: Bool) {
        guard isConnected else { return }
        if down {
            held[axis] = sign
        } else if held[axis] == sign {
            held[axis] = nil
        }
        engine.setHeld(axis, sign, down: down)
    }

    public func setSpeed(_ mmPerSec: Double) {
        speedMmPerSec = mmPerSec
        engine.speedMmPerSec = mmPerSec
        engine.speedDegPerSec = mmPerSec
    }

    public func setVacuum(_ on: Bool) async {
        do {
            try await arm.setVacuum(on)
            vacuumOn = on
        } catch {
            lastError = describe(error)
            if isTimeout(error) {
                isConnected = false
            }
        }
    }

    public func tickJog(dt: Double) async {
        guard isConnected else { return }
        let steps = engine.tick(dt: dt)
        for step in steps {
            do {
                if step.axis.isCartesian {
                    try await arm.jogCartesian(
                        axis: step.axis,
                        deltaMm: step.delta,
                        feedMmPerMin: step.feedMmPerMin
                    )
                } else {
                    try await arm.jogJoint(
                        axis: step.axis,
                        deltaDeg: step.delta,
                        feedMmPerMin: step.feedMmPerMin
                    )
                }
            } catch {
                clearHolds()
                lastError = describe(error)
                if isTimeout(error) {
                    isConnected = false
                }
                return
            }
        }
        if engine.wantsFlush {
            do {
                try await arm.flush()
                engine.didFlush()
            } catch {
                clearHolds()
                lastError = describe(error)
                if isTimeout(error) {
                    isConnected = false
                }
            }
        }
    }

    public func startJogLoop() {
        jogState.cancel()
        let task = Task { [weak self] in
            let dt = 1.0 / 60.0
            while !Task.isCancelled {
                guard let self, self.isConnected else { break }
                await self.tickJog(dt: dt)
                try? await Task.sleep(for: .seconds(dt))
            }
        }
        jogState.set(task)
    }

    public func stop() async {
        clearHolds()
        vacuumOn = false
        jogState.cancel()
        do {
            try await arm.stop()
        } catch {
            lastError = describe(error)
        }
    }

    private func applyPoseResult(_ result: Result<ArmPose, Error>) {
        switch result {
        case .success(let pose):
            self.pose = pose
        case .failure(let error):
            markPoseStale(error)
            if isTimeout(error) {
                isConnected = false
            }
        }
    }

    private func markPoseStale(_ error: Error) {
        if var current = pose {
            current.isStale = true
            pose = current
        }
        lastError = describe(error)
    }

    private func clearHolds() {
        held.removeAll()
        engine.clearAll()
    }

    private func isTimeout(_ error: Error) -> Bool {
        (error as? ArmError) == .timeout
    }

    private func describe(_ error: Error) -> String {
        if let armError = error as? ArmError {
            return String(describing: armError)
        }
        return error.localizedDescription
    }
}
