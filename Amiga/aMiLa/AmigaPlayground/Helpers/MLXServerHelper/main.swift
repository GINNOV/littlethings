import Darwin
import Foundation

struct HelperStatus: Codable {
    let event: String
    let message: String
    let code: String?
    let action: String?

    init(event: String, message: String, code: String? = nil, action: String? = nil) {
        self.event = event
        self.message = message
        self.code = code
        self.action = action
    }
}

struct HelperConfiguration {
    let modelPath: String
    let adapterPath: String?
    let port: Int
    let logFilePath: String
    let runtimeCommand: String
    let uvPath: String?

    var endpoint: String {
        "http://localhost:\(port)/v1"
    }

    var healthCheckURL: URL {
        URL(string: "http://localhost:\(port)/v1/models")!
    }
}

enum HelperArgumentError: Error {
    case missingValue(String)
    case missingRequired(String)
    case invalidPort(String)

    var message: String {
        switch self {
        case .missingValue(let option):
            return "Missing value for \(option)."
        case .missingRequired(let option):
            return "Missing required option \(option)."
        case .invalidPort(let value):
            return "Invalid port: \(value)"
        }
    }
}

@discardableResult
func emit(event: String, message: String, code: String? = nil, action: String? = nil) -> HelperStatus {
    let status = HelperStatus(event: event, message: message, code: code, action: action)
    if let data = try? JSONEncoder().encode(status),
       let line = String(data: data, encoding: .utf8) {
        print(line)
        fflush(stdout)
    }
    return status
}

func parseArguments(_ arguments: [String]) throws -> HelperConfiguration {
    var values: [String: String] = [:]
    var index = 0

    while index < arguments.count {
        let option = arguments[index]
        guard option.hasPrefix("--") else {
            index += 1
            continue
        }

        let valueIndex = index + 1
        guard valueIndex < arguments.count, !arguments[valueIndex].hasPrefix("--") else {
            throw HelperArgumentError.missingValue(option)
        }

        values[option] = arguments[valueIndex]
        index += 2
    }

    func required(_ option: String) throws -> String {
        guard let value = values[option], !value.isEmpty else {
            throw HelperArgumentError.missingRequired(option)
        }
        return value
    }

    let portString = try required("--port")
    guard let port = Int(portString), (1...65535).contains(port) else {
        throw HelperArgumentError.invalidPort(portString)
    }

    let adapterRaw = values["--adapter-path"]?.trimmingCharacters(in: .whitespacesAndNewlines)
    return HelperConfiguration(
        modelPath: try required("--model"),
        adapterPath: (adapterRaw?.isEmpty == false) ? adapterRaw : nil,
        port: port,
        logFilePath: try required("--log-file"),
        runtimeCommand: try required("--runtime-command"),
        uvPath: values["--uv-path"]
    )
}

func fail(_ message: String, code: String? = nil, action: String? = nil, exitCode: Int32 = 2) -> Never {
    emit(event: "failed", message: message, code: code, action: action)
    exit(exitCode)
}

func shellQuote(_ value: String) -> String {
    "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
}

func launchCommand(configuration: HelperConfiguration) -> String {
    let runtimeCommand = normalizedRuntimeCommand(configuration.runtimeCommand, uvPath: configuration.uvPath)
    var parts = [
        runtimeCommand,
        "--model", shellQuote(configuration.modelPath),
        "--port", shellQuote("\(configuration.port)")
    ]
    if let adapterPath = configuration.adapterPath, !adapterPath.isEmpty {
        parts += ["--adapter-path", shellQuote(adapterPath)]
    }
    return parts.joined(separator: " ")
}

func normalizedRuntimeCommand(_ command: String, uvPath: String?) -> String {
    guard let uvPath, !uvPath.isEmpty else {
        return command
    }

    let quotedUV = shellQuote(uvPath)
    if command == "uv" {
        return quotedUV
    }
    if command.hasPrefix("uv ") {
        return quotedUV + command.dropFirst(2)
    }
    return command.replacingOccurrences(of: "&& uv ", with: "&& \(quotedUV) ")
}

func prepareLogFile(path: String) throws -> FileHandle {
    let url = URL(fileURLWithPath: path)
    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    _ = FileManager.default.createFile(atPath: path, contents: nil)
    return try FileHandle(forWritingTo: url)
}

func isServerHealthy(url: URL, timeout: TimeInterval = 1.5) -> Bool {
    let semaphore = DispatchSemaphore(value: 0)
    var healthy = false

    var request = URLRequest(url: url)
    request.timeoutInterval = timeout

    URLSession.shared.dataTask(with: request) { _, response, _ in
        healthy = (response as? HTTPURLResponse).map { (200..<300).contains($0.statusCode) } ?? false
        semaphore.signal()
    }.resume()

    _ = semaphore.wait(timeout: .now() + timeout + 0.5)
    return healthy
}

func waitUntilHealthy(configuration: HelperConfiguration, process: Process) -> Bool {
    for _ in 0..<30 {
        if isServerHealthy(url: configuration.healthCheckURL) {
            emit(event: "running", message: "MLX server is ready at \(configuration.endpoint)")
            return true
        }

        if !process.isRunning {
            return false
        }

        Thread.sleep(forTimeInterval: 2)
    }

    return false
}

func commandOutput(_ executable: String, _ arguments: [String]) -> String {
    let pipe = Pipe()
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    process.standardOutput = pipe
    process.standardError = Pipe()

    do {
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { return "" }
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    } catch {
        return ""
    }
}

func commandSucceeds(_ executable: String, _ arguments: [String]) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    process.standardOutput = Pipe()
    process.standardError = Pipe()

    do {
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus == 0
    } catch {
        return false
    }
}

func resolveUVExecutable(explicitPath: String?) -> String? {
    if let explicitPath {
        return FileManager.default.isExecutableFile(atPath: explicitPath) ? explicitPath : nil
    }

    var candidates = [
        "/opt/homebrew/bin/uv",
        "/usr/local/bin/uv",
        "\(FileManager.default.homeDirectoryForCurrentUser.path)/.local/bin/uv"
    ]

    let shellPath = commandOutput("/bin/zsh", ["-lc", "command -v uv"])
        .trimmingCharacters(in: .whitespacesAndNewlines)
    if !shellPath.isEmpty {
        candidates.insert(shellPath, at: 0)
    }

    return candidates.first { FileManager.default.isExecutableFile(atPath: $0) }
}

func portIsBusy(_ port: Int) -> Bool {
    let descriptor = socket(AF_INET, SOCK_STREAM, 0)
    guard descriptor >= 0 else {
        return false
    }
    defer { close(descriptor) }

    var reuse = Int32(1)
    setsockopt(descriptor, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))

    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = in_port_t(port).bigEndian
    address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))

    let result = withUnsafePointer(to: &address) { pointer in
        pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { socketAddress in
            Darwin.bind(descriptor, socketAddress, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }

    return result != 0 && errno == EADDRINUSE
}

func preflight(configuration: HelperConfiguration) -> HelperConfiguration {
    guard FileManager.default.fileExists(atPath: configuration.modelPath) else {
        fail(
            "MLX model directory was not found: \(configuration.modelPath)",
            code: "missing_model",
            action: "Run aMiLa/fine_tuning/download_model.sh to fetch the Qwen2.5-Coder base into runtime/base/, then start the server again."
        )
    }

    if let adapterPath = configuration.adapterPath, !adapterPath.isEmpty {
        let weights = URL(fileURLWithPath: adapterPath).appendingPathComponent("adapters.safetensors").path
        guard FileManager.default.fileExists(atPath: weights) else {
            fail(
                "MLX adapter was not found: \(weights)",
                code: "missing_adapter",
                action: "Run aMiLa/fine_tuning/download_model.sh to fetch runtime/adapter from bmove/amiga-playground-asm."
            )
        }
    }

    guard let uvPath = resolveUVExecutable(explicitPath: configuration.uvPath) else {
        fail(
            "uv was not found.",
            code: "missing_uv",
            action: "Install uv with `curl -LsSf https://astral.sh/uv/install.sh | sh`, then restart Amiga Playground. If uv is already installed, make sure it is available at /opt/homebrew/bin/uv, /usr/local/bin/uv, or ~/.local/bin/uv."
        )
    }

    guard commandSucceeds(uvPath, ["--version"]) else {
        fail(
            "uv exists but could not be executed at \(uvPath).",
            code: "uv_not_executable",
            action: "Check the uv installation permissions, reinstall uv, then restart Amiga Playground."
        )
    }

    let workingDirectory = FileManager.default.currentDirectoryPath
    guard commandSucceeds("/bin/zsh", ["-lc", "cd \(shellQuote(workingDirectory)) && \(shellQuote(uvPath)) run python -c 'import mlx_lm.server'"]) else {
        fail(
            "MLX-LM is not available in the configured Python environment.",
            code: "missing_mlx_lm",
            action: "Open Terminal, run `cd \(workingDirectory) && \(uvPath) sync`, then start the server again. The required dependency is `mlx-lm>=0.20.0` from pyproject.toml."
        )
    }

    guard !portIsBusy(configuration.port) else {
        fail(
            "Port \(configuration.port) is already in use.",
            code: "port_busy",
            action: "Stop the other local model server using port \(configuration.port), or change the Amiga Playground MLX server port."
        )
    }

    emit(event: "preflight", message: "MLX runtime preflight passed")
    return HelperConfiguration(
        modelPath: configuration.modelPath,
        adapterPath: configuration.adapterPath,
        port: configuration.port,
        logFilePath: configuration.logFilePath,
        runtimeCommand: configuration.runtimeCommand,
        uvPath: uvPath
    )
}

func runServer(configuration: HelperConfiguration) throws -> Never {
    let logHandle = try prepareLogFile(path: configuration.logFilePath)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    process.arguments = ["-lc", launchCommand(configuration: configuration)]
    process.standardOutput = logHandle
    process.standardError = logHandle

    signal(SIGINT, SIG_IGN)
    signal(SIGTERM, SIG_IGN)

    let sigintSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
    let sigtermSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
    for source in [sigintSource, sigtermSource] {
        source.setEventHandler {
            if process.isRunning {
                process.terminate()
            }
        }
        source.resume()
    }

    try process.run()
    emit(event: "started", message: "MLX-LM process started with pid \(process.processIdentifier)")

    if !waitUntilHealthy(configuration: configuration, process: process) {
        if process.isRunning {
            process.terminate()
        }
        try? logHandle.close()
        fail(
            "Timed out waiting for MLX server at \(configuration.endpoint)",
            code: "server_timeout",
            action: "Open the MLX server log at \(configuration.logFilePath), fix the reported runtime error, then start the server again.",
            exitCode: 1
        )
    }

    process.waitUntilExit()
    try? logHandle.close()
    emit(event: "stopped", message: "MLX-LM process stopped")
    exit(process.terminationStatus)
}

do {
    let configuration = try parseArguments(Array(CommandLine.arguments.dropFirst()))
    try runServer(configuration: preflight(configuration: configuration))
} catch let error as HelperArgumentError {
    fail(error.message, code: "invalid_arguments")
} catch {
    fail(error.localizedDescription, code: "invalid_arguments")
}
