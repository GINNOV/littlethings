import EvidenceProbeSupport
import Foundation

do {
    try Probe.main(kind: "RuntimeTraceProbe", arguments: Array(CommandLine.arguments.dropFirst()))
} catch {
    FileHandle.standardError.write(Data("ERROR: \(error)\n".utf8))
    exit(2)
}
