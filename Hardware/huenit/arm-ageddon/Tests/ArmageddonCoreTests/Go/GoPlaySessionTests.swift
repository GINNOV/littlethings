import Foundation
import Testing
@testable import ArmageddonCore

private struct ScriptedPoster: HTTPPosting {
    func post(url: URL, headers: [String: String], body: Data) async throws -> Data {
        _ = url
        _ = headers
        _ = body
        return Data(#"{"choices":[{"message":{"content":"{\"row\":8,\"column\":8}"}}]}"#.utf8)
    }
}

struct GoPlaySessionTests {
    @Test("I moved diffs the grid and asks the injected decision client")
    func humanMovedProducesReply() async throws {
        let empty = try BoardGrid(size: 9, cells: Array(repeating: .empty, count: 81))
        var withHuman = empty.cells
        withHuman[0] = .black
        let afterHuman = try BoardGrid(size: 9, cells: withHuman)
        let source = QueueBoardGridSource(grids: [empty, afterHuman])
        let client = CappellaGoClient(
            baseURL: URL(string: "http://192.168.0.69:8888/v1")!,
            model: "qwen3.8-27b-sglang",
            poster: ScriptedPoster()
        )
        let session = GoPlaySession(source: source, client: client)
        let baseline = try await session.startGame()
        #expect(baseline.stone(row: 0, column: 0) == .empty)
        let turn = try await session.humanMoved()
        #expect(turn.human.row == 0)
        #expect(turn.human.column == 0)
        #expect(turn.human.stone == .black)
        #expect(turn.reply == GoIntersection(row: 8, column: 8))
        try await session.acknowledgePlace()
        let state = await session.state
        #expect(state == .inGame)
        let placed = await session.lastGrid
        #expect(placed?.stone(row: 8, column: 8) == .white)
    }

    @Test("humanMoved before startGame fails")
    func requiresStart() async throws {
        let empty = try BoardGrid(size: 9, cells: Array(repeating: .empty, count: 81))
        let source = QueueBoardGridSource(grids: [empty])
        let client = CappellaGoClient(
            baseURL: URL(string: "http://192.168.0.69:8888/v1")!,
            model: "qwen3.8-27b-sglang",
            poster: ScriptedPoster()
        )
        let session = GoPlaySession(source: source, client: client)
        await #expect(throws: GoPlayError.notStarted) {
            _ = try await session.humanMoved()
        }
    }
}
