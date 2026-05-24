import Foundation
import Combine

final class MLXServerController: ObservableObject {
    static let shared = MLXServerController()

    struct Configuration: Equatable {
        var workingDirectory: URL
        var modelDirectoryName: String
        var port: Int
        var logFileName: String

        static var `default`: Configuration {
            Configuration(
                workingDirectory: defaultFineTuningDirectory(),
                modelDirectoryName: "fused_model",
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

    struct HelperStatus: Decodable, Equatable {
        enum Event: String, Decodable {
            case ready
            case preflight
            case started
            case running
            case stopped
            case failed
        }

        let event: Event
        let message: String
        let code: String?
        let action: String?

        static func parse(line: String) throws -> HelperStatus {
            try JSONDecoder().decode(HelperStatus.self, from: Data(line.utf8))
        }

        var userFacingMessage: String {
            guard let action, !action.isEmpty else {
                return message
            }

            return "\(message)\n\n\(action)"
        }
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
                return "Starting MLX Server"
            case .running:
                return "MLX Server Running"
            case .runningExternally:
                return "MLX Running Outside App"
            case .stopping:
                return "Stopping MLX Server"
            case .failed:
                return "MLX Setup Needed"
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
    private var helperOutputBuffer = ""

    init(configuration: Configuration = .default, urlSession: URLSession = .shared) {
        self.configuration = configuration
        self.urlSession = urlSession
    }

    deinit {
        stop()
    }

    static func buildInvocation(configuration: Configuration) -> Invocation {
        let modelDirectory = configuration.workingDirectory.appendingPathComponent(configuration.modelDirectoryName, isDirectory: true)
        let logFile = configuration.workingDirectory.appendingPathComponent(configuration.logFileName)

        return Invocation(
            executableURL: defaultHelperURL(),
            arguments: [
                "--model", modelDirectory.path,
                "--port", "\(configuration.port)",
                "--log-file", logFile.path,
                "--runtime-command", "uv run python -m mlx_lm.server"
            ],
            workingDirectory: configuration.workingDirectory,
            logFile: logFile
        )
    }

    static func defaultHelperURL() -> URL {
        if let helper = Bundle.main.url(forAuxiliaryExecutable: "MLXServerHelper") {
            return helper
        }

        return URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent(".build/debug/MLXServerHelper")
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
            status = .failed("MLX model directory was not found: \(modelDirectory.path)\n\nBuild or copy the fused MLX model to \(modelDirectory.path), then start the server again.")
            return
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
            let process = Process()
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.executableURL = invocation.executableURL
            process.arguments = invocation.arguments
            process.currentDirectoryURL = invocation.workingDirectory
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            process.terminationHandler = { [weak self] launchedProcess in
                DispatchQueue.main.async {
                    guard let self, self.process === launchedProcess else { return }
                    self.process = nil
                    outputPipe.fileHandleForReading.readabilityHandler = nil
                    errorPipe.fileHandleForReading.readabilityHandler = nil
                    if case .stopping = self.status {
                        self.status = .stopped
                    } else if case .failed = self.status {
                        return
                    } else if case .stopped = self.status {
                        return
                    } else {
                        self.status = .failed("MLX server exited with status \(launchedProcess.terminationStatus). See \(invocation.logFile.path)")
                    }
                }
            }

            self.process = process
            helperOutputBuffer = ""
            outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
                let data = handle.availableData
                guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
                DispatchQueue.main.async {
                    self?.handleHelperOutput(text)
                }
            }
            errorPipe.fileHandleForReading.readabilityHandler = { handle in
                _ = handle.availableData
            }
            try process.run()
        } catch {
            closeLogFile()
            process = nil
            status = .failed(error.localizedDescription)
        }
    }

    private func handleHelperOutput(_ text: String) {
        helperOutputBuffer += text

        while let newlineRange = helperOutputBuffer.range(of: "\n") {
            let line = String(helperOutputBuffer[..<newlineRange.lowerBound])
            helperOutputBuffer.removeSubrange(...newlineRange.lowerBound)
            handleHelperLine(line)
        }
    }

    private func handleHelperLine(_ line: String) {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLine.isEmpty else { return }

        guard let helperStatus = try? HelperStatus.parse(line: trimmedLine) else {
            return
        }

        switch helperStatus.event {
        case .ready, .preflight, .started:
            status = .starting
        case .running:
            status = .running
        case .stopped:
            status = .stopped
        case .failed:
            status = .failed(helperStatus.userFacingMessage)
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
