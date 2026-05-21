import Foundation

class EmulatorService {
    static let shared = EmulatorService()
    
    var romsDirectory: String {
        return UserDefaults.standard.string(forKey: "romsDirectoryPath") ?? "/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware"
    }
    let defaultEmulatorPath = "/opt/homebrew/bin/fs-uae"
    
    func getAvailableRoms() -> [String] {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: romsDirectory) else {
            return []
        }
        // Filter for ROM and zip firmware files, excluding dotfiles
        return files.filter { file in
            let lower = file.lowercased()
            return (lower.hasSuffix(".rom") || lower.hasSuffix(".zip")) && !lower.hasPrefix(".")
        }.sorted()
    }
    
    func launchEmulator(adfPath: String, romFilename: String, model: String, chipRamMb: String, fastRamMb: String, cpu: String, jit: Bool, customArgs: String, completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            
            // Check if emulator exists
            guard fileManager.fileExists(atPath: self.defaultEmulatorPath) else {
                DispatchQueue.main.async {
                    completion(false, "FS-UAE emulator not found at \(self.defaultEmulatorPath).\nPlease install it via 'brew install fs-uae' to run your ADF files.")
                }
                return
            }
            
            // Map memory sizes from MB strings to KB values for FS-UAE arguments
            let chipMemKb = self.mapRamToKb(ramStr: chipRamMb, isChip: true)
            let fastMemKb = self.mapRamToKb(ramStr: fastRamMb, isChip: false)
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: self.defaultEmulatorPath)
            
            var args = [
                "--floppy_drive_0=\(adfPath)",
                "--amiga_model=\(model)",
                "--chip_memory=\(chipMemKb)",
                "--fast_memory=\(fastMemKb)",
                "--cpu=\(cpu)",
                "--jit=\(jit ? "1" : "0")"
            ]
            
            // Append custom Kickstart ROM if specified
            if !romFilename.isEmpty {
                let romPath = "\(self.romsDirectory)/\(romFilename)"
                if fileManager.fileExists(atPath: romPath) {
                    args.append("--kickstart_file=\(romPath)")
                }
            }
            
            // Append any custom command-line arguments the user specified in the settings dialog
            if !customArgs.trimmingCharacters(in: .whitespaces).isEmpty {
                let extraArgs = customArgs.components(separatedBy: " ").filter { !$0.isEmpty }
                args.append(contentsOf: extraArgs)
            }
            
            process.arguments = args
            
            do {
                try process.run()
                DispatchQueue.main.async {
                    completion(true, "Successfully launched FS-UAE with Amiga \(model), CPU \(cpu), Chip RAM \(chipRamMb), Fast RAM \(fastRamMb), JIT: \(jit ? "Enabled" : "Disabled").")
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Failed to execute FS-UAE emulator process: \(error.localizedDescription)")
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
}
