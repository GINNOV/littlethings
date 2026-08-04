import Foundation
import Testing
@testable import AuDeluxe

struct FileMutatorTests {
    @Test("A rename collision leaves both files untouched")
    func renameCollisionLeavesFilesUntouched() throws {
        // Given
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let original = root.appendingPathComponent("original.mod")
        let destination = root.appendingPathComponent("existing.mod")
        try Data("original".utf8).write(to: original)
        try Data("existing".utf8).write(to: destination)
        defer { try? FileManager.default.removeItem(at: root) }
        var metadataWasWritten = false

        // When
        let error = #expect(throws: FileOperationError.self) {
            try FileMutator.update(from: original, to: destination) { _ in
                metadataWasWritten = true
            }
        }

        // Then
        #expect(error == .destinationExists(destination))
        #expect(!metadataWasWritten)
        #expect(try Data(contentsOf: original) == Data("original".utf8))
        #expect(try Data(contentsOf: destination) == Data("existing".utf8))
    }

    @Test("A metadata failure rolls a rename back")
    func metadataFailureRollsRenameBack() throws {
        // Given
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let original = root.appendingPathComponent("original.mod")
        let destination = root.appendingPathComponent("renamed.mod")
        try Data("original".utf8).write(to: original)
        defer { try? FileManager.default.removeItem(at: root) }

        // When
        #expect(throws: FileOperationError.self) {
            try FileMutator.update(from: original, to: destination) { _ in
                throw CocoaError(.fileWriteNoPermission)
            }
        }

        // Then
        #expect(FileManager.default.fileExists(atPath: original.path))
        #expect(!FileManager.default.fileExists(atPath: destination.path))
    }
}
