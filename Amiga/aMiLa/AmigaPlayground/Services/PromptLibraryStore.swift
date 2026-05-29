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
    private let defaultSeedVersionKey = "promptLibraryDefaultSeedVersion"
    private let currentDefaultSeedVersion = 3

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let storedPrompts = Self.loadStoredPrompts(from: userDefaults, storageKey: storageKey)
        let seedVersion = userDefaults.integer(forKey: defaultSeedVersionKey)

        if seedVersion < currentDefaultSeedVersion {
            self.prompts = Self.mergedDefaultPrompts(with: storedPrompts)
            save()
            userDefaults.set(currentDefaultSeedVersion, forKey: defaultSeedVersionKey)
        } else {
            self.prompts = Self.sortedPrompts(storedPrompts)
        }
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

    private static func loadStoredPrompts(from userDefaults: UserDefaults, storageKey: String) -> [PromptLibraryItem] {
        guard let data = userDefaults.data(forKey: storageKey),
              let prompts = try? JSONDecoder().decode([PromptLibraryItem].self, from: data) else {
            return []
        }

        return prompts
    }

    private static func mergedDefaultPrompts(with storedPrompts: [PromptLibraryItem]) -> [PromptLibraryItem] {
        let storedNames = Set(storedPrompts.map { $0.name })
        let missingDefaults = defaultPrompts.filter { !storedNames.contains($0.name) }
        return sortedPrompts(missingDefaults + storedPrompts)
    }

    private static func sortedPrompts(_ prompts: [PromptLibraryItem]) -> [PromptLibraryItem] {
        prompts.sorted { $0.updatedAt > $1.updatedAt }
    }

    nonisolated static let defaultPrompts: [PromptLibraryItem] = [
        PromptLibraryItem(
            id: UUID(uuidString: "CD89F5BC-55C2-488D-82D4-38AE46BFD924")!,
            name: "Demo 01 Copper Bars",
            prompt: "Generate static copper bars with six clean horizontal bands and an OCS-safe copper list in Chip RAM.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_030),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_030)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "C78CA371-E700-4E4B-905E-58EFB8E9E203")!,
            name: "Demo 02 Bouncing Copper Bars",
            prompt: "Generate bouncing copper bars that move vertically at a slow speed, rewrite copper wait positions each frame, and exit on left mouse click.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_029),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_029)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "4507F6A5-A63D-48E4-9456-0452FD272FF6")!,
            name: "Demo 03 Raster Splits",
            prompt: "Generate raster split copper code that changes COLOR00 at multiple scanlines for a classic horizontal split background.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_028),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_028)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "34C14D04-E650-45D9-89D5-E980F3314BE2")!,
            name: "Demo 04 Sinusoidal Text Scroller",
            prompt: "Make the words \"flying saucer\" scroll left across the screen in a slow sinusoidal pattern, with a visible bright text band and smooth frame timing.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_027),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_027)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "C69728C1-43F7-42EB-9C95-BBF177F4140B")!,
            name: "Demo 05 Starfield",
            prompt: "Generate a fast starfield with twenty stars, varied brightness, wraparound movement, and a black background.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_026),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_026)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "F80B1160-0FC0-4874-B62F-71BFDFD5CA4D")!,
            name: "Demo 06 Hardware Sprite Motion",
            prompt: "Generate a slow bouncing saucer hardware sprite moving vertically, with sprite data in Chip RAM, a proper sprite terminator, and a blank bitplane setup.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_025),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_025)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "10588652-E320-4525-8772-CB4A7695896E")!,
            name: "Demo 07 Blitter Bitplane Clear",
            prompt: "Clear the bitplane screen with the blitter, including canonical blitter busy waits before and after BLTSIZE.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_024),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_024)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "9393A48B-85C0-47A1-9EFB-841DB5789386")!,
            name: "Demo 08 Color-Cycling Logo",
            prompt: "Make a fast blue color-cycling logo that says \"amiga\", centered on screen, using a small color table and stable one-bitplane rendering.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_023),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_023)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "FE649D83-6422-474B-BC91-97DA7BF36197")!,
            name: "Demo 09 Double Buffered Bitplane",
            prompt: "Generate double-buffered bitplane animation that swaps front and back bitplane pointers on vblank and exits on left mouse click.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_022),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_022)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "D49716F9-91F2-4E08-A76A-63205AE0972D")!,
            name: "Demo 10 Frame-Synced Audio Intro",
            prompt: "Generate a frame-synced intro loop with a Paula audio pulse, COLOR00 changes every vblank, and a clean left mouse exit.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_021),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_021)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "8B8F2410-F7F8-4C38-8426-0C2B7A8E6101")!,
            name: "01 Minimal Executable",
            prompt: "Generate a minimal runnable Amiga program that exits cleanly.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_010),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_010)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "9F03055C-6613-4F76-A4C1-14BDB409D72C")!,
            name: "02 Background Color",
            prompt: "Set the screen background color to blue using an OCS-safe one-bitplane display.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_009),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_009)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "3E03D32C-7DB7-448C-A675-6B1999904B56")!,
            name: "03 VBlank Mouse Exit",
            prompt: "Write a vertical blank wait loop that exits when the left mouse button is pressed.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_008),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_008)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "6E64C14B-D589-4B12-B83C-B6E5686C3E19")!,
            name: "04 Static Copper Bars",
            prompt: "Generate static copper bars with six clean horizontal bands and an OCS-safe copper list in Chip RAM.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_007),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_007)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "42A63F04-63ED-480B-AD28-AE340084F26E")!,
            name: "05 Bouncing Copper Bars",
            prompt: "Generate bouncing copper bars that move vertically at a slow speed, use a frame counter, wait for vertical blank, and exit cleanly on left mouse click.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_006),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_006)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "2F67BD72-FC3C-43CC-B770-F9B2EF844E95")!,
            name: "06 Centered Fancy Text",
            prompt: "Write in the center of the screen with a fancy bitmap font the words \"flying saucer\" in yellow, holding the display long enough to inspect it.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_005),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_005)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "154FE4D4-406F-4589-9D36-B6CCDDDD8A8C")!,
            name: "07 Sinusoidal Text Scroll",
            prompt: "Make the words \"flying saucer\" scroll left across the screen in a slow sinusoidal pattern, with a visible bright text band and smooth frame timing.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_004),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_004)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "8C24B3C4-D37F-45B8-B4E4-6B6B273D364A")!,
            name: "08 Color-Cycling Logo",
            prompt: "Make a fast blue color-cycling logo that says \"amiga\", centered on screen, using a small color table and stable one-bitplane rendering.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_003),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_003)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "38D3B33E-88F4-43E1-AE74-ABF0E20F6C90")!,
            name: "09 Bouncing Saucer Sprite",
            prompt: "Generate a slow bouncing saucer sprite moving vertically, with sprite data in Chip RAM, a proper sprite terminator, and a blank bitplane setup.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_002),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_002)
        ),
        PromptLibraryItem(
            id: UUID(uuidString: "CB4D311B-1563-4902-A79E-88BD7B4AF812")!,
            name: "10 Starfield",
            prompt: "Generate a fast starfield with twenty stars, varied brightness, wraparound movement, and a black background.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_001),
            updatedAt: Date(timeIntervalSinceReferenceDate: 1_000_001)
        )
    ]
}
