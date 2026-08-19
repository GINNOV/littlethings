import Foundation

struct LaunchArguments: Sendable {
    let profile: LaunchProfile
    let paths: LaunchPaths?
    let scope: ScopeArguments?
    let requestedDestination: String?
    let windowSize: WindowSize

    static func parse(_ arguments: [String]) throws -> LaunchArguments {
        let values = try values(arguments)
        let isUITesting = arguments.contains("-ui-testing")
        let rawProfile = values["-fixture-profile"] ?? LaunchProfile.noDevices.rawValue
        guard let profile = LaunchProfile(rawValue: rawProfile) else { throw LaunchArgumentError.unknownProfile(rawProfile) }
        let paths = try isUITesting ? LaunchPaths(values: values) : nil
        let scope = try ScopeArguments(values: values)
        let windowSize = try WindowSize(values: values)
        return LaunchArguments(
            profile: profile,
            paths: paths,
            scope: scope,
            requestedDestination: values["-fixture-destination"],
            windowSize: windowSize
        )
    }

    private static func values(_ arguments: [String]) throws -> [String: String] {
        let names: Set<String> = ["-fixture-profile", "-fixture-destination", "-qa-window-width", "-qa-window-height", "-qa-preference-suite", "-qa-application-support-root", "-qa-cache-root", "-qa-temp-root", "-qa-fixture-root", "-qa-scope-launch-receipt", "-qa-scope-ready-receipt", "-qa-await-scope-gate"]
        var result: [String: String] = [:]
        for name in names {
            guard let index = arguments.firstIndex(of: name) else { continue }
            guard arguments.indices.contains(index + 1) else { throw LaunchArgumentError.missingValue(name) }
            result[name] = arguments[index + 1]
        }
        return result
    }
}

enum LaunchArgumentError: Error {
    case missingValue(String)
    case unknownProfile(String)
    case missingRequiredPath(String)
    case invalidPath(String)
    case incompleteScope
    case invalidWindowSize
}
