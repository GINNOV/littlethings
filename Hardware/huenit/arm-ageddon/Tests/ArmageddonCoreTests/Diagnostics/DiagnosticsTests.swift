import Foundation
import Testing
@testable import ArmageddonCore

struct DiagnosticsTests {
    @Test("event log keeps a bounded rolling window")
    func boundedRollingWindow() async throws {
        let log = try DiagnosticEventLog(limit: 100_000)
        for index in 0..<100_050 {
            _ = await log.append(
                occurredAt: MonotonicInstant(nanoseconds: UInt64(index)),
                generation: 1,
                category: .storage,
                severity: .info,
                code: "event",
                message: "event \(index)"
            )
        }
        let events = await log.snapshot()
        #expect(events.count == 100_000)
        #expect(events.first?.id == 50)
        #expect(events.last?.id == 100_049)
    }

    @Test("event metadata redacts paths and unknown fields")
    func eventRedaction() {
        let event = DiagnosticEvent(
            id: 1,
            occurredAt: MonotonicInstant(nanoseconds: 1),
            generation: 1,
            category: .storage,
            severity: .warning,
            code: "metadata",
            message: "secret-token /Users/example/frame.jpg",
            metadata: [
                "path": "/Users/example/private",
                "reason": "safe",
                "secret": "do-not-export"
            ]
        )
        #expect(event.message == "redacted")
        #expect(event.metadata["path"] == nil)
        #expect(event.metadata["secret"] == nil)
        #expect(event.metadata["reason"] == "safe")
    }

    @Test("support export contains only allowlisted hashed members")
    func supportExport() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("armageddon-support-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let event = DiagnosticEvent(
            id: 1,
            occurredAt: MonotonicInstant(nanoseconds: 1),
            generation: 1,
            category: .capture,
            severity: .info,
            code: "captured",
            message: "frame captured",
            metadata: ["modelHash": String(repeating: "a", count: 64)]
        )
        let snapshot = DiagnosticSnapshot(
            generatedAt: MonotonicInstant(nanoseconds: 2),
            states: ["capture": "ready"],
            metrics: ["latencyMilliseconds": 20],
            modelHashes: [String(repeating: "b", count: 64)]
        )
        let zip = try SupportBundleExporter.export(
            to: root.appendingPathExtension("zip"),
            appVersion: "1.0",
            toolVersion: "swift",
            events: [event],
            snapshot: snapshot
        )
        #expect(FileManager.default.fileExists(atPath: zip.path))
        let listing = try shell("/usr/bin/unzip", arguments: ["-Z1", zip.path])
        #expect(listing.contains("events.json"))
        #expect(listing.contains("snapshot.json"))
        #expect(listing.contains("manifest.json"))
        #expect(!listing.localizedCaseInsensitiveContains("frame.jpg"))
        #expect(!listing.localizedCaseInsensitiveContains("secret"))
    }

    private func shell(_ executable: String, arguments: [String]) throws -> String {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { throw DiagnosticsError.exportFailed("listing") }
        return String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    }
}
