import ArmageddonCore
import Foundation

let arguments = Array(CommandLine.arguments.dropFirst())
guard arguments.count == 6,
      arguments[0] == "--manifest",
      arguments[2] == "--root",
      arguments[4] == "--mode",
      ["happy", "failure"].contains(arguments[5]) else {
    FileHandle.standardError.write(Data("ERROR: expected --manifest PATH --root PATH --mode happy|failure\n".utf8))
    exit(2)
}

let registry = ModelRegistry(root: URL(fileURLWithPath: arguments[3]))
do {
    try await registry.open()
    let manifestURL = URL(fileURLWithPath: arguments[1])
    _ = try await registry.importAndActivate(manifestURL: manifestURL)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    if arguments[5] == "failure" {
        let activeBefore = try await registry.activeModel()
        let declaredBytes = Data("{\"class\":\"fixture-object\",\"confidence\":1,\"schemaVersion\":1,\"type\":\"constant-output-detector\"}\n".utf8)
        let declaredHash = ModelRegistry.sha256(declaredBytes)
        let incoming = URL(fileURLWithPath: arguments[3]).appendingPathComponent("incoming-v3", isDirectory: true)
        try FileManager.default.createDirectory(at: incoming, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let artifactURL = incoming.appendingPathComponent("fixture.v3.fixture")
        try declaredBytes.write(to: artifactURL, options: [.atomic])
        let detector = try DetectorManifest(
            identifier: "fixture.v3",
            sha256: declaredHash,
            input: activeBefore.detector.input,
            output: activeBefore.detector.output,
            labels: activeBefore.detector.labels,
            confidenceThreshold: activeBefore.detector.confidenceThreshold,
            nmsIoUThreshold: activeBefore.detector.nmsIoUThreshold
        )
        let manifest = ModelBundleManifest(
            identifier: "fixture.v3",
            displayName: "Corrupted v3",
            minimumOS: "15.0",
            artifact: ModelArtifactDescriptor(fileName: artifactURL.lastPathComponent, sha256: declaredHash, kind: .fixture),
            detector: detector
        )
        let corruptedManifestURL = incoming.appendingPathComponent("fixture.v3.armmodel.json")
        try encoder.encode(manifest).write(to: corruptedManifestURL, options: [.atomic])
        try Data("corrupted-v3".utf8).write(to: artifactURL, options: [.atomic])
        var rejectedError = "none"
        do {
            _ = try await registry.importAndActivate(manifestURL: corruptedManifestURL)
        } catch {
            rejectedError = String(describing: error)
        }
        let activeAfter = try await registry.activeModel()
        let unchanged = activeBefore.id == activeAfter.id
            && activeBefore.artifactHash == activeAfter.artifactHash
            && activeBefore.compiledHash == activeAfter.compiledHash
            && activeBefore.compiledRelativePath == activeAfter.compiledRelativePath
        guard rejectedError.contains("hashMismatch"), unchanged else {
            throw ProbeError.failureReceiptMismatch
        }
        let receipt = FailureReceipt(
            mode: "failure",
            rejectedError: rejectedError,
            activeBeforeID: activeBefore.id,
            activeAfterID: activeAfter.id,
            activeBeforeHash: activeBefore.artifactHash,
            activeAfterHash: activeAfter.artifactHash,
            activeCompiledHashBefore: activeBefore.compiledHash,
            activeCompiledHashAfter: activeAfter.compiledHash,
            activePathBefore: activeBefore.compiledRelativePath,
            activePathAfter: activeAfter.compiledRelativePath,
            unchangedActive: unchanged
        )
        print(String(decoding: try encoder.encode(receipt), as: UTF8.self))
    } else {
        print(String(decoding: try encoder.encode(try await registry.snapshot()), as: UTF8.self))
    }
} catch {
    FileHandle.standardError.write(Data("ERROR: \(error)\n".utf8))
    exit(1)
}

private enum ProbeError: Error {
    case failureReceiptMismatch
}

private struct FailureReceipt: Codable {
    let mode: String
    let rejectedError: String
    let activeBeforeID: String
    let activeAfterID: String
    let activeBeforeHash: String
    let activeAfterHash: String
    let activeCompiledHashBefore: String
    let activeCompiledHashAfter: String
    let activePathBefore: String
    let activePathAfter: String
    let unchangedActive: Bool
}
