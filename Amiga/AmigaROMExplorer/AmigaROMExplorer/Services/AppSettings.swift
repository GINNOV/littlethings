import Foundation

enum CatalogMode: String, Sendable {
    case referenceOnly
    case localLibrary
}

enum AppSettings {
    static let firmwareDirectoryKey = "firmwareDirectoryPath"
    static let ollamaBaseURLKey = "ollamaBaseURL"
    static let ollamaModelKey = "ollamaModel"
    static let enableSubAgentsKey = "enableSubAgents"
    static let prefetchResearchKey = "prefetchResearch"
    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    static let catalogModeKey = "catalogMode"

    static let defaultOllamaBaseURL = "http://127.0.0.1:11434"
    static let defaultOllamaModel = "llama3.2"

    static let bundledManifestName = "manifest"
    static let bundledChecksumsName = "checksums"
    static let bundledResearchFolderName = "research"

    static func firmwareDirectoryURL() -> URL? {
        guard let stored = UserDefaults.standard.string(forKey: firmwareDirectoryKey),
              !stored.isEmpty,
              FileManager.default.fileExists(atPath: stored) else {
            return nil
        }
        return URL(fileURLWithPath: stored, isDirectory: true)
    }

    static var catalogMode: CatalogMode {
        get {
            guard let raw = UserDefaults.standard.string(forKey: catalogModeKey),
                  let mode = CatalogMode(rawValue: raw) else {
                return firmwareDirectoryURL() == nil ? .referenceOnly : .localLibrary
            }
            return mode
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: catalogModeKey)
        }
    }

    static var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey) }
    }

    static func clearFirmwareDirectory() {
        UserDefaults.standard.removeObject(forKey: firmwareDirectoryKey)
        catalogMode = .referenceOnly
    }
}