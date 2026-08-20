import Cocoa
import Foundation
import ImageIO
import CoreGraphics

// MARK: - Constants & Presets
public enum KickstartPreset: String, CaseIterable {
    case ks13 = "1.3"
    case ks20 = "2.0"
    case ks31 = "3.1"
    
    public var displayName: String {
        switch self {
        case .ks13: return "Kickstart 1.3"
        case .ks20: return "Kickstart 2.04"
        case .ks31: return "Kickstart 3.1"
        }
    }
    
    public var resourceName: String {
        switch self {
        case .ks13: return "kickstart13"
        case .ks20: return "kickstart20"
        case .ks31: return "kickstart31"
        }
    }
    
    /// Returns the preset data directly from embedded memory or local bundle
    public func loadData() -> Data? {
        // 1. Try embedded binary memory
        if let data = EmbeddedPresets.getData(for: resourceName) {
            return data
        }
        
        // 2. Check in App Bundle Resources / Presets
        if let bundleURL = Bundle.main.url(forResource: resourceName, withExtension: "png", subdirectory: "Presets"),
           let data = try? Data(contentsOf: bundleURL) {
            return data
        }
        if let bundleURL = Bundle.main.url(forResource: resourceName, withExtension: "png"),
           let data = try? Data(contentsOf: bundleURL) {
            return data
        }
        
        // 3. Check next to executable
        let exeDir = Bundle.main.bundleURL.deletingLastPathComponent()
        let localPresetURL = exeDir.appendingPathComponent("Presets/\(resourceName).png")
        if let data = try? Data(contentsOf: localPresetURL) {
            return data
        }
        
        return nil
    }
}

// MARK: - Image & Wallpaper Processor
public class WallpaperEngine {
    
    public static var outputDir: URL {
        let pictures = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        let dir = pictures.appendingPathComponent("AmigaLockScreen", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        return dir
    }
    
    /// Process from Data directly (in-memory, embedded presets)
    public static func processAndApply(data: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                    throw NSError(domain: "AmigaLoginScreen", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to parse image data from memory."])
                }
                
                let processedURL = try renderWallpaperFromSource(imageSource: imageSource)
                try applyWallpaper(imageURL: processedURL)
                completion(.success(processedURL))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Process an image from local file URL or download from web URL
    public static func processAndApply(sourceURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var localURL = sourceURL
                if sourceURL.scheme == "http" || sourceURL.scheme == "https" {
                    localURL = try downloadImageSynchronously(from: sourceURL)
                }
                
                guard let imageSource = CGImageSourceCreateWithURL(localURL as CFURL, nil) else {
                    throw NSError(domain: "AmigaLoginScreen", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to read image at \(localURL.path)"])
                }
                
                let processedURL = try renderWallpaperFromSource(imageSource: imageSource)
                try applyWallpaper(imageURL: processedURL)
                completion(.success(processedURL))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Synchronous HTTP download with browser User-Agent
    private static func downloadImageSynchronously(from url: URL) throws -> URL {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("image/png,image/jpeg,image/*;q=0.8", forHTTPHeaderField: "Accept")
        
        var downloadedData: Data?
        var downloadError: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                downloadError = error
            } else if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                downloadError = NSError(
                    domain: "AmigaLoginScreen",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP download returned status \(httpResponse.statusCode) for \(url.absoluteString)"]
                )
            } else {
                downloadedData = data
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        if let error = downloadError {
            throw error
        }
        guard let data = downloadedData, !data.isEmpty else {
            throw NSError(domain: "AmigaLoginScreen", code: 404, userInfo: [NSLocalizedDescriptionKey: "Received empty response from \(url.absoluteString)"])
        }
        
        let filename = url.lastPathComponent.isEmpty ? "downloaded_image.png" : url.lastPathComponent
        let destinationURL = outputDir.appendingPathComponent(filename)
        try data.write(to: destinationURL)
        return destinationURL
    }
    
    /// Reads CGImageSource, detects background color, pads to screen resolution (supports multi-frame animated GIFs)
    public static func renderWallpaperFromSource(imageSource: CGImageSource) throws -> URL {
        let frameCount = CGImageSourceGetCount(imageSource)
        guard frameCount > 0 else {
            throw NSError(domain: "AmigaLoginScreen", code: 2, userInfo: [NSLocalizedDescriptionKey: "Image contains no valid frames."])
        }
        
        // Select primary frame for background color detection and sizing
        let primaryIndex = frameCount > 1 ? min(1, frameCount - 1) : 0
        guard let firstFrame = CGImageSourceCreateImageAtIndex(imageSource, primaryIndex, nil) ?? CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw NSError(domain: "AmigaLoginScreen", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to extract image frame."])
        }
        
        let imgWidth = firstFrame.width
        let imgHeight = firstFrame.height
        
        // Sample border/background color from corner pixels
        let bgColor = detectBackgroundColor(cgImage: firstFrame)
        
        // Determine target screen resolution
        let (targetWidth, targetHeight) = getTargetResolution()
        
        // Calculate scaling (fill screen with nearest-neighbor integer multiplier)
        let scale: CGFloat
        if CGFloat(imgWidth) > CGFloat(targetWidth) || CGFloat(imgHeight) > CGFloat(targetHeight) {
            scale = min(CGFloat(targetWidth) / CGFloat(imgWidth), CGFloat(targetHeight) / CGFloat(imgHeight))
        } else {
            scale = max(1.0, floor(min(CGFloat(targetWidth) / CGFloat(imgWidth), CGFloat(targetHeight) / CGFloat(imgHeight))))
        }
        
        let drawWidth = CGFloat(imgWidth) * scale
        let drawHeight = CGFloat(imgHeight) * scale
        let drawX = round((CGFloat(targetWidth) - drawWidth) / 2.0)
        let drawY = round((CGFloat(targetHeight) - drawHeight) / 2.0)
        let drawRect = CGRect(x: drawX, y: drawY, width: drawWidth, height: drawHeight)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let outDir = outputDir
        try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true, attributes: nil)
        
        // Handle Multi-Frame Animated GIFs
        if frameCount > 1 {
            let outputGIFURL = outDir.appendingPathComponent("amiga_lockscreen.gif")
            let fileProperties = CGImageSourceCopyProperties(imageSource, nil) as? [CFString: Any]
            let gifFileProps = fileProperties?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
            let loopCount = gifFileProps?[kCGImagePropertyGIFLoopCount] as? Int ?? 0
            
            let destProps: [CFString: Any] = [
                kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFLoopCount: loopCount
                ]
            ]
            
            guard let destination = CGImageDestinationCreateWithURL(outputGIFURL as CFURL, "com.compuserve.gif" as CFString, frameCount, nil) else {
                throw NSError(domain: "AmigaLoginScreen", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to create animated GIF destination."])
            }
            CGImageDestinationSetProperties(destination, destProps as CFDictionary)
            
            var primaryRenderedImage: CGImage?
            
            for i in 0..<frameCount {
                guard let frameCG = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else { continue }
                let frameProps = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) as? [CFString: Any]
                let gifFrameProps = frameProps?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
                
                guard let context = CGContext(
                    data: nil,
                    width: targetWidth,
                    height: targetHeight,
                    bitsPerComponent: 8,
                    bytesPerRow: targetWidth * 4,
                    space: colorSpace,
                    bitmapInfo: bitmapInfo.rawValue
                ) else { continue }
                
                context.interpolationQuality = .none
                context.setFillColor(bgColor)
                context.fill(CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
                context.draw(frameCG, in: drawRect)
                
                if let outputFrame = context.makeImage() {
                    if i == primaryIndex {
                        primaryRenderedImage = outputFrame
                    }
                    var frameDestProps: [CFString: Any] = [:]
                    if let props = gifFrameProps {
                        frameDestProps[kCGImagePropertyGIFDictionary] = props
                    }
                    CGImageDestinationAddImage(destination, outputFrame, frameDestProps as CFDictionary)
                }
            }
            
            guard CGImageDestinationFinalize(destination) else {
                throw NSError(domain: "AmigaLoginScreen", code: 7, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize animated GIF."])
            }
            try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: outputGIFURL.path)
            
            // Also generate static PNG fallback for lockscreen
            if let staticCG = primaryRenderedImage {
                let staticPNGURL = outDir.appendingPathComponent("amiga_lockscreen.png")
                if let pngDest = CGImageDestinationCreateWithURL(staticPNGURL as CFURL, "public.png" as CFString, 1, nil) {
                    CGImageDestinationAddImage(pngDest, staticCG, nil)
                    CGImageDestinationFinalize(pngDest)
                    try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: staticPNGURL.path)
                }
            }
            
            return outputGIFURL
        }
        
        // Single Frame (Static Image)
        guard let context = CGContext(
            data: nil,
            width: targetWidth,
            height: targetHeight,
            bitsPerComponent: 8,
            bytesPerRow: targetWidth * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            throw NSError(domain: "AmigaLoginScreen", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to create graphics context."])
        }
        
        context.interpolationQuality = .none
        context.setFillColor(bgColor)
        context.fill(CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
        context.draw(firstFrame, in: drawRect)
        
        guard let outputCGImage = context.makeImage() else {
            throw NSError(domain: "AmigaLoginScreen", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to render target image."])
        }
        
        let outputURL = outDir.appendingPathComponent("amiga_lockscreen.png")
        guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, "public.png" as CFString, 1, nil) else {
            throw NSError(domain: "AmigaLoginScreen", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to create destination PNG file at \(outputURL.path)"])
        }
        
        CGImageDestinationAddImage(destination, outputCGImage, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "AmigaLoginScreen", code: 7, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize and save PNG."])
        }
        
        try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: outputURL.path)
        return outputURL
    }
    
    /// Sample corner pixels to find the predominant border color
    public static func detectBackgroundColor(cgImage: CGImage) -> CGColor {
        let w = cgImage.width
        let h = cgImage.height
        let defaultAmigaBlue = CGColor(red: 0.0, green: 85.0/255.0, blue: 170.0/255.0, alpha: 1.0)
        
        guard let pixelData = cgImage.dataProvider?.data,
              let data = CFDataGetBytePtr(pixelData) else {
            return defaultAmigaBlue
        }
        
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        
        let samplePoints: [(Int, Int)] = [
            (2, 2),
            (max(0, w - 3), 2),
            (2, max(0, h - 3)),
            (max(0, w - 3), max(0, h - 3))
        ]
        
        var rTotal: CGFloat = 0
        var gTotal: CGFloat = 0
        var bTotal: CGFloat = 0
        var validCount: CGFloat = 0
        
        for (x, y) in samplePoints {
            let offset = y * bytesPerRow + x * bytesPerPixel
            if offset + 2 < CFDataGetLength(pixelData) {
                let r = CGFloat(data[offset]) / 255.0
                let g = CGFloat(data[offset + 1]) / 255.0
                let b = CGFloat(data[offset + 2]) / 255.0
                rTotal += r
                gTotal += g
                bTotal += b
                validCount += 1
            }
        }
        
        if validCount > 0 {
            return CGColor(red: rTotal / validCount, green: gTotal / validCount, blue: bTotal / validCount, alpha: 1.0)
        }
        
        return defaultAmigaBlue
    }
    
    /// Gets main screen native resolution
    public static func getTargetResolution() -> (Int, Int) {
        if let mainScreen = NSScreen.main {
            let frame = mainScreen.frame
            let scale = mainScreen.backingScaleFactor
            let w = Int(frame.width * scale)
            let h = Int(frame.height * scale)
            if w > 0 && h > 0 {
                return (w, h)
            }
        }
        return (2560, 1440)
    }
    
    /// Applies wallpaper to all screens via NSWorkspace and System Events for lockscreen synchronization
    public static func applyWallpaper(imageURL: URL) throws {
        for screen in NSScreen.screens {
            try? NSWorkspace.shared.setDesktopImageURL(imageURL, for: screen, options: [:])
        }
        
        let posixPath = imageURL.path.replacingOccurrences(of: "\"", with: "\\\"")
        let scriptSource = """
        tell application "System Events"
            tell every desktop
                set picture to "\(posixPath)"
            end tell
        end tell
        """
        
        if let appleScript = NSAppleScript(source: scriptSource) {
            var errorInfo: NSDictionary?
            appleScript.executeAndReturnError(&errorInfo)
        }
    }
}

// MARK: - Notifications & UI Helpers
public class UIHelper {
    public static func sendNotification(title: String, subtitle: String, message: String) {
        let script = """
        display notification "\(message)" with title "\(title)" subtitle "\(subtitle)" sound name "Glass"
        """
        if let appleScript = NSAppleScript(source: script) {
            var err: NSDictionary?
            appleScript.executeAndReturnError(&err)
        }
    }
    
    public static func showAlert(title: String, message: String, isError: Bool = false) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = isError ? .critical : .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - App Delegate (Droplet Mode)
public class AppDelegate: NSObject, NSApplicationDelegate {
    
    public var processedFilesCount = 0
    public var isHandlingOpenFiles = false
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !self.isHandlingOpenFiles && self.processedFilesCount == 0 {
                self.showInteractiveMenu()
            }
        }
    }
    
    public func application(_ sender: NSApplication, openFiles filenames: [String]) {
        isHandlingOpenFiles = true
        guard let firstFile = filenames.first else {
            NSApp.terminate(nil)
            return
        }
        
        let fileURL = URL(fileURLWithPath: firstFile)
        WallpaperEngine.processAndApply(sourceURL: fileURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outputURL):
                    self.processedFilesCount += 1
                    UIHelper.sendNotification(
                        title: "AmigaLoginScreen",
                        subtitle: "Lock Screen & Wallpaper Updated!",
                        message: "Applied image from \(fileURL.lastPathComponent)"
                    )
                    print("Successfully applied: \(outputURL.path)")
                case .failure(let error):
                    UIHelper.showAlert(
                        title: "AmigaLoginScreen Error",
                        message: "Failed to process image: \(error.localizedDescription)",
                        isError: true
                    )
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    NSApp.terminate(nil)
                }
            }
        }
    }
    
    public func showInteractiveMenu() {
        NSApp.activate(ignoringOtherApps: true)
        
        let alert = NSAlert()
        alert.messageText = "🕹️ Amiga Login Screen & Wallpaper"
        alert.informativeText = "Choose a classic Amiga Kickstart boot screen preset, or select your own custom image / animated GIF from disk."
        
        alert.addButton(withTitle: "💾 Kickstart 1.3")
        alert.addButton(withTitle: "🟣 Kickstart 2.04")
        alert.addButton(withTitle: "🌈 Kickstart 3.1")
        alert.addButton(withTitle: "📁 Choose Image / GIF...")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        switch response {
        case .alertFirstButtonReturn:
            applyPreset(preset: .ks13)
        case .alertSecondButtonReturn:
            applyPreset(preset: .ks20)
        case .alertThirdButtonReturn:
            applyPreset(preset: .ks31)
        case NSApplication.ModalResponse(rawValue: 1003):
            promptFilePicker()
        default:
            NSApp.terminate(nil)
        }
    }
    
    public func applyPreset(preset: KickstartPreset) {
        guard let presetData = preset.loadData() else {
            UIHelper.showAlert(
                title: "Error",
                message: "Failed to load embedded \(preset.displayName) image data.",
                isError: true
            )
            NSApp.terminate(nil)
            return
        }
        
        WallpaperEngine.processAndApply(data: presetData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outputURL):
                    UIHelper.sendNotification(
                        title: "AmigaLoginScreen",
                        subtitle: "Preset Applied!",
                        message: "\(preset.displayName) is now active as your wallpaper and lock screen."
                    )
                    UIHelper.showAlert(
                        title: "Success! 💾",
                        message: "\(preset.displayName) boot screen has been centered and set as your desktop wallpaper and lock screen.\n\nFile saved to:\n\(outputURL.path)"
                    )
                case .failure(let error):
                    UIHelper.showAlert(
                        title: "Error",
                        message: "Failed to apply \(preset.displayName): \(error.localizedDescription)",
                        isError: true
                    )
                }
                NSApp.terminate(nil)
            }
        }
    }
    
    public func promptFilePicker() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select an Amiga Image or Animated GIF"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["png", "jpg", "jpeg", "gif", "webp", "tiff", "bmp", "heic"]
        
        if openPanel.runModal() == .OK, let selectedURL = openPanel.url {
            WallpaperEngine.processAndApply(sourceURL: selectedURL) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let outputURL):
                        UIHelper.sendNotification(
                            title: "AmigaLoginScreen",
                            subtitle: "Custom Image Applied!",
                            message: "Wallpaper updated from \(selectedURL.lastPathComponent)"
                        )
                        UIHelper.showAlert(
                            title: "Success! 🕹️",
                            message: "Your image \(selectedURL.lastPathComponent) has been formatted and applied to your wallpaper and lock screen.\n\nFile saved to:\n\(outputURL.path)"
                        )
                    case .failure(let error):
                        UIHelper.showAlert(
                            title: "Error",
                            message: "Failed to apply image: \(error.localizedDescription)",
                            isError: true
                        )
                    }
                    NSApp.terminate(nil)
                }
            }
        } else {
            NSApp.terminate(nil)
        }
    }
}
