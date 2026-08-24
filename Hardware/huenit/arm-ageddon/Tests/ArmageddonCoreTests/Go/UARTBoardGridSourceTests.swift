import Foundation
import Testing
@testable import ArmageddonCore

struct UARTBoardGridSourceTests {
    @Test("fragmented fixture UART yields a 9x9 grid with one black stone")
    func splitFixture() async throws {
        let text = try Self.fixtureText()
        let data = Data(text.utf8)
        let mid = data.count / 2
        let source = UARTBoardGridSource()
        try await source.ingest(data.prefix(mid))
        await #expect(throws: GoPlayError.noGrid) {
            _ = try await source.readGrid()
        }
        try await source.ingest(data.suffix(from: mid))
        let grid = try await source.readGrid()
        #expect(grid.size == 9)
        #expect(grid.stone(row: 0, column: 1) == .black)
    }

    private static func fixtureText() throws -> String {
        var directory = URL(fileURLWithPath: #filePath)
        for _ in 0..<4 {
            directory.deleteLastPathComponent()
        }
        let url = directory.appending(path: "Tests/Fixtures/Serial/huenit-board-grid.txt")
        return try String(contentsOf: url, encoding: .utf8)
    }
}
