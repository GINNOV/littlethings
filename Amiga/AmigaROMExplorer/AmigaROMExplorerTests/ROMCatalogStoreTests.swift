import Foundation
import Testing
@testable import AmigaROMExplorer

@MainActor
struct ROMCatalogStoreTests {
    private let firmwareRoot = URL(
        fileURLWithPath: "/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware",
        isDirectory: true
    )

    @Test func flatFolderIncreasesInstalledCount() async throws {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("amiga-rom-explorer-catalog-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)

        let copies: [(source: String, alias: String)] = [
            (
                "kickstart/v1-2-r33-180/a500-a1000-a2000/good/kickstart-v1-2-r33-180-1986-10-commodore-a500-a1000-a2000-good.rom",
                "kick12.rom"
            ),
            (
                "kickstart/v1-3-r34-005/a500-a1000-a2000-cdtv/good/kickstart-v1-3-r34-005-1987-12-commodore-a500-a1000-a2000-cdtv-good.rom",
                "kick13.rom"
            ),
            (
                "bootstrap/a1000/good/amiga-1000-rom-bootstrap-1985-commodore-a1000-good.rom",
                "Kickstart Bootstrap (1985)(Commodore)(A1000).rom"
            )
        ]

        for copy in copies {
            let source = firmwareRoot.appendingPathComponent(copy.source)
            let destination = tempRoot.appendingPathComponent(copy.alias)
            try FileManager.default.copyItem(at: source, to: destination)
        }
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let store = ROMCatalogStore(localFirmwareDirectory: tempRoot)
        store.reload()

        try await Task.sleep(for: .seconds(2))
        #expect(store.installedCount >= 3)
    }
}