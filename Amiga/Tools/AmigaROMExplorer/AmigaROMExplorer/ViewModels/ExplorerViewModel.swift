import Foundation
import Observation

@MainActor
@Observable
final class ExplorerViewModel {
    var selectedCategory: ROMCategory?
    var selectedHardwareModel: HardwareModel?
    var selectedItemID: ROMCatalogItem.ID?
    var searchText = ""
    var firmwareDirectoryPath: String
    var catalogMode: CatalogMode
    var ollamaBaseURL: String
    var ollamaModel: String
    var enableSubAgents: Bool
    var prefetchResearch: Bool
    var showOnboarding: Bool
    var ollamaStatusMessage: String = "Not tested"
    var isTestingOllama = false
    var bulkResearchFeedback: String?

    let catalog = ROMCatalogStore()
    let research: ROMResearchService

    init() {
        let uiTesting = UITestingSupport.isActive

        firmwareDirectoryPath = AppSettings.firmwareDirectoryURL()?.path ?? ""
        catalogMode = AppSettings.catalogMode
        ollamaBaseURL = UserDefaults.standard.string(forKey: AppSettings.ollamaBaseURLKey) ?? AppSettings.defaultOllamaBaseURL
        ollamaModel = UserDefaults.standard.string(forKey: AppSettings.ollamaModelKey) ?? AppSettings.defaultOllamaModel
        var resolvedEnableSubAgents = UserDefaults.standard.object(forKey: AppSettings.enableSubAgentsKey) as? Bool ?? true
        prefetchResearch = UserDefaults.standard.object(forKey: AppSettings.prefetchResearchKey) as? Bool ?? false

        if uiTesting {
            if ProcessInfo.processInfo.arguments.contains(UITestingSupport.disableSubAgentsArgument) {
                resolvedEnableSubAgents = false
            }
            showOnboarding = false
            AppSettings.hasCompletedOnboarding = true
        } else {
            showOnboarding = !AppSettings.hasCompletedOnboarding
        }

        enableSubAgents = resolvedEnableSubAgents
        research = ROMResearchService(
            autoHydrate: true,
            runsAgents: !uiTesting,
            useSubAgents: resolvedEnableSubAgents
        )

        catalog.updateLocalDirectory(AppSettings.firmwareDirectoryURL())
        catalog.reload()
    }

    var filteredItems: [ROMCatalogItem] {
        let base = catalog.items(for: selectedCategory, hardwareModel: selectedHardwareModel)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return base }

        return base.filter { item in
            let haystack = [
                item.displayTitle,
                item.manifest.source,
                item.manifest.destination,
                item.machines.map(\.name).joined(separator: " "),
                item.parsed.variantLabel,
                item.versionLabel
            ].joined(separator: " ").lowercased()

            return haystack.contains(query.lowercased())
        }
    }

    var selectedItem: ROMCatalogItem? {
        guard let selectedItemID else { return nil }
        return catalog.item(withID: selectedItemID)
    }

    var categoryCounts: [ROMCategory: Int] {
        Dictionary(grouping: catalog.items, by: \.category).mapValues(\.count)
    }

    var hardwareModelCounts: [(model: HardwareModel, count: Int)] {
        HardwareModel.catalog.compactMap { model in
            let count = catalog.items(for: nil, hardwareModel: model).count
            return count > 0 ? (model, count) : nil
        }
    }

    var listTitle: String {
        if let selectedHardwareModel {
            return selectedHardwareModel.name
        }
        if let selectedCategory {
            return selectedCategory.title
        }
        return "All ROMs"
    }

    var listSubtitle: String {
        if let selectedHardwareModel {
            return selectedHardwareModel.chipset
        }
        if let selectedCategory {
            return selectedCategory.subtitle
        }
        return isReferenceOnlyMode ? "Reference catalog" : "\(catalog.installedCount) installed"
    }

    func selectAllROMs() {
        selectedCategory = nil
        selectedHardwareModel = nil
        selectedItemID = nil
    }

    func selectCategory(_ category: ROMCategory?) {
        selectedCategory = category
        selectedHardwareModel = nil
        selectedItemID = nil
    }

    func selectHardwareModel(_ model: HardwareModel) {
        selectedHardwareModel = model
        selectedCategory = nil
        selectedItemID = nil
    }

    var isReferenceOnlyMode: Bool {
        catalogMode == .referenceOnly || catalog.localFirmwareDirectory == nil
    }

    func reloadCatalog() {
        persistSettings()
        catalog.updateLocalDirectory(firmwareDirectoryPath.isEmpty ? nil : URL(fileURLWithPath: firmwareDirectoryPath, isDirectory: true))
    }

    func select(_ item: ROMCatalogItem?) {
        selectedItemID = item?.id
    }

    func researchAll(forceRefresh: Bool = false) {
        persistSettings()
        research.researchAll(items: catalog.items, forceRefresh: forceRefresh)
        bulkResearchFeedback = research.bulkResearchMessage
    }

    func setLocalFirmwareDirectory(_ path: String?) {
        if let path, !path.isEmpty {
            firmwareDirectoryPath = path
            catalogMode = .localLibrary
            AppSettings.catalogMode = .localLibrary
            UserDefaults.standard.set(path, forKey: AppSettings.firmwareDirectoryKey)
            catalog.updateLocalDirectory(URL(fileURLWithPath: path, isDirectory: true))
        } else {
            firmwareDirectoryPath = ""
            catalogMode = .referenceOnly
            AppSettings.catalogMode = .referenceOnly
            AppSettings.clearFirmwareDirectory()
            catalog.clearLocalDirectory()
        }
    }

    func completeOnboarding(referenceOnly: Bool) {
        if referenceOnly {
            setLocalFirmwareDirectory(nil)
        }
        persistSettings()
        AppSettings.hasCompletedOnboarding = true
        showOnboarding = false
    }

    func testOllamaConnection() {
        isTestingOllama = true
        ollamaStatusMessage = "Testing…"
        let client = OllamaClient(baseURL: ollamaBaseURL, model: ollamaModel)

        Task {
            let available = await client.isAvailable()
            ollamaStatusMessage = available ? "Ollama is reachable." : "Could not reach Ollama at \(ollamaBaseURL)."
            isTestingOllama = false
        }
    }

    func persistSettings() {
        if firmwareDirectoryPath.isEmpty {
            AppSettings.clearFirmwareDirectory()
        } else {
            UserDefaults.standard.set(firmwareDirectoryPath, forKey: AppSettings.firmwareDirectoryKey)
            AppSettings.catalogMode = catalogMode
        }
        UserDefaults.standard.set(ollamaBaseURL, forKey: AppSettings.ollamaBaseURLKey)
        UserDefaults.standard.set(ollamaModel, forKey: AppSettings.ollamaModelKey)
        UserDefaults.standard.set(enableSubAgents, forKey: AppSettings.enableSubAgentsKey)
        UserDefaults.standard.set(prefetchResearch, forKey: AppSettings.prefetchResearchKey)
        research.configure(ollamaBaseURL: ollamaBaseURL, model: ollamaModel, enableSubAgents: enableSubAgents)
    }
}