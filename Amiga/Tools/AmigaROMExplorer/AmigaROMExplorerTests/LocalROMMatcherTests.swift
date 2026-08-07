import Foundation
import Testing
@testable import AmigaROMExplorer

struct LocalROMMatcherTests {
    private let firmwareRoot = URL(
        fileURLWithPath: "/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware",
        isDirectory: true
    )

    private let kick13GoodDestination =
        "kickstart/v1-3-r34-005/a500-a1000-a2000-cdtv/good/kickstart-v1-3-r34-005-1987-12-commodore-a500-a1000-a2000-cdtv-good.rom"

    @Test func checksumIndexLoadsBundledEntries() {
        let index = ROMChecksumIndex.loadBundled()
        #expect(index.md5(for: kick13GoodDestination) == "82a21c1890cae844b3df741f2762d48d")
    }

    @Test func matchesExactStructuredPath() throws {
        let entry = ManifestEntry(
            source: "Kickstart v1.3 r34.005 (1987-12)(Commodore)(A500-A1000-A2000-CDTV)[!].zip",
            destination: kick13GoodDestination,
            status: .moved
        )

        let localIndex = LocalROMIndex.build(root: firmwareRoot)
        let checksums = ROMChecksumIndex.loadBundled()
        let matched = LocalROMMatcher.match(
            entry: entry,
            localRoot: firmwareRoot,
            index: localIndex,
            checksums: checksums
        )

        #expect(matched != nil)
        #expect(matched?.lastPathComponent == "kickstart-v1-3-r34-005-1987-12-commodore-a500-a1000-a2000-cdtv-good.rom")
    }

    @Test func matchesFlatFolderByChecksum() throws {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("amiga-rom-explorer-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)

        let sourceROM = firmwareRoot
            .appendingPathComponent(kick13GoodDestination)
        let flatROM = tempRoot.appendingPathComponent("kick13.rom")
        try FileManager.default.copyItem(at: sourceROM, to: flatROM)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let entry = ManifestEntry(
            source: "Kickstart v1.3 r34.005 (1987-12)(Commodore)(A500-A1000-A2000-CDTV)[!].zip",
            destination: kick13GoodDestination,
            status: .moved
        )

        let localIndex = LocalROMIndex.build(root: tempRoot)
        let checksums = ROMChecksumIndex.loadBundled()
        #expect(localIndex.files.count == 1)
        #expect(localIndex.files.first?.md5 == checksums.md5(for: kick13GoodDestination))

        let matched = LocalROMMatcher.match(
            entry: entry,
            localRoot: tempRoot,
            index: localIndex,
            checksums: checksums
        )

        #expect(matched?.standardizedFileURL == flatROM.standardizedFileURL)
    }

    @Test func matchesTOSECStyleFilenameByChecksum() throws {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("amiga-rom-explorer-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)

        let sourceROM = firmwareRoot
            .appendingPathComponent(kick13GoodDestination)
        let flatROM = tempRoot.appendingPathComponent(
            "Kickstart - 315093-02 (USA, Europe) (v1.3 Rev 34.005) (A500, A2000).rom"
        )
        try FileManager.default.copyItem(at: sourceROM, to: flatROM)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let entry = ManifestEntry(
            source: "Kickstart v1.3 r34.005 (1987-12)(Commodore)(A500-A1000-A2000-CDTV)[!].zip",
            destination: kick13GoodDestination,
            status: .moved
        )

        let localIndex = LocalROMIndex.build(root: tempRoot)
        let checksums = ROMChecksumIndex.loadBundled()
        let matched = LocalROMMatcher.match(
            entry: entry,
            localRoot: tempRoot,
            index: localIndex,
            checksums: checksums
        )

        #expect(matched?.standardizedFileURL == flatROM.standardizedFileURL)
    }

    @Test func normalizeNameStripsNoIntroTags() {
        let normalized = LocalROMIndex.normalizeName(
            "Kickstart v1.3 r34.005 (1987-12)(Commodore)(A500-A1000-A2000-CDTV)[!].zip"
        )
        #expect(normalized.contains("kickstart"))
        #expect(!normalized.contains("["))
    }
}