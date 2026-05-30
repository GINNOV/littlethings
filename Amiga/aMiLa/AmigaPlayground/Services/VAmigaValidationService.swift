import Darwin
import Foundation

struct VAmigaServerConfig: Equatable {
    let remoteShellPort: Int
    let rpcPort: Int
    let prometheusPort: Int
    let serialPort: Int
    let configPath: String
    let backupPath: String?
    let autoConfigure: Bool

    init(
        remoteShellPort: Int = 8080,
        rpcPort: Int = 8081,
        prometheusPort: Int = 8083,
        serialPort: Int = 8085,
        configPath: String = VAmigaServerConfig.defaultConfigPath,
        backupPath: String? = nil,
        autoConfigure: Bool = true
    ) {
        self.remoteShellPort = remoteShellPort
        self.rpcPort = rpcPort
        self.prometheusPort = prometheusPort
        self.serialPort = serialPort
        self.configPath = configPath
        self.backupPath = backupPath
        self.autoConfigure = autoConfigure
    }

    static var defaultConfigPath: String {
        URL(fileURLWithPath: hostHomeDirectory, isDirectory: true)
            .appendingPathComponent("Library/Application Support/vAmiga/vAmiga.ini")
            .path
    }

    private static var hostHomeDirectory: String {
        if let passwd = getpwuid(getuid()),
           let home = passwd.pointee.pw_dir {
            return String(cString: home)
        }
        return FileManager.default.homeDirectoryForCurrentUser.path
    }
}

struct VAmigaCommandRecord: Equatable {
    let command: String
    let response: String
    let timestamp: String
    let durationMs: Int
    let parsedRecords: [CpuTraceRecord]
    let error: String?
}

struct VAmigaValidationResult {
    let success: Bool
    let runId: String
    let artifactDirectory: String
    let summary: String
    let failures: [String]
    let tracePath: String
    let metricsPath: String
}

struct VAmigaRPCResponse: Equatable {
    let result: String?
    let errorMessage: String?
    let id: Int?
}

struct VAmigaServerConfigPatcher {
    private let vAmigaVersion: String?

    init(vAmigaVersion: String? = VAmigaServerConfigPatcher.installedVAmigaVersionString()) {
        self.vAmigaVersion = vAmigaVersion
    }

    func apply(config: VAmigaServerConfig) throws -> VAmigaServerConfig {
        guard config.autoConfigure else { return config }

        let fileManager = FileManager.default
        let configURL = URL(fileURLWithPath: config.configPath)
        try fileManager.createDirectory(at: configURL.deletingLastPathComponent(), withIntermediateDirectories: true)

        if !fileManager.fileExists(atPath: config.configPath) {
            try "[SRV]\n".write(to: configURL, atomically: true, encoding: .utf8)
        }

        let original = try String(contentsOf: configURL, encoding: .utf8)
        let backupURL = configURL.deletingPathExtension()
            .appendingPathExtension("ini.AmigaPlaygroundBackup.\(Self.timestampForFilename())")
        try original.write(to: backupURL, atomically: true, encoding: .utf8)

        let patched = patchServerSection(in: original, config: config)
        try patched.write(to: configURL, atomically: true, encoding: .utf8)

        return VAmigaServerConfig(
            remoteShellPort: config.remoteShellPort,
            rpcPort: config.rpcPort,
            prometheusPort: config.prometheusPort,
            serialPort: config.serialPort,
            configPath: config.configPath,
            backupPath: backupURL.path,
            autoConfigure: config.autoConfigure
        )
    }

    func restore(config: VAmigaServerConfig) {
        guard let backupPath = config.backupPath else { return }
        try? FileManager.default.removeItem(atPath: config.configPath)
        try? FileManager.default.copyItem(
            at: URL(fileURLWithPath: backupPath),
            to: URL(fileURLWithPath: config.configPath)
        )
    }

    private func patchServerSection(in text: String, config: VAmigaServerConfig) -> String {
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        var lines = normalized.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let legacyServerLayout = Self.parsedVersion(vAmigaVersion).map { $0.major == 4 && $0.minor < 4 } ?? false
        let serverKeys: [String: String] = [
            // vAmiga 4.4+: RSH=0, RPC=1, GDB=2, PROM=3, SER=4.
            "ENABLE0": "1",
            "ENABLE1": "1",
            "ENABLE3": "1",
            "ENABLE4": "1",
            "PORT0": "\(config.remoteShellPort)",
            "PORT1": legacyServerLayout ? "\(config.remoteShellPort)" : "\(config.rpcPort)",
            "PORT3": "\(config.prometheusPort)",
            "PORT4": "\(config.serialPort)",
            "PROTOCOL0": "0",
            "PROTOCOL1": "0",
            "PROTOCOL3": "0",
            "PROTOCOL4": "0",
            "VERBOSE0": "1",
            "VERBOSE1": "1",
            "VERBOSE3": "1",
            "VERBOSE4": "1",

            // vAmiga 4.2.x: SER=0, RSH=1, PROM=2, GDB=3 and enable is named AUTORUN.
            "AUTORUN1": "1",
            "AUTORUN2": "1",
            "PORT2": "\(config.prometheusPort)",
            "PROTOCOL2": "0",
            "VERBOSE2": "1"
        ]

        guard let sectionStart = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == "[SRV]" }) else {
            if !lines.isEmpty && lines.last != "" {
                lines.append("")
            }
            lines.append("[SRV]")
            lines.append(contentsOf: serverKeys.sorted { $0.key.localizedStandardCompare($1.key) == .orderedAscending }.map { "\($0.key)=\($0.value)" })
            return lines.joined(separator: "\n") + "\n"
        }

        let nextSection = lines[(sectionStart + 1)...].firstIndex { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("[") && trimmed.hasSuffix("]")
        } ?? lines.endIndex

        var existingKeys: Set<String> = []
        for index in (sectionStart + 1)..<nextSection {
            let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
            guard let equals = trimmed.firstIndex(of: "=") else { continue }
            let key = String(trimmed[..<equals])
            if let value = serverKeys[key] {
                lines[index] = "\(key)=\(value)"
                existingKeys.insert(key)
            }
        }

        let missing = serverKeys
            .filter { !existingKeys.contains($0.key) }
            .sorted { $0.key.localizedStandardCompare($1.key) == .orderedAscending }
            .map { "\($0.key)=\($0.value)" }
        lines.insert(contentsOf: missing, at: nextSection)
        return lines.joined(separator: "\n") + "\n"
    }

    private static func timestampForFilename() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.string(from: Date())
    }

    private static func installedVAmigaVersionString() -> String? {
        let plistURL = URL(fileURLWithPath: "/Applications/vAmiga.app/Contents/Info.plist")
        guard
            let data = try? Data(contentsOf: plistURL),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
            let dictionary = plist as? [String: Any],
            let version = dictionary["CFBundleShortVersionString"] as? String
        else {
            return nil
        }

        return version
    }

    private static func parsedVersion(_ version: String?) -> (major: Int, minor: Int)? {
        guard let version else { return nil }
        let components = version.split(separator: ".").compactMap { Int($0) }
        guard components.count >= 2 else { return nil }
        return (components[0], components[1])
    }
}

final class VAmigaRPCClient {
    let host: String
    let port: Int
    let timeout: TimeInterval

    init(host: String = "127.0.0.1", port: Int = 8081, timeout: TimeInterval = 3.0) {
        self.host = host
        self.port = port
        self.timeout = timeout
    }

    static func makeRequest(command: String, id: Int) throws -> String {
        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "retroshell",
            "params": command,
            "id": id
        ]
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func parseResponse(_ text: String) throws -> VAmigaRPCResponse {
        let data = Data(text.utf8)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw VAmigaValidationError.invalidRPCResponse(text)
        }

        let id = json["id"] as? Int
        if let result = json["result"] as? String {
            return VAmigaRPCResponse(result: result, errorMessage: nil, id: id)
        }
        if let error = json["error"] as? [String: Any] {
            return VAmigaRPCResponse(result: nil, errorMessage: error["message"] as? String ?? "\(error)", id: id)
        }
        return VAmigaRPCResponse(result: nil, errorMessage: "RPC response did not contain result or error", id: id)
    }

    func send(command: String, id: Int) throws -> VAmigaRPCResponse {
        let request = try Self.makeRequest(command: command, id: id) + "\n"
        let response = try sendRaw(request)
        return try Self.parseResponse(response)
    }

    func probe() -> Bool {
        (try? send(command: "server", id: 0)) != nil
    }

    private func sendRaw(_ request: String) throws -> String {
        var inputStream: InputStream?
        var outputStream: OutputStream?
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        guard let inputStream, let outputStream else {
            throw VAmigaValidationError.connectionFailed("Unable to create RPC streams for \(host):\(port)")
        }

        inputStream.open()
        outputStream.open()
        defer {
            inputStream.close()
            outputStream.close()
        }

        let bytes = [UInt8](request.utf8)
        let written = outputStream.write(bytes, maxLength: bytes.count)
        guard written == bytes.count else {
            throw VAmigaValidationError.connectionFailed("Failed to write RPC request to \(host):\(port)")
        }

        let deadline = Date().addingTimeInterval(timeout)
        var response = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)

        while Date() < deadline {
            if inputStream.hasBytesAvailable {
                let count = inputStream.read(&buffer, maxLength: buffer.count)
                if count > 0 {
                    response.append(buffer, count: count)
                    if let text = String(data: response, encoding: .utf8),
                       (try? JSONSerialization.jsonObject(with: Data(text.utf8))) != nil {
                        return text.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                } else if count < 0 {
                    throw VAmigaValidationError.connectionFailed(inputStream.streamError?.localizedDescription ?? "RPC stream read failed")
                }
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.03))
        }

        throw VAmigaValidationError.timeout("Timed out waiting for RPC response from \(host):\(port)")
    }
}

final class VAmigaPrometheusClient {
    let host: String
    let port: Int
    let timeout: TimeInterval

    init(host: String = "127.0.0.1", port: Int = 8083, timeout: TimeInterval = 3.0) {
        self.host = host
        self.port = port
        self.timeout = timeout
    }

    static func parseMetrics(_ text: String) -> [String: Double] {
        var metrics: [String: Double] = [:]
        for line in text.split(whereSeparator: \.isNewline).map(String.init) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }
            let parts = trimmed.split(whereSeparator: \.isWhitespace)
            guard parts.count >= 2, let value = Double(parts[1]) else { continue }
            metrics[String(parts[0])] = value
        }
        return metrics
    }

    func fetchMetrics() throws -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var output: Result<String, Error> = .failure(VAmigaValidationError.timeout("Prometheus request did not start"))
        let url = URL(string: "http://\(host):\(port)/metrics")!
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                output = .failure(error)
            } else if let data, let text = String(data: data, encoding: .utf8) {
                output = .success(text)
            } else {
                output = .failure(VAmigaValidationError.connectionFailed("Prometheus returned no readable metrics"))
            }
            semaphore.signal()
        }.resume()

        if semaphore.wait(timeout: .now() + timeout + 0.5) == .timedOut {
            throw VAmigaValidationError.timeout("Timed out fetching Prometheus metrics from \(host):\(port)")
        }

        return try output.get()
    }
}

struct VAmigaValidationArtifactWriter {
    let rootDirectory: String

    init(rootDirectory: String = "/tmp/AmigaPlayground/validation") {
        self.rootDirectory = rootDirectory
    }

    func write(
        runId: String,
        config: VAmigaServerConfig,
        commands: [VAmigaCommandRecord],
        metrics: String,
        stdoutStderr: String,
        failures: [String],
        summary: String
    ) throws -> VAmigaValidationResult {
        let runURL = URL(fileURLWithPath: rootDirectory, isDirectory: true).appendingPathComponent(runId, isDirectory: true)
        try FileManager.default.createDirectory(at: runURL, withIntermediateDirectories: true)

        let traceURL = runURL.appendingPathComponent("trace.jsonl")
        let commandsURL = runURL.appendingPathComponent("commands.jsonl")
        let metricsURL = runURL.appendingPathComponent("metrics.prom")
        let stdoutURL = runURL.appendingPathComponent("stdout-stderr.log")
        let manifestURL = runURL.appendingPathComponent("manifest.json")
        let failureSummaryURL = runURL.appendingPathComponent("failure-summary.md")

        let commandLines = commands.map(jsonLine)
        try commandLines.joined(separator: "\n").write(to: commandsURL, atomically: true, encoding: .utf8)

        let traceLines = commands.flatMap { command in
            command.parsedRecords.map { record in
                traceJSONLine(command: command.command, record: record)
            }
        }
        try traceLines.joined(separator: "\n").write(to: traceURL, atomically: true, encoding: .utf8)
        try metrics.write(to: metricsURL, atomically: true, encoding: .utf8)
        try stdoutStderr.write(to: stdoutURL, atomically: true, encoding: .utf8)

        let manifest = """
        {
          "runId": "\(escapeJSON(runId))",
          "success": \(failures.isEmpty ? "true" : "false"),
          "summary": "\(escapeJSON(summary))",
          "configPath": "\(escapeJSON(config.configPath))",
          "backupPath": \(jsonValue(config.backupPath)),
          "remoteShellPort": \(config.remoteShellPort),
          "rpcPort": \(config.rpcPort),
          "prometheusPort": \(config.prometheusPort),
          "serialPort": \(config.serialPort),
          "tracePath": "\(escapeJSON(traceURL.path))",
          "metricsPath": "\(escapeJSON(metricsURL.path))"
        }
        """
        try manifest.write(to: manifestURL, atomically: true, encoding: .utf8)

        let failureText = """
        # vAmiga Validation

        \(summary)

        ## Failures
        \(failures.isEmpty ? "None" : failures.map { "- \($0)" }.joined(separator: "\n"))

        ## Artifacts
        - Trace: \(traceURL.path)
        - Metrics: \(metricsURL.path)
        - Commands: \(commandsURL.path)
        """
        try failureText.write(to: failureSummaryURL, atomically: true, encoding: .utf8)

        return VAmigaValidationResult(
            success: failures.isEmpty,
            runId: runId,
            artifactDirectory: runURL.path,
            summary: summary,
            failures: failures,
            tracePath: traceURL.path,
            metricsPath: metricsURL.path
        )
    }

    private func jsonLine(for record: VAmigaCommandRecord) -> String {
        #"{"timestamp":"\#(escapeJSON(record.timestamp))","command":"\#(escapeJSON(record.command))","durationMs":\#(record.durationMs),"error":\#(jsonValue(record.error)),"response":"\#(escapeJSON(record.response))"}"#
    }

    private func traceJSONLine(command: String, record: CpuTraceRecord) -> String {
        let registers = record.registers
            .sorted { $0.key < $1.key }
            .map { #""\#(escapeJSON($0.key))":"\#(escapeJSON($0.value))""# }
            .joined(separator: ",")
        let memory = record.memoryAccesses.map { #""\#(escapeJSON($0))""# }.joined(separator: ",")
        return #"{"command":"\#(escapeJSON(command))","event":"\#(escapeJSON(record.event))","pc":\#(jsonValue(record.pc)),"instruction":\#(jsonValue(record.instruction)),"registers":{\#(registers)},"sr":\#(jsonValue(record.sr)),"memoryAccesses":[\#(memory)],"breakpoint":\#(jsonValue(record.breakpoint)),"watchpoint":\#(jsonValue(record.watchpoint)),"rawLine":"\#(escapeJSON(record.rawLine))"}"#
    }
}

final class VAmigaValidationService {
    static let shared = VAmigaValidationService()

    private let patcher: VAmigaServerConfigPatcher
    private let artifactWriter: VAmigaValidationArtifactWriter

    init(
        patcher: VAmigaServerConfigPatcher = VAmigaServerConfigPatcher(),
        artifactWriter: VAmigaValidationArtifactWriter = VAmigaValidationArtifactWriter()
    ) {
        self.patcher = patcher
        self.artifactWriter = artifactWriter
    }

    func validate(config launchConfig: EmulatorLaunchConfig, completion: @escaping (VAmigaValidationResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let runId = Self.makeRunId()
            var failures: [String] = []
            var warnings: [String] = []
            var commands: [VAmigaCommandRecord] = []
            var stdoutStderr = ""
            var metrics = ""
            var serverConfig = launchConfig.vAmigaServerConfig

            do {
                serverConfig = try self.patcher.apply(config: serverConfig)
                if serverConfig.autoConfigure && !VAmigaRPCClient(port: serverConfig.rpcPort, timeout: 0.5).probe() {
                    stdoutStderr += self.quitRunningVAmigaIfPresent()
                }
                let launchOutput = try self.launchVAmiga(config: launchConfig)
                stdoutStderr += launchOutput

                let rpcClient = VAmigaRPCClient(port: serverConfig.rpcPort, timeout: 3.0)
                let promClient = VAmigaPrometheusClient(port: serverConfig.prometheusPort, timeout: 3.0)

                try self.waitForRPC(rpcClient, timeout: 12.0)

                do {
                    metrics += "# before\n"
                    metrics += try promClient.fetchMetrics()
                    metrics += "\n"
                } catch {
                    warnings.append("Prometheus metrics unavailable before run: \(error.localizedDescription)")
                }

                let validationCommands = self.validationCommands(for: launchConfig)
                for (index, command) in validationCommands.enumerated() {
                    let record = try self.execute(command: command, id: index + 1, rpcClient: rpcClient)
                    commands.append(record)
                    if let error = record.error, self.isRequiredCommand(command) {
                        failures.append("Required RetroShell command '\(command)' failed: \(error)")
                    }
                    if command == "amiga run" || command == "run" {
                        Thread.sleep(forTimeInterval: 0.5)
                    }
                }

                do {
                    metrics += "\n# after\n"
                    metrics += try promClient.fetchMetrics()
                    metrics += "\n"
                } catch {
                    warnings.append("Prometheus metrics unavailable after run: \(error.localizedDescription)")
                }

                if !commands.contains(where: { !$0.parsedRecords.filter { $0.event == "cpu" }.isEmpty }) {
                    failures.append("No usable CPU evidence was captured from RetroShell.")
                }
                if !commands.contains(where: { $0.parsedRecords.contains { $0.instruction != nil } }) {
                    failures.append("No disassembly evidence was captured from RetroShell.")
                }
            } catch {
                failures.append(error.localizedDescription)
            }

            if metrics.isEmpty {
                metrics = "# No Prometheus metrics captured.\n"
            }
            if !warnings.isEmpty {
                stdoutStderr += "\nWarnings:\n" + warnings.map { "- \($0)" }.joined(separator: "\n") + "\n"
            }

            let summary = failures.isEmpty
                ? "Validation passed with RPC command execution, CPU evidence, disassembly, and runtime metrics."
                : "Validation failed. Captured \(commands.count) RPC command records for diagnosis."

            let result: VAmigaValidationResult
            do {
                result = try self.artifactWriter.write(
                    runId: runId,
                    config: serverConfig,
                    commands: commands,
                    metrics: metrics,
                    stdoutStderr: stdoutStderr,
                    failures: failures,
                    summary: summary
                )
            } catch {
                result = VAmigaValidationResult(
                    success: false,
                    runId: runId,
                    artifactDirectory: self.artifactWriter.rootDirectory,
                    summary: "Validation artifact writing failed: \(error.localizedDescription)",
                    failures: failures + [error.localizedDescription],
                    tracePath: "",
                    metricsPath: ""
                )
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    private func launchVAmiga(config: EmulatorLaunchConfig) throws -> String {
        let executablePath = config.vAmigaExecutablePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? EmulatorService.shared.defaultVAmigaPath
            : config.vAmigaExecutablePath
        guard FileManager.default.fileExists(atPath: executablePath) else {
            throw VAmigaValidationError.launchFailed("vAmiga executable not found at \(executablePath)")
        }

        let appPath = appBundlePath(from: executablePath) ?? executablePath
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        var args = ["-a", appPath, config.adfPath]
        let customArgs = EmulatorService.shared.splitCommandLine(config.vAmigaCustomArgs)
        if !customArgs.isEmpty {
            args.append("--args")
            args.append(contentsOf: customArgs)
        }
        process.arguments = args

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        try process.run()
        process.waitUntilExit()

        let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let error = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        if process.terminationStatus != 0 {
            throw VAmigaValidationError.launchFailed(error.isEmpty ? "open exited with status \(process.terminationStatus)" : error)
        }

        return ([output, error].filter { !$0.isEmpty }).joined(separator: "\n")
    }

    private func quitRunningVAmigaIfPresent() -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", #"tell application "vAmiga" to quit"#]
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()
            Thread.sleep(forTimeInterval: 1.5)
        } catch {
            return "Could not ask running vAmiga to quit before auto-configured relaunch: \(error.localizedDescription)\n"
        }

        let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let error = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
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
        throw VAmigaValidationError.timeout("Timed out waiting for vAmiga RPC server on localhost:\(client.port). Last error: \(lastError?.localizedDescription ?? "none")")
    }

    private func execute(command: String, id: Int, rpcClient: VAmigaRPCClient) throws -> VAmigaCommandRecord {
        let start = Date()
        let timestamp = Self.isoTimestamp(Date())
        let response = try rpcClient.send(command: command, id: id)
        let duration = Int(Date().timeIntervalSince(start) * 1000)
        if let errorMessage = response.errorMessage {
            return VAmigaCommandRecord(
                command: command,
                response: "",
                timestamp: timestamp,
                durationMs: duration,
                parsedRecords: [],
                error: errorMessage
            )
        }

        let text = response.result ?? ""
        return VAmigaCommandRecord(
            command: command,
            response: text,
            timestamp: timestamp,
            durationMs: duration,
            parsedRecords: EmulatorService.shared.parseCpuTrace(text),
            error: nil
        )
    }

    private func validationCommands(for config: EmulatorLaunchConfig) -> [String] {
        var commands: [String] = ["server"]
        if let romPath = EmulatorService.shared.resolveRomPathForValidation(config.romRelativePath) {
            commands.append("mem load rom \(quote(romPath))")
        }
        commands.append(contentsOf: [
            "df0 connect",
            "df0 insert \(quote(config.adfPath))",
            "amiga reset",
            "amiga run",
            "run",
            "r cpu",
            "disassemble",
            "? cpu",
            "? memory",
            "? memory bankmap",
            "break",
            "watch"
        ])
        return commands
    }

    private func isRequiredCommand(_ command: String) -> Bool {
        command == "server"
            || command == "df0 connect"
            || command.hasPrefix("df0 insert ")
            || command == "amiga reset"
            || command == "r cpu"
            || command == "disassemble"
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

    private static func makeRunId() -> String {
        "vamiga-\(isoTimestamp(Date()).replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ".", with: ""))-\(UUID().uuidString.prefix(8))"
    }

    private static func isoTimestamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

enum VAmigaValidationError: LocalizedError {
    case invalidRPCResponse(String)
    case connectionFailed(String)
    case timeout(String)
    case launchFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidRPCResponse(let message), .connectionFailed(let message), .timeout(let message), .launchFailed(let message):
            return message
        }
    }
}

private func escapeJSON(_ value: String) -> String {
    value
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\r", with: "\\r")
}

private func jsonValue(_ value: String?) -> String {
    guard let value else { return "null" }
    return #""\#(escapeJSON(value))""#
}
