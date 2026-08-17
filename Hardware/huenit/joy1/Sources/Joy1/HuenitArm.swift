import Foundation

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
    private var ioBusy = false
    private var ioWaiters: [CheckedContinuation<Void, Never>] = []

    public init(transport: any SerialTransport, commandTimeout: Duration = .seconds(2)) {
        self.transport = transport
        self.commandTimeout = commandTimeout
    }

    public func connect() async throws {
        try await transport.open()
        do {
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
    public func send(_ line: String) async throws -> String {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.uppercased().contains("G28") {
            throw ArmError.forbiddenCommand("G28")
        }
        guard isConnected else {
            throw ArmError.disconnected
        }
        return try await transact(trimmed)
    }

    public func queryPose() async throws -> ArmPose {
        let xyzText = try await send("M1008 A3")
        let abcText = try await send("M1008 A2")
        return ArmPose(
            cartesian: try CartesianPose.parseM1008(xyzText),
            joints: try JointPose.parseM1008(abcText),
            isStale: false
        )
    }

    public func setVacuum(_ on: Bool) async throws {
        _ = try await send(on ? "M1400 A1023" : "M1400 A0")
    }

    public func flush() async throws {
        _ = try await send("M400")
    }

    public func stop() async throws {
        _ = try? await transact("M1400 A0")
        do {
            _ = try await transact("M410")
        } catch {
            _ = try await transact("M84")
        }
    }

    public func jogCartesian(axis: Axis, deltaMm: Double, feedMmPerMin: Double) async throws {
        precondition(axis.isCartesian)
        let line = String(format: "G1 \(axis.gcodeLetter)%.4f F%.1f", deltaMm, feedMmPerMin)
        _ = try await send(line)
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
