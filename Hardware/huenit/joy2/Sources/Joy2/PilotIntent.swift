public struct JogVector: Equatable, Sendable {
    public var dx: Int
    public var dy: Int
    public var dz: Int
    public var de: Int

    public init(dx: Int, dy: Int, dz: Int, de: Int) {
        self.dx = dx
        self.dy = dy
        self.dz = dz
        self.de = de
    }

    public var isZero: Bool { dx == 0 && dy == 0 && dz == 0 && de == 0 }
}

public enum PilotIntent: Equatable, Sendable {
    case none
    case jog(JogVector)
    case toggleVacuum
    case stop
}
