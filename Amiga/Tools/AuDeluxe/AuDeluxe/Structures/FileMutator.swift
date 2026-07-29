import Foundation

enum FileOperationError: LocalizedError, Equatable, Identifiable {
    case accessDenied
    case destinationExists(URL)
    case mutationFailed(String)
    case rollbackFailed(String)

    var id: String { errorDescription ?? String(describing: self) }

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            "AuDeluxe could not access the selected music folder."
        case .destinationExists(let url):
            "A file named “\(url.lastPathComponent)” already exists."
        case .mutationFailed(let message):
            "The file could not be updated: \(message)"
        case .rollbackFailed(let message):
            "The update failed and the original filename could not be restored: \(message)"
        }
    }
}

enum FileMutator {
    static func update(
        from originalURL: URL,
        to destinationURL: URL,
        writeMetadata: (URL) throws -> Void
    ) throws {
        let shouldRename = originalURL.standardizedFileURL != destinationURL.standardizedFileURL

        if shouldRename, FileManager.default.fileExists(atPath: destinationURL.path) {
            throw FileOperationError.destinationExists(destinationURL)
        }

        do {
            if shouldRename {
                try FileManager.default.moveItem(at: originalURL, to: destinationURL)
            }
            try writeMetadata(shouldRename ? destinationURL : originalURL)
        } catch let operationError {
            guard shouldRename, FileManager.default.fileExists(atPath: destinationURL.path) else {
                throw FileOperationError.mutationFailed(operationError.localizedDescription)
            }
            do {
                try FileManager.default.moveItem(at: destinationURL, to: originalURL)
            } catch {
                throw FileOperationError.rollbackFailed(error.localizedDescription)
            }
            throw FileOperationError.mutationFailed(operationError.localizedDescription)
        }
    }
}
