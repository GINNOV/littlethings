import Foundation

public enum GoPlayState: Sendable, Equatable {
    case idle
    case inGame
    case readingBoard
    case deciding
    case awaitingConfirm(human: BoardStoneDelta, reply: GoIntersection)
    case failed(String)
}

public struct GoPlayTurn: Sendable, Equatable {
    public let human: BoardStoneDelta
    public let reply: GoIntersection
    public let grid: BoardGrid
}

public protocol BoardGridSourcing: Sendable {
    func readGrid() async throws -> BoardGrid
}

public actor QueueBoardGridSource: BoardGridSourcing {
    private var grids: [BoardGrid]

    public init(grids: [BoardGrid] = []) {
        self.grids = grids
    }

    public func enqueue(_ grid: BoardGrid) {
        grids.append(grid)
    }

    public func readGrid() async throws -> BoardGrid {
        guard !grids.isEmpty else {
            throw GoPlayError.noGrid
        }
        return grids.removeFirst()
    }
}

public enum GoPlayError: Error, Equatable, Sendable {
    case noGrid
    case notStarted
    case busy
}

public actor GoPlaySession {
    private let source: any BoardGridSourcing
    private let client: CappellaGoClient
    private let machineColor: GoStone

    public private(set) var state: GoPlayState = .idle
    public private(set) var lastGrid: BoardGrid?

    public init(
        source: any BoardGridSourcing,
        client: CappellaGoClient,
        humanColor: GoStone = .black
    ) {
        self.source = source
        self.client = client
        self.machineColor = humanColor == .black ? .white : .black
    }

    public func startGame() async throws -> BoardGrid {
        if case .readingBoard = state { throw GoPlayError.busy }
        if case .deciding = state { throw GoPlayError.busy }
        state = .readingBoard
        do {
            let grid = try await source.readGrid()
            lastGrid = grid
            state = .inGame
            return grid
        } catch {
            state = .failed(String(describing: error))
            throw error
        }
    }

    public func humanMoved() async throws -> GoPlayTurn {
        guard state == .inGame || isAwaitingConfirm, let previous = lastGrid else {
            throw GoPlayError.notStarted
        }
        state = .readingBoard
        do {
            let grid = try await source.readGrid()
            let human = try grid.addedStone(since: previous)
            lastGrid = grid
            state = .deciding
            let reply = try await client.requestMove(grid: grid, toPlay: machineColor)
            let turn = GoPlayTurn(human: human, reply: reply, grid: grid)
            state = .awaitingConfirm(human: human, reply: reply)
            return turn
        } catch {
            state = .failed(String(describing: error))
            throw error
        }
    }

    public func acknowledgePlace() throws {
        guard case .awaitingConfirm(_, let reply) = state else {
            throw GoPlayError.busy
        }
        guard var cells = lastGrid?.cells, let size = lastGrid?.size else {
            throw GoPlayError.notStarted
        }
        let index = reply.row * size + reply.column
        guard cells.indices.contains(index), cells[index] == .empty else {
            throw GoPlayError.busy
        }
        cells[index] = machineColor
        lastGrid = try BoardGrid(size: size, cells: cells)
        state = .inGame
    }

    private var isAwaitingConfirm: Bool {
        if case .awaitingConfirm = state { return true }
        return false
    }
}
