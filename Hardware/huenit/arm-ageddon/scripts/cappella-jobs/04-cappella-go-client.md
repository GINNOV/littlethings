Write a single Swift 6 file `CappellaGoClient.swift` for ArmageddonCore (import Foundation).

Existing types (do not redefine BoardGrid/GoStone except you may assume):

```swift
public enum GoStone: String, Sendable { case empty, black, white }
public struct BoardGrid: Sendable, Equatable {
  public let size: Int
  public let cells: [GoStone]
  public func ascii() -> String
  public func stone(row: Int, column: Int) -> GoStone
}
```

Injected HTTP so ordinary tests never hit the network:

```swift
public protocol HTTPPosting: Sendable {
  func post(url: URL, headers: [String: String], body: Data) async throws -> Data
}

public struct GoIntersection: Sendable, Equatable {
  public let row: Int
  public let column: Int
}

public enum CappellaGoClientError: Error, Equatable, Sendable {
  case invalidURL, emptyResponse, unparseableMove, illegalIntersection, httpStatus
}

public actor CappellaGoClient {
  public init(baseURL: URL, model: String, poster: any HTTPPosting, sessionPath: String = "/chat/completions")
  public func requestMove(grid: BoardGrid, toPlay: GoStone) async throws -> GoIntersection
}
```

Behavior:
- POST `{baseURL}{sessionPath}` JSON OpenAI chat completions
- model from init
- Authorization not required (LAN). Header Content-Type application/json
- User content: the grid ascii() plus `toPlay=black|white` and instruction: reply with ONE line `{"row":n,"column":n}` 0-indexed from top-left, empty point only
- Parse the assistant `choices[0].message.content` (also tolerate a markdown fence). Extract JSON object with row/column Int
- Throw illegalIntersection if row/col out of 0..<size or cell is not empty
- Throw unparseableMove if JSON missing
- Do not import Network beyond URLSession; do not create a live URLSession inside the actor — only use `poster`
- Also provide `public struct URLSessionHTTPPoster: HTTPPosting` that uses URLSession.shared for operator live smoke (not used by tests)

Output only the Swift file.
