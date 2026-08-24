import Foundation

public actor UARTBoardGridSource: BoardGridSourcing {
    private var decoder = BoardGridDecoder()
    private var latest: BoardGrid?

    public init() {}

    public func ingest(_ data: Data) async throws {
        if let grid = try decoder.append(data) {
            latest = grid
        }
    }

    public func readGrid() async throws -> BoardGrid {
        guard let latest else {
            throw GoPlayError.noGrid
        }
        return latest
    }
}
