import Foundation
import Combine

final class MLXServerController: ObservableObject {
    static let shared = MLXServerController()

    struct Configuration: Equatable {
        var workingDirectory: URL
        /// Base MLX model directory. Named `default_model` so mlx_lm.server maps
        /// the OpenAI model id `default_model` (Amiga Playground default) onto
        /// this path *with* the adapter — see mlx_lm adapter_map behavior.
        var modelDirectoryName: String
        /// LoRA adapter directory (Qwen2.5-Coder Amiga ASM b6 POR). Empty disables.
        var adapterDirectoryName: String
        var port: Int
        var logFileName: String

        static var `default`: Configuration {
            Configuration(
                workingDirectory: defaultFineTuningDirectory(),
                modelDirectoryName: "default_model",
                adapterDirectoryName: "adapters_b6",
                port: 1234,
                logFileName: "server.log"
            )
        }

        var healthCheckURL: URL? {
            URL(string: "http://localhost:\(port)/v1/models")
        }

        private static func defaultFineTuningDirectory() -> URL {
            URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("fine_tuning", isDirectory: true)
        }
    }

    struct Invocation: Equatable {
        let executableURL: URL
        let arguments: [String]
        let workingDirectory: URL
        let logFile: URL
    }

    enum Status: Equatable {
        case stopped
        case starting
        case running
        case runningExternally
        case stopping
        case failed(String)

        var label: String {
            switch self {
            case .stopped:
                return "Stopped"
            case .starting:
                return "Starting..."
            case .running:
                return "Running"
            case .runningExternally:
                return "Already running outside app"
            case .stopping:
                return "Stopping..."
            case .failed:
                return "Failed"
            }
        }

        var detail: String? {
            if case .failed(let message) = self {
                return message
            }

            return nil
        }
    }

    @Published private(set) var status: Status = .stopped

    let configuration: Configuration
    private var process: Process?
    private var logFileHandle: FileHandle?
    private let urlSession: URLSession

    init(configuration: Configuration = .default, urlSession: URLSession = .shared) {
        self.configuration = configuration
        self.urlSession = urlSession
    }

    deinit {
        stop()
    }

    static func buildInvocation(configuration: Configuration) -> Invocation {
        var parts = [
            "cd", shellQuoted(configuration.workingDirectory.path), "&&",
            "exec", "uv", "run", "python", "-m", "mlx_lm.server",
            "--model", shellQuoted(configuration.modelDirectoryName),
            "--port", shellQuoted("\(configuration.port)")
        ]
        let adapter = configuration.adapterDirectoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !adapter.isEmpty {
            parts += ["--adapter-path", shellQuoted(adapter)]
        }
        let command = parts.joined(separator: " ")

        return Invocation(
            executableURL: URL(fileURLWithPath: "/bin/zsh"),
            arguments: ["-lc", command],
            workingDirectory: configuration.workingDirectory,
            logFile: configuration.workingDirectory.appendingPathComponent(configuration.logFileName)
        )
    }

    private static func shellQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }

    var endpointDescription: String {
        "http://localhost:\(configuration.port)/v1"
    }

    var logFilePath: String {
        Self.buildInvocation(configuration: configuration).logFile.path
    }

    var canStart: Bool {
        switch status {
        case .stopped, .failed:
            return true
        case .starting, .running, .runningExternally, .stopping:
            return false
        }
    }

    var canStop: Bool {
        switch status {
        case .running, .starting:
            return process != nil
        case .stopped, .runningExternally, .stopping, .failed:
            return false
        }
    }

    func refreshStatus() {
        probeHealth { [weak self] isHealthy in
            DispatchQueue.main.async {
                guard let self else { return }

                if isHealthy {
                    self.status = self.process == nil ? .runningExternally : .running
                } else if self.process == nil {
                    self.status = .stopped
                }
            }
        }
    }

    func start() {
        guard canStart else { return }

        let invocation = Self.buildInvocation(configuration: configuration)
        let modelDirectory = configuration.workingDirectory.appendingPathComponent(configuration.modelDirectoryName, isDirectory: true)
        guard FileManager.default.fileExists(atPath: modelDirectory.path) else {
            status = .failed(
                "Model directory not found: \(modelDirectory.path). Run `./download_model.sh` in aMiLa/fine_tuning to fetch the Qwen2.5-Coder base + Amiga ASM LoRA (b6)."
            )
            return
        }
        let adapterName = configuration.adapterDirectoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !adapterName.isEmpty {
            let adapterDirectory = configuration.workingDirectory.appendingPathComponent(adapterName, isDirectory: true)
            let adapterWeights = adapterDirectory.appendingPathComponent("adapters.safetensors")
            guard FileManager.default.fileExists(atPath: adapterWeights.path) else {
                status = .failed(
                    "Adapter not found: \(adapterWeights.path). Run `./download_model.sh` in aMiLa/fine_tuning (needs adapters_b6 from bmove/amiga-rc-cappella-asm-qwen25)."
                )
                return
            }
        }

        status = .starting
        probeHealth { [weak self] isHealthy in
            DispatchQueue.main.async {
                guard let self else { return }

                if isHealthy {
                    self.status = .runningExternally
                    return
                }

                self.launch(invocation: invocation)
            }
        }
    }

    func stop() {
        guard let process else {
            if case .runningExternally = status {
                return
            }
            status = .stopped
            return
        }

        status = .stopping
        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.process = nil
                self?.closeLogFile()
                self?.status = .stopped
            }
        }
        process.terminate()
    }

    private func launch(invocation: Invocation) {
        do {
            let logDirectory = invocation.logFile.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
            _ = FileManager.default.createFile(atPath: invocation.logFile.path, contents: nil)

            let handle = try FileHandle(forWritingTo: invocation.logFile)
            let process = Process()
            process.executableURL = invocation.executableURL
            process.arguments = invocation.arguments
            process.currentDirectoryURL = invocation.workingDirectory
            process.standardOutput = handle
            process.standardError = handle
            process.terminationHandler = { [weak self] launchedProcess in
                DispatchQueue.main.async {
                    guard let self, self.process === launchedProcess else { return }
                    self.process = nil
                    self.closeLogFile()
                    if case .stopping = self.status {
                        self.status = .stopped
                    } else {
                        self.status = .failed("MLX server exited with status \(launchedProcess.terminationStatus). See \(invocation.logFile.path)")
                    }
                }
            }

            logFileHandle = handle
            self.process = process
            try process.run()
            waitUntilHealthy(remainingAttempts: 30)
        } catch {
            closeLogFile()
            process = nil
            status = .failed(error.localizedDescription)
        }
    }

    private func waitUntilHealthy(remainingAttempts: Int) {
        guard remainingAttempts > 0 else {
            status = .failed("Timed out waiting for MLX server at \(endpointDescription). See \(logFilePath)")
            return
        }

        guard process?.isRunning == true else {
            status = .failed("MLX server stopped before it became ready. See \(logFilePath)")
            return
        }

        probeHealth { [weak self] isHealthy in
            DispatchQueue.main.asyncAfter(deadline: .now() + (isHealthy ? 0 : 2)) {
                guard let self else { return }

                if isHealthy {
                    self.status = .running
                } else {
                    self.waitUntilHealthy(remainingAttempts: remainingAttempts - 1)
                }
            }
        }
    }

    private func probeHealth(completion: @escaping (Bool) -> Void) {
        guard let url = configuration.healthCheckURL else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 1.5

        urlSession.dataTask(with: request) { _, response, _ in
            let isHealthy = (response as? HTTPURLResponse).map { (200..<300).contains($0.statusCode) } ?? false
            completion(isHealthy)
        }.resume()
    }

    private func closeLogFile() {
        try? logFileHandle?.close()
        logFileHandle = nil
    }
}
