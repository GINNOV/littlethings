import AppKit
import Foundation

enum EmulatorBackend: String, CaseIterable, Identifiable {
    case fsUAE = "fsUAE"
    case vAmiga = "vAmiga"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fsUAE:
            return "FS-UAE"
        case .vAmiga:
            return "vAmiga CPU Trace"
        }
    }
}

struct RomEntry: Hashable, Identifiable {
    let displayName: String
    let relativePath: String
    let absolutePath: String
    let inferredMetadata: String

    var id: String { relativePath }
}

struct EmulatorLaunchConfig {
    let backend: EmulatorBackend
    let adfPath: String
    let romRelativePath: String
    let model: String
    let chipRamMb: String
    let fastRamMb: String
    let cpu: String
    let jit: Bool
    let customArgs: String
    let vAmigaExecutablePath: String
    let vAmigaCustomArgs: String
    let vAmigaServerConfig: VAmigaServerConfig
    let vAmigaScriptScreenshotBasePath: String?
    let vAmigaScriptWaitSeconds: Int
    let vAmigaTraceCommandsEnabled: Bool

    init(
        backend: EmulatorBackend,
        adfPath: String,
        romRelativePath: String,
        model: String,
        chipRamMb: String,
        fastRamMb: String,
        cpu: String,
        jit: Bool,
        customArgs: String,
        vAmigaExecutablePath: String,
        vAmigaCustomArgs: String,
        vAmigaServerConfig: VAmigaServerConfig = VAmigaServerConfig(),
        vAmigaScriptScreenshotBasePath: String? = nil,
        vAmigaScriptWaitSeconds: Int = 4,
        vAmigaTraceCommandsEnabled: Bool = true
    ) {
        self.backend = backend
        self.adfPath = adfPath
        self.romRelativePath = romRelativePath
        self.model = model
        self.chipRamMb = chipRamMb
        self.fastRamMb = fastRamMb
        self.cpu = cpu
        self.jit = jit
        self.customArgs = customArgs
        self.vAmigaExecutablePath = vAmigaExecutablePath
        self.vAmigaCustomArgs = vAmigaCustomArgs
        self.vAmigaServerConfig = vAmigaServerConfig
        self.vAmigaScriptScreenshotBasePath = vAmigaScriptScreenshotBasePath
        self.vAmigaScriptWaitSeconds = vAmigaScriptWaitSeconds
        self.vAmigaTraceCommandsEnabled = vAmigaTraceCommandsEnabled
    }
}

struct EmulatorLaunchResult {
    let success: Bool
    let backend: EmulatorBackend
    let message: String
    let tracePath: String?
}

struct VAmigaProcessInvocation: Equatable {
    let executablePath: String
    let arguments: [String]
}

struct CpuTraceRecord: Equatable {
    let event: String
    let pc: String?
    let instruction: String?
    let registers: [String: String]
    let sr: String?
    let memoryAccesses: [String]
    let breakpoint: String?
    let watchpoint: String?
    let rawLine: String
}

class EmulatorService {
    static let shared = EmulatorService()
    static var defaultRomsDirectory: String {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/FS-UAE/Kickstarts", isDirectory: true)
            .path
    }

    var romsDirectory: String {
        return UserDefaults.standard.string(forKey: "romsDirectoryPath") ?? Self.defaultRomsDirectory
    }
    let defaultEmulatorPath = "/opt/homebrew/bin/fs-uae"
    let defaultEmulatorAppPath = "/Applications/FS-UAE.app"
    let defaultVAmigaPath = "/Applications/vAmiga.app/Contents/MacOS/vAmiga"

    func getAvailableRoms(in directory: String? = nil) -> [RomEntry] {
        let fileManager = FileManager.default
        let rootPath = directory ?? romsDirectory
        let rootURL = URL(fileURLWithPath: rootPath, isDirectory: true)
        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return []
        }

        return enumerator.compactMap { item -> RomEntry? in
            guard let url = item as? URL else { return nil }
            guard (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else { return nil }
            guard url.pathExtension.lowercased() == "rom" else { return nil }

            let relativePath = Self.relativePath(for: url, rootURL: rootURL)
            let parent = url.deletingLastPathComponent().lastPathComponent
            let fileBase = url.deletingPathExtension().lastPathComponent
            let metadata = parent == rootURL.lastPathComponent ? fileBase : parent
            let displayName = metadata == fileBase ? url.lastPathComponent : "\(metadata) / \(url.lastPathComponent)"

            return RomEntry(
                displayName: displayName,
                relativePath: relativePath,
                absolutePath: url.path,
                inferredMetadata: metadata
            )
        }
        .sorted {
            $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending
        }
    }

    func launchEmulator(adfPath: String, romFilename: String, model: String, chipRamMb: String, fastRamMb: String, cpu: String, jit: Bool, customArgs: String, completion: @escaping (Bool, String) -> Void) {
        let config = EmulatorLaunchConfig(
            backend: .fsUAE,
            adfPath: adfPath,
            romRelativePath: romFilename,
            model: model,
            chipRamMb: chipRamMb,
            fastRamMb: fastRamMb,
            cpu: cpu,
            jit: jit,
            customArgs: customArgs,
            vAmigaExecutablePath: defaultVAmigaPath,
            vAmigaCustomArgs: ""
        )

        launchEmulator(config: config) { result in
            completion(result.success, result.message)
        }
    }

    func launchEmulator(config: EmulatorLaunchConfig, completion: @escaping (EmulatorLaunchResult) -> Void) {
        switch config.backend {
        case .fsUAE:
            launchFSUAE(config: config, completion: completion)
        case .vAmiga:
            launchVAmiga(config: config, completion: completion)
        }
    }

    func buildFSUAEArguments(config: EmulatorLaunchConfig) -> [String] {
        let chipMemKb = effectiveChipMemoryKb(for: config)
        let fastMemKb = mapRamToKb(ramStr: config.fastRamMb, isChip: false)

        var args = [
            "--floppy_drive_0=\(config.adfPath)",
            "--amiga_model=\(config.model)",
            "--chip_memory=\(chipMemKb)",
            "--fast_memory=\(fastMemKb)",
            "--cpu=\(config.cpu)",
            "--jit=\(config.jit ? "1" : "0")"
        ]

        if let romPath = resolveRomPath(config.romRelativePath, model: config.model) {
            args.append("--kickstart_file=\(romPath)")
        }

        args.append(contentsOf: splitCommandLine(config.customArgs))
        return args
    }

    func buildVAmigaArguments(config: EmulatorLaunchConfig, scriptPath: String) -> [String] {
        var args: [String] = []
        args.append("-source \(retroShellQuotedPath(scriptPath))")
        args.append(contentsOf: splitCommandLine(config.vAmigaCustomArgs))
        return args
    }

    func buildVAmigaInvocation(executablePath: String, config: EmulatorLaunchConfig, scriptPath: String) -> VAmigaProcessInvocation {
        if let appBundlePath = vAmigaAppBundlePath(for: executablePath) {
            return VAmigaProcessInvocation(
                executablePath: "/usr/bin/open",
                arguments: ["-n", "-a", appBundlePath, scriptPath]
            )
        }

        return VAmigaProcessInvocation(
            executablePath: executablePath,
            arguments: buildVAmigaArguments(config: config, scriptPath: scriptPath)
        )
    }

    private func vAmigaAppBundlePath(for executablePath: String) -> String? {
        let url = URL(fileURLWithPath: executablePath).standardizedFileURL
        let components = url.pathComponents
        guard let appIndex = components.firstIndex(where: { $0.hasSuffix(".app") }) else {
            return nil
        }
        return NSString.path(withComponents: Array(components[0...appIndex]))
    }

    func createVAmigaRetroShellScript(config: EmulatorLaunchConfig, tracePath: String) throws -> String {
        let scriptDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("AmigaPlayground/vamiga-traces", isDirectory: true)
        try FileManager.default.createDirectory(at: scriptDirectory, withIntermediateDirectories: true)

        let scriptURL = scriptDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("retrosh")
        let romBootstrap: String
        if let romPath = resolveRomPath(config.romRelativePath) {
            romBootstrap = "try mem load rom \(retroShellQuotedPath(romPath))"
        } else {
            romBootstrap = "# No explicit ROM selected; vAmiga will use its configured default ROM."
        }

        let screenshotCapture: String
        if config.vAmigaScriptScreenshotBasePath != nil || !config.vAmigaTraceCommandsEnabled {
            screenshotCapture = """
            # Runtime smoke capture is requested later through the remote RetroShell.
            """
        } else {
            screenshotCapture = """
            help
            config
            cpu
            regs
            disassemble
            break
            watch
            """
        }

        let serverBootstrap = vAmigaServerBootstrapCommands(config: config)
        let script = """
        # AmigaPlayground vAmiga CPU trace bootstrap
        # Trace file target: \(tracePath)
        # The validation path opens this RetroShell script as the vAmiga document.
        # It explicitly inserts the generated ADF into DF0 and starts execution,
        # which is more reliable than opening an ADF document and relying on the
        # previous desktop power/run state.
        try amiga init \(vAmigaInitPreset(for: config.model))
        \(serverBootstrap)
        \(romBootstrap)
        try df0 eject
        try df0 insert \(retroShellQuotedPath(config.adfPath))
        try amiga power on
        try amiga reset
        \(screenshotCapture)
        """
        try script.write(to: scriptURL, atomically: true, encoding: .utf8)
        return scriptURL.path
    }

    private func vAmigaServerBootstrapCommands(config: EmulatorLaunchConfig) -> String {
        if isLegacyVAmigaServerLayout(executablePath: config.vAmigaExecutablePath) {
            return """
            try server rshell set PORT \(config.vAmigaServerConfig.remoteShellPort)
            try server rshell start
            """
        }

        return """
        try server rshell set PORT \(config.vAmigaServerConfig.remoteShellPort)
        try server rshell start
        try server rsh set port \(config.vAmigaServerConfig.remoteShellPort)
        try server rsh set enable true
        try server rpc set port \(config.vAmigaServerConfig.rpcPort)
        try server rpc set enable true
        """
    }

    private func isLegacyVAmigaServerLayout(executablePath: String) -> Bool {
        guard let version = installedVAmigaVersion(executablePath: executablePath) else {
            return false
        }
        let components = version.split(separator: ".").compactMap { Int($0) }
        guard components.count >= 2 else { return false }
        return components[0] == 4 && components[1] < 4
    }

    private func installedVAmigaVersion(executablePath: String) -> String? {
        guard let appBundlePath = vAmigaAppBundlePath(for: executablePath) else {
            return nil
        }
        let plistURL = URL(fileURLWithPath: appBundlePath, isDirectory: true)
            .appendingPathComponent("Contents/Info.plist")
        guard
            let data = try? Data(contentsOf: plistURL),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
            let dictionary = plist as? [String: Any]
        else {
            return nil
        }
        return dictionary["CFBundleShortVersionString"] as? String
    }

    func vAmigaInitPreset(for model: String) -> String {
        switch model.uppercased().replacingOccurrences(of: " ", with: "") {
        case "A1000":
            return "A1000_OCS_1MB"
        case "A500":
            return "A500_OCS_1MB"
        case "A500+", "A500PLUS":
            return "A500_PLUS_1MB"
        default:
            return "A500_ECS_1MB"
        }
    }

    func parseCpuTrace(_ text: String) -> [CpuTraceRecord] {
        text.split(whereSeparator: \.isNewline).map { parseCpuTraceLine(String($0)) }
    }

    func splitCommandLine(_ text: String) -> [String] {
        var args: [String] = []
        var current = ""
        var quote: Character?
        var escaping = false

        for char in text {
            if escaping {
                current.append(char)
                escaping = false
                continue
            }
            if char == "\\" {
                escaping = true
                continue
            }
            if let activeQuote = quote {
                if char == activeQuote {
                    quote = nil
                } else {
                    current.append(char)
                }
                continue
            }
            if char == "\"" || char == "'" {
                quote = char
                continue
            }
            if char.isWhitespace {
                if !current.isEmpty {
                    args.append(current)
                    current = ""
                }
                continue
            }
            current.append(char)
        }

        if !current.isEmpty {
            args.append(current)
        }
        return args
    }

    private func launchFSUAE(config: EmulatorLaunchConfig, completion: @escaping (EmulatorLaunchResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default

            guard fileManager.fileExists(atPath: self.defaultEmulatorAppPath) || fileManager.fileExists(atPath: self.defaultEmulatorPath) else {
                DispatchQueue.main.async {
                    completion(EmulatorLaunchResult(
                        success: false,
                        backend: .fsUAE,
                        message: "FS-UAE emulator not found at \(self.defaultEmulatorAppPath) or \(self.defaultEmulatorPath).\nPlease install FS-UAE to run your ADF files.",
                        tracePath: nil
                    ))
                }
                return
            }

            let launchedChipRam = self.formatRam(kilobytes: self.effectiveChipMemoryKb(for: config))
            let process = Process()
            if fileManager.fileExists(atPath: self.defaultEmulatorAppPath) {
                process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
                process.arguments = ["-n", "-a", self.defaultEmulatorAppPath, "--args"] + self.buildFSUAEArguments(config: config)
            } else {
                process.executableURL = URL(fileURLWithPath: self.defaultEmulatorPath)
                process.arguments = self.buildFSUAEArguments(config: config)
            }

            do {
                try process.run()
                if process.executableURL?.path == "/usr/bin/open" {
                    process.waitUntilExit()
                    guard process.terminationStatus == 0 else {
                        DispatchQueue.main.async {
                            completion(EmulatorLaunchResult(
                                success: false,
                                backend: .fsUAE,
                                message: "Failed to open FS-UAE app bundle with status \(process.terminationStatus).",
                                tracePath: nil
                            ))
                        }
                        return
                    }
                    self.activateFSUAEApp()
                } else {
                    self.activate(process: process)
                }
                DispatchQueue.main.async {
                    completion(EmulatorLaunchResult(
                        success: true,
                        backend: .fsUAE,
                        message: "Successfully launched FS-UAE with Amiga \(config.model), CPU \(config.cpu), Chip RAM \(launchedChipRam), Fast RAM \(config.fastRamMb), JIT: \(config.jit ? "Enabled" : "Disabled").",
                        tracePath: nil
                    ))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(EmulatorLaunchResult(
                        success: false,
                        backend: .fsUAE,
                        message: "Failed to execute FS-UAE emulator process: \(error.localizedDescription)",
                        tracePath: nil
                    ))
                }
            }
        }
    }

    private func activateFSUAEApp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NSRunningApplication.runningApplications(withBundleIdentifier: "no.fengestad.fs-uae")
                .last?
                .activate(options: [.activateAllWindows])
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NSRunningApplication.runningApplications(withBundleIdentifier: "no.fengestad.fs-uae")
                .last?
                .activate(options: [.activateAllWindows])
        }
    }

    private func activate(process: Process) {
        let processIdentifier = process.processIdentifier
        let activationOptions: NSApplication.ActivationOptions
        if #available(macOS 14.0, *) {
            activationOptions = [.activateAllWindows]
        } else {
            activationOptions = [.activateAllWindows, .activateIgnoringOtherApps]
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NSRunningApplication(processIdentifier: processIdentifier)?
                .activate(options: activationOptions)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NSRunningApplication(processIdentifier: processIdentifier)?
                .activate(options: activationOptions)
        }
    }

    private func launchVAmiga(config: EmulatorLaunchConfig, completion: @escaping (EmulatorLaunchResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            let executablePath = config.vAmigaExecutablePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? self.defaultVAmigaPath : config.vAmigaExecutablePath

            guard fileManager.fileExists(atPath: executablePath) else {
                DispatchQueue.main.async {
                    completion(EmulatorLaunchResult(
                        success: false,
                        backend: .vAmiga,
                        message: "vAmiga executable not found at \(executablePath).\nInstall vAmiga Desktop or choose the vAmiga executable in Settings.",
                        tracePath: nil
                    ))
                }
                return
            }

            do {
                let tracePath = try self.createTraceFilePath()
                let scriptPath = try self.createVAmigaRetroShellScript(config: config, tracePath: tracePath)
                if let appBundlePath = self.vAmigaAppBundlePath(for: executablePath) {
                    self.launchVAmigaApplicationBundle(
                        appBundlePath: appBundlePath,
                        scriptPath: scriptPath,
                        tracePath: tracePath,
                        completion: completion
                    )
                    return
                }

                let invocation = self.buildVAmigaInvocation(executablePath: executablePath, config: config, scriptPath: scriptPath)
                let process = Process()
                process.executableURL = URL(fileURLWithPath: invocation.executablePath)
                process.arguments = invocation.arguments

                let outputPipe = Pipe()
                let errorPipe = Pipe()
                process.standardOutput = outputPipe
                process.standardError = errorPipe

                var capturedOutput = ""
                let outputHandler: (FileHandle) -> Void = { handle in
                    let data = handle.availableData
                    if !data.isEmpty, let text = String(data: data, encoding: .utf8) {
                        capturedOutput += text
                    }
                }
                outputPipe.fileHandleForReading.readabilityHandler = outputHandler
                errorPipe.fileHandleForReading.readabilityHandler = outputHandler

                try process.run()

                DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1.0) {
                    outputPipe.fileHandleForReading.readabilityHandler = nil
                    errorPipe.fileHandleForReading.readabilityHandler = nil
                    self.writeTraceSnapshot(
                        path: tracePath,
                        scriptPath: scriptPath,
                        processArguments: [invocation.executablePath] + invocation.arguments,
                        capturedOutput: capturedOutput
                    )
                }

                DispatchQueue.main.async {
                    completion(EmulatorLaunchResult(
                        success: true,
                        backend: .vAmiga,
                        message: "Successfully launched vAmiga Desktop with an explicit RetroShell validation script.\nTrace output will be captured at:\n\(tracePath)\n\nRetroShell script:\n\(scriptPath)",
                        tracePath: tracePath
                    ))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(EmulatorLaunchResult(
                        success: false,
                        backend: .vAmiga,
                        message: "Failed to launch vAmiga CPU trace session: \(error.localizedDescription)",
                        tracePath: nil
                    ))
                }
            }
        }
    }

    private func launchVAmigaApplicationBundle(
        appBundlePath: String,
        scriptPath: String,
        tracePath: String,
        completion: @escaping (EmulatorLaunchResult) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let documentOpenResult = self.launchVAmigaScriptDocument(appBundlePath: appBundlePath, scriptPath: scriptPath)

            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1.0) {
                self.writeTraceSnapshot(
                    path: tracePath,
                    scriptPath: scriptPath,
                    processArguments: ["/bin/zsh", "-lc", self.vAmigaDocumentOpenCommand(appBundlePath: appBundlePath, scriptPath: scriptPath)],
                    capturedOutput: documentOpenResult.output
                )
            }

            if !documentOpenResult.success {
                DispatchQueue.main.async {
                    completion(EmulatorLaunchResult(
                        success: false,
                        backend: .vAmiga,
                        message: "Failed to launch vAmiga RetroShell script document: \(documentOpenResult.output)",
                        tracePath: tracePath
                    ))
                }
                return
            }

            DispatchQueue.main.async {
                completion(EmulatorLaunchResult(
                    success: true,
                    backend: .vAmiga,
                    message: "Successfully launched vAmiga Desktop with an explicit RetroShell validation script.\nTrace output will be captured at:\n\(tracePath)\n\nRetroShell script:\n\(scriptPath)",
                    tracePath: tracePath
                ))
            }
        }
    }

    private func launchVAmigaScriptDocument(appBundlePath: String, scriptPath: String) -> (success: Bool, output: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-lc", vAmigaDocumentOpenCommand(appBundlePath: appBundlePath, scriptPath: scriptPath)]
        process.environment = sanitizedLaunchEnvironment()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()
            let output = [outputPipe, errorPipe]
                .compactMap { try? $0.fileHandleForReading.readToEnd() }
                .compactMap { String(data: $0, encoding: .utf8) }
                .joined()
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let summary = output.isEmpty
                ? "Document delivery exited with status \(process.terminationStatus)."
                : "Document delivery exited with status \(process.terminationStatus): \(output)"
            if process.terminationStatus == 0 {
                return (true, summary)
            }
            let workspaceBridgeResult = launchVAmigaScriptDocumentWithWorkspaceBridge(appBundlePath: appBundlePath, scriptPath: scriptPath)
            if workspaceBridgeResult.success {
                return (true, "\(summary)\n\(workspaceBridgeResult.output)")
            }
            let directWorkspaceResult = launchVAmigaScriptDocumentWithWorkspace(appBundlePath: appBundlePath, scriptPath: scriptPath)
            return directWorkspaceResult.success
                ? (true, "\(summary)\n\(workspaceBridgeResult.output)\n\(directWorkspaceResult.output)")
                : (false, "\(summary)\n\(workspaceBridgeResult.output)\n\(directWorkspaceResult.output)")
        } catch {
            let workspaceBridgeResult = launchVAmigaScriptDocumentWithWorkspaceBridge(appBundlePath: appBundlePath, scriptPath: scriptPath)
            if workspaceBridgeResult.success {
                return (true, "\(error.localizedDescription)\n\(workspaceBridgeResult.output)")
            }
            let directWorkspaceResult = launchVAmigaScriptDocumentWithWorkspace(appBundlePath: appBundlePath, scriptPath: scriptPath)
            return directWorkspaceResult.success
                ? (true, "\(workspaceBridgeResult.output)\n\(error.localizedDescription)\n\(directWorkspaceResult.output)")
                : (false, "\(workspaceBridgeResult.output)\n\(error.localizedDescription)\n\(directWorkspaceResult.output)")
        }
    }

    private func sanitizedLaunchEnvironment() -> [String: String] {
        [
            "HOME": NSHomeDirectory(),
            "USER": NSUserName(),
            "LOGNAME": NSUserName(),
            "PATH": "/usr/bin:/bin:/usr/sbin:/sbin",
            "TMPDIR": NSTemporaryDirectory()
        ]
    }

    private func launchVAmigaScriptDocumentWithWorkspace(appBundlePath: String, scriptPath: String) -> (success: Bool, output: String) {
        let appURL = URL(fileURLWithPath: appBundlePath, isDirectory: true)
        let scriptURL = URL(fileURLWithPath: scriptPath)
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.createsNewApplicationInstance = true

        let semaphore = DispatchSemaphore(value: 0)
        var result: (success: Bool, output: String) = (false, "NSWorkspace document delivery did not complete.")

        DispatchQueue.main.async {
            NSWorkspace.shared.open(
                [scriptURL],
                withApplicationAt: appURL,
                configuration: configuration
            ) { application, error in
                if let error {
                    result = (false, "NSWorkspace document delivery failed: \(error.localizedDescription)")
                } else {
                    let pidDescription = application.map { " pid \($0.processIdentifier)" } ?? ""
                    result = (true, "NSWorkspace delivered RetroShell document to vAmiga\(pidDescription).")
                }
                semaphore.signal()
            }
        }

        _ = semaphore.wait(timeout: .now() + 8)
        return result
    }

    private func launchVAmigaScriptDocumentWithWorkspaceBridge(appBundlePath: String, scriptPath: String) -> (success: Bool, output: String) {
        let appURL = URL(fileURLWithPath: appBundlePath, isDirectory: true)
        let scriptURL = URL(fileURLWithPath: scriptPath)
        let appConfiguration = NSWorkspace.OpenConfiguration()
        appConfiguration.activates = true
        appConfiguration.createsNewApplicationInstance = true

        let appSemaphore = DispatchSemaphore(value: 0)
        var output: [String] = []
        var launchedApplication: NSRunningApplication?
        var launchError: Error?

        DispatchQueue.main.async {
            NSWorkspace.shared.openApplication(at: appURL, configuration: appConfiguration) { application, error in
                launchedApplication = application
                launchError = error
                appSemaphore.signal()
            }
        }

        if appSemaphore.wait(timeout: .now() + 8) == .timedOut {
            return (false, "NSWorkspace bridge timed out launching visible vAmiga app.")
        }
        if let launchError {
            return (false, "NSWorkspace bridge failed to launch visible vAmiga app: \(launchError.localizedDescription)")
        }
        output.append("NSWorkspace bridge launched visible vAmiga app\(launchedApplication.map { " pid \($0.processIdentifier)" } ?? "").")

        Thread.sleep(forTimeInterval: 3.0)

        let documentConfiguration = NSWorkspace.OpenConfiguration()
        documentConfiguration.activates = true
        documentConfiguration.createsNewApplicationInstance = false

        let documentSemaphore = DispatchSemaphore(value: 0)
        var documentResult: (success: Bool, output: String) = (false, "NSWorkspace bridge document delivery did not complete.")

        DispatchQueue.main.async {
            NSWorkspace.shared.open(
                [scriptURL],
                withApplicationAt: appURL,
                configuration: documentConfiguration
            ) { application, error in
                if let error {
                    documentResult = (false, "NSWorkspace bridge document delivery failed: \(error.localizedDescription)")
                } else {
                    let pidDescription = application.map { " pid \($0.processIdentifier)" } ?? ""
                    documentResult = (true, "NSWorkspace bridge delivered RetroShell document to visible vAmiga\(pidDescription).")
                }
                documentSemaphore.signal()
            }
        }

        if documentSemaphore.wait(timeout: .now() + 8) == .timedOut {
            return (false, (output + ["NSWorkspace bridge timed out delivering RetroShell document."]).joined(separator: "\n"))
        }

        output.append(documentResult.output)
        return (documentResult.success, output.joined(separator: "\n"))
    }

    private func shellQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }

    private func vAmigaDocumentOpenCommand(appBundlePath: String, scriptPath: String) -> String {
        // vAmiga 4.2 can accept a .retrosh file without creating a visible,
        // control-ready document. Launch the GUI first, then deliver the script
        // to that running app through the interactive user launch session.
        let environment = sanitizedLaunchEnvironment()
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\(shellQuoted($0.value))" }
            .joined(separator: " ")
        let bundleIdentifier = vAmigaBundleIdentifier(appBundlePath: appBundlePath) ?? "dirkwhoffmann.vAmiga"
        let escapedScriptPath = scriptPath
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let openScript = "tell application id \"\(bundleIdentifier)\" to open POSIX file \"\(escapedScriptPath)\""
        let activateScript = "tell application id \"\(bundleIdentifier)\" to activate"
        return [
            "/usr/bin/open -n -a \(shellQuoted(appBundlePath))",
            "/bin/sleep 3.0",
            "/usr/bin/env -i \(environment) /usr/bin/osascript -e \(shellQuoted(openScript)) -e \(shellQuoted(activateScript))"
        ].joined(separator: " && ")
    }

    private func vAmigaBundleIdentifier(appBundlePath: String) -> String? {
        Bundle(url: URL(fileURLWithPath: appBundlePath, isDirectory: true))?.bundleIdentifier
    }

    func mapRamToKb(ramStr: String, isChip: Bool) -> Int {
        // e.g. "512 KB" -> 512, "1 MB" -> 1024, "2 MB" -> 2048, "8 MB" -> 8192, etc.
        let cleaned = ramStr.replacingOccurrences(of: " KB", with: "").replacingOccurrences(of: " MB", with: "").trimmingCharacters(in: .whitespaces)
        guard let num = Int(cleaned) else {
            return isChip ? 512 : 0
        }

        if ramStr.contains("MB") {
            return num * 1024
        }
        return num
    }

    private func effectiveChipMemoryKb(for config: EmulatorLaunchConfig) -> Int {
        let requestedKb = mapRamToKb(ramStr: config.chipRamMb, isChip: true)

        switch config.model {
        case "A1200", "A4000":
            return max(requestedKb, 2048)
        default:
            return requestedKb
        }
    }

    private func formatRam(kilobytes: Int) -> String {
        if kilobytes >= 1024, kilobytes % 1024 == 0 {
            return "\(kilobytes / 1024) MB"
        }

        return "\(kilobytes) KB"
    }

    private static func relativePath(for url: URL, rootURL: URL) -> String {
        let rootPath = rootURL.standardizedFileURL.path
        let path = url.standardizedFileURL.path
        guard path.hasPrefix(rootPath + "/") else { return url.lastPathComponent }
        return String(path.dropFirst(rootPath.count + 1))
    }

    private func resolveRomPath(_ relativePath: String) -> String? {
        guard !relativePath.isEmpty else { return nil }
        let url = URL(fileURLWithPath: relativePath)
        let path = url.isFileURL && relativePath.hasPrefix("/") ? relativePath : URL(fileURLWithPath: romsDirectory, isDirectory: true).appendingPathComponent(relativePath).path
        return FileManager.default.fileExists(atPath: path) ? path : nil
    }

    private func resolveRomPath(_ relativePath: String, model: String) -> String? {
        let selectedPath = resolveRomPath(relativePath)

        if let selectedPath, isCompatibleRom(atPath: selectedPath, model: model) {
            return selectedPath
        }

        return findCompatibleRom(for: model) ?? selectedPath
    }

    private func isCompatibleRom(atPath path: String, model: String) -> Bool {
        guard ["A1200", "A4000"].contains(model) else {
            return true
        }

        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path),
              let size = attributes[.size] as? NSNumber else {
            return true
        }

        return size.intValue >= 524_288
    }

    private func findCompatibleRom(for model: String) -> String? {
        guard ["A1200", "A4000"].contains(model) else {
            return nil
        }

        let rootURL = URL(fileURLWithPath: romsDirectory, isDirectory: true)
        guard let enumerator = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return nil
        }

        let candidates = enumerator.compactMap { item -> URL? in
            guard let url = item as? URL,
                  url.pathExtension.lowercased() == "rom",
                  let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey]),
                  values.isRegularFile == true,
                  (values.fileSize ?? 0) >= 524_288 else {
                return nil
            }

            let name = url.lastPathComponent.lowercased()
            return name.contains(model.lowercased()) ? url : nil
        }

        return candidates.sorted { lhs, rhs in
            romCandidateScore(lhs) == romCandidateScore(rhs)
                ? lhs.lastPathComponent.localizedStandardCompare(rhs.lastPathComponent) == .orderedAscending
                : romCandidateScore(lhs) > romCandidateScore(rhs)
        }
        .first?
        .path
    }

    private func romCandidateScore(_ url: URL) -> Int {
        let name = url.lastPathComponent.lowercased()
        var score = 0
        if name.contains("3.1") { score += 2 }
        if !name.contains("[") { score += 1 }
        return score
    }

    func resolveRomPathForValidation(_ relativePath: String) -> String? {
        resolveRomPath(relativePath, model: "A500")
    }

    private func vAmigaAppBundlePath(from executablePath: String) -> String? {
        let url = URL(fileURLWithPath: executablePath)
        if url.pathExtension == "app" {
            return url.path
        }

        let components = url.pathComponents
        guard let appIndex = components.firstIndex(where: { $0.hasSuffix(".app") }) else {
            return nil
        }

        return NSString.path(withComponents: Array(components[0...appIndex]))
    }

    private func createTraceFilePath() throws -> String {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("AmigaPlayground/vamiga-traces", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jsonl").path
    }

    private func writeTraceSnapshot(path: String, scriptPath: String, processArguments: [String], capturedOutput: String) {
        let records = parseCpuTrace(capturedOutput)
        var lines: [String] = [
            #"{"event":"session","backend":"vAmiga","scriptPath":"\#(escapeJSON(scriptPath))","arguments":"\#(escapeJSON(processArguments.joined(separator: " ")))"}"#
        ]

        if capturedOutput.isEmpty {
            lines.append(#"{"event":"note","rawLine":"No stdout/stderr was captured from vAmiga Desktop yet. Use the generated RetroShell script or enable the RetroShell remote server for interactive trace capture."}"#)
        } else {
            lines.append(contentsOf: records.map(jsonLine))
        }

        try? lines.joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
    }

    private func parseCpuTraceLine(_ line: String) -> CpuTraceRecord {
        let lower = line.lowercased()
        let pc = firstMatch(in: line, pattern: #"(?:PC|pc)[:= ]+\$?([0-9A-Fa-f]{4,8})"#)
        let sr = firstMatch(in: line, pattern: #"(?:SR|sr)[:= ]+\$?([0-9A-Fa-f]{4})"#)
        var registers: [String: String] = [:]

        for register in ["D0", "D1", "D2", "D3", "D4", "D5", "D6", "D7", "A0", "A1", "A2", "A3", "A4", "A5", "A6", "A7"] {
            if let value = firstMatch(in: line, pattern: #"\#(register)[:= ]+\$?([0-9A-Fa-f]{1,8})"#) {
                registers[register] = value
            }
        }

        let instruction: String?
        if let pcRange = line.range(of: #"\$?[0-9A-Fa-f]{4,8}\s*[:]\s*"#, options: .regularExpression) {
            instruction = String(line[pcRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        } else {
            instruction = nil
        }

        let event: String
        if lower.contains("breakpoint") {
            event = "breakpoint"
        } else if lower.contains("watchpoint") {
            event = "watchpoint"
        } else if lower.contains("read") || lower.contains("write") || lower.contains("memory") {
            event = "memory"
        } else if pc != nil || instruction != nil || !registers.isEmpty {
            event = "cpu"
        } else {
            event = "raw"
        }

        return CpuTraceRecord(
            event: event,
            pc: pc,
            instruction: instruction,
            registers: registers,
            sr: sr,
            memoryAccesses: event == "memory" ? [line] : [],
            breakpoint: event == "breakpoint" ? line : nil,
            watchpoint: event == "watchpoint" ? line : nil,
            rawLine: line
        )
    }

    private func firstMatch(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range), match.numberOfRanges > 1 else { return nil }
        let captureRange = match.range(at: match.numberOfRanges - 1)
        guard let swiftRange = Range(captureRange, in: text) else { return nil }
        return String(text[swiftRange])
    }

    private func jsonLine(for record: CpuTraceRecord) -> String {
        let registerJSON = record.registers
            .sorted { $0.key < $1.key }
            .map { #""\#(escapeJSON($0.key))":"\#(escapeJSON($0.value))""# }
            .joined(separator: ",")
        let memoryJSON = record.memoryAccesses.map { #""\#(escapeJSON($0))""# }.joined(separator: ",")
        return #"{"event":"\#(escapeJSON(record.event))","pc":\#(jsonValue(record.pc)),"instruction":\#(jsonValue(record.instruction)),"registers":{\#(registerJSON)},"sr":\#(jsonValue(record.sr)),"memoryAccesses":[\#(memoryJSON)],"breakpoint":\#(jsonValue(record.breakpoint)),"watchpoint":\#(jsonValue(record.watchpoint)),"rawLine":"\#(escapeJSON(record.rawLine))"}"#
    }

    private func jsonValue(_ value: String?) -> String {
        guard let value else { return "null" }
        return #""\#(escapeJSON(value))""#
    }

    private func escapeJSON(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
    }

    private func retroShellQuotedPath(_ path: String) -> String {
        "\"\(path.replacingOccurrences(of: "\"", with: "\\\""))\""
    }
}
