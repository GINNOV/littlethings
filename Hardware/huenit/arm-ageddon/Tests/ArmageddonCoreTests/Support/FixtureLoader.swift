import Foundation

struct FixtureLoader: Sendable {
    let root: URL

    func data(at relativePath: String) throws -> Data {
        let candidate = root.appending(path: relativePath).standardizedFileURL
        guard candidate.path.hasPrefix(root.standardizedFileURL.path + "/") else {
            throw FixtureLoaderError.pathEscape(relativePath)
        }
        return try Data(contentsOf: candidate, options: [.mappedIfSafe])
    }
}

enum FixtureLoaderError: Error, Equatable {
    case pathEscape(String)
}
