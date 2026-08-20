import XCTest
import Cocoa
import ImageIO
import CoreGraphics

final class AmigaLoginScreenUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    // MARK: - Preset & Data Integrity Tests
    
    func testKickstart13PresetLoadsFromMemory() throws {
        guard let data = KickstartPreset.ks13.loadData() else {
            XCTFail("Kickstart 1.3 preset data failed to load from memory")
            return
        }
        XCTAssertGreaterThan(data.count, 1000, "Kickstart 1.3 data is too small or corrupted")
        
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            XCTFail("Kickstart 1.3 data is not a valid image format")
            return
        }
        XCTAssertGreaterThan(CGImageSourceGetCount(source), 0, "Kickstart 1.3 contains 0 frames")
        
        let outputURL = try WallpaperEngine.renderWallpaperFromSource(imageSource: source)
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path), "Failed to render Kickstart 1.3 wallpaper")
    }
    
    func testKickstart20PresetLoadsFromMemory() throws {
        guard let data = KickstartPreset.ks20.loadData() else {
            XCTFail("Kickstart 2.0 preset data failed to load from memory")
            return
        }
        XCTAssertGreaterThan(data.count, 1000, "Kickstart 2.0 data is too small or corrupted")
        
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            XCTFail("Kickstart 2.0 data is not a valid image format")
            return
        }
        XCTAssertGreaterThan(CGImageSourceGetCount(source), 0, "Kickstart 2.0 contains 0 frames")
        
        let outputURL = try WallpaperEngine.renderWallpaperFromSource(imageSource: source)
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path), "Failed to render Kickstart 2.0 wallpaper")
    }
    
    func testKickstart31PresetLoadsFromMemory() throws {
        guard let data = KickstartPreset.ks31.loadData() else {
            XCTFail("Kickstart 3.1 preset data failed to load from memory")
            return
        }
        XCTAssertGreaterThan(data.count, 1000, "Kickstart 3.1 data is too small or corrupted")
        
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            XCTFail("Kickstart 3.1 data is not a valid image format")
            return
        }
        XCTAssertGreaterThan(CGImageSourceGetCount(source), 0, "Kickstart 3.1 contains 0 frames")
        
        let outputURL = try WallpaperEngine.renderWallpaperFromSource(imageSource: source)
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path), "Failed to render Kickstart 3.1 wallpaper")
    }
    
    // MARK: - Image Processing & Color Detection Tests
    
    func testBackgroundColorSampling() throws {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil, width: 100, height: 100, bitsPerComponent: 8, bytesPerRow: 400, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            XCTFail("Failed to create graphics context")
            return
        }
        context.setFillColor(CGColor(red: 0.0, green: 85.0/255.0, blue: 170.0/255.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        
        guard let cgImage = context.makeImage() else {
            XCTFail("Failed to make image from context")
            return
        }
        
        let detected = WallpaperEngine.detectBackgroundColor(cgImage: cgImage)
        guard let components = detected.components, components.count >= 3 else {
            XCTFail("Detected color has invalid color components")
            return
        }
        
        XCTAssertLessThan(components[0], 0.1, "Expected red near 0")
        XCTAssertGreaterThan(components[1], 0.25, "Expected green component")
        XCTAssertGreaterThan(components[2], 0.55, "Expected blue component")
    }
    
    func testCustomResolutionCalculation() throws {
        let (w, h) = WallpaperEngine.getTargetResolution()
        XCTAssertGreaterThan(w, 0, "Target screen width must be positive")
        XCTAssertGreaterThan(h, 0, "Target screen height must be positive")
    }
    
    // MARK: - Asynchronous Execution & Semaphore Tests
    
    func testAsyncProcessAndApplyExecution() throws {
        guard let data = KickstartPreset.ks31.loadData() else {
            XCTFail("Missing Kickstart 3.1 data")
            return
        }
        
        let expectation = self.expectation(description: "Process and apply completes without hanging")
        
        WallpaperEngine.processAndApply(data: data) { result in
            switch result {
            case .success(let url):
                XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Process and apply failed with error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Preset Enum Tests
    
    func testAllPresetsContainValidData() throws {
        for preset in KickstartPreset.allCases {
            guard let data = preset.loadData() else {
                XCTFail("Preset \(preset.displayName) failed to return data")
                continue
            }
            XCTAssertFalse(data.isEmpty, "Data for \(preset.displayName) is empty")
            XCTAssertFalse(preset.displayName.isEmpty, "DisplayName for \(preset.rawValue) is empty")
            XCTAssertFalse(preset.resourceName.isEmpty, "ResourceName for \(preset.rawValue) is empty")
        }
    }
}
