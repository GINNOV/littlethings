import CryptoKit
import Foundation

@MainActor
@Observable
final class ROMCatalogStore {
    private(set) var items: [ROMCatalogItem] = []
    private(set) var isLoading = false
    private(set) var lastError: String?
    private(set) var localFirmwareDirectory: URL?
    private(set) var localScanReport: LocalROMScanReport?
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
                let buildResult = buildCatalog(entries: entries, localRoot: localFirmwareDirectory)
                items = buildResult.items.sorted {
                    $0.displayTitle.localizedStandardCompare($1.displayTitle) == .orderedAscending
                }
                localScanReport = buildResult.scanReport
                catalogSource = localFirmwareDirectory == nil ? .bundled : .bundledWithLocalFiles
                isLoading = false
            } catch {
                lastError = error.localizedDescription
                items = []
                localScanReport = nil
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

    func items(for category: ROMCategory?, hardwareModel: HardwareModel? = nil) -> [ROMCatalogItem] {
        items.filter { item in
            let matchesCategory = category.map { item.category == $0 } ?? true
            let matchesHardware = hardwareModel.map { model in
                item.machines.contains(where: { $0.id == model.id })
            } ?? true
            return matchesCategory && matchesHardware
        }
    }

    func item(withID id: String) -> ROMCatalogItem? {
        items.first { $0.id == id }
    }

    private struct CatalogBuildResult {
        let items: [ROMCatalogItem]
        let scanReport: LocalROMScanReport?
    }

    private func buildCatalog(entries: [ManifestEntry], localRoot: URL?) -> CatalogBuildResult {
        guard let localRoot else {
            return CatalogBuildResult(items: entries.map { makeCatalogItem($0, fileInfo: nil) }, scanReport: nil)
        }

        let scanBundle = LocalROMScanner.scan(root: localRoot)
        let checksums = ROMChecksumIndex.loadBundled()
        var matchedURLs: Set<URL> = []

        let items = entries.map { entry in
            let matchedURL = LocalROMMatcher.match(
                entry: entry,
                localRoot: localRoot,
                index: scanBundle.index,
                checksums: checksums
            )
            if let matchedURL {
                matchedURLs.insert(matchedURL.standardizedFileURL)
            }
            let fileInfo = matchedURL.flatMap { Self.inspectFile(at: $0) }
            return makeCatalogItem(entry, fileInfo: fileInfo)
        }

        let scanReport = LocalROMScanAnalyzer.makeReport(
            scanBundle: scanBundle,
            matchedURLs: matchedURLs,
            entries: entries,
            checksums: checksums,
            matchedCatalogEntries: items.filter(\.isOnDisk).count
        )

        return CatalogBuildResult(items: items, scanReport: scanReport)
    }

    private func makeCatalogItem(_ entry: ManifestEntry, fileInfo: ROMFileInfo?) -> ROMCatalogItem {
        ROMCatalogItem(manifest: entry, parsed: ROMPathParser.parse(manifest: entry), fileInfo: fileInfo)
    }

    private static func inspectFile(at url: URL) -> ROMFileInfo? {
        let manager = FileManager.default
        guard manager.fileExists(atPath: url.path) else { return nil }

        let values = try? url.resourceValues(forKeys: [
            .fileSizeKey,
            .contentModificationDateKey,
            .isDirectoryKey,
            .isRegularFileKey
        ])
        if values?.isDirectory == true { return nil }
        if values?.isRegularFile == false { return nil }
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