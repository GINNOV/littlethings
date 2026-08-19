actor ArmCommandGateway {
    enum ControlMode: Equatable, Sendable {
        case hold
        case step
    }

    private let arm: HuenitArm
    private let emergencyStop: EmergencyStopController
    private let poseMonitor: PoseMonitor
    private var jogTask: Task<Void, Never>?
    private var engine = JogEngine(speedMmPerSec: 20, speedDegPerSec: 20)
    private var held: [Axis: Sign] = [:]

    private(set) var isConnected = false
    private(set) var isMoving = false
    private(set) var lastError: ArmError?
    private(set) var pose: ArmPose?
    private(set) var controlMode: ControlMode = .hold

    let isArmed = false
    let visionMotionEnabled = false

    init(arm: HuenitArm, emergencyStop: EmergencyStopController) {
        self.arm = arm
        self.emergencyStop = emergencyStop
        self.poseMonitor = PoseMonitor(arm: arm)
    }

    func connect() async throws {
        try await arm.connect()
        isConnected = true
        lastError = nil
    }

    func markConnectedForTests() async {
        await arm.forceConnectedForTests()
        isConnected = true
    }

    func setControlMode(_ mode: ControlMode) {
        clearHolds()
        controlMode = mode
    }

    func setHeld(_ axis: Axis, _ sign: Sign, down: Bool) {
        guard isConnected else { return }
        if down { held[axis] = sign }
        else if held[axis] == sign { held[axis] = nil }
        engine.setHeld(axis, sign, down: down)
        isMoving = !held.isEmpty
    }

    func heldAxes() -> [Axis: Sign] { held }

    func tickJog(dt: Double) async {
        guard isConnected else { return }
        let token = await emergencyStop.issueMotionGeneration()
        let steps = engine.tick(dt: dt)
        for step in steps {
            guard await emergencyStop.isCurrent(token) else { return }
            do {
                if step.axis.isCartesian {
                    try await arm.jogCartesian(axis: step.axis, deltaMm: step.delta, feedMmPerMin: step.feedMmPerMin)
                } else if step.axis.isModule {
                    try await arm.jogModule(delta: step.delta, feedMmPerMin: step.feedMmPerMin)
                } else {
                    try await arm.jogJoint(axis: step.axis, deltaDeg: step.delta, feedMmPerMin: step.feedMmPerMin)
                }
            } catch let error as ArmError {
                lastError = error
                clearHolds()
                return
            } catch {
                clearHolds()
                return
            }
        }
        isMoving = !held.isEmpty
        if engine.wantsFlush, await emergencyStop.isCurrent(token) {
            do {
                try await arm.flush()
                engine.didFlush()
            } catch let error as ArmError {
                lastError = error
                clearHolds()
            } catch {
                clearHolds()
            }
        }
    }

    func step(dx: Double, dy: Double, dz: Double, feedMmPerMin: Double = 1200) async throws {
        guard isConnected else { throw ArmError.disconnected }
        guard controlMode == .step else { throw ArmError.invalidControlMode }
        let token = await emergencyStop.issueMotionGeneration()
        guard await emergencyStop.isCurrent(token) else { return }
        do {
            try await arm.step(dx: dx, dy: dy, dz: dz, feedMmPerMin: feedMmPerMin)
        } catch let error as ArmError {
            lastError = error
            throw error
        }
    }

    func setVacuum(_ on: Bool) async throws {
        guard isConnected else { throw ArmError.disconnected }
        try await arm.setVacuum(on)
    }

    func setMotors(_ on: Bool) async throws {
        guard isConnected else { throw ArmError.disconnected }
        try await arm.setMotors(on)
    }

    func home(feedMmPerMin: Double = 1200) async throws {
        guard isConnected else { throw ArmError.disconnected }
        let token = await emergencyStop.issueMotionGeneration()
        guard await emergencyStop.isCurrent(token) else { return }
        try await arm.home(feedMmPerMin: feedMmPerMin)
    }

    func zeroZ(feedMmPerMin: Double = 1200) async throws {
        guard isConnected else { throw ArmError.disconnected }
        let token = await emergencyStop.issueMotionGeneration()
        guard await emergencyStop.isCurrent(token) else { return }
        try await arm.setZ0(feedMmPerMin: feedMmPerMin)
    }

    func startJogLoop() {
        guard jogTask == nil else { return }
        jogTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { break }
                await self.tickJog(dt: 1.0 / 60.0)
                try? await Task.sleep(for: .milliseconds(16))
            }
        }
    }

    func stopJogLoop() {
        jogTask?.cancel()
        jogTask = nil
        clearHolds()
    }

    func startPoseMonitoring() async {
        await poseMonitor.start { [weak self] result in
            guard let self else { return }
            if case .success(let pose) = result { await self.setPose(pose) }
        }
    }

    func stopPoseMonitoring() async {
        await poseMonitor.stop()
    }

    func isPoseMonitoring() async -> Bool {
        await poseMonitor.isRunning
    }

    func emergencyStop() async -> EmergencyStopReceipt {
        stopJogLoop()
        let receipt = await emergencyStop.stop()
        isMoving = false
        return receipt
    }

    func focusLost() async -> EmergencyStopReceipt {
        await emergencyStop()
    }

    func disconnect() async -> EmergencyStopReceipt {
        let receipt = await emergencyStop()
        await poseMonitor.stop()
        await arm.disconnect()
        isConnected = false
        return receipt
    }

    private func setPose(_ pose: ArmPose) {
        self.pose = pose
    }

    private func clearHolds() {
        held.removeAll()
        engine.clearAll()
        isMoving = false
    }
}
