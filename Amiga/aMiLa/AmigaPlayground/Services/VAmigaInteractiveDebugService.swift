import Foundation
import AppKit

struct PlaygroundDebugLaunchContext {
    let backend: EmulatorBackend
    let displayName: String
    let launchConfig: EmulatorLaunchConfig
    let startupCommands: [String]

    static let defaultStartupCommands = [
        "amiga reset",
        "amiga run",
        "r cpu",
        "disassemble"
    ]
}

enum PlaygroundDebugState: Equatable {
    case idle
    case starting
    case connected
    case sending
    case disconnected
    case failed(String)

    var label: String {
        switch self {
        case .idle: return "Not started"
        case .starting: return "Starting"
        case .connected: return "Connected"
        case .sending: return "Executing"
        case .disconnected: return "Disconnected"
        case .failed: return "Needs attention"
        }
    }

    var isActive: Bool {
        switch self {
        case .connected, .sending:
            return true
        case .idle, .starting, .disconnected, .failed:
            return false
        }
    }

    var canExecute: Bool {
        self == .connected
    }
}

struct VAmigaInteractiveDebugStartResult {
    let session: VAmigaDebugSession
    let bootstrapRecords: [VAmigaCommandRecord]
    let launchMessage: String
}

final class VAmigaDebugSession {
    private let client: VAmigaRPCClient
    private let commandQueue = DispatchQueue(label: "com.littlethings.AmigaPlayground.vAmigaDebugSession")
    private let stateLock = NSLock()
    private let idLock = NSLock()
    private let restoreConfiguration: (() throws -> Void)?
    private var nextCommandID = 100
    private var disconnected = false

    init(client: VAmigaRPCClient, restoreConfiguration: (() throws -> Void)? = nil) {
        self.client = client
        self.restoreConfiguration = restoreConfiguration
    }

    deinit {
        try? restoreConfiguration?()
    }

    func send(command: String, completion: @escaping (Result<VAmigaCommandRecord, Error>) -> Void) {
        stateLock.lock()
        let isDisconnected = disconnected
        stateLock.unlock()

        guard !isDisconnected else {
            DispatchQueue.main.async {
                completion(.failure(VAmigaValidationError.connectionFailed("The vAmiga debug session is disconnected.")))
            }
            return
        }

        let commandID = nextID()
        commandQueue.async {
            let startedAt = Date()
            let timestamp = Self.timestamp(for: startedAt)

            do {
                let response = try self.client.send(command: command, id: commandID)
                let durationMs = Int(Date().timeIntervalSince(startedAt) * 1000)
                let record: VAmigaCommandRecord
                if let errorMessage = response.errorMessage {
                    record = VAmigaCommandRecord(
                        command: command,
                        response: "",
                        timestamp: timestamp,
                        durationMs: durationMs,
                        parsedRecords: [],
                        error: errorMessage
                    )
                } else {
                    let text = response.result ?? ""
                    record = VAmigaCommandRecord(
                        command: command,
                        response: text,
                        timestamp: timestamp,
                        durationMs: durationMs,
                        parsedRecords: EmulatorService.shared.parseCpuTrace(text),
                        error: nil
                    )
                }
                DispatchQueue.main.async {
                    completion(.success(record))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func disconnect(completion: @escaping (Error?) -> Void = { _ in }) {
        stateLock.lock()
        if disconnected {
            stateLock.unlock()
            DispatchQueue.main.async { completion(nil) }
            return
        }
        disconnected = true
        stateLock.unlock()

        DispatchQueue.global(qos: .utility).async {
            let restoreError: Error?
            do {
                try self.restoreConfiguration?()
                restoreError = nil
            } catch {
                restoreError = error
            }
            DispatchQueue.main.async {
                completion(restoreError)
            }
        }
    }

    private func nextID() -> Int {
        idLock.lock()
        defer { idLock.unlock() }
        defer { nextCommandID += 1 }
        return nextCommandID
    }

    private static func timestamp(for date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

final class VAmigaInteractiveDebugService {
    static let shared = VAmigaInteractiveDebugService()

    private let patcher: VAmigaServerConfigPatcher

    init(patcher: VAmigaServerConfigPatcher = VAmigaServerConfigPatcher()) {
        self.patcher = patcher
    }

    func start(context: PlaygroundDebugLaunchContext, completion: @escaping (Result<VAmigaInteractiveDebugStartResult, Error>) -> Void) {
        guard context.backend == .vAmiga else {
            completion(.failure(VAmigaValidationError.connectionFailed("The \(context.backend.displayName) backend does not provide an interactive RetroShell session yet.")))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var serverConfig = context.launchConfig.vAmigaServerConfig
            do {
                serverConfig = try self.patcher.apply(config: serverConfig)
                let client = VAmigaRPCClient(port: serverConfig.rpcPort, timeout: 3.0)
                var launchMessage = "Connected to the existing vAmiga RetroShell server."

                if !client.probe() {
                    launchMessage = try self.launchVAmiga(config: context.launchConfig)
                    try self.waitForRPC(client, timeout: 12.0)
                }

                let session = VAmigaDebugSession(
                    client: client,
                    restoreConfiguration: { try self.patcher.restore(config: serverConfig) }
                )
                let bootstrapCommands = self.bootstrapCommands(for: context)
                var records: [VAmigaCommandRecord] = []
                for command in bootstrapCommands {
                    let record = try self.send(command: command, through: client, id: records.count + 1)
                    records.append(record)
                    if record.error != nil && self.isRequiredBootstrapCommand(command) {
                        throw VAmigaValidationError.connectionFailed(
                            "RetroShell command '\(command)' failed: \(record.error ?? "unknown error")"
                        )
                    }
                }

                let result = VAmigaInteractiveDebugStartResult(
                    session: session,
                    bootstrapRecords: records,
                    launchMessage: launchMessage.isEmpty ? "vAmiga RetroShell session started." : launchMessage
                )
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                try? self.patcher.restore(config: serverConfig)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    private func send(command: String, through client: VAmigaRPCClient, id: Int) throws -> VAmigaCommandRecord {
        let startedAt = Date()
        let response = try client.send(command: command, id: id)
        let durationMs = Int(Date().timeIntervalSince(startedAt) * 1000)
        if let errorMessage = response.errorMessage {
            return VAmigaCommandRecord(
                command: command,
                response: "",
                timestamp: Self.timestamp(for: startedAt),
                durationMs: durationMs,
                parsedRecords: [],
                error: errorMessage
            )
        }

        let text = response.result ?? ""
        return VAmigaCommandRecord(
            command: command,
            response: text,
            timestamp: Self.timestamp(for: startedAt),
            durationMs: durationMs,
            parsedRecords: EmulatorService.shared.parseCpuTrace(text),
            error: nil
        )
    }

    private func bootstrapCommands(for context: PlaygroundDebugLaunchContext) -> [String] {
        var commands = ["server"]
        if let romPath = EmulatorService.shared.resolveRomPathForValidation(context.launchConfig.romRelativePath) {
            commands.append("mem load rom \(quote(romPath))")
        }
        commands.append("df0 connect")
        commands.append("df0 insert \(quote(context.launchConfig.adfPath))")
        let startupCommands = context.startupCommands.isEmpty
            ? PlaygroundDebugLaunchContext.defaultStartupCommands
            : context.startupCommands
        commands.append(contentsOf: startupCommands.filter { $0 != "server" })
        return commands
    }

    private func isRequiredBootstrapCommand(_ command: String) -> Bool {
        command == "server"
            || command == "df0 connect"
            || command.hasPrefix("df0 insert ")
            || command == "amiga reset"
            || command == "r cpu"
            || command == "disassemble"
    }

    private func launchVAmiga(config: EmulatorLaunchConfig) throws -> String {
        let executablePath = config.vAmigaExecutablePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? EmulatorService.shared.defaultVAmigaPath
            : config.vAmigaExecutablePath
        guard FileManager.default.fileExists(atPath: executablePath) else {
            throw VAmigaValidationError.launchFailed("vAmiga executable not found at \(executablePath)")
        }

        let process = Process()
        let customArguments = EmulatorService.shared.splitCommandLine(config.vAmigaCustomArgs)
        if let appPath = appBundlePath(from: executablePath) {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            var arguments = ["-n", "-a", appPath, config.adfPath]
            if !customArguments.isEmpty {
                arguments.append("--args")
                arguments.append(contentsOf: customArguments)
            }
            process.arguments = arguments
        } else {
            process.executableURL = URL(fileURLWithPath: executablePath)
            process.arguments = [config.adfPath] + customArguments
        }

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        try process.run()
        if let appPath = appBundlePath(from: executablePath) {
            activateApplication(at: appPath)
        }
        process.waitUntilExit()

        let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let error = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        if process.terminationStatus != 0 {
            throw VAmigaValidationError.launchFailed(error.isEmpty ? "vAmiga launch exited with status \(process.terminationStatus)" : error)
        }
        return ([output, error].filter { !$0.isEmpty }).joined(separator: "\n")
    }

    private func waitForRPC(_ client: VAmigaRPCClient, timeout: TimeInterval) throws {
        let deadline = Date().addingTimeInterval(timeout)
        var lastError: Error?
        while Date() < deadline {
            do {
                _ = try client.send(command: "server", id: 0)
                return
            } catch {
                lastError = error
                Thread.sleep(forTimeInterval: 0.4)
            }
        }
        throw VAmigaValidationError.timeout(
            "Timed out waiting for vAmiga RPC server on localhost:\(client.port). Last error: \(lastError?.localizedDescription ?? "none")"
        )
    }

    private func activateApplication(at appPath: String) {
        let bundleURL = URL(fileURLWithPath: appPath)
        let bundleIdentifier = Bundle(url: bundleURL)?.bundleIdentifier
        let application: NSRunningApplication?
        if let bundleIdentifier {
            application = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).last
        } else {
            application = NSWorkspace.shared.runningApplications.first { $0.bundleURL == bundleURL }
        }
        application?.activate(options: [.activateAllWindows])
    }

    private func appBundlePath(from executablePath: String) -> String? {
        let url = URL(fileURLWithPath: executablePath)
        if url.pathExtension == "app" { return url.path }
        let components = url.pathComponents
        guard let appIndex = components.firstIndex(where: { $0.hasSuffix(".app") }) else { return nil }
        return NSString.path(withComponents: Array(components[0...appIndex]))
    }

    private func quote(_ path: String) -> String {
        "\"\(path.replacingOccurrences(of: "\"", with: "\\\""))\""
    }

    private static func timestamp(for date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
