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
struct PatternCell: Identifiable, Equatable {
    let id: String  // Composite ID for better performance
    let text: String
    let type: CellType
    let position: Int
    
    init(text: String, type: CellType, position: Int) {
        self.position = position
        self.id = "\(type)-\(text)-\(position)"
        self.text = text
        self.type = type
    }
    
    static func == (lhs: PatternCell, rhs: PatternCell) -> Bool {
        lhs.type == rhs.type && lhs.text == rhs.text && lhs.position == rhs.position
    }
    
    enum CellType {
        case rowNumber, note, instrument, volume, effect, effectParam
    }
}
