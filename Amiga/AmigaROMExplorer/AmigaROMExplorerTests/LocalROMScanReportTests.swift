import Foundation
import Testing
@testable import AmigaROMExplorer

struct LocalROMScanReportTests {
    private let firmwareRoot = URL(
        fileURLWithPath: "/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware",
        isDirectory: true
    )

    private let kick13GoodDestination =
        "kickstart/v1-3-r34-005/a500-a1000-a2000-cdtv/good/kickstart-v1-3-r34-005-1987-12-commodore-a500-a1000-a2000-cdtv-good.rom"

    @Test @MainActor func summaryIncludesSkippedZipAndUnrecognizedFiles() async throws {
        let tempRoot = try makeTempFolder()
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let goodROM = firmwareRoot.appendingPathComponent(kick13GoodDestination)
        try FileManager.default.copyItem(at: goodROM, to: tempRoot.appendingPathComponent("kick13.rom"))
        try Data([0x00, 0x01, 0x02, 0x03]).write(to: tempRoot.appendingPathComponent("aros.rom.bin"))
        try Data([0x50, 0x4B, 0x03, 0x04]).write(to: tempRoot.appendingPathComponent("kick13.rom.zip"))

        let report = try await scanReport(at: tempRoot)

        #expect(report.scannedFirmwareFiles == 2)
        #expect(report.matchedCatalogEntries >= 1)
        #expect(report.skippedArchiveFiles.count == 1)
        #expect(report.unrecognizedFiles.count == 1)
        #expect(report.summaryLine.contains("skipped (.zip)"))
        #expect(report.summaryLine.contains("unrecognized"))
    }

    @Test @MainActor func wrongKickstartDumpReportedAsChecksumMismatch() async throws {
        let tempRoot = try makeTempFolder()
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        try Data(repeating: 0xFF, count: 262_144).write(to: tempRoot.appendingPathComponent("kick13.rom"))

        let report = try await scanReport(at: tempRoot)

        #expect(report.checksumMismatches.count == 1)
        #expect(report.checksumMismatches.first?.file.displayName == "kick13.rom")
        #expect(report.checksumMismatches.first?.hint.localizedCaseInsensitiveContains("kickstart v1.3") == true)
        #expect(report.summaryLine.contains("checksum mismatch"))
    }

    @Test func summaryLineFormatsCounts() {
        let report = LocalROMScanReport(
            scannedFirmwareFiles: 18,
            matchedCatalogEntries: 9,
            skippedArchiveFiles: [
                ScannedROMFileSummary(url: URL(fileURLWithPath: "/tmp/a.zip"), displayName: "a.zip", md5: "", byteCount: 0)
            ],
            unrecognizedFiles: [
                ScannedROMFileSummary(url: URL(fileURLWithPath: "/tmp/aros.bin"), displayName: "aros.bin", md5: "abc", byteCount: 10),
                ScannedROMFileSummary(url: URL(fileURLWithPath: "/tmp/v314.rom"), displayName: "v314.rom", md5: "def", byteCount: 10)
            ],
            checksumMismatches: [
                ChecksumMismatchSummary(
                    file: ScannedROMFileSummary(url: URL(fileURLWithPath: "/tmp/kick13.rom"), displayName: "kick13.rom", md5: "111", byteCount: 10),
                    hint: "Looks like Kickstart v1.3",
                    expectedMD5: "222",
                    catalogDestination: kick13GoodDestination
                ),
                ChecksumMismatchSummary(
                    file: ScannedROMFileSummary(url: URL(fileURLWithPath: "/tmp/kick12.rom"), displayName: "kick12.rom", md5: "333", byteCount: 10),
                    hint: "Looks like Kickstart v1.2",
                    expectedMD5: "444",
                    catalogDestination: nil
                )
            ]
        )

        #expect(report.summaryLine == "Scanned 18 files · 9 matched catalog entries · 2 checksum mismatches · 2 unrecognized · 1 skipped (.zip)")
    }

    private func makeTempFolder() throws -> URL {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("amiga-rom-explorer-scan-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)
        return tempRoot
    }

    @MainActor
    private func scanReport(at root: URL) async throws -> LocalROMScanReport {
        let store = ROMCatalogStore(localFirmwareDirectory: root)
        store.reload()

        let deadline = Date().addingTimeInterval(3)
        while store.isLoading && Date() < deadline {
            try await Task.sleep(for: .milliseconds(50))
        }

        return try #require(store.localScanReport)
    }
}