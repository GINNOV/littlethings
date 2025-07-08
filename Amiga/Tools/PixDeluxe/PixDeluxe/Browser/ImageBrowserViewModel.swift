//
//  ImageBrowserViewModel.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/8/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct BrowserItem: Identifiable, Hashable {
    let id: URL
    let nsImage: NSImage
    let details: IFFImageDetails

    static func == (lhs: BrowserItem, rhs: BrowserItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@MainActor
class ImageBrowserViewModel: ObservableObject {
    @Published var browserItems: [BrowserItem] = []
    @Published var isLoading: Bool = false
    @Published var statusText: String = "Select a folder to begin browsing."

    private let iffWrapper = IFFWrapper()

    // AI_REVIEW: The `openFolder` method has been updated to be fully asynchronous.
    // It now uses `openPanel.begin` with a completion handler instead of the blocking
    // `runModal()` call. This fixes the console error and prevents the UI from freezing,
    // which was the root cause of the gesture recognition bugs.
    func openFolder() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.title = "Select a Folder of IFF Images"

        openPanel.begin { [weak self] response in
            guard let self = self else { return }
            if response == .OK, let url = openPanel.url {
                Task {
                    await self.findImages(in: url)
                }
            }
        }
    }

    private func findImages(in folderURL: URL) async {
        isLoading = true
        statusText = "Scanning for images..."
        var items: [BrowserItem] = []
        var foundURLs: [URL] = []

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

        for (index, url) in foundURLs.enumerated() {
            statusText = "Processing \(index + 1) of \(foundURLs.count): \(url.lastPathComponent)"
            
            do {
                let data = try Data(contentsOf: url)
                if let parseResult = self.iffWrapper.parse(data: data, fileURL: url) {
                    let nsImage = NSImage(cgImage: parseResult.cgImage, size: NSSize(width: parseResult.cgImage.width, height: parseResult.cgImage.height))
                    let newItem = BrowserItem(id: url, nsImage: nsImage, details: parseResult.details)
                    items.append(newItem)
                    self.browserItems = items
                }
            } catch {
                print("❌ [Debug] Could not read data from URL: \(url.path). Error: \(error)")
            }
        }
        
        statusText = "Finished! Found \(items.count) images."
        isLoading = false
    }
}
