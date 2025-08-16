//
//  TrackerView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

struct TrackerView: View {
    @EnvironmentObject private var engine: OpenMPTEngine
    @State private var contentOffset: CGPoint = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            // The tracker is now shown as long as a song is loaded (duration > 0)
            if engine.currentSongDuration > 0 {
                TrackerHeaderView(offset: $contentOffset)
                
                ScrollViewReader { proxy in
                    ScrollView([.horizontal, .vertical]) {
                        TrackerContentView()
                            .padding(.vertical, 8)
                            .background(GeometryReader { geo in
                                Color.clear.preference(
                                    key: ViewOffsetKey.self,
                                    value: geo.frame(in: .named("scroll")).origin
                                )
                            })
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ViewOffsetKey.self) { offset in
                        contentOffset = offset
                    }
                    .background(Color.black)
                    // Updated onChange syntax to resolve deprecation warning.
                    .onChange(of: engine.currentRow) { oldValue, newValue in
                        proxy.scrollTo(Int(newValue), anchor: .center)
                    }
                }
            } else {
                placeholderView
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private var placeholderView: some View {
        VStack {
            Spacer()
            Text("Play a song to see the tracker data.")
                .font(.title2)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct TrackerContentView: View {
    @EnvironmentObject private var engine: OpenMPTEngine
    
    var body: some View {
        LazyVStack(spacing: 2) {
            ForEach(engine.visiblePatternRows) { row in
                HStack(spacing: 0) {
                    ForEach(row.cells) { cell in
                        TrackerCellView(cell: cell)
                    }
                }
                .frame(height: 20)
                .background(row.rowNumber == Int(engine.currentRow) ? Color.purple.opacity(0.35) : Color.clear)
            }
        }
    }
}

struct TrackerHeaderView: View {
    @EnvironmentObject private var engine: OpenMPTEngine
    @Binding var offset: CGPoint
    
    var body: some View {
        HStack(spacing: 0) {
            Text("Row")
                .bold()
                .frame(width: 30, alignment: .leading)
                .padding(.horizontal, 2)
            
            ForEach(0..<Int(engine.numChannels), id: \.self) { channel in
                Group {
                    Text("NTE").bold().frame(width: 45, alignment: .leading).padding(.horizontal, 2)
                    Text("INS").bold().frame(width: 30, alignment: .leading).padding(.horizontal, 2)
                    Text("VOL").bold().frame(width: 30, alignment: .leading).padding(.horizontal, 2)
                    Text("EFF").bold().frame(width: 25, alignment: .leading).padding(.horizontal, 2)
                    Text("PRM").bold().frame(width: 30, alignment: .leading).padding(.horizontal, 2)
                }
            }
        }
        .font(.system(size: 10, design: .monospaced))
        .padding(.vertical, 2)
        .offset(x: offset.x)
        .frame(height: 20)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary),
            alignment: .bottom
        )
    }
}
