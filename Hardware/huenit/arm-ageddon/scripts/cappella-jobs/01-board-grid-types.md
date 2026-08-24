Write a single Swift 6 file `BoardGrid.swift` for module ArmageddonCore (import Foundation).

Frozen UART contract for a 9×9 (size 1...19) go board:

```
grid=9
row=.b.......
row=.........
end
```

- `.` empty, `b`/`B` black, `w`/`W` white
- exactly `size` `row=` lines, each length `size`
- `#` comments and blank lines ignored
- `grid=` once, before rows; `end` required
- host receipt time is NOT a capture timestamp

API (public, Sendable, Equatable as makes sense):

```swift
public enum GoStone: String, Sendable { case empty, black, white }
public struct BoardGrid: Sendable, Equatable {
  public let size: Int
  public let cells: [GoStone] // row-major, count == size*size
  public init(size: Int, cells: [GoStone]) throws
  public func stone(row: Int, column: Int) -> GoStone
  public func ascii() -> String  // same UART body without comments
}
public struct BoardStoneDelta: Sendable, Equatable {
  public let row: Int
  public let column: Int
  public let stone: GoStone  // black or white
}
public enum BoardGridError: Error, Equatable, Sendable {
  case invalidSize, wrongCellCount, badCharacter, missingHeader, rowCount, rowLength, missingEnd, notSingleMove
}
```

`BoardGrid.init` throws `invalidSize` unless 1...19, `wrongCellCount` if cells.count != size*size.

Do NOT include a UART decoder in this file (that's another job).
Do NOT import XCTest, Testing, or mention G28/motors.
Include `BoardGrid.addedStone(since previous: BoardGrid) throws -> BoardStoneDelta` that requires identical size and exactly one cell change from empty to black or white; otherwise `notSingleMove`.

Output only the Swift file.
