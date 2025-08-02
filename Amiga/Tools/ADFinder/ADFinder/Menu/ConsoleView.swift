//
//  ConsoleView.swift
//  ADFinder
//
//  Created by Mario Esposito on 6/13/25.
//

import SwiftUI
import AppKit // Required for NSPasteboard

struct ConsoleView: View {
    @Environment(LogStore.self) private var logStore
    @State private var autoScroll = true
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(logStore.messages) { entry in
                            HStack(alignment: .top, spacing: 8) {
                                Text(entry.formattedTimestamp)
                                    .foregroundColor(.secondary)
                                
                                Text(entry.text)
                                    .textSelection(.enabled)
                            }
                            .padding(.horizontal, 8)
                            .id(entry.id)
                        }
                    }
                }
                .font(.system(.body, design: .monospaced))
                .onChange(of: logStore.messages.count) {
                    if autoScroll, let lastMessageId = logStore.messages.last?.id {
                        proxy.scrollTo(lastMessageId, anchor: .bottom)
                    }
                }
            }
            
            Divider()
            
            HStack {
                Toggle(isOn: $autoScroll) {
                    Text("Auto-Scroll")
                }
                .toggleStyle(.checkbox)
                
                Spacer()
                
                // rationale: This new button copies the entire log to the clipboard.
                Button("Copy", systemImage: "doc.on.doc") {
                    copyLogToClipboard()
                }
                .help("Copy the entire log to the clipboard")

                Button("Clear") {
                    logStore.clear()
                }
            }
            .padding(8)
            .background(.bar)
        }
        .frame(minWidth: 600, minHeight: 400)
        .navigationTitle("ADFlib Console")
    }

    private func copyLogToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(logStore.fullLogAsText, forType: .string)
    }
}

#Preview {
    ConsoleView()
        .environment(LogStore.shared)
}
