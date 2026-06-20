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
    
    let xdftoolPath = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/.venv/bin/xdftool"

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
                xdfProcess.waitUntilExit()
                
                let errorData = xdfErrorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorStr = String(data: errorData, encoding: .utf8) ?? ""
                let outputData = xdfOutputPipe.fileHandleForReading.readDataToEndOfFile()
                let outputStr = String(data: outputData, encoding: .utf8) ?? ""
                
                // Cleanup temp files
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: outputFile)
                try? FileManager.default.removeItem(at: startupFile)
                
                if xdfProcess.terminationStatus == 0 {
                    DispatchQueue.main.async {
                        completion(true, "Successfully generated bootable ADF disk image at:\n\(targetADFPath)\n\nMount this disk in your Amiga emulator (e.g. FS-UAE / WinUAE) to boot and run your compiled assembly program instantly!")
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, "xdftool failed to generate ADF:\n\(errorStr)\n\(outputStr)")
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
}
