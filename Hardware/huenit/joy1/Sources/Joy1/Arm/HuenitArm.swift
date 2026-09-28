import Foundation

public typealias ArmMotionPermit = @Sendable () async -> Bool

public actor HuenitArm {
    private let transport: any SerialTransport
    public private(set) var isConnected = false
    /// Live probe of G1 A, G1 I, and M1007 A all returned `ok` without moving joint A.
    /// Default stays the G1 template; do not couple joints through Cartesian G1 X/Y/Z.
    public private(set) var jointCommandFormat: String = "G1 {A}{delta} F{F}"

    public func setJointCommandFormat(_ format: String) {
        jointCommandFormat = format
    }

    private let commandTimeout: Duration
    private let settleAfterOpen: Duration
    private var ioBusy = false
    private var ioWaiters: [CheckedContinuation<Void, Never>] = []

    public init(
        transport: any SerialTransport,
        commandTimeout: Duration = .seconds(2),
        settleAfterOpen: Duration = .seconds(2)
    ) {
        self.transport = transport
        self.commandTimeout = commandTimeout
        self.settleAfterOpen = settleAfterOpen
    }

    public func connect() async throws {
        try await transport.open()
        do {
            // FTDI open resets Marlin; wait out the banner, then drop it.
            if settleAfterOpen > .zero {
                try await Task.sleep(for: settleAfterOpen)
            }
            await transport.discardInput()
            let identity = try await transact("M115")
            guard FirmwareIdentity.parse(identity).isHuenitMarlin else {
                throw ArmError.connectFailed("not HUENIT Marlin: \(identity)")
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

    public func disconnect() async {
        await transport.close()
        isConnected = false
    }

    public func forceConnectedForTests() {
        isConnected = true
    }

    @discardableResult
    public func send(_ line: String, motionPermit: ArmMotionPermit? = nil) async throws -> String {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.uppercased().contains("G28") {
            throw ArmError.forbiddenCommand("G28")
        }
        guard isConnected else {
            throw ArmError.disconnected
        }
        return try await transact(trimmed, motionPermit: motionPermit)
    }

    public func queryPose() async throws -> ArmPose {
        let xyzText = try await send("M1008 A3")
        let abcText = try await send("M1008 A2")
        let statusText = try await send("M114")
        let extras = ArmPose.parseM114Extras(statusText)
        return ArmPose(
            cartesian: try CartesianPose.parseM1008(xyzText),
            joints: try JointPose.parseM1008(abcText),
            e: extras.e,
            motorStatus: extras.motorStatus,
            isStale: false
        )
    }

    /// Wire profile on this FYSETC E4: `M1400 A1023` / `M1400 A0`.
    /// Do not send community-SDK `M1111`–`M1114` or silently fall back.
    public func setVacuum(_ on: Bool) async throws {
        _ = try await send(on ? "M1400 A1023" : "M1400 A0")
    }

    public func flush(motionPermit: ArmMotionPermit? = nil) async throws {
        _ = try await send("M400", motionPermit: motionPermit)
    }

    public func stop() async throws {
        _ = try? await transact("M1400 A0")
        do {
            _ = try await transact("M410")
        } catch {
            _ = try await transact("M84")
        }
    }

    public func jogCartesian(axis: Axis, deltaMm: Double, feedMmPerMin: Double, motionPermit: ArmMotionPermit? = nil) async throws {
        precondition(axis.isCartesian)
        try await step(dx: axis == .x ? deltaMm : 0, dy: axis == .y ? deltaMm : 0, dz: axis == .z ? deltaMm : 0, feedMmPerMin: feedMmPerMin, motionPermit: motionPermit)
    }

    public func step(dx: Double, dy: Double, dz: Double, feedMmPerMin: Double, motionPermit: ArmMotionPermit? = nil) async throws {
        var parts = ["G1"]
        if dx != 0 { parts.append(String(format: "X%.4f", dx)) }
        if dy != 0 { parts.append(String(format: "Y%.4f", dy)) }
        if dz != 0 { parts.append(String(format: "Z%.4f", dz)) }
        guard parts.count > 1 else { return }
        parts.append(String(format: "F%.1f", feedMmPerMin))
        _ = try await send(parts.joined(separator: " "), motionPermit: motionPermit)
    }

    public func jogModule(delta: Double, feedMmPerMin: Double, motionPermit: ArmMotionPermit? = nil) async throws {
        _ = try await send(String(format: "G1 E%.4f F%.1f", delta, feedMmPerMin), motionPermit: motionPermit)
    }

    public func jogJoint(axis: Axis, deltaDeg: Double, feedMmPerMin: Double, motionPermit: ArmMotionPermit? = nil) async throws {
        precondition(!axis.isCartesian && !axis.isModule)
        let line = jointCommandFormat
            .replacingOccurrences(of: "{A}", with: axis.gcodeLetter)
            .replacingOccurrences(of: "{delta}", with: String(format: "%.4f", deltaDeg))
            .replacingOccurrences(of: "{F}", with: String(format: "%.1f", feedMmPerMin))
        _ = try await send(line, motionPermit: motionPermit)
    }

    public func moveAbsolute(x: Double, y: Double, z: Double, feedMmPerMin: Double, motionPermit: ArmMotionPermit? = nil) async throws {
        _ = try await send("G90", motionPermit: motionPermit)
        do {
            _ = try await send(String(format: "G1 X%.4f Y%.4f Z%.4f F%.1f", x, y, z, feedMmPerMin), motionPermit: motionPermit)
            try await flush(motionPermit: motionPermit)
        } catch {
            _ = try? await send("G91")
            throw error
        }
        _ = try await send("G91")
    }

    public func home(feedMmPerMin: Double, motionPermit: ArmMotionPermit? = nil) async throws {
        try await moveAbsolute(
            x: CartesianPose.officialHome.x,
            y: CartesianPose.officialHome.y,
            z: CartesianPose.officialHome.z,
            feedMmPerMin: feedMmPerMin,
            motionPermit: motionPermit
        )
    }

    public func setZ0(feedMmPerMin: Double, motionPermit: ArmMotionPermit? = nil) async throws {
        _ = try await send("G90", motionPermit: motionPermit)
        do {
            _ = try await send(String(format: "G1 Z0.0000 F%.1f", feedMmPerMin), motionPermit: motionPermit)
            try await flush(motionPermit: motionPermit)
        } catch {
            _ = try? await send("G91")
            throw error
        }
        _ = try await send("G91")
    }

    public func setMotors(_ on: Bool) async throws {
        _ = try await send(on ? "M17" : "M84")
    }

    public func jogJoint(axis: Axis, deltaDeg: Double, feedMmPerMin: Double) async throws {
        precondition(!axis.isCartesian)
        let line = jointCommandFormat
            .replacingOccurrences(of: "{A}", with: axis.gcodeLetter)
            .replacingOccurrences(of: "{delta}", with: String(format: "%.4f", deltaDeg))
            .replacingOccurrences(of: "{F}", with: String(format: "%.1f", feedMmPerMin))
        _ = try await send(line)
    }

    @discardableResult
    private func transact(_ line: String, motionPermit: ArmMotionPermit? = nil) async throws -> String {
        await acquireIO()
        defer { releaseIO() }
        if let motionPermit, await motionPermit() == false {
            throw ArmError.motionInvalidated
        }
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
            await withCheckedContinuation { continuation in
                ioWaiters.append(continuation)
            }
        } else {
            ioBusy = true
        }
    }

    private func releaseIO() {
        if ioWaiters.isEmpty {
            ioBusy = false
        } else {
            ioWaiters.removeFirst().resume()
        }
    }
}
