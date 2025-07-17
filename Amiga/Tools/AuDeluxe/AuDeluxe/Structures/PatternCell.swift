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
    
    init(text: String, type: CellType) {
        self.id = "\(type)-\(text)"
        self.text = text
        self.type = type
    }
    
    enum CellType {
        case rowNumber, note, instrument, volume, effect, effectParam
    }
}

