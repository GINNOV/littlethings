import CryptoKit
import Foundation

@MainActor
@Observable
final class ROMCatalogStore {
    private(set) var items: [ROMCatalogItem] = []
    private(set) var isLoading = false
    private(set) var lastError: String?
    private(set) var localFirmwareDirectory: URL?
    private(set) var catalogSource: CatalogSource = .bundled

    enum CatalogSource: String {
        case bundled
        case bundledWithLocalFiles
    }

    init(localFirmwareDirectory: URL? = AppSettings.firmwareDirectoryURL()) {
        self.localFirmwareDirectory = localFirmwareDirectory
    }

    func reload() {
        isLoading = true
        lastError = nil

        Task {
            do {
                let entries = try BundledCatalogLoader.loadManifest()
                let built = buildCatalog(entries: entries, localRoot: localFirmwareDirectory)
                items = built.sorted { $0.displayTitle.localizedStandardCompare($1.displayTitle) == .orderedAscending }
                catalogSource = localFirmwareDirectory == nil ? .bundled : .bundledWithLocalFiles
                isLoading = false
            } catch {
                lastError = error.localizedDescription
                items = []
                isLoading = false
            }
        }
    }

    func updateLocalDirectory(_ url: URL?) {
        localFirmwareDirectory = url
        reload()
    }

    func clearLocalDirectory() {
        localFirmwareDirectory = nil
        reload()
    }

    var installedCount: Int {
        items.filter(\.isOnDisk).count
    }

    func items(for category: ROMCategory?) -> [ROMCatalogItem] {
        guard let category else { return items }
        return items.filter { $0.category == category }
    }

    func item(withID id: String) -> ROMCatalogItem? {
        items.first { $0.id == id }
    }

    private func buildCatalog(entries: [ManifestEntry], localRoot: URL?) -> [ROMCatalogItem] {
        entries.map { entry in
            let parsed = ROMPathParser.parse(manifest: entry)
            let fileInfo: ROMFileInfo?
            if let localRoot {
                let absolute = localRoot.appendingPathComponent(entry.destination)
                fileInfo = Self.inspectFile(at: absolute)
            } else {
                fileInfo = nil
            }
            return ROMCatalogItem(manifest: entry, parsed: parsed, fileInfo: fileInfo)
        }
    }

    private static func inspectFile(at url: URL) -> ROMFileInfo? {
        let manager = FileManager.default
        guard manager.fileExists(atPath: url.path) else { return nil }

        let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
        let data = try? Data(contentsOf: url, options: [.mappedIfSafe])
        let md5 = data.map { digestMD5($0) }

        return ROMFileInfo(
            absolutePath: url.path,
            byteCount: values?.fileSize ?? data?.count ?? 0,
            md5: md5,
            modifiedAt: values?.contentModificationDate
        )
    }

    private static func digestMD5(_ data: Data) -> String {
        Insecure.MD5.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}