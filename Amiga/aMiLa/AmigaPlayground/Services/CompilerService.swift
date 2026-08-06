import Foundation

class CompilerService {
    static let shared = CompilerService()
    
    let vasmPath = "/usr/local/bin/vasmm68k_mot"
    let ndkInclude = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/Dataset/corpus3/amiga-dev/targets/m68k-amigaos/ndk/include_i"
    
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
                process.waitUntilExit()
                
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                
                let outputStr = String(data: outputData, encoding: .utf8) ?? ""
                let errorStr = String(data: errorData, encoding: .utf8) ?? ""
                
                let fullOutput = (outputStr + "\n" + errorStr).trimmingCharacters(in: .whitespacesAndNewlines)
                let success = (process.terminationStatus == 0)
                
                // Cleanup
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: outputFile)
                
                DispatchQueue.main.async {
                    completion(success, fullOutput)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Failed to execute vasm: \(error.localizedDescription)\nEnsure /usr/local/bin/vasmm68k_mot is installed.")
                }
            }
        }
    }
    
    var send2adfPath: String {
        let candidatePaths = [
            "/usr/local/bin/send2adf",
            "/Volumes/AIWork/code/littlethings/Amiga/Tools/send2adf/build/ci/send2adf",
            "/Volumes/AIWork/code/littlethings/Amiga/Tools/send2adf/build/send2adf"
        ]
        for path in candidatePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return "/usr/local/bin/send2adf"
    }

    func generateBootableADF(assemblyCode: String, targetADFPath: String, completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let tempDir = FileManager.default.temporaryDirectory
            let sourceFile = tempDir.appendingPathComponent("playground_source.s")
            let outputFile = tempDir.appendingPathComponent("playground_bin")
            
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
                vasmProcess.waitUntilExit()
                
                let errorData = vasmErrorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorStr = String(data: errorData, encoding: .utf8) ?? ""
                let outputData = vasmOutputPipe.fileHandleForReading.readDataToEndOfFile()
                let outputStr = String(data: outputData, encoding: .utf8) ?? ""
                
                if vasmProcess.terminationStatus != 0 {
                    try? FileManager.default.removeItem(at: sourceFile)
                    DispatchQueue.main.async {
                        completion(false, "Assembly compilation failed:\n\(errorStr)\n\(outputStr)")
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
            
            // 3. Create staging directory for send2adf (s/startup-sequence and playground_bin)
            let stagingDir = tempDir.appendingPathComponent(UUID().uuidString)
            let sDir = stagingDir.appendingPathComponent("s")
            let startupFile = sDir.appendingPathComponent("startup-sequence")
            let stagingBinFile = stagingDir.appendingPathComponent("playground_bin")
            
            do {
                try FileManager.default.createDirectory(at: sDir, withIntermediateDirectories: true, attributes: nil)
                let startupSequenceContent = "playground_bin\n"
                try startupSequenceContent.write(to: startupFile, atomically: true, encoding: .utf8)
                try FileManager.default.copyItem(at: outputFile, to: stagingBinFile)
            } catch {
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: outputFile)
                try? FileManager.default.removeItem(at: stagingDir)
                DispatchQueue.main.async {
                    completion(false, "Failed to prepare staging directory for send2adf: \(error.localizedDescription)")
                }
                return
            }
            
            // 4. Create and format ADF using send2adf
            // Resolve canonical paths using realpath for POSIX O_NOFOLLOW compatibility with send2adf
            let resolvedTargetADFPath = self.canonicalPath(for: targetADFPath)
            try? FileManager.default.removeItem(atPath: resolvedTargetADFPath)
            
            let resolvedSDirPath = self.canonicalDirectoryPath(for: sDir.path)
            let resolvedStagingBinPath = self.canonicalPath(for: stagingBinFile.path)
            
            let send2adfProcess = Process()
            send2adfProcess.executableURL = URL(fileURLWithPath: self.send2adfPath)
            send2adfProcess.arguments = [
                "-o", resolvedTargetADFPath,
                "-N", "Playground",
                "-B", "1.3",
                resolvedSDirPath,
                resolvedStagingBinPath
            ]
            
            let send2adfErrorPipe = Pipe()
            send2adfProcess.standardError = send2adfErrorPipe
            let send2adfOutputPipe = Pipe()
            send2adfProcess.standardOutput = send2adfOutputPipe
            
            do {
                try send2adfProcess.run()
                send2adfProcess.waitUntilExit()
                
                let errorData = send2adfErrorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorStr = String(data: errorData, encoding: .utf8) ?? ""
                let outputData = send2adfOutputPipe.fileHandleForReading.readDataToEndOfFile()
                let outputStr = String(data: outputData, encoding: .utf8) ?? ""
                
                // Cleanup temp files
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: outputFile)
                try? FileManager.default.removeItem(at: stagingDir)
                
                if send2adfProcess.terminationStatus == 0 {
                    DispatchQueue.main.async {
                        completion(true, "Successfully generated bootable ADF disk image at:\n\(resolvedTargetADFPath)\n\nMount this disk in your Amiga emulator (e.g. FS-UAE / WinUAE) to boot and run your compiled assembly program instantly!")
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, "send2adf failed to generate ADF:\n\(errorStr)\n\(outputStr)")
                    }
                }
            } catch {
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: outputFile)
                try? FileManager.default.removeItem(at: stagingDir)
                DispatchQueue.main.async {
                    completion(false, "Failed to run send2adf process: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func canonicalPath(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let parentDir = url.deletingLastPathComponent().path
        if let realParent = realpath(parentDir, nil) {
            let realParentPath = String(cString: realParent)
            free(realParent)
            return (realParentPath as NSString).appendingPathComponent(url.lastPathComponent)
        }
        return path
    }
    
    private func canonicalDirectoryPath(for path: String) -> String {
        if let realDir = realpath(path, nil) {
            let realDirPath = String(cString: realDir)
            free(realDir)
            return realDirPath
        }
        return path
    }
}
