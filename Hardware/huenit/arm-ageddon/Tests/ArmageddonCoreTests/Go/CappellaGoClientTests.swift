import Foundation
import Testing
@testable import ArmageddonCore

private struct FakePoster: HTTPPosting {
    let body: Data
    func post(url: URL, headers: [String: String], body: Data) async throws -> Data {
        _ = url
        _ = headers
        _ = body
        return self.body
    }
}

struct CappellaGoClientTests {
    @Test("parses a JSON move onto an empty point")
    func parsesMove() async throws {
        let grid = try BoardGrid(size: 9, cells: Array(repeating: .empty, count: 81))
        let payload = """
        {"choices":[{"message":{"content":"{\\"row\\":2,\\"column\\":3}"}}]}
        """
        let client = CappellaGoClient(
            baseURL: URL(string: "http://192.168.0.69:8888/v1")!,
            model: "qwen3.8-27b-sglang",
            poster: FakePoster(body: Data(payload.utf8))
        )
        let move = try await client.requestMove(grid: grid, toPlay: .black)
        #expect(move == GoIntersection(row: 2, column: 3))
    }

    @Test("rejects a stone on an occupied point")
    func occupied() async throws {
        var cells = Array(repeating: GoStone.empty, count: 81)
        cells[0] = .black
        let grid = try BoardGrid(size: 9, cells: cells)
        let payload = """
        {"choices":[{"message":{"content":"{\\"row\\":0,\\"column\\":0}"}}]}
        """
        let client = CappellaGoClient(
            baseURL: URL(string: "http://192.168.0.69:8888/v1")!,
            model: "qwen3.8-27b-sglang",
            poster: FakePoster(body: Data(payload.utf8))
        )
        await #expect(throws: CappellaGoClientError.illegalIntersection) {
            _ = try await client.requestMove(grid: grid, toPlay: .white)
        }
    }

    @Test("rejects unparseable assistant content")
    func unparseable() async throws {
        let grid = try BoardGrid(size: 9, cells: Array(repeating: .empty, count: 81))
        let payload = """
        {"choices":[{"message":{"content":"play the star point"}}]}
        """
        let client = CappellaGoClient(
            baseURL: URL(string: "http://192.168.0.69:8888/v1")!,
            model: "qwen3.8-27b-sglang",
            poster: FakePoster(body: Data(payload.utf8))
        )
        await #expect(throws: CappellaGoClientError.unparseableMove) {
            _ = try await client.requestMove(grid: grid, toPlay: .black)
        }
    }
}
