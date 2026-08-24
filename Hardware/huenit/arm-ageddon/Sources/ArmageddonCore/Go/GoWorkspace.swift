import Foundation

public struct GoWorkspace: Codable, Sendable, Equatable {
    public var size: Int
    public var originX: Double
    public var originY: Double
    public var stepX: Double
    public var stepY: Double
    public var safeZ: Double
    public var pickZ: Double
    public var placeZ: Double
    public var bowlX: Double
    public var bowlY: Double
    public var bowlZ: Double
    public var feedMmPerMin: Double

    public init(
        size: Int = 9,
        originX: Double,
        originY: Double,
        stepX: Double,
        stepY: Double,
        safeZ: Double,
        pickZ: Double,
        placeZ: Double,
        bowlX: Double,
        bowlY: Double,
        bowlZ: Double,
        feedMmPerMin: Double
    ) {
        self.size = size
        self.originX = originX
        self.originY = originY
        self.stepX = stepX
        self.stepY = stepY
        self.safeZ = safeZ
        self.pickZ = pickZ
        self.placeZ = placeZ
        self.bowlX = bowlX
        self.bowlY = bowlY
        self.bowlZ = bowlZ
        self.feedMmPerMin = feedMmPerMin
    }

    public static let fixture = GoWorkspace(
        originX: 20,
        originY: -90,
        stepX: 22,
        stepY: 22,
        safeZ: 80,
        pickZ: 18,
        placeZ: 18,
        bowlX: 20,
        bowlY: -90,
        bowlZ: 80,
        feedMmPerMin: 300
    )

    public var bowl: ArmCartesianPose {
        ArmCartesianPose(x: bowlX, y: bowlY, z: bowlZ)
    }

    public func cartesian(for move: GoIntersection) throws -> (x: Double, y: Double) {
        guard (0..<size).contains(move.row), (0..<size).contains(move.column) else {
            throw CappellaGoClientError.illegalIntersection
        }
        return (
            originX + Double(move.column) * stepX,
            originY + Double(move.row) * stepY
        )
    }

    public func recordingBowl(_ pose: ArmCartesianPose) -> GoWorkspace {
        var copy = self
        copy.bowlX = pose.x
        copy.bowlY = pose.y
        copy.bowlZ = pose.z
        return copy
    }

    public func recordingOrigin(_ pose: ArmCartesianPose) -> GoWorkspace {
        var copy = self
        copy.originX = pose.x
        copy.originY = pose.y
        return copy
    }

    public func recordingFarCorner(_ pose: ArmCartesianPose, row: Int, column: Int) -> GoWorkspace {
        var copy = self
        let denomRow = Double(max(row, 1))
        let denomCol = Double(max(column, 1))
        copy.stepX = (pose.x - originX) / denomCol
        copy.stepY = (pose.y - originY) / denomRow
        return copy
    }

    public func recordingSafeZ(_ z: Double) -> GoWorkspace {
        var copy = self
        copy.safeZ = z
        return copy
    }

    public func recordingPickZ(_ z: Double) -> GoWorkspace {
        var copy = self
        copy.pickZ = z
        return copy
    }

    public func recordingPlaceZ(_ z: Double) -> GoWorkspace {
        var copy = self
        copy.placeZ = z
        return copy
    }

    public static func load(from url: URL) throws -> GoWorkspace {
        try JSONDecoder().decode(GoWorkspace.self, from: Data(contentsOf: url))
    }

    public func save(to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(self).write(to: url, options: .atomic)
    }
}

public actor FileBoardGridSource: BoardGridSourcing {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func readGrid() async throws -> BoardGrid {
        var data = try Data(contentsOf: url)
        if data.last != 0x0A {
            data.append(0x0A)
        }
        var decoder = BoardGridDecoder()
        guard let grid = try decoder.append(data) else {
            throw GoPlayError.noGrid
        }
        return grid
    }
}

public actor DemoGoBoardSource: BoardGridSourcing {
    private var reads = 0

    public init() {}

    public func readGrid() async throws -> BoardGrid {
        var cells = Array(repeating: GoStone.empty, count: 81)
        if reads >= 1 {
            cells[4 * 9 + 4] = .black
        }
        reads += 1
        return try BoardGrid(size: 9, cells: cells)
    }
}

public struct CannedGoHTTPPoster: HTTPPosting {
    public init() {}

    public func post(url: URL, headers: [String: String], body: Data) async throws -> Data {
        _ = url
        _ = headers
        _ = body
        return Data(#"{"choices":[{"message":{"content":"{\"row\":8,\"column\":8}"}}]}"#.utf8)
    }
}
