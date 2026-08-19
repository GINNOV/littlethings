import CryptoKit
import Darwin
import Foundation

enum ScopeBootstrap {
    private struct ReadyReceipt: Encodable {
        let birthIdentity: String
        let executable: String
        let executableSHA256: String
        let launchReceipt: String
        let launchSHA256: String
        let pid: Int32
    }

    static func prepare(_ scope: ScopeArguments?) throws {
        guard let scope else { return }
        let launchData = try Data(contentsOf: scope.launchReceipt, options: [.mappedIfSafe])
        guard let launch = try JSONSerialization.jsonObject(with: launchData) as? [String: Any],
              launch["kind"] as? String == "process-launch",
              launch["preexecBarrier"] as? Bool == true,
              let child = launch["child"] as? [String: Any],
              child["pid"] as? Int == Int(getpid()),
              let birthIdentity = child["birthAndCommand"] as? String else {
            throw ScopeBootstrapError.invalidLaunchReceipt
        }
        let executable = try executableURL()
        let executableHash = hash(try Data(contentsOf: executable, options: [.mappedIfSafe]))
        guard launch["executable"] as? String == executable.path, launch["executableSHA256"] as? String == executableHash else {
            throw ScopeBootstrapError.invalidLaunchReceipt
        }
        let value = ReadyReceipt(birthIdentity: birthIdentity, executable: executable.path, executableSHA256: executableHash, launchReceipt: scope.launchReceipt.path, launchSHA256: hash(launchData), pid: getpid())
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value) + Data("\n".utf8)
        try exclusiveWrite(data, to: scope.readyReceipt)
        let gate = open(scope.gate.path, O_RDONLY)
        guard gate >= 0 else { throw ScopeBootstrapError.system(errno) }
        defer { close(gate) }
        var token: UInt8 = 0
        guard read(gate, &token, 1) == 1, token == 49 else {
            throw ScopeBootstrapError.invalidGateToken
        }
    }

    private static func executableURL() throws -> URL {
        guard let path = Bundle.main.executablePath else { throw ScopeBootstrapError.missingExecutable }
        return URL(fileURLWithPath: path)
    }

    private static func hash(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private static func exclusiveWrite(_ data: Data, to url: URL) throws {
        let descriptor = open(url.path, O_WRONLY | O_CREAT | O_EXCL, 0o600)
        guard descriptor >= 0 else { throw ScopeBootstrapError.system(errno) }
        defer { close(descriptor) }
        let written = try data.withUnsafeBytes { bytes in
            guard write(descriptor, bytes.baseAddress, bytes.count) == bytes.count else { throw ScopeBootstrapError.system(errno) }
            return bytes.count
        }
        guard written == data.count, fsync(descriptor) == 0 else { throw ScopeBootstrapError.system(errno) }
        let parent = open(url.deletingLastPathComponent().path, O_RDONLY)
        guard parent >= 0 else { throw ScopeBootstrapError.system(errno) }
        defer { close(parent) }
        guard fsync(parent) == 0 else { throw ScopeBootstrapError.system(errno) }
    }
}

enum ScopeBootstrapError: Error {
    case invalidLaunchReceipt
    case invalidGateToken
    case missingExecutable
    case system(Int32)
}
