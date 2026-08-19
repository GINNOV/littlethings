import Darwin
import Foundation

let arguments = Array(CommandLine.arguments.dropFirst())
if arguments == ["--help"] || arguments == ["-h"] {
    print("Usage: ModelFixtureGenerator --output PATH")
    exit(0)
}
guard arguments.count == 2, arguments[0] == "--output" else {
    FileHandle.standardError.write(Data("ERROR: expected --output PATH\n".utf8))
    exit(2)
}
let descriptor = open(arguments[1], O_WRONLY | O_CREAT | O_EXCL, 0o600)
guard descriptor >= 0 else {
    FileHandle.standardError.write(Data("ERROR: output must not already exist\n".utf8))
    exit(2)
}
let fixture = Data("{\"class\":\"fixture-object\",\"confidence\":1,\"schemaVersion\":1,\"type\":\"constant-output-detector\"}\n".utf8)
let written = fixture.withUnsafeBytes { write(descriptor, $0.baseAddress, $0.count) }
guard written == fixture.count, fsync(descriptor) == 0, close(descriptor) == 0 else {
    FileHandle.standardError.write(Data("ERROR: fixture write failed\n".utf8))
    exit(2)
}
