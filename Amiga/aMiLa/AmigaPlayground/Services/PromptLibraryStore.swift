import Foundation

struct PromptLibraryItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var prompt: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        prompt: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.prompt = prompt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Notification.Name {
    static let pastePromptIntoAssistant = Notification.Name("pastePromptIntoAssistant")
}

@MainActor
final class PromptLibraryStore: ObservableObject {
    static let shared = PromptLibraryStore()

    @Published private(set) var prompts: [PromptLibraryItem] = []

    private let userDefaults: UserDefaults
    private let storageKey = "promptLibraryItems"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.prompts = Self.loadPrompts(from: userDefaults, storageKey: storageKey)
    }

    func createPrompt() -> PromptLibraryItem {
        let item = PromptLibraryItem(name: uniquePromptName(), prompt: "")
        prompts.insert(item, at: 0)
        save()
        return item
    }

    func updatePrompt(id: PromptLibraryItem.ID, name: String, prompt: String) {
        guard let index = prompts.firstIndex(where: { $0.id == id }) else { return }
        prompts[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        prompts[index].prompt = prompt
        prompts[index].updatedAt = Date()
        save()
    }

    func deletePrompt(id: PromptLibraryItem.ID) {
        prompts.removeAll { $0.id == id }
        save()
    }

    func prompt(withID id: PromptLibraryItem.ID?) -> PromptLibraryItem? {
        guard let id else { return nil }
        return prompts.first { $0.id == id }
    }

    private func uniquePromptName() -> String {
        let baseName = "Untitled Prompt"
        guard prompts.contains(where: { $0.name == baseName }) else { return baseName }

        var suffix = 2
        while prompts.contains(where: { $0.name == "\(baseName) \(suffix)" }) {
            suffix += 1
        }
        return "\(baseName) \(suffix)"
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(prompts) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    private static func loadPrompts(from userDefaults: UserDefaults, storageKey: String) -> [PromptLibraryItem] {
        guard let data = userDefaults.data(forKey: storageKey),
              let prompts = try? JSONDecoder().decode([PromptLibraryItem].self, from: data) else {
            return []
        }

        return prompts.sorted { $0.updatedAt > $1.updatedAt }
    }
}
