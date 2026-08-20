import Darwin
import Foundation

public enum SupportBundleExporter {
    public static func export(
        to outputURL: URL,
        appVersion: String,
        toolVersion: String,
        events: [DiagnosticEvent],
        snapshot: DiagnosticSnapshot
    ) throws -> URL {
        let outputURL = outputURL.standardizedFileURL
        guard !FileManager.default.fileExists(atPath: outputURL.path) else {
            throw DiagnosticsError.outputExists(outputURL.path)
        }
        let stagingURL = outputURL.deletingPathExtension()
            .appendingPathExtension("\(UUID().uuidString).staging")
        try FileManager.default.createDirectory(at: stagingURL, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try write(try encoder.encode(events) + Data("\n".utf8), to: stagingURL.appendingPathComponent("events.json"))
            try write(try encoder.encode(snapshot) + Data("\n".utf8), to: stagingURL.appendingPathComponent("snapshot.json"))
            let members = try ["events.json", "snapshot.json"].map { filename in
                let data = try Data(contentsOf: stagingURL.appendingPathComponent(filename))
                return SupportBundleMember(filename: filename, sha256: CaptureHashing.sha256(data), byteCount: data.count)
            }
            let manifest = SupportBundleManifest(
                appVersion: sanitized(appVersion),
                toolVersion: sanitized(toolVersion),
                members: members
            )
            try write(try encoder.encode(manifest) + Data("\n".utf8), to: stagingURL.appendingPathComponent("manifest.json"))
            let zipURL = outputURL.pathExtension == "zip" ? outputURL : outputURL.appendingPathExtension("zip")
            try zip(stagingURL, to: zipURL)
            try FileManager.default.removeItem(at: stagingURL)
            return zipURL
        } catch {
            try? FileManager.default.removeItem(at: stagingURL)
            throw error
        }
    }

    private static func sanitized(_ value: String) -> String {
        let value = value.replacingOccurrences(of: "\n", with: " ")
        return value.contains("/") || value.contains("\\") ? "redacted" : String(value.prefix(128))
    }

    private static func write(_ data: Data, to url: URL) throws {
        let descriptor = Darwin.open(url.path, O_WRONLY | O_CREAT | O_EXCL, mode_t(0o600))
        guard descriptor >= 0 else { throw DiagnosticsError.outputExists(url.path) }
        var closeRequired = true
        defer { if closeRequired { _ = Darwin.close(descriptor) } }
        try data.withUnsafeBytes { buffer in
            var offset = 0
            while offset < buffer.count {
                let written = Darwin.write(descriptor, buffer.baseAddress!.advanced(by: offset), buffer.count - offset)
                guard written > 0 else { throw DiagnosticsError.exportFailed("write") }
                offset += written
            }
        }
        guard Darwin.fsync(descriptor) == 0, Darwin.close(descriptor) == 0 else {
            throw DiagnosticsError.exportFailed("fsync")
        }
        closeRequired = false
    }

    private static func zip(_ directory: URL, to output: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-c", "-k", "--sequesterRsrc", "--keepParent", directory.path, output.path]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { throw DiagnosticsError.exportFailed("zip") }
    }
}
