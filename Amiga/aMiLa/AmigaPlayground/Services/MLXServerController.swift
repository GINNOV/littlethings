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

    struct ModelDownloadFile: Equatable {
        let relativePath: String

        var remoteURL: URL {
            let escapedPath = relativePath
                .split(separator: "/")
                .map { String($0).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String($0) }
                .joined(separator: "/")

            return URL(string: "https://huggingface.co/\(OllamaService.publishedModelID)/resolve/main/\(escapedPath)")!
        }
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
        case downloading(completed: Int, total: Int, currentFile: String)
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
            case .downloading(let completed, let total, _):
                return "Downloading Model \(completed)/\(total)"
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
    private var downloadProcess: Process?
    private var logFileHandle: FileHandle?
    private let urlSession: URLSession
    private var helperOutputBuffer = ""

    static let modelDownloadFiles: [ModelDownloadFile] = [
        ModelDownloadFile(relativePath: "README.md"),
        ModelDownloadFile(relativePath: "chat_template.jinja"),
        ModelDownloadFile(relativePath: "config.json"),
        ModelDownloadFile(relativePath: "generation_config.json"),
        ModelDownloadFile(relativePath: "model.safetensors"),
        ModelDownloadFile(relativePath: "model.safetensors.index.json"),
        ModelDownloadFile(relativePath: "model_version.json"),
        ModelDownloadFile(relativePath: "tokenizer.json"),
        ModelDownloadFile(relativePath: "tokenizer_config.json"),
        ModelDownloadFile(relativePath: "adapters_asm/adapter_config.json"),
        ModelDownloadFile(relativePath: "adapters_asm/adapters.safetensors"),
        ModelDownloadFile(relativePath: "adapters_c/adapter_config.json"),
        ModelDownloadFile(relativePath: "adapters_c/adapters.safetensors"),
        ModelDownloadFile(relativePath: "docs/asm_capability_ladder.yaml"),
        ModelDownloadFile(relativePath: "docs/model_learnings.md")
    ]

    init(configuration: Configuration = .default, urlSession: URLSession = .shared) {
        self.configuration = configuration
        self.urlSession = urlSession
    }

    deinit {
        downloadProcess?.terminate()
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

    var modelDirectory: URL {
        configuration.workingDirectory.appendingPathComponent(configuration.modelDirectoryName, isDirectory: true)
    }

    var modelIsDownloaded: Bool {
        Self.modelDownloadFiles
            .filter { $0.relativePath.hasSuffix(".safetensors") || $0.relativePath == "config.json" || $0.relativePath == "tokenizer.json" }
            .allSatisfy { FileManager.default.fileExists(atPath: modelDirectory.appendingPathComponent($0.relativePath).path) }
    }

    var canDownload: Bool {
        guard !modelIsDownloaded else { return false }

        switch status {
        case .stopped, .failed:
            return true
        case .starting, .running, .runningExternally, .stopping, .downloading:
            return false
        }
    }

    var canStart: Bool {
        switch status {
        case .stopped, .failed:
            return true
        case .starting, .running, .runningExternally, .stopping, .downloading:
            return false
        }
    }

    var canStop: Bool {
        switch status {
        case .running, .starting:
            return process != nil
        case .stopped, .runningExternally, .stopping, .downloading, .failed:
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
        guard modelIsDownloaded else {
            status = .failed("MLX model files were not found in \(modelDirectory.path)\n\nUse Download Model in Amiga Playground, or run `cd \(configuration.workingDirectory.path) && ./download_model.sh`, then start the server again.")
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

    func downloadModel(startAfterDownload: Bool = false) {
        guard canDownload else { return }

        let files = Self.modelDownloadFiles
        status = .downloading(completed: 0, total: files.count, currentFile: files.first?.relativePath ?? "model")

        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self else { return }

            do {
                try FileManager.default.createDirectory(at: self.modelDirectory, withIntermediateDirectories: true)

                for (index, file) in files.enumerated() {
                    DispatchQueue.main.async {
                        self.status = .downloading(completed: index, total: files.count, currentFile: file.relativePath)
                    }

                    try self.download(file: file)
                }

                DispatchQueue.main.async {
                    self.downloadProcess = nil
                    self.status = .stopped
                    if startAfterDownload {
                        self.start()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.downloadProcess = nil
                    self.status = .failed("Model download failed: \(error.localizedDescription)\n\nCheck your internet connection and make sure `/usr/bin/curl` is available, then try Download Model again.")
                }
            }
        }
    }

    private func download(file: ModelDownloadFile) throws {
        let destination = modelDirectory.appendingPathComponent(file.relativePath)
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
        process.arguments = [
            "--fail",
            "--location",
            "--continue-at", "-",
            "--output", destination.path,
            file.remoteURL.absoluteString
        ]
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        DispatchQueue.main.sync {
            self.downloadProcess = process
        }

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            throw NSError(
                domain: "MLXServerController.ModelDownload",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: "Could not download \(file.relativePath)"]
            )
        }
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
