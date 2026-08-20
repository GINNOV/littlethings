import Cocoa
import Foundation

// MARK: - CLI & Droplet Main Entry Point
func runMain() {
    let args = CommandLine.arguments
    
    if args.contains("-h") || args.contains("--help") {
        print("""
        🕹️ AmigaLoginScreen - Zero-Dependency Amiga Wallpaper & Lock Screen Droplet / CLI
        
        Usage:
          AmigaLoginScreen                                Launch interactive droplet dialog
          AmigaLoginScreen <file_path_or_url>             Format & apply specified image or GIF
          AmigaLoginScreen --preset <1.3|2.0|3.1>         Apply classic Kickstart preset (100% offline)
          AmigaLoginScreen --target <lockscreen|desktop|both>  Choose target (default: lockscreen)
          AmigaLoginScreen --help, -h                     Show this help message
        
        Supported Formats:
          PNG, JPEG, GIF (animated or static), WebP, TIFF, BMP, HEIC
        
        Features:
          • Choose target: Lock Screen only (default), Desktop only, or Both
          • Preserves crisp pixel art without bilinear blur
          • Multi-frame animated GIF preservation
          • Automatic background color detection from image corners
          • Built-in offline embedded presets for Kickstart 1.3, 2.04, and 3.1
          • Retina display & multi-monitor support
          • macOS Droplet drag-and-drop support
        """)
        exit(0)
    }
    
    // Parse target mode (defaults to lockscreen)
    var targetMode = SettingsManager.targetMode
    if let targetIdx = args.firstIndex(of: "--target") ?? args.firstIndex(of: "-t"), targetIdx + 1 < args.count {
        let val = args[targetIdx + 1].lowercased()
        if let mode = WallpaperTargetMode(rawValue: val) {
            targetMode = mode
            SettingsManager.targetMode = mode
        } else {
            print("⚠️ Unknown target '\(val)'. Using '\(targetMode.rawValue)'. Valid: lockscreen, desktop, both")
        }
    }
    
    if let presetIdx = args.firstIndex(of: "--preset"), presetIdx + 1 < args.count {
        let presetVal = args[presetIdx + 1]
        let preset: KickstartPreset?
        switch presetVal {
        case "1.3": preset = .ks13
        case "2.0", "2.04": preset = .ks20
        case "3.1": preset = .ks31
        default: preset = nil
        }
        
        guard let p = preset, let data = p.loadData() else {
            print("❌ Unknown preset or failed to load data for: \(presetVal). Options: 1.3, 2.0, 3.1")
            exit(1)
        }
        
        print("🖥️ Processing embedded preset \(p.displayName) for \(targetMode.targetDescription)...")
        let semaphore = DispatchSemaphore(value: 0)
        WallpaperEngine.processAndApply(data: data, mode: targetMode) { result in
            switch result {
            case .success(let outputURL):
                print("✅ Success! Set \(p.displayName) as your \(targetMode.targetDescription).")
                print("📁 Saved output to: \(outputURL.path)")
            case .failure(let error):
                print("❌ Error: \(error.localizedDescription)")
            }
            semaphore.signal()
        }
        semaphore.wait()
        exit(0)
    } else if args.count > 1 && !args[1].starts(with: "-") {
        let input = args[1]
        let url: URL
        if input.starts(with: "http://") || input.starts(with: "https://") {
            url = URL(string: input)!
        } else {
            url = URL(fileURLWithPath: input)
        }
        
        print("🖥️ Processing image from: \(url.path) for \(targetMode.targetDescription)...")
        let semaphore = DispatchSemaphore(value: 0)
        WallpaperEngine.processAndApply(sourceURL: url, mode: targetMode) { result in
            switch result {
            case .success(let outputURL):
                print("✅ Success! Updated \(targetMode.targetDescription).")
                print("📁 Saved output to: \(outputURL.path)")
            case .failure(let error):
                print("❌ Error: \(error.localizedDescription)")
            }
            semaphore.signal()
        }
        semaphore.wait()
        exit(0)
    }
    
    // Launch Cocoa App Droplet GUI
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
}

runMain()
