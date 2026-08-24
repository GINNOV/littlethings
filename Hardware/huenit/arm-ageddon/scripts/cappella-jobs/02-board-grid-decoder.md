Write a single Swift 6 file `BoardGridDecoder.swift` for ArmageddonCore (import Foundation).

It MUST use these types that already exist in the same module (do not redefine them):

```swift
public enum GoStone: String, Sendable { case empty, black, white }
public struct BoardGrid: Sendable, Equatable {
  public let size: Int
  public let cells: [GoStone]
  public init(size: Int, cells: [GoStone]) throws
}
public enum BoardGridError: Error, Equatable, Sendable {
  case invalidSize, wrongCellCount, badCharacter, missingHeader, rowCount, rowLength, missingEnd, notSingleMove
}
```

Streaming UART decoder, same shape as line-oriented K210 telemetry:

```swift
public struct BoardGridDecoder: Sendable {
  public private(set) var malformedLineCount: Int
  public private(set) var oversizedLineCount: Int
  public var bufferedByteCount: Int { get }
  public init(maxLineBytes: Int = 256)
  public mutating func append(_ data: Data) throws -> BoardGrid?
}
```

Rules:
- Accumulate bytes, split on `\n` (strip `\r`)
- Lines: `grid=N`, `row=....`, `end`, `#` comments, blanks
- If a line exceeds maxLineBytes, drop it, increment oversizedLineCount, continue
- A complete message is grid= then exactly N row= lines then `end`
- On success return BoardGrid and reset message state (keep counters)
- On protocol error for the current message: increment malformedLineCount, reset message state, throw BoardGridError (missingHeader/rowCount/rowLength/badCharacter/missingEnd/invalidSize)
- `append` may return nil if incomplete
- Do not treat any clock as capture time
- Fragmented TCP/UART chunks must work (grid= on one append, rows later)

Output only the Swift file.
