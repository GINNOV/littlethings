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
        vAmigaServerConfig: VAmigaServerConfig = VAmigaServerConfig()
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

    var romsDirectory: String {
        return UserDefaults.standard.string(forKey: "romsDirectoryPath") ?? "/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware"
    }
    let defaultEmulatorPath = "/opt/homebrew/bin/fs-uae"
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
        let chipMemKb = mapRamToKb(ramStr: config.chipRamMb, isChip: true)
        let fastMemKb = mapRamToKb(ramStr: config.fastRamMb, isChip: false)

        var args = [
            "--floppy_drive_0=\(config.adfPath)",
            "--amiga_model=\(config.model)",
            "--chip_memory=\(chipMemKb)",
            "--fast_memory=\(fastMemKb)",
            "--cpu=\(config.cpu)",
            "--jit=\(config.jit ? "1" : "0")"
        ]

        if let romPath = resolveRomPath(config.romRelativePath) {
            args.append("--kickstart_file=\(romPath)")
        }

        args.append(contentsOf: splitCommandLine(config.customArgs))
        return args
    }

    func buildVAmigaArguments(config: EmulatorLaunchConfig, scriptPath: String) -> [String] {
        var args: [String] = []
        args.append(scriptPath)
        args.append(contentsOf: splitCommandLine(config.vAmigaCustomArgs))
        return args
    }

    func buildVAmigaInvocation(executablePath: String, config: EmulatorLaunchConfig, scriptPath: String) -> VAmigaProcessInvocation {
        let customArgs = splitCommandLine(config.vAmigaCustomArgs)
        if let appBundlePath = vAmigaAppBundlePath(from: executablePath) {
            var args = ["-n", "-a", appBundlePath, scriptPath]
            if !customArgs.isEmpty {
                args.append("--args")
                args.append(contentsOf: customArgs)
            }
            return VAmigaProcessInvocation(executablePath: "/usr/bin/open", arguments: args)
        }

        return VAmigaProcessInvocation(
            executablePath: executablePath,
            arguments: buildVAmigaArguments(config: config, scriptPath: scriptPath)
        )
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

        let script = """
        # AmigaPlayground vAmiga CPU trace bootstrap
        # Trace file target: \(tracePath)
        # The validation path opens this RetroShell script as the vAmiga document.
        # It explicitly inserts the generated ADF into DF0 and starts execution,
        # which is more reliable than opening an ADF document and relying on the
        # previous desktop power/run state.
        \(romBootstrap)
        try df0 connect
        try df0 insert \(retroShellQuotedPath(config.adfPath))
        try amiga power on
        try amiga run
        try power on
        try run
        help
        config
        cpu
        regs
        disassemble
        break
        watch
        """
        try script.write(to: scriptURL, atomically: true, encoding: .utf8)
        return scriptURL.path
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

            guard fileManager.fileExists(atPath: self.defaultEmulatorPath) else {
                DispatchQueue.main.async {
                    completion(EmulatorLaunchResult(
                        success: false,
                        backend: .fsUAE,
                        message: "FS-UAE emulator not found at \(self.defaultEmulatorPath).\nPlease install it via 'brew install fs-uae' to run your ADF files.",
                        tracePath: nil
                    ))
                }
                return
            }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: self.defaultEmulatorPath)
            process.arguments = self.buildFSUAEArguments(config: config)

            do {
                try process.run()
                DispatchQueue.main.async {
                    completion(EmulatorLaunchResult(
                        success: true,
                        backend: .fsUAE,
                        message: "Successfully launched FS-UAE with Amiga \(config.model), CPU \(config.cpu), Chip RAM \(config.chipRamMb), Fast RAM \(config.fastRamMb), JIT: \(config.jit ? "Enabled" : "Disabled").",
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
                        message: "Successfully launched vAmiga Desktop through the app bundle with an explicit RetroShell validation script.\nTrace output will be captured at:\n\(tracePath)\n\nRetroShell script:\n\(scriptPath)",
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

    func resolveRomPathForValidation(_ relativePath: String) -> String? {
        resolveRomPath(relativePath)
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
