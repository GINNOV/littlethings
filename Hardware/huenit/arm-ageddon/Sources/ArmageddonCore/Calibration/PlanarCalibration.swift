import Foundation

public struct CalibrationPoint: Codable, Equatable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public var isFinite: Bool { x.isFinite && y.isFinite }
}

public struct CalibrationCorrespondence: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let source: CalibrationPoint
    public let workspace: CalibrationPoint
    public let isValidation: Bool

    public init(
        id: UUID = UUID(),
        source: CalibrationPoint,
        workspace: CalibrationPoint,
        isValidation: Bool
    ) {
        self.id = id
        self.source = source
        self.workspace = workspace
        self.isValidation = isValidation
    }
}

public struct CalibrationPolygon: Codable, Equatable, Sendable {
    public let vertices: [CalibrationPoint]

    public init(vertices: [CalibrationPoint]) throws {
        guard vertices.count >= 3,
              vertices.allSatisfy(\.isFinite),
              abs(Self.signedArea(vertices)) > 0.000_001,
              Self.isSimple(vertices) else {
            throw CalibrationError.invalidWorkspacePolygon
        }
        self.vertices = vertices
    }

    public var area: Double { abs(Self.signedArea(vertices)) }

    private static func signedArea(_ points: [CalibrationPoint]) -> Double {
        zip(points, points.dropFirst() + points.prefix(1)).reduce(0) { partial, pair in
            partial + pair.0.x * pair.1.y - pair.1.x * pair.0.y
        } / 2
    }

    private static func isSimple(_ points: [CalibrationPoint]) -> Bool {
        for first in points.indices {
            let second = (first + 1) % points.count
            for other in (first + 1)..<points.count {
                let next = (other + 1) % points.count
                if first == other || second == other || first == next { continue }
                if segmentsIntersect(points[first], points[second], points[other], points[next]) { return false }
            }
        }
        return true
    }

    private static func segmentsIntersect(
        _ a: CalibrationPoint,
        _ b: CalibrationPoint,
        _ c: CalibrationPoint,
        _ d: CalibrationPoint
    ) -> Bool {
        let ab = orientation(a, b, c)
        let ab2 = orientation(a, b, d)
        let cd = orientation(c, d, a)
        let cd2 = orientation(c, d, b)
        return ((ab > 0 && ab2 < 0) || (ab < 0 && ab2 > 0))
            && ((cd > 0 && cd2 < 0) || (cd < 0 && cd2 > 0))
    }

    private static func orientation(_ a: CalibrationPoint, _ b: CalibrationPoint, _ c: CalibrationPoint) -> Double {
        (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    }
}

public struct CalibrationSafeZBand: Codable, Equatable, Sendable {
    public let minimum: Double
    public let maximum: Double

    public init(minimum: Double, maximum: Double) throws {
        guard minimum.isFinite, maximum.isFinite, minimum < maximum else { throw CalibrationError.invalidSafeZBand }
        self.minimum = minimum
        self.maximum = maximum
    }
}

public struct CalibrationResidual: Codable, Equatable, Sendable {
    public let correspondenceID: UUID
    public let errorMillimeters: Double

    public init(correspondenceID: UUID, errorMillimeters: Double) {
        self.correspondenceID = correspondenceID
        self.errorMillimeters = errorMillimeters
    }
}

public enum CalibrationError: Error, Equatable, Sendable {
    case notEnoughFitPoints
    case notEnoughValidationPoints
    case nonFinitePoint
    case duplicatePoint
    case collinearFitPoints
    case singularSystem
    case invalidWorkspacePolygon
    case invalidSafeZBand
    case errorThresholdExceeded(rms: Double, maximum: Double)
    case bindingMismatch
}

public struct PlanarCalibrationProfile: Codable, Equatable, Sendable, Identifiable {
    public let schemaVersion: Int
    public let id: UUID
    public let deviceID: String
    public let format: CaptureFormat
    public let toolID: String
    public let polygon: CalibrationPolygon
    public let safeZBand: CalibrationSafeZBand
    public let toolOffsetXY: CalibrationPoint
    public let fitPoints: [CalibrationCorrespondence]
    public let validationPoints: [CalibrationCorrespondence]
    public let coefficients: [Double]
    public let rmsErrorMillimeters: Double
    public let maximumValidationErrorMillimeters: Double

    public static let maximumRMSMillimeters = 3.0
    public static let maximumValidationMillimeters = 5.0

    public init(
        id: UUID = UUID(),
        deviceID: String,
        format: CaptureFormat,
        toolID: String,
        polygon: CalibrationPolygon,
        safeZBand: CalibrationSafeZBand,
        toolOffsetXY: CalibrationPoint = CalibrationPoint(x: 0, y: 0),
        correspondences: [CalibrationCorrespondence]
    ) throws {
        guard correspondences.filter({ !$0.isValidation }).count >= 4 else { throw CalibrationError.notEnoughFitPoints }
        guard correspondences.filter(\.isValidation).count >= 2 else { throw CalibrationError.notEnoughValidationPoints }
        guard format.isValid, toolOffsetXY.isFinite, correspondences.allSatisfy({ $0.source.isFinite && $0.workspace.isFinite }) else {
            throw CalibrationError.nonFinitePoint
        }
        let fitPoints = correspondences.filter { !$0.isValidation }
        guard Set(fitPoints.map { "\($0.source.x),\($0.source.y)" }).count == fitPoints.count else {
            throw CalibrationError.duplicatePoint
        }
        guard Self.hasNonCollinearTriangle(fitPoints.map(\.source)) else { throw CalibrationError.collinearFitPoints }
        let coefficients = try Self.solve(fitPoints)
        let validationPoints = correspondences.filter(\.isValidation)
        let residuals = validationPoints.map { point in
            CalibrationResidual(correspondenceID: point.id, errorMillimeters: Self.error(coefficients, point))
        }
        let squared = residuals.map { $0.errorMillimeters * $0.errorMillimeters }
        let rms = sqrt(squared.reduce(0, +) / Double(max(1, squared.count)))
        let maximum = residuals.map(\.errorMillimeters).max() ?? .infinity
        guard rms <= Self.maximumRMSMillimeters, maximum <= Self.maximumValidationMillimeters else {
            throw CalibrationError.errorThresholdExceeded(rms: rms, maximum: maximum)
        }
        schemaVersion = 1
        self.id = id
        self.deviceID = deviceID
        self.format = format
        self.toolID = toolID
        self.polygon = polygon
        self.safeZBand = safeZBand
        self.toolOffsetXY = toolOffsetXY
        self.fitPoints = fitPoints
        self.validationPoints = validationPoints
        self.coefficients = coefficients
        rmsErrorMillimeters = rms
        maximumValidationErrorMillimeters = maximum
    }

    public func transform(_ source: CalibrationPoint) throws -> CalibrationPoint {
        guard source.isFinite, coefficients.count == 8 else { throw CalibrationError.singularSystem }
        let denominator = coefficients[6] * source.x + coefficients[7] * source.y + 1
        guard denominator.isFinite, abs(denominator) > 0.000_000_001 else { throw CalibrationError.singularSystem }
        let x = (coefficients[0] * source.x + coefficients[1] * source.y + coefficients[2]) / denominator + toolOffsetXY.x
        let y = (coefficients[3] * source.x + coefficients[4] * source.y + coefficients[5]) / denominator + toolOffsetXY.y
        guard x.isFinite, y.isFinite else { throw CalibrationError.singularSystem }
        return CalibrationPoint(x: x, y: y)
    }

    public func matches(deviceID: String, format: CaptureFormat, toolID: String) -> Bool {
        deviceID == self.deviceID && format == self.format && toolID == self.toolID
    }

    private static func hasNonCollinearTriangle(_ points: [CalibrationPoint]) -> Bool {
        for first in points.indices {
            for second in (first + 1)..<points.count {
                for third in (second + 1)..<points.count {
                    let area = (points[second].x - points[first].x) * (points[third].y - points[first].y)
                        - (points[second].y - points[first].y) * (points[third].x - points[first].x)
                    if abs(area) > 0.000_001 { return true }
                }
            }
        }
        return false
    }

    private static func solve(_ points: [CalibrationCorrespondence]) throws -> [Double] {
        var normal = Array(repeating: Array(repeating: 0.0, count: 9), count: 8)
        for point in points {
            let x = point.source.x
            let y = point.source.y
            let u = point.workspace.x
            let v = point.workspace.y
            let rows = [
                [x, y, 1, 0, 0, 0, -u * x, -u * y, u],
                [0, 0, 0, x, y, 1, -v * x, -v * y, v]
            ]
            for row in rows {
                for column in 0..<8 {
                    normal[column][0] += row[column] * row[8]
                    for right in 0..<8 { normal[column][right + 1] += row[column] * row[right] }
                }
            }
        }
        var augmented = Array(repeating: Array(repeating: 0.0, count: 9), count: 8)
        for row in 0..<8 {
            for column in 0..<8 { augmented[row][column] = normal[row][column + 1] }
            augmented[row][8] = normal[row][0]
        }
        for pivot in 0..<8 {
            guard let row = (pivot..<8).max(by: { abs(augmented[$0][pivot]) < abs(augmented[$1][pivot]) }),
                  abs(augmented[row][pivot]) > 0.000_000_000_001 else { throw CalibrationError.singularSystem }
            augmented.swapAt(pivot, row)
            let divisor = augmented[pivot][pivot]
            for column in pivot..<9 { augmented[pivot][column] /= divisor }
            for row in 0..<8 where row != pivot {
                let factor = augmented[row][pivot]
                for column in pivot..<9 { augmented[row][column] -= factor * augmented[pivot][column] }
            }
        }
        return augmented.map { $0[8] }
    }

    private static func error(_ coefficients: [Double], _ point: CalibrationCorrespondence) -> Double {
        let denominator = coefficients[6] * point.source.x + coefficients[7] * point.source.y + 1
        guard abs(denominator) > 0.000_000_001 else { return .infinity }
        let x = (coefficients[0] * point.source.x + coefficients[1] * point.source.y + coefficients[2]) / denominator
        let y = (coefficients[3] * point.source.x + coefficients[4] * point.source.y + coefficients[5]) / denominator
        return hypot(x - point.workspace.x, y - point.workspace.y)
    }
}
