import Foundation

actor HuenitArm {
    private let transport: any SerialTransport
    private let commandTimeout: Duration
    private let settleAfterOpen: Duration
    private var ioBusy = false
    private var ioWaiters: [CheckedContinuation<Void, Never>] = []

    private(set) var isConnected = false
    private(set) var jointCommandFormat = "G1 {A}{delta} F{F}"

    init(transport: any SerialTransport, commandTimeout: Duration = .seconds(2), settleAfterOpen: Duration = .seconds(2)) {
        self.transport = transport
        self.commandTimeout = commandTimeout
        self.settleAfterOpen = settleAfterOpen
    }

    func setJointCommandFormat(_ format: String) {
        jointCommandFormat = format
    }

    func connect() async throws {
        try await transport.open()
        do {
            if settleAfterOpen > .zero { try await Task.sleep(for: settleAfterOpen) }
            await transport.discardInput()
            let identity = try await transact("M115")
            guard FirmwareIdentity.parse(identity).isHuenitMarlin else {
                throw ArmError.connectFailed("not HUENIT Marlin")
            }
            _ = try await transact("G21")
            _ = try await transact("G91")
            isConnected = true
        } catch {
            await transport.close()
            isConnected = false
            throw error
        }
    }

    func disconnect() async {
        await transport.close()
        isConnected = false
    }

    func forceConnectedForTests() {
        isConnected = true
    }

    @discardableResult
    func send(_ line: String) async throws -> String {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.uppercased().contains("G28") { throw ArmError.forbiddenCommand("G28") }
        guard isConnected else { throw ArmError.disconnected }
        return try await transact(trimmed)
    }

    func queryPose() async throws -> ArmPose {
        let cartesian = try await send("M1008 A3")
        let joints = try await send("M1008 A2")
        let status = try await send("M114")
        let extras = ArmPose.parseM114Extras(status)
        return ArmPose(
            cartesian: try CartesianPose.parseM1008(cartesian),
            joints: try JointPose.parseM1008(joints),
            e: extras.e,
            motorStatus: extras.motorStatus,
            isStale: false
        )
    }

    func setVacuum(_ on: Bool) async throws {
        _ = try await send(on ? "M1400 A1023" : "M1400 A0")
    }

    func flush() async throws { _ = try await send("M400") }

    func stop() async throws {
        _ = try? await transact("M1400 A0")
        do { _ = try await transact("M410") }
        catch { _ = try await transact("M84") }
    }

    func jogCartesian(axis: Axis, deltaMm: Double, feedMmPerMin: Double) async throws {
        precondition(axis.isCartesian)
        try await step(dx: axis == .x ? deltaMm : 0, dy: axis == .y ? deltaMm : 0, dz: axis == .z ? deltaMm : 0, feedMmPerMin: feedMmPerMin)
    }

    func step(dx: Double, dy: Double, dz: Double, feedMmPerMin: Double) async throws {
        var parts = ["G1"]
        if dx != 0 { parts.append(String(format: "X%.4f", dx)) }
        if dy != 0 { parts.append(String(format: "Y%.4f", dy)) }
        if dz != 0 { parts.append(String(format: "Z%.4f", dz)) }
        guard parts.count > 1 else { return }
        parts.append(String(format: "F%.1f", feedMmPerMin))
        _ = try await send(parts.joined(separator: " "))
    }

    func jogJoint(axis: Axis, deltaDeg: Double, feedMmPerMin: Double) async throws {
        precondition(!axis.isCartesian && axis != .e)
        let line = jointCommandFormat
            .replacingOccurrences(of: "{A}", with: axis.gcodeLetter)
            .replacingOccurrences(of: "{delta}", with: String(format: "%.4f", deltaDeg))
            .replacingOccurrences(of: "{F}", with: String(format: "%.1f", feedMmPerMin))
        _ = try await send(line)
    }

    func moveAbsolute(x: Double, y: Double, z: Double, feedMmPerMin: Double) async throws {
        _ = try await send("G90")
        do {
            _ = try await send(String(format: "G1 X%.4f Y%.4f Z%.4f F%.1f", x, y, z, feedMmPerMin))
            try await flush()
        } catch {
            _ = try? await send("G91")
            throw error
        }
        _ = try await send("G91")
    }

    func home(feedMmPerMin: Double) async throws {
        try await moveAbsolute(x: CartesianPose.officialHome.x, y: CartesianPose.officialHome.y, z: CartesianPose.officialHome.z, feedMmPerMin: feedMmPerMin)
    }

    func setZ0(feedMmPerMin: Double) async throws {
        _ = try await send("G90")
        do {
            _ = try await send(String(format: "G1 Z0.0000 F%.1f", feedMmPerMin))
            try await flush()
        } catch {
            _ = try? await send("G91")
            throw error
        }
        _ = try await send("G91")
    }

    func setMotors(_ on: Bool) async throws { _ = try await send(on ? "M17" : "M84") }

    private func transact(_ line: String) async throws -> String {
        await acquireIO()
        defer { releaseIO() }
        do {
            try await transport.writeLine(line)
            return try await transport.readUntilOk(timeout: commandTimeout)
        } catch let error as ArmError where error == .disconnected || error == .timeout {
            isConnected = false
            throw error
        }
    }

    private func acquireIO() async {
        if ioBusy {
            await withCheckedContinuation { ioWaiters.append($0) }
        } else { ioBusy = true }
    }

    private func releaseIO() {
        if ioWaiters.isEmpty { ioBusy = false }
        else { ioWaiters.removeFirst().resume() }
    }
}
