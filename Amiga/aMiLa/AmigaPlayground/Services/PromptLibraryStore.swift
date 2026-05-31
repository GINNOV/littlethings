import Foundation

struct PromptLibraryItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var prompt: String
    var metadata: DemoSchoolMetadata
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        prompt: String,
        metadata: DemoSchoolMetadata = DemoSchoolMetadata(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.prompt = prompt
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, prompt, metadata, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        prompt = try container.decode(String.self, forKey: .prompt)
        metadata = try container.decodeIfPresent(DemoSchoolMetadata.self, forKey: .metadata) ?? DemoSchoolMetadata()
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

struct PendingDefaultPromptUpdate: Equatable {
    let remotePrompts: [PromptLibraryItem]
    let conflictNames: [String]
}

extension Notification.Name {
    static let pastePromptIntoAssistant = Notification.Name("pastePromptIntoAssistant")
}

@MainActor
final class PromptLibraryStore: ObservableObject {
    static let shared = PromptLibraryStore()
    nonisolated static let defaultPromptUpdateEndpoint = URL(string: "https://raw.githubusercontent.com/GINNOV/littlethings/main/Amiga/aMiLa/AmigaPlayground/Resources/default-prompts.json")!

    @Published private(set) var prompts: [PromptLibraryItem] = []

    private let userDefaults: UserDefaults
    private let storageKey = "promptLibraryItems"
    private let defaultSeedVersionKey = "promptLibraryDefaultSeedVersion"
    private let currentDefaultSeedVersion = 7

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

    func updatePrompt(id: PromptLibraryItem.ID, name: String, prompt: String, metadata: DemoSchoolMetadata? = nil) {
        guard let index = prompts.firstIndex(where: { $0.id == id }) else { return }
        prompts[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        prompts[index].prompt = prompt
        if let metadata {
            prompts[index].metadata = metadata
        }
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

    func checkForDefaultPromptUpdates(from endpoint: URL = PromptLibraryStore.defaultPromptUpdateEndpoint) async throws -> PendingDefaultPromptUpdate? {
        let (data, response) = try await URLSession.shared.data(from: endpoint)
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }

        let remotePrompts = try Self.decodeRemoteDefaultPrompts(from: data)
        return prepareDefaultPromptUpdate(remotePrompts)
    }

    func prepareDefaultPromptUpdate(_ remotePrompts: [PromptLibraryItem]) -> PendingDefaultPromptUpdate? {
        let remoteSystemPrompts = remotePrompts.filter { Self.isSystemPromptID($0.id) }
        guard !remoteSystemPrompts.isEmpty else { return nil }

        let bundledDefaultsByID = Dictionary(uniqueKeysWithValues: Self.defaultPrompts.map { ($0.id, $0) })
        let localSystemPromptsByID = Dictionary(uniqueKeysWithValues: prompts.filter { Self.isSystemPromptID($0.id) }.map { ($0.id, $0) })

        var conflictNames: [String] = []
        for remotePrompt in remoteSystemPrompts {
            guard let localPrompt = localSystemPromptsByID[remotePrompt.id],
                  let bundledPrompt = bundledDefaultsByID[remotePrompt.id],
                  localPrompt != bundledPrompt,
                  localPrompt != remotePrompt else {
                continue
            }

            conflictNames.append(localPrompt.name.isEmpty ? remotePrompt.name : localPrompt.name)
        }

        if conflictNames.isEmpty {
            applyDefaultPromptUpdate(remoteSystemPrompts)
            return nil
        }

        return PendingDefaultPromptUpdate(
            remotePrompts: remoteSystemPrompts,
            conflictNames: conflictNames.sorted()
        )
    }

    func confirmDefaultPromptUpdate(_ update: PendingDefaultPromptUpdate) {
        applyDefaultPromptUpdate(update.remotePrompts)
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

    private static func decodeRemoteDefaultPrompts(from data: Data) throws -> [PromptLibraryItem] {
        let decoder = JSONDecoder()
        if let prompts = try? decoder.decode([PromptLibraryItem].self, from: data) {
            return prompts
        }

        return try decoder.decode(RemoteDefaultPromptEnvelope.self, from: data).prompts
    }

    private func applyDefaultPromptUpdate(_ remotePrompts: [PromptLibraryItem]) {
        let remoteSystemPrompts = remotePrompts.filter { Self.isSystemPromptID($0.id) }
        guard !remoteSystemPrompts.isEmpty else { return }

        let remoteSystemPromptIDs = Set(remoteSystemPrompts.map(\.id))
        var merged = prompts.filter { !remoteSystemPromptIDs.contains($0.id) }
        merged.append(contentsOf: remoteSystemPrompts)

        prompts = Self.sortedPrompts(merged)
        save()
    }

    private nonisolated static func isSystemPromptID(_ id: UUID) -> Bool {
        id.uuidString.hasPrefix("00000000-0000-4000-8000-")
    }

    private static func mergedDefaultPrompts(with storedPrompts: [PromptLibraryItem]) -> [PromptLibraryItem] {
        let currentDefaultNames = Set(defaultPrompts.map(\.name))
        let legacyNames = Set([
            "Demo 01 Copper Bars", "Demo 02 Bouncing Copper Bars", "Demo 03 Raster Splits",
            "Demo 04 Sinusoidal Text Scroller", "Demo 05 Starfield", "Demo 06 Hardware Sprite Motion",
            "Demo 07 Blitter Bitplane Clear", "Demo 08 Color-Cycling Logo",
            "Demo 09 Double Buffered Bitplane", "Demo 10 Frame-Synced Audio Intro",
            "01 Minimal Executable", "02 Background Color", "03 VBlank Mouse Exit",
            "04 Static Copper Bars", "05 Bouncing Copper Bars", "06 Centered Fancy Text",
            "07 Sinusoidal Text Scroll", "08 Color-Cycling Logo", "09 Bouncing Saucer Sprite",
            "10 Starfield",
            "03 System - VBlank Mouse Exit", "04 System - Clean Takeover Skeleton",
            "05 Custom Chips - Register Map Tour", "06 Copper - Static Rainbow Bars",
            "07 Copper - Raster Splits", "08 Copper - Runtime Patching",
            "09 Display - One-Bitplane Screen", "10 Display - Double Buffer Flip",
            "11 Blitter - Clear and Fill", "12 Blitter - Masked Copy",
            "13 Sprites - Bouncing Hardware Sprite", "14 Sprites - Attached Sprite Logo",
            "15 Audio - Paula Pulse", "16 Audio - Frame-Synced Intro",
            "17 Math - Sine Table Motion", "18 Effects - Starfield and Parallax",
            "19 Effects - Color-Cycling Logo", "20 Showcase - Mini Demo Megamix"
        ])
        let customPrompts = storedPrompts.filter { !legacyNames.contains($0.name) && !currentDefaultNames.contains($0.name) }
        return sortedPrompts(defaultPrompts + customPrompts)
    }

    private static func sortedPrompts(_ prompts: [PromptLibraryItem]) -> [PromptLibraryItem] {
        prompts.sorted {
            if $0.metadata.stage == $1.metadata.stage {
                return $0.updatedAt > $1.updatedAt
            }
            return $0.updatedAt > $1.updatedAt
        }
    }

    nonisolated private static func item(
        _ index: Int,
        _ name: String,
        _ prompt: String,
        difficulty: String,
        stage: String,
        effectType: String,
        hardware: [String],
        concepts: [String],
        value: [String] = ["Learn"],
        status: String = "Verified",
        language: String = "ASM",
        dependencies: [String] = []
    ) -> PromptLibraryItem {
        PromptLibraryItem(
            id: UUID(uuidString: String(format: "00000000-0000-4000-8000-%012d", index))!,
            name: name,
            prompt: prompt,
            metadata: DemoSchoolMetadata(
                difficulty: difficulty,
                stage: stage,
                language: language,
                effectType: effectType,
                hardware: hardware,
                concepts: concepts,
                value: value,
                status: status,
                dependencies: dependencies
            ),
            createdAt: Date(timeIntervalSinceReferenceDate: TimeInterval(2_000_000 - index)),
            updatedAt: Date(timeIntervalSinceReferenceDate: TimeInterval(2_000_000 - index))
        )
    }

    nonisolated static let defaultPrompts: [PromptLibraryItem] = [
        item(1, "01 Foundations - Minimal Executable", "Generate a minimal runnable Amiga program that exits cleanly. Explain registers, labels, SECTION, XDEF, and RTS in comments.", difficulty: "Beginner", stage: "Foundations", effectType: "Reference", hardware: ["Exec"], concepts: ["68000 basics", "sections", "clean exit"]),
        item(2, "02 Foundations - Registers and Stack", "Generate a small 68000 routine that demonstrates D registers, A registers, stack save/restore with MOVEM, subroutines, and data labels.", difficulty: "Beginner", stage: "Foundations", effectType: "Reference", hardware: ["Exec"], concepts: ["registers", "stack", "subroutines"], status: "Draft", dependencies: ["01 Foundations - Minimal Executable"]),
        item(3, "03 Foundations - Addressing and Memory", "Generate a 68000 addressing modes lesson that shows immediate, register, indirect, post-increment, displacement, labels, data sections, Chip RAM, and Fast RAM scratch data.", difficulty: "Beginner", stage: "Foundations", effectType: "Reference", hardware: ["Exec"], concepts: ["addressing modes", "Chip RAM", "Fast RAM", "data sections"], status: "Draft", dependencies: ["02 Foundations - Registers and Stack"]),
        item(4, "04 System - VBlank Mouse Exit", "Write a vertical blank wait loop that exits when the left mouse button is pressed, using custom chip beam position and CIA mouse input.", difficulty: "Beginner", stage: "System", effectType: "System", hardware: ["CIA", "Bitplanes"], concepts: ["VBlank", "mouse input"], dependencies: ["01 Foundations - Minimal Executable"]),
        item(5, "05 System - Clean Takeover Skeleton", "Generate an Amiga clean takeover skeleton that captures ExecBase, opens graphics.library, saves the active view, saves/restores DMACON and INTENA, disables the OS display safely, waits for left mouse, and restores everything on exit.", difficulty: "Intermediate", stage: "System", effectType: "System", hardware: ["Exec", "Copper", "Bitplanes"], concepts: ["ExecBase", "graphics.library", "OS restore", "DMACON", "INTENA", "disable OS safely"], status: "Needs Emulator", dependencies: ["04 System - VBlank Mouse Exit"]),
        item(6, "06 Custom Chips - Register Map Tour", "Generate an annotated register map tour for $dff000 showing DMACON, INTENA, COLOR00, BPLCON0, bitplane pointers, sprite pointers, and audio channel registers.", difficulty: "Beginner", stage: "Custom Chips", effectType: "Reference", hardware: ["Copper", "Bitplanes", "Sprites", "Paula"], concepts: ["register map", "custom chips"], status: "Draft"),
        item(7, "07 Copper - Static Rainbow Bars", "Generate static copper bars with six clean horizontal bands and an OCS-safe copper list in Chip RAM.", difficulty: "Beginner", stage: "Copper", effectType: "Raster Bars", hardware: ["Copper"], concepts: ["WAIT", "MOVE", "COLOR00"], dependencies: ["04 System - VBlank Mouse Exit"]),
        item(8, "08 Copper - Raster Splits", "Generate raster split copper code that changes COLOR00 at multiple scanlines for a classic horizontal split background.", difficulty: "Beginner", stage: "Copper", effectType: "Raster Bars", hardware: ["Copper"], concepts: ["raster splits", "beam sync"], dependencies: ["07 Copper - Static Rainbow Bars"]),
        item(9, "09 Copper - Runtime Patching", "Generate bouncing copper bars that move vertically at a slow speed, rewrite copper wait positions each frame, and exit on left mouse click.", difficulty: "Intermediate", stage: "Copper", effectType: "Raster Bars", hardware: ["Copper"], concepts: ["runtime patching", "frame counter"], dependencies: ["08 Copper - Raster Splits"]),
        item(10, "10 Copper - Double-Buffered Lists", "Generate double-buffered copper lists that swap active and back copper lists on VBlank so palette changes can be patched safely.", difficulty: "Advanced", stage: "Copper", effectType: "Raster Bars", hardware: ["Copper"], concepts: ["double-buffered copper lists", "runtime patching", "VBlank"], dependencies: ["09 Copper - Runtime Patching"]),
        item(11, "11 Display - One-Bitplane Screen", "Set the screen background color to blue using an OCS-safe one-bitplane display, with bitplane pointers and palette setup called out in comments.", difficulty: "Beginner", stage: "Display", effectType: "Bitplane", hardware: ["Bitplanes", "Copper"], concepts: ["BPLCON0", "DIW", "DDF"], dependencies: ["07 Copper - Static Rainbow Bars"]),
        item(12, "12 Display - Four-Bitplane Palette", "Generate a 4-bitplane 16-color display setup with DIWSTRT, DIWSTOP, DDFSTRT, DDFSTOP, BPLCON0/1, bitplane pointers, and palette setup.", difficulty: "Intermediate", stage: "Display", effectType: "Bitplane", hardware: ["Bitplanes"], concepts: ["4-bitplane display", "16-color palette", "DIW", "DDF"], dependencies: ["11 Display - One-Bitplane Screen"]),
        item(13, "13 Display - Double Buffer Flip", "Generate double-buffered bitplane animation that swaps front and back bitplane pointers on vblank and exits on left mouse click.", difficulty: "Intermediate", stage: "Display", effectType: "Bitplane", hardware: ["Bitplanes", "Copper"], concepts: ["double buffering", "BPL pointers"], dependencies: ["11 Display - One-Bitplane Screen"]),
        item(14, "14 Blitter - Clear and Fill", "Clear the bitplane screen with the blitter, including canonical blitter busy waits before and after BLTSIZE.", difficulty: "Intermediate", stage: "Blitter", effectType: "Blitter", hardware: ["Blitter", "Bitplanes"], concepts: ["BBUSY", "fill", "BLTSIZE"], dependencies: ["11 Display - One-Bitplane Screen"]),
        item(15, "15 Blitter - Masked Copy", "Generate a blitter rectangular masked copy lesson using A/B/C to D cookie-cut minterms, with a helper comment explaining the minterm.", difficulty: "Advanced", stage: "Blitter", effectType: "Blitter", hardware: ["Blitter"], concepts: ["rectangular copy", "cookie-cut", "minterms", "masked blit"], status: "Draft", dependencies: ["14 Blitter - Clear and Fill"]),
        item(16, "16 Blitter - Line Mode", "Generate a blitter line draw lesson using line mode, octant/sign bits, BLTCON0/1, BLTADAT, BLTSIZE, and busy waits before and after drawing.", difficulty: "Advanced", stage: "Blitter", effectType: "Blitter", hardware: ["Blitter"], concepts: ["line mode", "octant mode", "wireframe"], dependencies: ["14 Blitter - Clear and Fill"]),
        item(17, "17 Sprites - Bouncing Hardware Sprite", "Generate a slow bouncing saucer hardware sprite moving vertically, with sprite position/control words, sprite data in Chip RAM, a proper sprite terminator, beam-synced movement notes, and a blank bitplane setup.", difficulty: "Intermediate", stage: "Sprites", effectType: "Sprite Logo", hardware: ["Sprites", "Copper"], concepts: ["SPRxPOS", "SPRxCTL", "sprite terminator", "Copper-driven sprite movement"], dependencies: ["11 Display - One-Bitplane Screen"]),
        item(18, "18 Sprites - Attached Sprite Logo", "Generate an attached hardware sprite pair logo lesson that explains how two 16-pixel sprites become one 15-color object.", difficulty: "Advanced", stage: "Sprites", effectType: "Sprite Logo", hardware: ["Sprites", "Copper"], concepts: ["attached sprites", "15-color sprite"], status: "Draft", dependencies: ["17 Sprites - Bouncing Hardware Sprite"]),
        item(19, "19 Audio - Paula Pulse", "Generate a Paula audio channel 0 pulse sample with AUD0LC, AUD0LEN, AUD0PER, AUD0VOL, DMA enable, and clean shutdown notes.", difficulty: "Intermediate", stage: "Audio", effectType: "Audio", hardware: ["Paula"], concepts: ["sample playback", "period", "volume"], dependencies: ["04 System - VBlank Mouse Exit"]),
        item(20, "20 Audio - Four-Channel Waveform", "Generate a four channel Paula waveform lesson that sets AUD0-AUD3 sample pointers, lengths, periods, volumes, and audio DMA bits.", difficulty: "Advanced", stage: "Audio", effectType: "Audio", hardware: ["Paula"], concepts: ["4 channels", "waveform generation", "period", "volume"], dependencies: ["19 Audio - Paula Pulse"]),
        item(21, "21 Audio - CIA-Timed MOD Scaffold", "Generate a CIA-timed MOD replay scaffold with a speed counter, pattern rows, period table, Paula audio channel setup, and Timer B sync notes.", difficulty: "Advanced", stage: "Audio", effectType: "Audio", hardware: ["Paula", "CIA"], concepts: ["MOD replay", "CIA timer sync", "pattern rows"], status: "Draft", dependencies: ["20 Audio - Four-Channel Waveform"]),
        item(22, "22 Math - Fixed-Point Sine Motion", "Make the words \"flying saucer\" scroll left across the screen in a slow sinusoidal pattern, with a visible bright text band and smooth frame timing.", difficulty: "Advanced", stage: "Math", effectType: "Scroller", hardware: ["Bitplanes"], concepts: ["sine table", "fixed point", "custom font"], dependencies: ["13 Display - Double Buffer Flip"]),
        item(23, "23 Math - Interpolation and Scaling", "Generate a fixed-point interpolation and perspective scaling lesson that builds a small scale table for later geometric demo effects.", difficulty: "Advanced", stage: "Math", effectType: "Reference", hardware: ["Math"], concepts: ["fixed point", "interpolation", "perspective scaling"], dependencies: ["22 Math - Fixed-Point Sine Motion"]),
        item(24, "24 Effects - Starfield and Parallax", "Generate a fast starfield with twenty stars, varied brightness, wraparound movement, and a black background.", difficulty: "Advanced", stage: "Effects", effectType: "Starfield", hardware: ["Bitplanes"], concepts: ["parallax", "fixed point", "wraparound"], dependencies: ["22 Math - Fixed-Point Sine Motion"]),
        item(25, "25 Effects - Plasma Palette", "Generate a plasma effect scaffold using sine tables and copper palette updates so COLOR00 changes in a smooth wave pattern.", difficulty: "Advanced", stage: "Effects", effectType: "Plasma", hardware: ["Copper"], concepts: ["plasma", "sine table", "palette update"], dependencies: ["10 Copper - Double-Buffered Lists"]),
        item(26, "26 Effects - Twister Slices", "Generate a twister effect scaffold using sinusoidal blitter copies per slice, line offsets, and screen buffer workflows.", difficulty: "Advanced", stage: "Effects", effectType: "Twister", hardware: ["Blitter", "Bitplanes"], concepts: ["twister", "sine offsets", "blitter slices"], dependencies: ["16 Blitter - Line Mode"]),
        item(27, "27 Effects - Rotozoom Lite", "Generate a rotozoom-lite bitplane scaffold using fixed-point texture sampling, incremental u/v coordinates, and a tiny texture table.", difficulty: "Advanced", stage: "Effects", effectType: "Rotozoom", hardware: ["Bitplanes", "Math"], concepts: ["rotozoom", "fixed point", "texture sampling"], dependencies: ["23 Math - Interpolation and Scaling"]),
        item(28, "28 Effects - Parallax Logo Scene", "Generate a parallax logo scene with two bitplane layers, different scroll speeds, palette cycling, and a logo foreground.", difficulty: "Advanced", stage: "Effects", effectType: "Parallax", hardware: ["Bitplanes", "Copper"], concepts: ["parallax", "logo scene", "palette cycle"], dependencies: ["24 Effects - Starfield and Parallax"]),
        item(29, "29 C Integration - Menu Navigation", "Generate a menu/navigation shell that reads joystick or CIA mouse input, tracks a selected scene, and dispatches to scene IDs.", difficulty: "Intermediate", stage: "C Integration", effectType: "Menu", hardware: ["CIA", "Exec"], concepts: ["menu", "input", "scene dispatch"], language: "C", dependencies: ["04 System - VBlank Mouse Exit"]),
        item(30, "30 Showcase - Mini Demo Megamix", "Generate a mini demo scene plan that combines clean takeover, copper bars, sprite logo, sine scroller, starfield, Paula pulse, MOD replay scaffold, and clean restore.", difficulty: "Showcase", stage: "Showcase", effectType: "Megamix", hardware: ["Copper", "Blitter", "Sprites", "Paula", "CIA", "Bitplanes"], concepts: ["composition", "scene orchestration", "MOD replay"], value: ["Showcase", "Reuse"], status: "Verified", language: "C + ASM", dependencies: ["05 System - Clean Takeover Skeleton", "21 Audio - CIA-Timed MOD Scaffold", "28 Effects - Parallax Logo Scene"])
    ]
}

private struct RemoteDefaultPromptEnvelope: Decodable {
    let prompts: [PromptLibraryItem]
}
