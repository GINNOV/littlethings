//
//  ImageBrowserViewModel.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/8/25.
//

import SwiftUI
import UniformTypeIdentifiers

/// A lightweight struct to hold data for each image in the browser grid.
/// It's identifiable and hashable to be used effectively in SwiftUI lists.
struct BrowserItem: Identifiable, Hashable {
    let id: URL
    let nsImage: NSImage
    let details: IFFImageDetails

    // AI_REVIEW: Manually conforming to Equatable and Hashable by using the `id` (the file URL)
    // as the unique identifier. This is necessary because NSImage is a class and doesn't
    // conform to these protocols by default. This resolves the compiler error.
    static func == (lhs: BrowserItem, rhs: BrowserItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// This ViewModel orchestrates the image browsing feature. It handles folder selection,
/// recursively finds and parses IFF images on a background thread, and publishes
/// the results for the `ImageBrowserView` to display.
@MainActor
class ImageBrowserViewModel: ObservableObject {
    @Published var browserItems: [BrowserItem] = []
    @Published var isLoading: Bool = false
    @Published var statusText: String = "Select a folder to begin browsing."

    private let iffParser = IFFParser()

    /// Presents the system's open panel to allow the user to select a directory.
    func openFolder() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.title = "Select a Folder of IFF Images"

        guard openPanel.runModal() == .OK, let url = openPanel.url else {
            return
        }

        // Kick off the asynchronous image search.
        Task {
            await findImages(in: url)
        }
    }

    /// Recursively scans the given folder URL to find and parse all IFF and LBM images.
    /// This function updates the UI with progress and handles the heavy lifting off the main thread.
    private func findImages(in folderURL: URL) async {
        isLoading = true
        statusText = "Scanning for images..."
        var items: [BrowserItem] = []
        var foundURLs: [URL] = []

        // Use FileManager's enumerator to find all files.
        let enumerator = FileManager.default.enumerator(at: folderURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants])

        if let fileURLs = enumerator?.allObjects as? [URL] {
            let imageExtensions = Set(["iff", "lbm"])
            foundURLs = fileURLs.filter { url in
                imageExtensions.contains(url.pathExtension.lowercased())
            }
        }
        
        guard !foundURLs.isEmpty else {
            statusText = "No IFF or LBM images were found in that folder."
            isLoading = false
            return
        }

        statusText = "Loading \(foundURLs.count) images..."

        // Process each found URL.
        for (index, url) in foundURLs.enumerated() {
            statusText = "Processing \(index + 1) of \(foundURLs.count): \(url.lastPathComponent)"
            
            // The existing IFFParser is used to load image data.
            if let parseResult = iffParser.parse(url: url) {
                // We convert the parsed data into an NSImage, which is efficient for UI display.
                let iffImage = parseResult.image
                let provider = CGDataProvider(data: Data(iffImage.pixels) as CFData)
                if let cgImage = CGImage(width: iffImage.width, height: iffImage.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: iffImage.width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider: provider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
                    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: iffImage.width, height: iffImage.height))
                    let newItem = BrowserItem(id: url, nsImage: nsImage, details: parseResult.details)
                    items.append(newItem)
                    
                    // The array is updated incrementally so the user sees images appearing as they load.
                    self.browserItems = items
                }
            }
        }
        
        statusText = "Finished! Found \(items.count) images."
        isLoading = false
    }
}
