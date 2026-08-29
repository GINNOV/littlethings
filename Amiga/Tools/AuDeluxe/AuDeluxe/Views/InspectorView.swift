//
//  InspectorView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct InspectorView: View {
    @Environment(\.dismiss) private var dismiss

    let item: PlaylistItem
    
    @State private var didCopy = false

    private let technicalKeys = ["channels", "patterns", "orders", "instruments", "samples", "subsongs"]

    private var technicalMetadata: [(String, String)] {
        technicalKeys.compactMap { key in
            guard let value = item.metadata[key], !value.isEmpty else { return nil }
            return (metadataLabel(for: key), value)
        }
    }

    private var descriptiveMetadata: [(String, String)] {
        let keys = ["type_long", "tracker", "date", "originaltype_long", "container_long"]
        return keys.compactMap { key in
            guard let value = item.metadata[key], !value.isEmpty else { return nil }
            return (metadataLabel(for: key), value)
        }
    }

    private var moduleMessage: String? {
        let message = item.metadata["message"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawMessage = item.metadata["message_raw"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let message = (message?.isEmpty == false ? message : rawMessage), !message.isEmpty else { return nil }
        return message
    }

    private var warningMessage: String? {
        guard let warning = item.metadata["warnings"]?.trimmingCharacters(in: .whitespacesAndNewlines), !warning.isEmpty else { return nil }
        return warning
    }

    private func metadataLabel(for key: String) -> String {
        switch key {
        case "type_long": "Format"
        case "tracker": "Tracker"
        case "date": "Date"
        case "originaltype_long": "Original Format"
        case "container_long": "Container"
        case "channels": "Channels"
        case "patterns": "Patterns"
        case "orders": "Orders"
        case "instruments": "Instruments"
        case "samples": "Samples"
        case "subsongs": "Subsongs"
        default: key
        }
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
                InfoRow(label: "Folder", value: item.folderName)
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

            if !descriptiveMetadata.isEmpty || !technicalMetadata.isEmpty || moduleMessage != nil || warningMessage != nil {
                VStack(alignment: .leading) {
                    Text("Module Metadata")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(.leading)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(descriptiveMetadata.enumerated()), id: \.offset) { index, entry in
                                InfoRow(label: entry.0, value: entry.1)
                                if index < descriptiveMetadata.count - 1 { Divider() }
                            }
                            if !technicalMetadata.isEmpty {
                                if !descriptiveMetadata.isEmpty { Divider() }
                                ForEach(Array(technicalMetadata.enumerated()), id: \.offset) { index, entry in
                                    InfoRow(label: entry.0, value: entry.1)
                                    if index < technicalMetadata.count - 1 { Divider() }
                                }
                            }
                            if let moduleMessage {
                                Divider()
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Module Notes")
                                        .font(.headline)
                                    Text(moduleMessage)
                                        .font(.body)
                                        .textSelection(.enabled)
                                }
                            }
                            if let warningMessage {
                                Divider()
                                VStack(alignment: .leading, spacing: 6) {
                                    Label("Warnings", systemImage: "exclamationmark.triangle.fill")
                                        .font(.headline)
                                        .foregroundStyle(.orange)
                                    Text(warningMessage)
                                        .font(.body)
                                        .textSelection(.enabled)
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
        .overlay(alignment: .topTrailing) {
            Button("Close", systemImage: "xmark", action: dismiss.callAsFunction)
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .font(.title3)
                .padding()
                .accessibilityHint("Closes song information")
        }
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
        let minuteText = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secondText = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return "\(minuteText):\(secondText)"
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
