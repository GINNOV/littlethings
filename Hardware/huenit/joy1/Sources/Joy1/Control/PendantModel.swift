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
    public private(set) var motorsOn = true
    public private(set) var speedMmPerSec: Double = 20
    public private(set) var labSpeed: Double = 100
    public private(set) var stepWidthMm: Double = 1
    public private(set) var controlMode: ControlMode = .step
    public var targetX: Double = CartesianPose.officialHome.x
    public var targetY: Double = CartesianPose.officialHome.y
    public var targetZ: Double = CartesianPose.officialHome.z
    public private(set) var held: [Axis: Sign] = [:]
    public private(set) var candidates: [SerialCandidate] = []

    public var makeTransport: @Sendable (String) -> any SerialTransport = { SerialPort(path: $0) }
    public var settleAfterOpen: Duration = .seconds(2)

    private var arm: HuenitArm
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
        portPath = PortDetector.pickArm(from: candidates)?.path
    }

    public func connect(path: String? = nil) async {
        lastError = nil
        refreshPorts()
        guard let resolved = PortDetector.pickArm(from: candidates)?.path ?? path, !resolved.isEmpty else {
            lastError = "No HUEARM serial port. Plug the arm USB-C into the Mac and Rescan."
            return
        }
        portPath = resolved

        if isConnected {
            await stop()
        } else {
            clearHolds()
            vacuumOn = false
        }
        await monitor.stop()
        await arm.disconnect()

        let arm = HuenitArm(transport: makeTransport(resolved), settleAfterOpen: settleAfterOpen)
        self.arm = arm
        await monitor.setArm(arm)

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

    public func setLabSpeed(_ value: Double) {
        labSpeed = min(400, max(1, value))
        setSpeed(labSpeed / 5)
    }

    public func setStepWidth(_ mm: Double) {
        stepWidthMm = mm
    }

    public func setControlMode(_ mode: ControlMode) {
        clearHolds()
        controlMode = mode
    }

    public var feedMmPerMin: Double {
        labSpeed * 6
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
                } else if step.axis.isModule {
                    try await arm.jogModule(delta: step.delta, feedMmPerMin: step.feedMmPerMin)
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
        if jogState.isRunning { return }
        let task = Task { [weak self] in
            let dt = 1.0 / 60.0
            while !Task.isCancelled {
                guard let self else { break }
                if !self.isConnected {
                    try? await Task.sleep(for: .milliseconds(50))
                    continue
                }
                let started = ContinuousClock.now
                await self.tickJog(dt: dt)
                let remaining = Duration.seconds(dt) - started.duration(to: .now)
                if remaining > .zero {
                    try? await Task.sleep(for: remaining)
                }
            }
        }
        jogState.set(task)
    }

    public func stop() async {
        clearHolds()
        vacuumOn = false
        do {
            try await arm.stop()
            motorsOn = false
        } catch {
            lastError = describe(error)
        }
    }

    public func setMotors(_ on: Bool) async {
        guard isConnected else { return }
        do {
            try await arm.setMotors(on)
            motorsOn = on
        } catch {
            lastError = describe(error)
        }
    }

    public func step(dx: Double, dy: Double, dz: Double) async {
        guard isConnected, controlMode == .step else { return }
        do {
            try await arm.step(
                dx: dx * stepWidthMm,
                dy: dy * stepWidthMm,
                dz: dz * stepWidthMm,
                feedMmPerMin: feedMmPerMin
            )
        } catch {
            lastError = describe(error)
        }
    }

    public func home() async {
        guard isConnected else { return }
        do {
            try await arm.home(feedMmPerMin: feedMmPerMin)
        } catch {
            lastError = describe(error)
        }
    }

    public func zeroZ() async {
        guard isConnected else { return }
        do {
            try await arm.setZ0(feedMmPerMin: feedMmPerMin)
        } catch {
            lastError = describe(error)
        }
    }

    public func moveToTarget() async {
        guard isConnected else { return }
        do {
            try await arm.moveAbsolute(x: targetX, y: targetY, z: targetZ, feedMmPerMin: feedMmPerMin)
        } catch {
            lastError = describe(error)
        }
    }

    public func jogModule(sign: Sign) async {
        guard isConnected else { return }
        do {
            try await arm.jogModule(delta: Double(sign.rawValue) * stepWidthMm, feedMmPerMin: feedMmPerMin)
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
