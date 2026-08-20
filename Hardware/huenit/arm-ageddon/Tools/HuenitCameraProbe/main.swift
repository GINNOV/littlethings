import ArmageddonCore
import CryptoKit
import Darwin
import Foundation

@main
struct HuenitCameraProbe {
    static func main() throws {
        let arguments = CommandLine.arguments
        let transcriptPath = value(after: "--transcript", in: arguments)
        let outputPath = value(after: "--output", in: arguments)
        let result: HuenitCameraProbeResult

        if let transcriptPath {
            let transcriptURL = URL(fileURLWithPath: transcriptPath).standardizedFileURL
            let data = try Data(contentsOf: transcriptURL, options: [.mappedIfSafe])
            guard let transcript = String(data: data, encoding: .utf8) else {
                throw ProbeError.invalidTranscript
            }
            result = try HuenitCameraProbeResult.parse(
                transcript: transcript,
                sourceHash: CaptureHashing.sha256(data),
                measuredAt: ISO8601DateFormatter().string(from: .now)
            )
        } else {
            guard ProcessInfo.processInfo.environment["ARMAGEDDON_LIVE_CAMERA_PROBE"] == "1" else {
                result = .notMeasured
                try write(result, to: outputPath)
                return
            }
            throw ProbeError.liveProbeRequiresReviewedTransport
        }

        try write(result, to: outputPath)
    }

    private static func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else { return nil }
        return arguments[index + 1]
    }

    private static func write(_ result: HuenitCameraProbeResult, to path: String?) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(result) + Data("\n".utf8)
        guard let path else {
            FileHandle.standardOutput.write(data)
            return
        }
        let url = URL(fileURLWithPath: path).standardizedFileURL
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        let descriptor = Darwin.open(url.path, O_WRONLY | O_CREAT | O_EXCL, mode_t(0o600))
        guard descriptor >= 0 else { throw ProbeError.outputExists }
        var closeRequired = true
        defer { if closeRequired { _ = Darwin.close(descriptor) } }
        try data.withUnsafeBytes { buffer in
            guard Darwin.write(descriptor, buffer.baseAddress, buffer.count) == buffer.count else {
                throw ProbeError.outputWrite
            }
        }
        guard Darwin.fsync(descriptor) == 0, Darwin.close(descriptor) == 0 else {
            throw ProbeError.outputWrite
        }
        closeRequired = false
    }
}

private enum ProbeError: Error {
    case invalidTranscript
    case liveProbeRequiresReviewedTransport
    case outputExists
    case outputWrite
}
