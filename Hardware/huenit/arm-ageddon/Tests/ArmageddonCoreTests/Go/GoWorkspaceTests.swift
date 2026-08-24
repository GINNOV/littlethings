import Foundation
import Testing
@testable import ArmageddonCore

struct GoWorkspaceTests {
    @Test("maps row/column onto taught origin and step")
    func mapsIntersection() throws {
        let workspace = GoWorkspace.fixture
        let origin = try workspace.cartesian(for: GoIntersection(row: 0, column: 0))
        #expect(origin.x == workspace.originX)
        #expect(origin.y == workspace.originY)
        let far = try workspace.cartesian(for: GoIntersection(row: 2, column: 3))
        #expect(far.x == workspace.originX + 3 * workspace.stepX)
        #expect(far.y == workspace.originY + 2 * workspace.stepY)
    }

    @Test("file grid source rereads UART text")
    func fileSource() async throws {
        var directory = URL(fileURLWithPath: #filePath)
        for _ in 0..<4 {
            directory.deleteLastPathComponent()
        }
        let url = directory.appending(path: "Tests/Fixtures/Serial/huenit-board-grid.txt")
        let source = FileBoardGridSource(url: url)
        let grid = try await source.readGrid()
        #expect(grid.size == 9)
        #expect(grid.stone(row: 0, column: 1) == .black)
    }
}
