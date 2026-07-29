import Foundation
import Testing
@testable import AuDeluxe

struct LibraryFingerprintTests {
    @Test("Nested module changes alter the library fingerprint")
    func nestedModuleChangeAltersFingerprint() throws {
        // Given
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let nested = root.appendingPathComponent("Nested")
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        let module = nested.appendingPathComponent("song.mod")
        try Data("first".utf8).write(to: module)
        defer { try? FileManager.default.removeItem(at: root) }
        let original = try LibraryFingerprint.discover(in: root).fingerprint

        // When
        try Data("updated content".utf8).write(to: module)
        let updated = try LibraryFingerprint.discover(in: root).fingerprint

        // Then
        #expect(updated != original)
    }

    @Test("Unrelated files do not affect the library fingerprint")
    func unrelatedFilesDoNotAffectFingerprint() throws {
        // Given
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try Data("module".utf8).write(to: root.appendingPathComponent("song.mod"))
        let original = try LibraryFingerprint.discover(in: root).fingerprint
        defer { try? FileManager.default.removeItem(at: root) }

        // When
        try Data("notes".utf8).write(to: root.appendingPathComponent("notes.txt"))
        let updated = try LibraryFingerprint.discover(in: root).fingerprint

        // Then
        #expect(updated == original)
    }
}
