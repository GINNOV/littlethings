import Foundation
import Testing
@testable import ArmageddonCore

struct BoardGridTests {
    @Test("parses a 9x9 UART grid split across two appends")
    func fragmentedUART() throws {
        var decoder = BoardGridDecoder()
        let first = try decoder.append(Data("grid=9\nrow=.b.......\nrow=.........\n".utf8))
        #expect(first == nil)
        var rest = ""
        for _ in 0..<7 {
            rest += "row=.........\n"
        }
        rest += "end\n"
        let grid = try #require(try decoder.append(Data(rest.utf8)))
        #expect(grid.size == 9)
        #expect(grid.stone(row: 0, column: 1) == .black)
        #expect(grid.stone(row: 0, column: 0) == .empty)
        #expect(decoder.malformedLineCount == 0)
    }

    @Test("addedStone detects exactly one new black stone")
    func oneNewStone() throws {
        let empty = try BoardGrid(size: 9, cells: Array(repeating: .empty, count: 81))
        var cells = empty.cells
        cells[4 * 9 + 4] = .black
        let next = try BoardGrid(size: 9, cells: cells)
        let delta = try next.addedStone(since: empty)
        #expect(delta.row == 4)
        #expect(delta.column == 4)
        #expect(delta.stone == .black)
    }

    @Test("addedStone throws when two cells change or sizes differ")
    func notSingleMove() throws {
        let empty = try BoardGrid(size: 9, cells: Array(repeating: .empty, count: 81))
        var two = empty.cells
        two[0] = .black
        two[1] = .black
        #expect(throws: BoardGridError.notSingleMove) {
            _ = try BoardGrid(size: 9, cells: two).addedStone(since: empty)
        }
        let small = try BoardGrid(size: 2, cells: Array(repeating: .empty, count: 4))
        #expect(throws: BoardGridError.notSingleMove) {
            _ = try empty.addedStone(since: small)
        }
    }

    @Test("malformed row length increments the counter and throws")
    func shortRow() throws {
        var decoder = BoardGridDecoder()
        #expect(throws: BoardGridError.rowLength) {
            _ = try decoder.append(Data("grid=9\nrow=....\n".utf8))
        }
        #expect(decoder.malformedLineCount == 1)
    }

    @Test("oversized line increments oversizedLineCount")
    func oversized() throws {
        var decoder = BoardGridDecoder(maxLineBytes: 8)
        let grid = try decoder.append(Data("grid=9this-is-too-long-without-newline".utf8))
        #expect(grid == nil)
        #expect(decoder.oversizedLineCount == 1)
    }

    @Test("comments and blanks are ignored")
    func comments() throws {
        var decoder = BoardGridDecoder()
        var text = "# ignore\n\ngrid=9\n"
        text += "row=.b.......\n"
        for _ in 0..<8 {
            text += "row=.........\n"
        }
        text += "end\n"
        let grid = try #require(try decoder.append(Data(text.utf8)))
        #expect(grid.stone(row: 0, column: 1) == .black)
    }

    @Test("ascii round-trips")
    func asciiRoundTrip() throws {
        var cells = Array(repeating: GoStone.empty, count: 81)
        cells[3 * 9 + 4] = .black
        cells[5 * 9 + 4] = .white
        let grid = try BoardGrid(size: 9, cells: cells)
        var decoder = BoardGridDecoder()
        let again = try #require(try decoder.append(Data((grid.ascii() + "\n").utf8)))
        #expect(again == grid)
    }
}
