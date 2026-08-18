public enum PadCell: String, Equatable, Sendable, Hashable, CaseIterable {
    case xPlus, xMinus, yPlus, yMinus
    case xyNE, xyNW, xySE, xySW
    case zPlus, zMinus, ePlus, eMinus
    case suction, zAngleMode
}
