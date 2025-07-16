//
//  PatternRow.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import Foundation

// Represents a single, identifiable row in the tracker view.
// Using the row number as the ID provides a stable identity for SwiftUI.
struct PatternRow: Identifiable {
    let id: Int
    let cells: [PatternCell]
}
