Write a single Swift Testing file `BoardGridTests.swift`:

```
import Foundation
import Testing
@testable import ArmageddonCore
```

Cover:
1. Parse a valid 9×9 UART blob (possibly split across two append calls) including one black stone; check stone(row:column:)
2. `addedStone(since:)` detects exactly one new black stone
3. `addedStone` throws `notSingleMove` if two cells change or size differs
4. malformed row length increments malformedLineCount and throws
5. oversized line increments oversizedLineCount
6. comments and blank lines ignored
7. ascii() round-trips size and stones

Use `@Test("...")` Swift Testing, not XCTest.
Do not touch USB, files on disk, or network.
Assume BoardGrid, BoardGridDecoder, BoardGridError, GoStone exist.

Output only the Swift file.
