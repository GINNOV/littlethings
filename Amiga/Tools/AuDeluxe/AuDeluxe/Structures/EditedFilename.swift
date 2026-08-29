import Foundation

enum EditedFilename {
    static func destinationURL(for originalURL: URL, editedFilename: String) throws -> URL {
        let filename = editedFilename.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !filename.isEmpty, filename == URL(fileURLWithPath: filename).lastPathComponent else {
            throw FileOperationError.mutationFailed("Enter a filename without folder separators.")
        }
        return originalURL.deletingLastPathComponent().appendingPathComponent(filename)
    }
}
