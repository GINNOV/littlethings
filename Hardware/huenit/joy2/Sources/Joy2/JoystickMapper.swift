public struct JoystickMapper: Sendable {
    private var previousRightFire = false

    public init() {}

    public mutating func map(_ sample: JoystickSample) -> (intent: PilotIntent, highlights: HighlightSet) {
        guard sample.connected else {
            previousRightFire = false
            return (.none, HighlightSet())
        }

        var cells = Set<PadCell>()
        var intent: PilotIntent = .none

        if sample.leftFire {
            cells.insert(.zAngleMode)
        }

        let risingRight = sample.rightFire && !previousRightFire
        previousRightFire = sample.rightFire
        if sample.rightFire {
            cells.insert(.suction)
        }
        if risingRight {
            intent = .toggleVacuum
        }

        let vector = sample.leftFire ? zAngleVector(sample.direction) : xyVector(sample.direction)
        if !vector.isZero {
            if !risingRight {
                intent = .jog(vector)
            }
            cells.formUnion(highlights(for: vector, zMode: sample.leftFire))
        }

        return (intent, HighlightSet(cells))
    }

    private func xyVector(_ d: StickDirection) -> JogVector {
        switch d {
        case .center: JogVector(dx: 0, dy: 0, dz: 0, de: 0)
        case .n: JogVector(dx: 0, dy: 1, dz: 0, de: 0)
        case .ne: JogVector(dx: -1, dy: 1, dz: 0, de: 0)
        case .e: JogVector(dx: -1, dy: 0, dz: 0, de: 0)
        case .se: JogVector(dx: -1, dy: -1, dz: 0, de: 0)
        case .s: JogVector(dx: 0, dy: -1, dz: 0, de: 0)
        case .sw: JogVector(dx: 1, dy: -1, dz: 0, de: 0)
        case .w: JogVector(dx: 1, dy: 0, dz: 0, de: 0)
        case .nw: JogVector(dx: 1, dy: 1, dz: 0, de: 0)
        }
    }

    private func zAngleVector(_ d: StickDirection) -> JogVector {
        switch d {
        case .center: JogVector(dx: 0, dy: 0, dz: 0, de: 0)
        case .n: JogVector(dx: 0, dy: 0, dz: 1, de: 0)
        case .s: JogVector(dx: 0, dy: 0, dz: -1, de: 0)
        case .e: JogVector(dx: 0, dy: 0, dz: 0, de: 1)
        case .w: JogVector(dx: 0, dy: 0, dz: 0, de: -1)
        case .ne: JogVector(dx: 0, dy: 0, dz: 1, de: 1)
        case .nw: JogVector(dx: 0, dy: 0, dz: 1, de: -1)
        case .se: JogVector(dx: 0, dy: 0, dz: -1, de: 1)
        case .sw: JogVector(dx: 0, dy: 0, dz: -1, de: -1)
        }
    }

    private func highlights(for vector: JogVector, zMode: Bool) -> Set<PadCell> {
        var cells = Set<PadCell>()
        if zMode {
            if vector.dz > 0 { cells.insert(.zPlus) }
            if vector.dz < 0 { cells.insert(.zMinus) }
            if vector.de > 0 { cells.insert(.ePlus) }
            if vector.de < 0 { cells.insert(.eMinus) }
            cells.insert(.zAngleMode)
        } else {
            if vector.dx > 0 { cells.insert(.xPlus) }
            if vector.dx < 0 { cells.insert(.xMinus) }
            if vector.dy > 0 { cells.insert(.yPlus) }
            if vector.dy < 0 { cells.insert(.yMinus) }
            if vector.dx > 0 && vector.dy > 0 { cells.insert(.xyNE) }
            if vector.dx < 0 && vector.dy > 0 { cells.insert(.xyNW) }
            if vector.dx > 0 && vector.dy < 0 { cells.insert(.xySE) }
            if vector.dx < 0 && vector.dy < 0 { cells.insert(.xySW) }
        }
        return cells
    }
}
