import Darwin
import CryptoKit
import Foundation

let arguments = Array(CommandLine.arguments.dropFirst())
if arguments == ["--help"] || arguments == ["-h"] {
    print("Usage: ModelFixtureGenerator --output PATH")
    exit(0)
}
guard arguments.count == 2, arguments[0] == "--output" else {
    FileHandle.standardError.write(Data("ERROR: expected --output MANIFEST.armmodel.json\n".utf8))
    exit(2)
}

let manifestURL = URL(fileURLWithPath: arguments[1]).standardizedFileURL
let artifactURL = manifestURL.deletingLastPathComponent().appendingPathComponent("fixture.v2.fixture")
try? FileManager.default.createDirectory(
    at: manifestURL.deletingLastPathComponent(),
    withIntermediateDirectories: true,
    attributes: [.posixPermissions: 0o700]
)

let fixture = Data("{\"class\":\"fixture-object\",\"confidence\":1,\"schemaVersion\":1,\"type\":\"constant-output-detector\"}\n".utf8)
let hash = SHA256.hash(data: fixture).map { String(format: "%02x", $0) }.joined()
let manifest = """
{\"artifact\":{\"fileName\":\"fixture.v2.fixture\",\"kind\":\"fixture\",\"sha256\":\"\(hash)\"},\"detector\":{\"confidenceThreshold\":0.5,\"identifier\":\"fixture.v2\",\"input\":{\"height\":224,\"kind\":\"image\",\"width\":224},\"kind\":\"objectDetection\",\"labels\":[\"target\",\"other\"],\"nmsIoUThreshold\":0.5,\"output\":{\"kind\":\"visionObjects\"},\"schemaVersion\":1,\"sha256\":\"\(hash)\"},\"displayName\":\"Constant output fixture v2\",\"identifier\":\"fixture.v2\",\"minimumOS\":\"15.0\",\"schemaVersion\":1,\"smokeFrameCount\":30}
"""

func writeExclusive(_ data: Data, to url: URL) -> Bool {
    let descriptor = open(url.path, O_WRONLY | O_CREAT | O_EXCL, 0o600)
    guard descriptor >= 0 else { return false }
    let written = data.withUnsafeBytes { write(descriptor, $0.baseAddress, $0.count) }
    let result = written == data.count && fsync(descriptor) == 0 && close(descriptor) == 0
    if !result { _ = close(descriptor) }
    return result
}

guard writeExclusive(fixture, to: artifactURL), writeExclusive(Data(manifest.utf8), to: manifestURL) else {
    FileHandle.standardError.write(Data("ERROR: output or artifact already exists, or fixture write failed\n".utf8))
    exit(2)
}
