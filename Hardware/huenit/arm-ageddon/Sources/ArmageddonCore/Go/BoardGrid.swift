import Foundation

public enum GoStone: String, Sendable {
    case empty
    case black
    case white
}

public struct BoardStoneDelta: Sendable, Equatable {
    public let row: Int
    public let column: Int
    public let stone: GoStone

    public init(row: Int, column: Int, stone: GoStone) {
        self.row = row
        self.column = column
        self.stone = stone
    }
}

public enum BoardGridError: Error, Equatable, Sendable {
    case invalidSize
    case wrongCellCount
    case badCharacter
    case missingHeader
    case rowCount
    case rowLength
    case missingEnd
    case notSingleMove
}

public struct BoardGrid: Sendable, Equatable {
    public let size: Int
    public let cells: [GoStone]

    public init(size: Int, cells: [GoStone]) throws {
        guard (1...19).contains(size) else {
            throw BoardGridError.invalidSize
        }
        guard cells.count == size * size else {
            throw BoardGridError.wrongCellCount
        }
        self.size = size
        self.cells = cells
    }

    public func stone(row: Int, column: Int) -> GoStone {
        guard (0..<size).contains(row), (0..<size).contains(column) else {
            return .empty
        }
        return cells[row * size + column]
    }

    public func ascii() -> String {
        var lines: [String] = ["grid=\(size)"]
        for row in 0..<size {
            var chars: [Character] = []
            chars.reserveCapacity(size)
            for column in 0..<size {
                switch cells[row * size + column] {
                case .empty: chars.append(".")
                case .black: chars.append("b")
                case .white: chars.append("w")
                }
            }
            lines.append("row=\(String(chars))")
        }
        lines.append("end")
        return lines.joined(separator: "\n")
    }

    public func addedStone(since previous: BoardGrid) throws -> BoardStoneDelta {
        guard size == previous.size else {
            throw BoardGridError.notSingleMove
        }
        var changed: [Int] = []
        for index in cells.indices where cells[index] != previous.cells[index] {
            changed.append(index)
        }
        guard changed.count == 1 else {
            throw BoardGridError.notSingleMove
        }
        let index = changed[0]
        let next = cells[index]
        guard previous.cells[index] == .empty, next == .black || next == .white else {
            throw BoardGridError.notSingleMove
        }
        return BoardStoneDelta(row: index / size, column: index % size, stone: next)
    }
}
