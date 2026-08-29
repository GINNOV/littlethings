import Foundation

enum LibraryScanStatus: Equatable {
    case idle
    case discovering
    case processing(
        processed: Int,
        total: Int,
        loaded: Int,
        skipped: Int,
        currentFile: String
    )
    case completed(loaded: Int, skipped: Int, usedCache: Bool)
    case cancelled
    case failed(message: String)

    var isActive: Bool {
        switch self {
        case .discovering, .processing:
            true
        case .idle, .completed, .cancelled, .failed:
            false
        }
    }

    var isVisible: Bool {
        self != .idle
    }

    var progressFraction: Double? {
        switch self {
        case .processing(let processed, let total, _, _, _):
            total > 0 ? Double(processed) / Double(total) : 0
        case .completed:
            1
        case .idle, .discovering, .cancelled, .failed:
            nil
        }
    }

    var statusText: String {
        switch self {
        case .idle:
            ""
        case .discovering:
            "Discovering modules…"
        case .processing(let processed, let total, _, _, _):
            "Processing \(processed.formatted()) of \(total.formatted())"
        case .completed(let loaded, _, let usedCache):
            usedCache
                ? "Loaded \(loaded.formatted()) cached modules"
                : "Loaded \(loaded.formatted()) modules"
        case .cancelled:
            "Scan cancelled"
        case .failed:
            "Scan failed"
        }
    }

    var detailText: String? {
        switch self {
        case .processing(_, _, _, _, let currentFile):
            currentFile.isEmpty ? nil : currentFile
        case .completed(_, let skipped, _):
            skipped == 0 ? nil : "Skipped \(skipped.formatted()) unreadable files"
        case .failed(let message):
            message
        case .idle, .discovering, .cancelled:
            nil
        }
    }
}
