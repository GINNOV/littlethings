import Cocoa
import Foundation

// MARK: - CLI & Droplet Main Entry Point
func runMain() {
    let args = CommandLine.arguments
    
    if args.contains("-h") || args.contains("--help") {
        print("""
        🕹️ AmigaLoginScreen - Zero-Dependency Amiga Wallpaper & Lock Screen Droplet / CLI
        
        Usage:
          AmigaLoginScreen                          Launch interactive droplet dialog
          AmigaLoginScreen <file_path_or_url>       Format & apply specified image or GIF
          AmigaLoginScreen --preset <1.3|2.0|3.1>   Apply classic Kickstart preset (100% offline)
          AmigaLoginScreen --help, -h               Show this help message
        
        Supported Formats:
          PNG, JPEG, GIF (animated or static), WebP, TIFF, BMP, HEIC
        
        Features:
          • Preserves crisp pixel art without bilinear blur
          • Automatic background color detection from image corners
          • Built-in offline embedded presets for Kickstart 1.3, 2.04, and 3.1
          • Retina display & multi-monitor support
          • macOS Droplet drag-and-drop support
        """)
        exit(0)
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
        
        print("🖥️ Processing embedded preset \(p.displayName)...")
        let semaphore = DispatchSemaphore(value: 0)
        WallpaperEngine.processAndApply(data: data) { result in
            switch result {
            case .success(let outputURL):
                print("✅ Success! Wallpaper and lockscreen updated with \(p.displayName).")
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
        
        print("🖥️ Processing image from: \(url.path)...")
        let semaphore = DispatchSemaphore(value: 0)
        WallpaperEngine.processAndApply(sourceURL: url) { result in
            switch result {
            case .success(let outputURL):
                print("✅ Success! Wallpaper and lockscreen updated.")
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
