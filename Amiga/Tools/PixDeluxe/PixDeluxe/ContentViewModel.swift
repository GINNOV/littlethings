//
//  FileManagerService.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/5/25.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

class ContentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var image: Image?
    @Published var hexdump: String? = nil
    @Published var isGeneratingHexdump = false
    @Published var isConverting = false

    // MARK: - Services
    let fileManager = FileManagerService()
    let imageConverter = ImageConverter()

    // MARK: - Private Properties
    private let iffParser = IFFParser()
    private var lastChunkyData: [UInt8]? = nil
    private var cancellables = Set<AnyCancellable>()
    private var lastNSImage: NSImage?
    
    init() {
        fileManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods (Intents)
    
    func selectFile(url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            print("❌ Could not gain security-scoped access to file: \(url.path)")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        print("✅ Gained security-scoped access to: \(url.path)")
        fileManager.addRecentFile(url: url)
        _displayImage(from: url)
    }
    
    func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            selectFile(url: url)
        case .failure(let error):
            print("❌ Error selecting file: \(error.localizedDescription)")
        }
    }
    
    func generateHexDump() {
        guard let data = lastChunkyData else { return }
        isGeneratingHexdump = true
        DispatchQueue.global(qos: .userInitiated).async {
            let generatedHexdump = HexdumpGenerator.format(data: data)
            DispatchQueue.main.async {
                self.hexdump = generatedHexdump
                self.isGeneratingHexdump = false
                self.copyHexdumpToClipboard()
            }
        }
    }

    func copyHexdumpToClipboard() {
        guard let hexdump = self.hexdump, !hexdump.isEmpty else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(hexdump, forType: .string)
        print("📋 Copied hexdump to clipboard.")
    }
    
    func convertToIFFFromImage() {
        isConverting = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.imageConverter.convertToIFF()
            DispatchQueue.main.async {
                self.isConverting = false
            }
        }
    }
    
    func exportToImage() {
        guard let nsImage = lastNSImage else { return }
        isConverting = true
        // This doesn't need a background thread as the save panel is modal.
        imageConverter.export(nsImage: nsImage, to: .png) // or .jpeg
        isConverting = false
    }

    // MARK: - Private Methods
    
    private func _displayImage(from url: URL) {
        DispatchQueue.main.async {
            self.image = nil
            self.hexdump = nil
            self.lastChunkyData = nil
            self.lastNSImage = nil
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let parseResult = self.iffParser.parse(url: url) else { return }
            
            let iffImage = parseResult.image
            
            let provider = CGDataProvider(data: Data(iffImage.pixels) as CFData)
            
            if let cgImage = CGImage(width: iffImage.width, height: iffImage.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: iffImage.width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider: provider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
                
                let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: iffImage.width, height: iffImage.height))
                
                DispatchQueue.main.async {
                    self.lastChunkyData = parseResult.chunkyData
                    self.lastNSImage = nsImage
                    self.image = Image(nsImage: nsImage)
                    print("🖼️ Successfully displayed image: \(url.lastPathComponent)")
                }
            }
        }
    }
}
