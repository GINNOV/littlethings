import Foundation

public struct BoardGridDecoder: Sendable {
    public private(set) var malformedLineCount = 0
    public private(set) var oversizedLineCount = 0
    private let maxLineBytes: Int
    private var buffer = Data()
    private var expectedSize: Int?
    private var rows: [GoStone] = []

    public var bufferedByteCount: Int { buffer.count }

    public init(maxLineBytes: Int = 256) {
        self.maxLineBytes = maxLineBytes
    }

    public mutating func append(_ data: Data) throws -> BoardGrid? {
        buffer.append(data)
        if buffer.count > maxLineBytes, buffer.firstIndex(of: 0x0A) == nil {
            oversizedLineCount += 1
            buffer.removeAll(keepingCapacity: true)
            resetMessage()
            return nil
        }
        var completed: BoardGrid?
        while let newline = buffer.firstIndex(of: 0x0A) {
            var line = buffer.subdata(in: buffer.startIndex..<newline)
            buffer.removeSubrange(buffer.startIndex...newline)
            if line.last == 0x0D {
                line.removeLast()
            }
            if line.count > maxLineBytes {
                oversizedLineCount += 1
                resetMessage()
                continue
            }
            let text = String(decoding: line, as: UTF8.self)
            if text.isEmpty || text.hasPrefix("#") {
                continue
            }
            do {
                if let grid = try processLine(text) {
                    completed = grid
                    break
                }
            } catch let error as BoardGridError {
                malformedLineCount += 1
                resetMessage()
                throw error
            }
        }
        return completed
    }

    private mutating func processLine(_ line: String) throws -> BoardGrid? {
        if line.hasPrefix("grid=") {
            let parsed = Int(line.dropFirst(5))
            guard let size = parsed, (1...19).contains(size) else {
                throw BoardGridError.invalidSize
            }
            expectedSize = size
            rows = []
            return nil
        }
        guard let size = expectedSize else {
            throw BoardGridError.missingHeader
        }
        if line.hasPrefix("row=") {
            let body = String(line.dropFirst(4))
            guard body.count == size else {
                throw BoardGridError.rowLength
            }
            var stones: [GoStone] = []
            stones.reserveCapacity(size)
            for character in body {
                switch character {
                case ".": stones.append(.empty)
                case "b", "B": stones.append(.black)
                case "w", "W": stones.append(.white)
                default: throw BoardGridError.badCharacter
                }
            }
            rows.append(contentsOf: stones)
            return nil
        }
        if line == "end" {
            guard rows.count == size * size else {
                throw BoardGridError.rowCount
            }
            let grid = try BoardGrid(size: size, cells: rows)
            resetMessage()
            return grid
        }
        throw BoardGridError.missingEnd
    }

    private mutating func resetMessage() {
        expectedSize = nil
        rows = []
    }
}
