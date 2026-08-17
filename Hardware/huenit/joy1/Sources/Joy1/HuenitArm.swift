import Foundation

public actor HuenitArm {
    private let transport: any SerialTransport
    public private(set) var isConnected = false
    public var jointCommandFormat: String = "G1 {A}{delta} F{F}"

    public init(transport: any SerialTransport) {
        self.transport = transport
    }

    public func connect() async throws {
        try await transport.open()
        do {
            let identity = try await send("M115")
            guard FirmwareIdentity.parse(identity).isHuenitMarlin else {
                throw ArmError.connectFailed("not HUENIT Marlin: \(identity)")
            }
            _ = try await send("G21")
            _ = try await send("G91")
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
        guard isConnected || trimmed == "M115" || trimmed == "G21" || trimmed == "G91" else {
            throw ArmError.disconnected
        }
        try await transport.writeLine(trimmed)
        return try await transport.readUntilOk(timeout: .seconds(2))
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
        _ = try? await send("M1400 A0")
        do {
            _ = try await send("M410")
        } catch {
            _ = try? await send("M84")
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
}
