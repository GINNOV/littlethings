//
//  TrackerView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct TrackerView: View {
    @EnvironmentObject private var engine: OpenMPTEngine
    
    // Define column widths for a classic tracker layout
    private var columns: [GridItem] {
        var gridItems: [GridItem] = [GridItem(.fixed(30), spacing: 5)] // Row number column
        
        for _ in 0..<Int(engine.numChannels) {
            gridItems.append(contentsOf: [
                GridItem(.fixed(40), spacing: 2), // Note
                GridItem(.fixed(25), spacing: 2), // Instrument
                GridItem(.fixed(25), spacing: 2), // Volume
                GridItem(.fixed(20), spacing: 2), // Effect
                GridItem(.fixed(25), spacing: 15)  // Effect Param (with larger spacing after)
            ])
        }
        return gridItems
    }

    var body: some View {
        VStack(spacing: 0) {
            if engine.isPlaying {
                ScrollViewReader { proxy in
                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        // The LazyVGrid now iterates over identifiable rows and cells,
                        // which is much simpler for the compiler.
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(engine.patternData) { row in
                                ForEach(row.cells) { cell in
                                    TrackerCellView(cell: cell)
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                    }
                    .background(Color.black)
                    .onChange(of: engine.currentRow) { newRow in
                        // Scrolling is now simpler, using the row's stable ID
                        withAnimation(.linear(duration: 0.1)) {
                            proxy.scrollTo(Int(newRow), anchor: .center)
                        }
                    }
                }
            } else {
                Spacer()
                Text("Play a song to see the tracker data.")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
