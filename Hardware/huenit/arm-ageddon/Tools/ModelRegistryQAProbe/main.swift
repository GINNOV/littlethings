import ArmageddonCore
import Foundation

let arguments = Array(CommandLine.arguments.dropFirst())
guard arguments.count == 4,
      arguments[0] == "--manifest",
      arguments[2] == "--root" else {
    FileHandle.standardError.write(Data("ERROR: expected --manifest PATH --root PATH\n".utf8))
    exit(2)
}

let registry = ModelRegistry(root: URL(fileURLWithPath: arguments[3]))
do {
    try await registry.open()
    let record = try await registry.importAndActivate(manifestURL: URL(fileURLWithPath: arguments[1]))
    let snapshot = try await registry.snapshot()
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    print(String(decoding: try encoder.encode(snapshot), as: UTF8.self))
    print("activated=\(record.id) hash=\(record.artifactHash)")
} catch {
    FileHandle.standardError.write(Data("ERROR: \(error)\n".utf8))
    exit(1)
}
