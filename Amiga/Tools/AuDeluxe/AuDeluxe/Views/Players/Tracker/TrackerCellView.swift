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
            .frame(width: widthFor(type: cell.type), alignment: .leading)
            .padding(.horizontal, 2)
            .drawingGroup()  // Improve rendering performance
    }
    
    private func colorFor(cell: PatternCell) -> Color {
        switch cell.type {
        case .rowNumber: return .yellow
        case .note: return .white
        case .instrument: return .cyan
        case .volume: return .green
        case .effect, .effectParam: return .pink
        }
    }
    
    private func widthFor(type: PatternCell.CellType) -> CGFloat {
        switch type {
        case .rowNumber: return 30
        case .note: return 45
        case .instrument: return 30
        case .volume: return 30
        case .effect: return 25
        case .effectParam: return 30
        }
    }
}

