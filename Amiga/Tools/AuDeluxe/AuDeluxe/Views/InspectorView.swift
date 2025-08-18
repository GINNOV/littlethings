//
//  InspectorView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct InspectorView: View {
    let item: PlaylistItem
    
    @State private var didCopy = false

    // Keys that have special handling or are displayed prominently.
    private let excludedKeys = ["title", "artist", "duration"]
    
    // The remaining metadata keys, sorted for a consistent display order.
    private var sortedMetadataKeys: [String] {
        item.metadata.keys.filter { !excludedKeys.contains($0) }.sorted()
    }

    var body: some View {
        VStack(spacing: 18) {
            // --- Header ---
            VStack {
                Text(item.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                if !item.artist.isEmpty {
                    Text("by \(item.artist)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 10)

            // --- Main Details in a rounded box ---
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text("Filename:")
                        .font(.system(.body, design: .monospaced).weight(.bold))
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .trailing)
                    
                    Text(item.fileURL.lastPathComponent)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: copyPath) {
                        Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(didCopy ? .green : .secondary)
                }
                
                Divider()
                InfoRow(label: "Duration", value: formatTime(item.duration))
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )

            // --- Full Metadata ScrollView ---
            if !sortedMetadataKeys.isEmpty {
                VStack(alignment: .leading) {
                    Text("Full Metadata")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(.leading)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(sortedMetadataKeys, id: \.self) { key in
                                InfoRow(label: key.capitalized, value: item.metadata[key] ?? "N/A")
                                if key != sortedMetadataKeys.last {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            
            Spacer()
        }
        .padding(30)
        .frame(minWidth: 550, minHeight: 450)
        .background(.regularMaterial)
    }

    private func copyPath() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.fileURL.path, forType: .string)
        
        didCopy = true
        // Reset the icon after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            didCopy = false
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// A helper subview to keep the row layout consistent.
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.system(.body, design: .monospaced).weight(.bold))
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .trailing)
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
