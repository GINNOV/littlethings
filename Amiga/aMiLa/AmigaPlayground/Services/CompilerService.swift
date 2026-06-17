import Foundation

class CompilerService {
    static let shared = CompilerService()
    private static let toolTimeout: TimeInterval = 10
    
    let vasmPath = CompilerService.resolveVasmPath()
    let ndkInclude = CompilerService.resolveRepoPath("Dataset/corpus3/amiga-dev/targets/m68k-amigaos/ndk/include_i")
    
    func compile(assemblyCode: String, completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tempDir = FileManager.default.temporaryDirectory
            let sourceFile = tempDir.appendingPathComponent("playground_source.s")
            let outputFile = tempDir.appendingPathComponent("playground_bin")
            
            do {
                let normalizedAssemblyCode = AssemblySourceFormatter.vasmReadySource(from: assemblyCode)
                try normalizedAssemblyCode.write(to: sourceFile, atomically: true, encoding: .utf8)
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Failed to write source code to temp file: \(error.localizedDescription)")
                }
                return
            }
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: self.vasmPath)
            process.arguments = [
                "-kick1hunks",
                "-Fhunkexe",
                "-I\(self.ndkInclude)",
                "-o", outputFile.path,
                "-nosym",
                sourceFile.path
            ]
            
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            
            do {
                try process.run()
                let timedOut = !Self.waitForProcess(process, timeout: Self.toolTimeout)
                if timedOut {
                    process.terminate()
                    _ = Self.waitForProcess(process, timeout: 1)
                }
                
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                
                let outputStr = String(data: outputData, encoding: .utf8) ?? ""
                let errorStr = String(data: errorData, encoding: .utf8) ?? ""
                
                let fullOutput = (outputStr + "\n" + errorStr).trimmingCharacters(in: .whitespacesAndNewlines)
                let success = !timedOut && process.terminationStatus == 0
                let diagnostic = timedOut
                    ? "vasm timed out after \(Int(Self.toolTimeout))s\n\(fullOutput)"
                    : fullOutput
                
                // Cleanup
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: outputFile)
                
                DispatchQueue.main.async {
                    completion(success, diagnostic)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Failed to execute vasm: \(error.localizedDescription)\nChecked: /usr/local/bin/vasmm68k_mot, /opt/homebrew/bin/vasmm68k_mot, /usr/local/bin/vasm, /opt/homebrew/bin/vasm.")
                }
            }
        }
    }
    
    let xdftoolPath = CompilerService.resolveRepoPath("fine_tuning/.venv/bin/xdftool")

    func generateBootableADF(assemblyCode: String, targetADFPath: String, completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tempDir = FileManager.default.temporaryDirectory
            let sourceFile = tempDir.appendingPathComponent("playground_source.s")
            let outputFile = tempDir.appendingPathComponent("playground_bin")
            let startupFile = tempDir.appendingPathComponent("test_startup")
            
            // 1. Write assembly source code
            do {
                let normalizedAssemblyCode = AssemblySourceFormatter.vasmReadySource(from: assemblyCode)
                try normalizedAssemblyCode.write(to: sourceFile, atomically: true, encoding: .utf8)
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Failed to write temp source code: \(error.localizedDescription)")
                }
                return
            }
            
            // 2. Run VASM compiler to compile to playground_bin
            let vasmProcess = Process()
            vasmProcess.executableURL = URL(fileURLWithPath: self.vasmPath)
            vasmProcess.arguments = [
                "-kick1hunks",
                "-Fhunkexe",
                "-I\(self.ndkInclude)",
                "-o", outputFile.path,
                "-nosym",
                sourceFile.path
            ]
            
            let vasmErrorPipe = Pipe()
            vasmProcess.standardError = vasmErrorPipe
            let vasmOutputPipe = Pipe()
            vasmProcess.standardOutput = vasmOutputPipe
            
            do {
                try vasmProcess.run()
                let timedOut = !Self.waitForProcess(vasmProcess, timeout: Self.toolTimeout)
                if timedOut {
                    vasmProcess.terminate()
                    _ = Self.waitForProcess(vasmProcess, timeout: 1)
                }
                
                let errorData = vasmErrorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorStr = String(data: errorData, encoding: .utf8) ?? ""
                let outputData = vasmOutputPipe.fileHandleForReading.readDataToEndOfFile()
                let outputStr = String(data: outputData, encoding: .utf8) ?? ""
                
                if timedOut || vasmProcess.terminationStatus != 0 {
                    try? FileManager.default.removeItem(at: sourceFile)
                    DispatchQueue.main.async {
                        let prefix = timedOut ? "Assembly compilation timed out after \(Int(Self.toolTimeout))s:" : "Assembly compilation failed:"
                        completion(false, "\(prefix)\n\(errorStr)\n\(outputStr)")
                    }
                    return
                }
            } catch {
                try? FileManager.default.removeItem(at: sourceFile)
                DispatchQueue.main.async {
                    completion(false, "Failed to execute vasm compiler: \(error.localizedDescription)")
                }
                return
            }
            
            // 3. Write standard startup-sequence text
            let startupSequenceContent = "playground_bin\n"
            do {
                try startupSequenceContent.write(to: startupFile, atomically: true, encoding: .utf8)
            } catch {
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: outputFile)
                DispatchQueue.main.async {
                    completion(false, "Failed to write startup-sequence file: \(error.localizedDescription)")
                }
                return
            }
            
            // 4. Create and format ADF using xdftool
            // Remove existing ADF if it exists at targetADFPath
            try? FileManager.default.removeItem(atPath: targetADFPath)
            
            let xdfProcess = Process()
            xdfProcess.executableURL = URL(fileURLWithPath: self.xdftoolPath)
            xdfProcess.arguments = [
                targetADFPath,
                "create",
                "+", "format", "Playground",
                "+", "boot", "install",
                "+", "makedir", "s",
                "+", "write", startupFile.path, "s/startup-sequence",
                "+", "write", outputFile.path, "playground_bin"
            ]
            
            let xdfErrorPipe = Pipe()
            xdfProcess.standardError = xdfErrorPipe
            let xdfOutputPipe = Pipe()
            xdfProcess.standardOutput = xdfOutputPipe
            
            do {
                try xdfProcess.run()
                let timedOut = !Self.waitForProcess(xdfProcess, timeout: Self.toolTimeout)
                if timedOut {
                    xdfProcess.terminate()
                    _ = Self.waitForProcess(xdfProcess, timeout: 1)
                }
                
                let errorData = xdfErrorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorStr = String(data: errorData, encoding: .utf8) ?? ""
                let outputData = xdfOutputPipe.fileHandleForReading.readDataToEndOfFile()
                let outputStr = String(data: outputData, encoding: .utf8) ?? ""
                
                // Cleanup temp files
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: outputFile)
                try? FileManager.default.removeItem(at: startupFile)
                
                if !timedOut && xdfProcess.terminationStatus == 0 {
                    DispatchQueue.main.async {
                        completion(true, "Successfully generated bootable ADF disk image at:\n\(targetADFPath)\n\nMount this disk in your Amiga emulator (e.g. FS-UAE / WinUAE) to boot and run your compiled assembly program instantly!")
                    }
                } else {
                    DispatchQueue.main.async {
                        let prefix = timedOut ? "xdftool timed out after \(Int(Self.toolTimeout))s:" : "xdftool failed to generate ADF:"
                        completion(false, "\(prefix)\n\(errorStr)\n\(outputStr)")
                    }
                }
            } catch {
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: outputFile)
                try? FileManager.default.removeItem(at: startupFile)
                DispatchQueue.main.async {
                    completion(false, "Failed to run xdftool process: \(error.localizedDescription)")
                }
            }
        }
    }

    private static func waitForProcess(_ process: Process, timeout: TimeInterval) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        let previousTerminationHandler = process.terminationHandler
        process.terminationHandler = { terminatedProcess in
            previousTerminationHandler?(terminatedProcess)
            semaphore.signal()
        }

        if !process.isRunning {
            return true
        }
        return semaphore.wait(timeout: .now() + timeout) == .success
    }

    private static func resolveVasmPath() -> String {
        let candidates = [
            "/usr/local/bin/vasmm68k_mot",
            "/opt/homebrew/bin/vasmm68k_mot",
            "/usr/local/bin/vasm",
            "/opt/homebrew/bin/vasm"
        ]

        return candidates.first { FileManager.default.isExecutableFile(atPath: $0) } ?? candidates[0]
    }

    private static func resolveRepoPath(_ relativePath: String) -> String {
        let sourceFile = URL(fileURLWithPath: #filePath)
        let repoRoot = sourceFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let repoPath = repoRoot.appendingPathComponent(relativePath).path

        if FileManager.default.fileExists(atPath: repoPath) {
            return repoPath
        }

        return relativePath
    }
}
