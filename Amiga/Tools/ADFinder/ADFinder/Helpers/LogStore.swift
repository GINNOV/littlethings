//
//  LogStore.swift
//  ADFinder
//
//  Created by Mario Esposito on 6/13/25.
//

import Foundation
import Observation

struct LogEntry: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let text: String


    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    var formattedTimestamp: String {
        return LogEntry.formatter.string(from: timestamp)
    }

    init(text: String) {
        self.timestamp = Date()
        self.text = text
    }
}


@Observable
@MainActor
class LogStore {
    static let shared = LogStore()
    
    private(set) var messages: [LogEntry] = []
    
    private init() {}
    
    func add(message: String) {
        let cleanedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanedMessage.isEmpty {
            messages.append(LogEntry(text: cleanedMessage))
        }
    }
    
    func clear() {
        messages.removeAll()
    }
}
