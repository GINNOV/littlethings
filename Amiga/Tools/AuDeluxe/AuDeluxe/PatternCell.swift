//
//  PatternCell.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import Foundation
import SwiftUI

// Represents a single cell in the tracker view grid.
// It's identifiable to be used in ForEach loops.
struct PatternCell: Identifiable {
    let id = UUID()
    let text: String
    let type: CellType

    enum CellType {
        case rowNumber, note, instrument, volume, effect, effectParam
    }
}
