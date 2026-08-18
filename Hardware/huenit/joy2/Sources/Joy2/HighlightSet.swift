public struct HighlightSet: Equatable, Sendable {
    public var cells: Set<PadCell>

    public init(_ cells: Set<PadCell> = []) {
        self.cells = cells
    }

    public func contains(_ cell: PadCell) -> Bool { cells.contains(cell) }
}
