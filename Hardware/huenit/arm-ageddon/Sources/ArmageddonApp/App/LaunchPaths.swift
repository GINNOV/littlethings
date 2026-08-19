import Foundation

struct LaunchPaths: Sendable {
    let preferenceSuite: String
    let applicationSupport: URL
    let cache: URL
    let temporary: URL
    let fixtures: URL

    init(values: [String: String]) throws {
        preferenceSuite = try Self.required("-qa-preference-suite", values: values)
        applicationSupport = try Self.directory("-qa-application-support-root", values: values)
        cache = try Self.directory("-qa-cache-root", values: values)
        temporary = try Self.directory("-qa-temp-root", values: values)
        fixtures = try Self.directory("-qa-fixture-root", values: values)
    }

    private static func required(_ name: String, values: [String: String]) throws -> String {
        guard let value = values[name], !value.isEmpty else { throw LaunchArgumentError.missingRequiredPath(name) }
        return value
    }

    private static func directory(_ name: String, values: [String: String]) throws -> URL {
        let raw = try required(name, values: values)
        let url = URL(fileURLWithPath: raw).standardizedFileURL
        var isDirectory: ObjCBool = false
        guard url.path.hasPrefix("/"), FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw LaunchArgumentError.invalidPath(name)
        }
        let values = try url.resourceValues(forKeys: [.isSymbolicLinkKey])
        guard values.isSymbolicLink != true else { throw LaunchArgumentError.invalidPath(name) }
        return url
    }
}
