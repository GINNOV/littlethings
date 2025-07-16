//
//  TrackerCellView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

// A view for a single cell in the tracker grid.
// Breaking this out helps the compiler process the main view.
struct TrackerCellView: View {
    let cell: PatternCell

    var body: some View {
        Text(cell.text)
            .font(.system(size: 14, weight: .regular, design: .monospaced))
            .foregroundColor(colorFor(cell: cell))
    }

    // Helper to select color based on cell type for that classic tracker look
    private func colorFor(cell: PatternCell) -> Color {
        switch cell.type {
        case .rowNumber:
            return .yellow
        case .note:
            return .white
        case .instrument:
            return .cyan
        case .volume:
            return .green
        case .effect, .effectParam:
            return .pink
        }
    }
}
