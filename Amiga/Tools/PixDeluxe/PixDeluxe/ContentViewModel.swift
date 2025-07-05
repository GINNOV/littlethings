import SwiftUI
import UniformTypeIdentifiers

class ContentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var image: Image?
    @Published var recentFiles: [URL] = []
    @Published var hexdump: String? = nil
    
    // MARK: - Private Properties
    private let iffParser = IFFParser()
    private var lastChunkyData: [UInt8]? = nil
    
    @AppStorage("recentFileBookmarks") private var recentFileBookmarksData: Data = Data()
    
    init() {
        loadRecentFilesFromBookmarks()
    }
    
    // MARK: - Public Methods (Intents)
    
    func selectRecentFile(url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            print("❌ Could not gain security-scoped access to recent file: \(url.path)")
            removeDeadRecentFile(url: url)
            return
        }
        defer {
            url.stopAccessingSecurityScopedResource()
            print("✅ Relinquished security-scoped access to: \(url.path)")
        }
        
        print("✅ Gained security-scoped access to recent file: \(url.path)")
        _displayImage(from: url)
    }
    
    func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            guard url.startAccessingSecurityScopedResource() else {
                print("❌ Could not gain security-scoped access to newly imported file: \(url.path)")
                return
            }
            defer {
                url.stopAccessingSecurityScopedResource()
                print("✅ Relinquished security-scoped access to: \(url.path)")
            }
            
            print("✅ Gained security-scoped access to newly imported file: \(url.path)")
            
            addRecentFile(url: url)
            _displayImage(from: url)
            
        case .failure(let error):
            print("❌ Error selecting file: \(error.localizedDescription)")
        }
    }
    
    func clearRecents() {
        recentFiles.removeAll()
        recentFileBookmarksData = Data()
        print("Cleared all recent files.")
    }

    func generateHexDump() {
        guard let data = lastChunkyData else {
            self.hexdump = "No decoded data available to dump."
            return
        }
        print("ℹ️ Generating hexdump of \(data.count) bytes.")
        self.hexdump = formatDataAsHexdump(data)
    }

    func copyHexdumpToClipboard() {
        guard let hexdump = self.hexdump, !hexdump.isEmpty else {
            print("📋 Nothing to copy.")
            return
        }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(hexdump, forType: .string)
        print("📋 Copied hexdump to clipboard.")
    }

    // MARK: - Private Methods
    
    private func _displayImage(from url: URL) {
        DispatchQueue.main.async {
            self.image = nil
            self.hexdump = nil
            self.lastChunkyData = nil
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let parseResult = self.iffParser.parse(url: url) else {
                print("❌ Failed to parse IFF image.")
                return
            }
            
            let iffImage = parseResult.image
            
            let bitsPerComponent = 8
            let bitsPerPixel = 32
            let bytesPerRow = iffImage.width * 4
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)]
            let provider = CGDataProvider(data: Data(iffImage.pixels) as CFData)
            
            if let cgImage = CGImage(width: iffImage.width, height: iffImage.height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, provider: provider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
                DispatchQueue.main.async {
                    self.lastChunkyData = parseResult.chunkyData
                    self.image = Image(nsImage: NSImage(cgImage: cgImage, size: NSSize(width: iffImage.width, height: iffImage.height)))
                    print("🖼️ Successfully displayed image: \(url.lastPathComponent)")
                }
            }
        }
    }
    
    private func addRecentFile(url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            var bookmarks = (try? JSONDecoder().decode([Data].self, from: recentFileBookmarksData)) ?? []
            
            if let index = recentFiles.firstIndex(of: url) {
                recentFiles.remove(at: index)
                if index < bookmarks.count {
                    bookmarks.remove(at: index)
                }
            }

            recentFiles.insert(url, at: 0)
            bookmarks.insert(bookmarkData, at: 0)
            
            if recentFiles.count > 10 {
                recentFiles.removeLast()
                bookmarks.removeLast()
            }
            
            recentFileBookmarksData = (try? JSONEncoder().encode(bookmarks)) ?? Data()
            print("💾 Saved bookmark for: \(url.lastPathComponent)")

        } catch {
            print("❌ Error creating or saving bookmark for \(url.path): \(error.localizedDescription)")
        }
    }

    private func loadRecentFilesFromBookmarks() {
        guard let bookmarks = try? JSONDecoder().decode([Data].self, from: recentFileBookmarksData) else {
            return
        }
        
        var resolvedURLs: [URL] = []
        for bookmarkData in bookmarks {
            do {
                var isStale = false
                let resolvedURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                
                if !isStale {
                    resolvedURLs.append(resolvedURL)
                }
            } catch {
                print("❌ Error resolving bookmark: \(error.localizedDescription)")
            }
        }
        self.recentFiles = resolvedURLs
        print("📚 Loaded \(recentFiles.count) recent files from bookmarks.")
    }
    
    private func removeDeadRecentFile(url: URL) {
        print("🗑️ Removing dead link from recents: \(url.lastPathComponent)")
        guard let index = recentFiles.firstIndex(of: url) else { return }
        recentFiles.remove(at: index)
        
        var bookmarks = (try? JSONDecoder().decode([Data].self, from: recentFileBookmarksData)) ?? []
        if index < bookmarks.count {
            bookmarks.remove(at: index)
        }
        recentFileBookmarksData = (try? JSONEncoder().encode(bookmarks)) ?? Data()
    }
    
    private func formatDataAsHexdump(_ data: [UInt8]) -> String {
        var result = ""
        let bytesPerRow = 16
        
        for i in stride(from: 0, to: data.count, by: bytesPerRow) {
            let address = String(format: "%08x", i)
            result += "\(address)  "
            
            let rowData = data[i..<min(i + bytesPerRow, data.count)]
            var hexString = rowData.map { String(format: "%02x", $0) }.joined(separator: " ")
            if i + 8 < data.count {
                hexString.insert(" ", at: hexString.index(hexString.startIndex, offsetBy: 23))
            }
            result += hexString.padding(toLength: 49, withPad: " ", startingAt: 0)
            
            let asciiString = rowData.map { ($0 >= 32 && $0 <= 126) ? Character(UnicodeScalar($0)) : "." }.map(String.init).joined()
            result += " |\(asciiString)|\n"
        }
        
        return result
    }
}
