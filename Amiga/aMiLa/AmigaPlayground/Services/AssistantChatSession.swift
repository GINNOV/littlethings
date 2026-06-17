import Foundation
import Combine
import AppKit

struct AssistantChatRequest {
    let messages: [OllamaService.ChatMessage]
}

struct AssistantChatCompletion {
    let injectedCode: String?
    let consoleMessage: String?
}

enum AssistantSourceEditPlanner {
    static func shouldEditExistingSource(prompt: String, source: String) -> Bool {
        let normalized = prompt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty,
              !source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        let generationStarters = ["generate", "create", "write", "build", "produce"]
        let startsAsNewGeneration = generationStarters.contains { starts(with: $0, in: normalized) }
        let wordEditSignals = [
            "set", "change", "update", "modify", "adjust", "replace",
            "add", "remove", "delete", "turn", "switch", "use",
            "preserve", "front", "back", "faster", "slower",
            "brighter", "darker"
        ]
        let phraseEditSignals = [
            "make it", "make this", "make the current", "without changing",
            "do not change", "don't change", "keep the code",
            "slow down", "speed up"
        ]
        let hasEditSignal = wordEditSignals.contains { containsWord($0, in: normalized) } ||
            phraseEditSignals.contains { containsPhrase($0, in: normalized) }
        let explicitlyTargetsExistingSource = containsWord("current", in: normalized) ||
            containsWord("existing", in: normalized)

        return hasEditSignal && (!startsAsNewGeneration || explicitlyTargetsExistingSource)
    }

    static func requestMessages(from messages: [OllamaService.ChatMessage], userPrompt: String, source: String) -> [OllamaService.ChatMessage] {
        let editPrompt = wrappedEditPrompt(userPrompt: userPrompt, source: source)
        guard !messages.isEmpty else {
            return [OllamaService.ChatMessage(role: "user", content: editPrompt)]
        }

        var editedMessages = messages
        editedMessages[editedMessages.count - 1] = OllamaService.ChatMessage(role: "user", content: editPrompt)
        return editedMessages
    }

    static func wrappedEditPrompt(userPrompt: String, source: String) -> String {
        let language = AssemblySourceFormatter.looksLikeC(source) ? "c" : "assembly"
        return """
        You are editing the source code currently open in the editor.

        User requested this change:
        \(userPrompt)

        Edit contract:
        - Modify the existing source below; do not start a new program from scratch.
        - Preserve labels, routines, setup/teardown code, comments, and structure unless the requested change requires a local edit.
        - Make the smallest coherent change that satisfies the request.
        - Return the complete updated source, not a fragment or explanation.
        - Return exactly one fenced code block tagged \(language), with no prose outside it.

        Current editor source:
        ```\(language)
        \(source)
        ```
        """
    }

    private static func starts(with word: String, in normalizedPrompt: String) -> Bool {
        normalizedPrompt.split { !$0.isLetter && !$0.isNumber }.first.map(String.init) == word.lowercased()
    }

    private static func containsWord(_ word: String, in normalizedPrompt: String) -> Bool {
        normalizedPrompt.split { !$0.isLetter && !$0.isNumber }.contains { $0 == word.lowercased() }
    }

    private static func containsPhrase(_ phrase: String, in normalizedPrompt: String) -> Bool {
        let promptTokens = normalizedPrompt.split { !$0.isLetter && !$0.isNumber }
        let phraseTokens = phrase.lowercased().split { !$0.isLetter && !$0.isNumber }
        guard !phraseTokens.isEmpty,
              phraseTokens.count <= promptTokens.count else {
            return false
        }
        for start in 0...(promptTokens.count - phraseTokens.count) {
            let window = promptTokens[start..<(start + phraseTokens.count)]
            if zip(window, phraseTokens).allSatisfy({ $0 == $1 }) {
                return true
            }
        }
        return false
    }
}

enum AssistantPromptRoute: Equatable {
    case structuredModelPatch(AmigaProgramFollowUpPatchOutcome)
    case sourceEdit
    case generation
}

enum AssistantPromptRouter {
    static func route(prompt: String, source: String, isSelfCorrection: Bool) -> AssistantPromptRoute {
        guard !isSelfCorrection else { return .generation }

        let structuredPatch = AmigaProgramFollowUpPlanner.patchOutcome(prompt: prompt, source: source)
        switch structuredPatch {
        case .patched, .rejected:
            return .structuredModelPatch(structuredPatch)
        case .notRecognized:
            break
        }

        if AssistantSourceEditPlanner.shouldEditExistingSource(prompt: prompt, source: source) {
            return .sourceEdit
        }

        return .generation
    }
}

enum AssistantReliabilityGatePolicy {
    static func allowsFreeFormRepair(source: String) -> Bool {
        AmigaSourceIndexer.index(source).model == nil
    }

    static func terminalFailureMessage(source: String, failures: [String]) -> String {
        let firstFailure = failures.first ?? "reliability gate failed"
        guard !allowsFreeFormRepair(source: source) else {
            return "Failed: \(firstFailure)"
        }

        return "Failed structured model-backed reliability gate. The app did not run free-form repair; editor content was kept.\nFirst failure: \(firstFailure)"
    }
}

enum AssistantStructuredPatchRejectionPresenter {
    static func assistantMessage(failures: [String]) -> String {
        """
        I could not safely apply that source-aware Amiga program patch:
        \(bulletList(from: failures))

        I left the editor unchanged.
        """
    }

    static func consoleMessage(failures: [String]) -> String {
        """
        Source-aware Amiga program patch rejected. The app did not fall back to free-form model editing.
        Failures:
        \(bulletList(from: failures))
        """
    }

    private static func bulletList(from failures: [String]) -> String {
        let normalizedFailures = failures
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !normalizedFailures.isEmpty else {
            return "- structured patch was rejected"
        }

        return normalizedFailures
            .map { "- \($0)" }
            .joined(separator: "\n")
    }
}

final class AssistantChatSession: ObservableObject {
    @Published private(set) var messages: [OllamaService.ChatMessage] = []
    @Published private(set) var currentGeneration = ""
    @Published private(set) var currentThinking = ""
    @Published private(set) var isGenerating = false

    func submit(_ rawPrompt: String) -> AssistantChatRequest? {
        let prompt = rawPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isGenerating else { return nil }

        let userMessage = OllamaService.ChatMessage(role: "user", content: prompt)
        messages.append(userMessage)
        currentGeneration = ""
        currentThinking = ""
        isGenerating = true

        return AssistantChatRequest(messages: messages)
    }

    func complete(fullResponse: String, streamedResponse: String, reasoningResponse: String = "", tokenUsage: TokenUsage? = nil) -> AssistantChatCompletion {
        isGenerating = false

        let initialResponseText = fullResponse.isEmpty ? streamedResponse : fullResponse
        let trimmedInitialResponse = initialResponseText.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalReasoning = reasoningResponse.isEmpty ? currentThinking : reasoningResponse
        let reasoningCodeFallback = Self.injectableCodeCandidate(from: finalReasoning)
        let responseText = trimmedInitialResponse.isEmpty ? (reasoningCodeFallback ?? initialResponseText) : initialResponseText
        let trimmedResponse = responseText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedResponse.isEmpty else {
            let errorText: String
            if !finalReasoning.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorText = "Thinking process completed, but no clean code or response was generated. You can view the reasoning chain in the Thinking Process tab."
            } else {
                errorText = "No response text was returned by the LLM server. Check the selected provider, model name, and server logs."
            }
            messages.append(OllamaService.ChatMessage(
                role: "assistant",
                content: errorText,
                reasoning: finalReasoning,
                tokenUsage: tokenUsage
            ))
            currentGeneration = ""
            currentThinking = ""
            return AssistantChatCompletion(injectedCode: nil, consoleMessage: nil)
        }

        messages.append(OllamaService.ChatMessage(role: "assistant", content: responseText, reasoning: finalReasoning, tokenUsage: tokenUsage))
        currentGeneration = ""
        currentThinking = ""

        return extractCodeForEditor(from: responseText)
    }

    static func stripPlanningBlocks(from text: String) -> String {
        let pattern = "(?s)<planning>.*?</planning>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return text
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        var result = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
        
        if let planningRange = result.range(of: "<planning>", options: .caseInsensitive) {
            result = String(result[..<planningRange.lowerBound])
        }
        return result
    }

    private static func injectableCodeCandidate(from reasoningText: String) -> String? {
        let stripped = stripPlanningBlocks(from: reasoningText)
        let trimmedReasoning = stripped.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedReasoning.isEmpty else { return nil }

        if let range = trimmedReasoning.range(of: "```[a-zA-Z0-9]*\n", options: .regularExpression),
           let endRange = trimmedReasoning[range.upperBound...].range(of: "```") {
            return String(trimmedReasoning[range.lowerBound..<endRange.upperBound])
        }

        let uppercased = trimmedReasoning.uppercased()
        guard uppercased.contains("SECTION") ||
                uppercased.contains("MOVE.") ||
                uppercased.contains("DC.W") else {
            return nil
        }

        return trimmedReasoning
    }

    private func extractCodeForEditor(from responseText: String) -> AssistantChatCompletion {
        let strippedResponse = Self.stripPlanningBlocks(from: responseText)
        if let range = strippedResponse.range(of: "```[a-zA-Z0-9]*\n", options: .regularExpression),
           let endRange = strippedResponse[range.upperBound...].range(of: "```") {
            let codeContent = strippedResponse[range.upperBound..<endRange.lowerBound]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return AssistantChatCompletion(
                injectedCode: AssemblySourceFormatter.vasmReadySource(from: codeContent),
                consoleMessage: "Injected code block from Amiga Assistant."
            )
        }

        if isLikelyInjectableCode(strippedResponse) {
            return AssistantChatCompletion(
                injectedCode: AssemblySourceFormatter.vasmReadySource(from: strippedResponse),
                consoleMessage: "Injected full assistant text block."
            )
        }

        return AssistantChatCompletion(injectedCode: nil, consoleMessage: nil)
    }

    func fail(_ error: Error) {
        isGenerating = false
        currentGeneration = ""
        currentThinking = ""
        messages.append(OllamaService.ChatMessage(
            role: "assistant",
            content: "Connection Error: \(error.localizedDescription)\nEnsure your LLM server (Ollama/LM Studio) is running on the specified port."
        ))
    }

    func cancel() {
        isGenerating = false

        let partialResponse = currentGeneration.trimmingCharacters(in: .whitespacesAndNewlines)
        currentGeneration = ""

        if partialResponse.isEmpty {
            messages.append(OllamaService.ChatMessage(role: "assistant", content: "Generation stopped."))
        } else {
            messages.append(OllamaService.ChatMessage(role: "assistant", content: "\(partialResponse)\n\n[Stopped]"))
        }
    }

    func reset() {
        messages = []
        currentGeneration = ""
        currentThinking = ""
        isGenerating = false
    }

    func appendChunk(_ chunk: String) {
        appendContentChunk(chunk)
    }

    func appendContentChunk(_ chunk: String) {
        currentGeneration += chunk
    }

    func appendReasoningChunk(_ chunk: String) {
        currentThinking += chunk
    }

    func reusablePrompt(from message: OllamaService.ChatMessage) -> String? {
        guard message.role == "user" else { return nil }

        let prompt = message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return prompt.isEmpty ? nil : prompt
    }

    func promptPrecedingAssistantMessage(_ assistantContent: String) -> String? {
        guard let assistantIndex = messages.firstIndex(where: {
            $0.role == "assistant" && $0.content == assistantContent
        }) else { return nil }

        return messages[..<assistantIndex]
            .last(where: { $0.role == "user" })
            .flatMap(reusablePrompt(from:))
    }

    func isLikelyInjectableCode(_ responseText: String) -> Bool {
        let uppercased = responseText.uppercased()
        guard !uppercased.contains("CONNECTION ERROR:"),
              !uppercased.contains("MODEL ") || !uppercased.contains(" NOT FOUND"),
              !uppercased.contains("ENSURE YOUR LLM SERVER") else {
            return false
        }

        return responseText.contains("```") ||
            uppercased.contains("SECTION") ||
            uppercased.contains("COPPER") ||
            uppercased.contains("MOVE.") ||
            uppercased.contains("DC.W")
    }
}

struct AssistantPromptTemplateMatch: Equatable {
    let id: String
    let name: String
    let source: String
    let parameters: [String: String]

    var consoleSummary: String {
        let parameterSummary = parameters
            .sorted { lhs, rhs in
                parameterDisplayOrder(lhs.key) < parameterDisplayOrder(rhs.key)
            }
            .map { "\(parameterDisplayName($0.key)): \($0.value)" }
            .joined(separator: "\n")

        if parameterSummary.isEmpty {
            return "Using template: \(name)"
        }

        return "Using template: \(name)\n\(parameterSummary)"
    }

    private func parameterDisplayName(_ key: String) -> String {
        switch key {
        case "text":
            return "Text"
        case "color":
            return "Color"
        case "speed":
            return "Speed"
        case "direction":
            return "Direction"
        case "object":
            return "Object"
        case "stars":
            return "Stars"
        case "bars":
            return "Bars"
        case "mode":
            return "Mode"
        case "motion":
            return "Motion"
        case "position":
            return "Position"
        case "font":
            return "Font"
        default:
            return key.prefix(1).uppercased() + key.dropFirst()
        }
    }

    private func parameterDisplayOrder(_ key: String) -> Int {
        switch key {
        case "text":
            return 10
        case "color":
            return 20
        case "mode":
            return 30
        case "motion":
            return 40
        case "position":
            return 50
        case "font":
            return 60
        case "speed":
            return 70
        case "direction":
            return 80
        case "object":
            return 90
        case "stars":
            return 100
        case "bars":
            return 110
        default:
            return 1_000
        }
    }
}

enum AssistantPromptTemplate {
    static func source(for prompt: String) -> String? {
        match(for: prompt)?.source
    }

    static func match(for prompt: String) -> AssistantPromptTemplateMatch? {
        let normalized = prompt.lowercased()

        if let programMatch = AmigaProgramFollowUpPlanner.modPlayerControlsMatch(for: prompt) {
            return programMatch
        }

        if normalized.contains("mini demo") || normalized.contains("megamix") || normalized.contains("scene plan") {
            return makeMatch(
                prompt: prompt,
                source: miniDemoMegamixDemo,
                id: "mini-demo-megamix",
                name: "Mini demo megamix",
                parameters: [
                    "mode": "composition",
                    "object": "multi-effect scene"
                ]
            )
        }

        if normalized.contains("register") && normalized.contains("stack") {
            return makeMatch(
                prompt: prompt,
                source: registersAndStackDemo,
                id: "registers-stack",
                name: "Registers and stack",
                parameters: [
                    "mode": "foundation",
                    "object": "68000 registers"
                ]
            )
        }

        if normalized.contains("addressing") || normalized.contains("fast ram") || normalized.contains("data sections") {
            return makeMatch(
                prompt: prompt,
                source: memoryAndAddressingDemo,
                id: "memory-addressing",
                name: "Addressing and memory sections",
                parameters: [
                    "mode": "foundation",
                    "object": "addressing modes and memory sections"
                ]
            )
        }

        if isMinimalExecutablePrompt(normalized) {
            return makeMatch(
                prompt: prompt,
                source: minimalExecutableDemo,
                id: "minimal-executable",
                name: "Minimal executable",
                parameters: [
                    "mode": "minimal"
                ]
            )
        }

        if normalized.contains("mod replay") || normalized.contains("mod-style") || normalized.contains("cia-timed") || normalized.contains("cia timer") {
            return makeMatch(
                prompt: prompt,
                source: modReplayScaffoldDemo,
                id: "mod-replay-scaffold",
                name: "MOD replay scaffold",
                parameters: [
                    "mode": "audio timing",
                    "object": "CIA-timed pattern rows"
                ]
            )
        }

        if normalized.contains("4 channel") || normalized.contains("four channel") || normalized.contains("waveform") {
            return makeMatch(
                prompt: prompt,
                source: fourChannelPaulaDemo,
                id: "four-channel-paula",
                name: "Four channel Paula waveform",
                parameters: [
                    "mode": "audio",
                    "object": "Paula channels"
                ]
            )
        }

        if normalized.contains("intuition.library") || (normalized.contains("intuition") && normalized.contains("window")) || (normalized.contains("window") && normalized.contains("gadget")) {
            guard let source = try? AmigaProgramTemplate.verifiedIntuitionWindowToolSource() else {
                return nil
            }
            return makeMatch(
                prompt: prompt,
                source: source,
                id: "intuition-window-tool",
                name: "Intuition windowed tool",
                parameters: [
                    "mode": "system friendly",
                    "object": "intuition window and gadgets"
                ]
            )
        }

        if normalized.contains("clean takeover") || normalized.contains("save") && normalized.contains("restore") && normalized.contains("os") {
            guard let source = try? AmigaProgramTemplate.verifiedCleanTakeoverRestoreSource() else {
                return nil
            }
            return makeMatch(
                prompt: prompt,
                source: source,
                id: AmigaProgramTemplate.cleanTakeoverRestoreID,
                name: "Clean takeover skeleton",
                parameters: [
                    "mode": "system init",
                    "object": "OS display state"
                ]
            )
        }

        if normalized.contains("double-buffered copper") || normalized.contains("double buffered copper") || normalized.contains("copper lists") && normalized.contains("swap") {
            return makeMatch(
                prompt: prompt,
                source: doubleBufferedCopperDemo,
                id: "double-buffered-copper",
                name: "Double-buffered copper lists",
                parameters: [
                    "mode": "copper",
                    "object": "two copper lists"
                ]
            )
        }

        if normalized.contains("register map") || normalized.contains("$dff000") || (normalized.contains("custom chip") && normalized.contains("register")) {
            return makeMatch(
                prompt: prompt,
                source: customChipRegisterMapDemo,
                id: "custom-chip-register-map",
                name: "Custom chip register map",
                parameters: [
                    "mode": "reference",
                    "object": "custom chip registers"
                ]
            )
        }

        if normalized.contains("twister") {
            return makeMatch(
                prompt: prompt,
                source: twisterBlitterDemo,
                id: "twister-effect",
                name: "Twister effect",
                parameters: [
                    "mode": "effect",
                    "object": "sine blitter slices"
                ]
            )
        }

        if normalized.contains("line mode") || normalized.contains("line draw") {
            return makeMatch(
                prompt: prompt,
                source: blitterLineModeDemo,
                id: "blitter-line-mode",
                name: "Blitter line mode",
                parameters: [
                    "mode": "blitter",
                    "object": "line draw"
                ]
            )
        }

        if normalized.contains("masked copy") || normalized.contains("cookie-cut") || normalized.contains("minterm") {
            return makeMatch(
                prompt: prompt,
                source: blitterMaskedCopyDemo,
                id: "blitter-masked-copy",
                name: "Blitter masked copy",
                parameters: [
                    "mode": "blitter helper",
                    "object": "cookie-cut copy"
                ]
            )
        }

        if normalized.contains("blitter"),
           (normalized.contains("bob") || normalized.contains("object")),
           normalized.contains("collision") || normalized.contains("bounds") {
            guard let source = try? AmigaProgramTemplate.verifiedBlitterBOBCollisionBoundsSource() else {
                return nil
            }
            return makeMatch(
                prompt: prompt,
                source: source,
                id: AmigaProgramTemplate.blitterBOBCollisionBoundsID,
                name: "Blitter BOB collision bounds",
                parameters: [
                    "mode": "blitter object",
                    "object": "bounded masked BOB",
                    "collision": "rectangle"
                ]
            )
        }

        if normalized.contains("4-bitplane") || normalized.contains("four-bitplane") || normalized.contains("16-color") || normalized.contains("16 color") {
            return makeMatch(
                prompt: prompt,
                source: fourBitplaneDisplayDemo,
                id: "four-bitplane-display",
                name: "Four-bitplane display",
                parameters: [
                    "mode": "display",
                    "object": "16-color bitplanes"
                ]
            )
        }

        if normalized.contains("blitter") || normalized.contains("blit") {
            return makeMatch(
                prompt: prompt,
                source: blitterClearDemo,
                id: "blitter-clear",
                name: "Blitter clear",
                parameters: [
                    "mode": "hardware sample",
                    "object": "screen buffer"
                ]
            )
        }

        if normalized.contains("plasma") {
            return makeMatch(
                prompt: prompt,
                source: plasmaPaletteDemo,
                id: "plasma-effect",
                name: "Plasma palette effect",
                parameters: [
                    "mode": "effect",
                    "object": "sine palette"
                ]
            )
        }

        if normalized.contains("rotozoom") || normalized.contains("roto-zoom") {
            return makeMatch(
                prompt: prompt,
                source: rotozoomLiteDemo,
                id: "rotozoom-lite",
                name: "Rotozoom lite",
                parameters: [
                    "mode": "effect",
                    "object": "fixed-point texture"
                ]
            )
        }

        if normalized.contains("parallax logo") || normalized.contains("logo scene") {
            return makeMatch(
                prompt: prompt,
                source: parallaxLogoSceneDemo,
                id: "parallax-logo-scene",
                name: "Parallax logo scene",
                parameters: [
                    "mode": "effect",
                    "object": "logo layers"
                ]
            )
        }

        if normalized.contains("menu") || normalized.contains("navigation") {
            return makeMatch(
                prompt: prompt,
                source: menuNavigationDemo,
                id: "menu-navigation",
                name: "Menu navigation",
                parameters: [
                    "mode": "control",
                    "object": "scene menu"
                ]
            )
        }

        if normalized.contains("interpolation") || normalized.contains("perspective") || normalized.contains("scaling") {
            return makeMatch(
                prompt: prompt,
                source: interpolationMathDemo,
                id: "interpolation-math",
                name: "Interpolation math",
                parameters: [
                    "mode": "math",
                    "object": "fixed-point interpolation"
                ]
            )
        }

        if normalized.contains("attached") && normalized.contains("sprite") {
            return makeMatch(
                prompt: prompt,
                source: attachedSpriteDemo,
                id: "attached-sprite-logo",
                name: "Attached sprite logo",
                parameters: [
                    "mode": "hardware sprite",
                    "object": "attached sprite pair"
                ]
            )
        }

        if normalized.contains("audio") || normalized.contains("sound") || normalized.contains("beep") || normalized.contains("tone") {
            if normalized.contains("frame") || normalized.contains("music") || normalized.contains("intro") {
                return makeMatch(
                    prompt: prompt,
                    source: frameSyncedAudioIntroDemo,
                    id: "frame-synced-audio-intro",
                    name: "Frame-synced audio intro",
                    parameters: [
                        "mode": "frame-synced",
                        "object": "Paula channel 0"
                    ]
                )
            }

            return makeMatch(
                prompt: prompt,
                source: audioPulseDemo,
                id: "audio-pulse",
                name: "Audio pulse",
                parameters: [
                    "mode": "hardware sample",
                    "object": "Paula channel 0"
                ]
            )
        }

        if normalized.contains("raster split") || normalized.contains("raster splits") {
            return makeMatch(
                prompt: prompt,
                source: rasterSplitDemo,
                id: "raster-splits",
                name: "Raster splits",
                parameters: [
                    "mode": "copper raster splits",
                    "bars": requestedCount(from: prompt, fallback: 6)
                ]
            )
        }

        if normalized.contains("starfield") || normalized.contains("star field") || normalized.contains("stars") {
            return makeMatch(
                prompt: prompt,
                source: starfieldDemo,
                id: "starfield",
                name: "Starfield",
                parameters: [
                    "mode": "scrolling",
                    "stars": requestedCount(from: prompt, fallback: 16),
                    "speed": requestedSpeed(from: prompt)
                ]
            )
        }

        if isMouseSpriteMultiplexPrompt(normalized),
           let source = try? mouseSpriteMultiplexDemo() {
            return makeMatch(
                prompt: prompt,
                source: source,
                id: "mouse-sprite-multiplex",
                name: "Mouse sprite multiplex",
                parameters: [
                    "mode": "mouse-controlled multiplex",
                    "object": "sprite",
                    "copies": "2"
                ]
            )
        }

        if (normalized.contains("sprite") || normalized.contains("object")) && normalized.contains("bounc") {
            return makeMatch(
                prompt: prompt,
                source: bouncingSpriteDemo,
                id: "bouncing-sprite",
                name: "Bouncing sprite",
                parameters: [
                    "mode": "bouncing",
                    "object": requestedObjectType(from: prompt),
                    "direction": requestedDirection(from: prompt, fallback: "vertical"),
                    "speed": requestedSpeed(from: prompt)
                ]
            )
        }

        if isDoubleBufferedBitplanePrompt(normalized) {
            let frontColor = requestedRoleColorName(from: prompt, role: "front") ?? "yellow"
            let backColor = requestedRoleColorName(from: prompt, role: "back") ?? "cyan"
            guard let source = try? AmigaProgramTemplate.verifiedDoubleBufferedBitplaneSource(frontColor: frontColor, backColor: backColor) else {
                return nil
            }
            return makeMatch(
                prompt: prompt,
                source: source,
                id: "double-buffer-bitplane",
                name: "Model-backed double-buffered bitplane",
                parameters: [
                    "mode": "double buffered",
                    "object": "bitplane",
                    "frontColor": frontColor,
                    "backColor": backColor
                ]
            )
        }

        if let textEffectSource = textEffectSource(for: prompt, normalized: normalized) {
            return makeMatch(prompt: prompt, source: textEffectSource)
        }

        if isBackgroundColorPrompt(normalized) {
            return makeMatch(
                prompt: prompt,
                source: backgroundColorDemo(prompt: prompt),
                id: "background-color",
                name: "Background color",
                parameters: [
                    "mode": "static",
                    "color": requestedColorName(from: prompt) ?? "yellow"
                ]
            )
        }

        if normalized.contains("copper") {
            if normalized.contains("bounc"),
               normalized.contains("bar") || normalized.contains("band") || normalized.contains("multi color") || normalized.contains("multicolor") || normalized.contains("multi-color") {
                return makeMatch(
                    prompt: prompt,
                    source: bouncingMulticolorCopperList,
                    id: "bouncing-copper-bars",
                    name: "Bouncing copper bars",
                    parameters: [
                        "mode": "bouncing",
                        "bars": requestedCount(from: prompt, fallback: 6),
                        "direction": requestedDirection(from: prompt, fallback: "vertical"),
                        "speed": requestedSpeed(from: prompt)
                    ]
                )
            }

            if normalized.contains("static") || normalized.contains("tiny") || normalized.contains("demo") || normalized.contains("sample") || normalized.contains("bar") || normalized.contains("band") || normalized.contains("stripe") {
                return makeMatch(
                    prompt: prompt,
                    source: staticCopperListDemo,
                    id: "static-copper-bars",
                    name: "Static copper bars",
                    parameters: [
                        "mode": "static",
                        "bars": requestedCount(from: prompt, fallback: 6)
                    ]
                )
            }
        }

        if isWaitOrMouseExitPrompt(normalized) {
            return makeMatch(
                prompt: prompt,
                source: waitForVBlankMouseExitDemo,
                id: "wait-vblank-mouse-exit",
                name: "VBlank mouse exit",
                parameters: [
                    "mode": "wait loop",
                    "object": "left mouse button"
                ]
            )
        }

        if isInputReaderPrompt(normalized) {
            return makeMatch(
                prompt: prompt,
                source: inputReaderDemo,
                id: "input-reader",
                name: "Input reader",
                parameters: [
                    "mode": "hardware sample",
                    "object": normalized.contains("joystick") ? "joystick" : "mouse"
                ]
            )
        }

        return nil
    }

    static func fallbackMessage(for prompt: String) -> String {
        let suggestions = nearestTemplateSuggestions(for: prompt)
        let suffix = suggestions.isEmpty ? "" : "\nNearest supported templates: \(suggestions.joined(separator: ", "))."
        return "No deterministic template matched this prompt. Using model generation with compile, semantic, and repair validation; generated code may still need repair before it is buildable or visually correct.\(suffix)"
    }

    private static func makeMatch(prompt: String, source: String) -> AssistantPromptTemplateMatch {
        if source.contains("Sinusoidal scrolling text template.") {
            return makeMatch(
                prompt: prompt,
                source: source,
                id: "sinusoidal-text",
                name: "Sinusoidal text",
                parameters: textParameters(for: prompt).merging([
                    "mode": "scrolling",
                    "motion": "sinusoidal scroll",
                    "direction": requestedDirection(from: prompt, fallback: "right"),
                    "speed": requestedSpeed(from: prompt)
                ]) { first, _ in first }
            )
        }

        if source.contains("Color-cycling text template.") {
            return makeMatch(
                prompt: prompt,
                source: source,
                id: "color-cycling-text",
                name: "Color-cycling text",
                parameters: textParameters(for: prompt).merging([
                    "mode": "centered",
                    "motion": "color cycle",
                    "speed": requestedSpeed(from: prompt)
                ]) { first, _ in first }
            )
        }

        return makeMatch(
            prompt: prompt,
            source: source,
            id: "centered-text",
            name: "Centered text",
            parameters: textParameters(for: prompt).merging([
                "mode": "centered",
                "position": "center",
                "font": "bitmap fancy"
            ]) { first, _ in first }
        )
    }

    private static func makeMatch(prompt: String, source: String, id: String, name: String, parameters: [String: String]) -> AssistantPromptTemplateMatch {
        let filteredParameters = parameters.filter { !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return AssistantPromptTemplateMatch(
            id: id,
            name: name,
            source: source,
            parameters: filteredParameters
        )
    }

    private static func textParameters(for prompt: String) -> [String: String] {
        [
            "text": requestedText(from: prompt),
            "color": requestedColorName(from: prompt) ?? "yellow"
        ]
    }

    private static func isMinimalExecutablePrompt(_ normalized: String) -> Bool {
        (normalized.contains("minimal") || normalized.contains("smallest") || normalized.contains("empty")) &&
            (normalized.contains("program") || normalized.contains("executable") || normalized.contains("sample") || normalized.contains("amiga"))
    }

    private static func isBackgroundColorPrompt(_ normalized: String) -> Bool {
        let asksForColor = normalized.contains("background") || normalized.contains("screen color") || normalized.contains("screen colour") || normalized.contains("set color") || normalized.contains("set colour")
        return asksForColor && !normalized.contains("text") && !normalized.contains("logo") && !normalized.contains("star")
    }

    private static func isInputReaderPrompt(_ normalized: String) -> Bool {
        normalized.contains("joystick") ||
            normalized.contains("read mouse") ||
            normalized.contains("mouse button") ||
            (normalized.contains("input") && !normalized.contains("copper") && !normalized.contains("sprite"))
    }

    private static func isDoubleBufferedBitplanePrompt(_ normalized: String) -> Bool {
        let hasDoubleBufferSignal = containsPhrase("double buffer", in: normalized) ||
            containsPhrase("double buffered", in: normalized)
        let hasBitplaneSignal = containsWord("bitplane", in: normalized) ||
            containsWord("bitplanes", in: normalized)
        let hasEffectSignal = containsWord("swap", in: normalized) ||
            containsWord("swaps", in: normalized) ||
            containsWord("pointer", in: normalized) ||
            containsWord("pointers", in: normalized) ||
            containsWord("animation", in: normalized) ||
            containsPhrase("front and back", in: normalized)
        return hasDoubleBufferSignal && hasBitplaneSignal && hasEffectSignal
    }

    private static func isWaitOrMouseExitPrompt(_ normalized: String) -> Bool {
        let asksForWait = normalized.contains("wait loop") ||
            normalized.contains("vblank") ||
            normalized.contains("vertical blank") ||
            normalized.contains("wait for raster") ||
            normalized.contains("wait for frame")
        let asksForExit = normalized.contains("exit") ||
            normalized.contains("quit") ||
            normalized.contains("stop") ||
            normalized.contains("until")
        let asksForMouse = normalized.contains("left mouse") ||
            normalized.contains("mouse click") ||
            normalized.contains("mouse button")
        return asksForWait || (asksForExit && asksForMouse)
    }

    private static func requestedCount(from prompt: String, fallback: Int) -> String {
        let numberWords: [String: Int] = [
            "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
            "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
            "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14,
            "fifteen": 15, "sixteen": 16, "seventeen": 17, "eighteen": 18,
            "nineteen": 19, "twenty": 20
        ]

        if let match = prompt.range(of: #"(?i)\b([0-9]{1,3})\s+(stars?|bars?|objects?|sprites?)\b"#, options: .regularExpression) {
            let phrase = String(prompt[match])
            if let number = phrase.split(whereSeparator: { !$0.isNumber }).first {
                return String(number)
            }
        }

        if let match = prompt.range(of: #"(?i)\b(stars?|bars?|objects?|sprites?)\s*[:=]?\s*([0-9]{1,3})\b"#, options: .regularExpression) {
            let phrase = String(prompt[match])
            if let number = phrase.split(whereSeparator: { !$0.isNumber }).first {
                return String(number)
            }
        }

        for (word, value) in numberWords where prompt.range(of: #"(?i)\b\#(word)\s+(stars?|bars?|objects?|sprites?)\b"#, options: .regularExpression) != nil {
            return "\(value)"
        }

        return "\(fallback)"
    }

    private static func requestedDirection(from prompt: String, fallback: String) -> String {
        let normalized = prompt.lowercased()
        if normalized.contains("left") {
            return "left"
        }
        if normalized.contains("right") {
            return "right"
        }
        if normalized.contains("horizontal") {
            return "horizontal"
        }
        if normalized.contains("vertical") || normalized.contains("up") || normalized.contains("down") {
            return "vertical"
        }
        return fallback
    }

    private static func requestedSpeed(from prompt: String) -> String {
        let normalized = prompt.lowercased()
        if normalized.contains("fast") {
            return "fast"
        }
        if normalized.contains("slow") {
            return "slow"
        }
        if let match = normalized.range(of: #"speed\s+[0-9]+"#, options: .regularExpression) {
            return String(normalized[match])
        }
        return "normal"
    }

    private static func isMouseSpriteMultiplexPrompt(_ normalized: String) -> Bool {
        normalized.contains("sprite")
            && (normalized.contains("mouse") || normalized.contains("pointer"))
            && (normalized.contains("multiplex") || normalized.contains("copy") || normalized.contains("second"))
    }

    private static func requestedObjectType(from prompt: String) -> String {
        let normalized = prompt.lowercased()
        for object in ["saucer", "ufo", "ball", "ship", "object", "sprite"] where normalized.contains(object) {
            return object
        }
        return "sprite"
    }

    private static func requestedColorName(from prompt: String) -> String? {
        let normalized = prompt.lowercased()
        for color in ["white", "yellow", "green", "cyan", "blue", "purple", "magenta", "red", "orange"] where normalized.contains(color) {
            return color
        }
        return nil
    }

    private static func requestedRoleColorName(from prompt: String, role: String) -> String? {
        let normalized = prompt.lowercased()
        guard let roleRange = normalized.range(of: role) else { return nil }
        let searchEnd = normalized.index(roleRange.upperBound, offsetBy: 80, limitedBy: normalized.endIndex) ?? normalized.endIndex
        let nearbyText = normalized[roleRange.upperBound..<searchEnd]
        var closestColor: (name: String, distance: Int)?
        for color in ["white", "yellow", "green", "cyan", "blue", "purple", "magenta", "red", "orange"] {
            guard let colorRange = nearbyText.range(of: color) else { continue }
            let distance = nearbyText.distance(from: nearbyText.startIndex, to: colorRange.lowerBound)
            if closestColor == nil || distance < closestColor!.distance {
                closestColor = (color, distance)
            }
        }
        return closestColor?.name
    }

    private static func requestedColorValue(from prompt: String) -> String {
        switch requestedColorName(from: prompt) {
        case "white":
            return "$0fff"
        case "green":
            return "$00f0"
        case "cyan":
            return "$00ff"
        case "blue":
            return "$000f"
        case "purple", "magenta":
            return "$0f0f"
        case "red":
            return "$0f00"
        case "orange":
            return "$0f80"
        default:
            return "$0ff0"
        }
    }

    private static func colorValue(named color: String?) -> String {
        switch color {
        case "white":
            return "$0fff"
        case "green":
            return "$00f0"
        case "cyan":
            return "$00ff"
        case "blue":
            return "$000f"
        case "purple", "magenta":
            return "$0f0f"
        case "red":
            return "$0f00"
        case "orange":
            return "$0f80"
        default:
            return "$0ff0"
        }
    }

    private static func nearestTemplateSuggestions(for prompt: String) -> [String] {
        let normalized = prompt.lowercased()
        var suggestions: [String] = []

        if normalized.contains("text") || normalized.contains("word") || normalized.contains("logo") {
            suggestions.append(contentsOf: ["Centered text", "Sinusoidal text", "Color-cycling text"])
        }
        if normalized.contains("copper") || normalized.contains("bar") {
            suggestions.append(contentsOf: ["Static copper bars", "Bouncing copper bars"])
        }
        if normalized.contains("star") {
            suggestions.append("Starfield")
        }
        if normalized.contains("sprite") || normalized.contains("object") || normalized.contains("bounc") {
            suggestions.append("Bouncing sprite")
        }

        return Array(NSOrderedSet(array: suggestions)) as? [String] ?? suggestions
    }

    private static func containsWord(_ word: String, in normalizedPrompt: String) -> Bool {
        normalizedPrompt
            .split { !$0.isLetter && !$0.isNumber }
            .contains { $0 == word }
    }

    private static func containsPhrase(_ phrase: String, in normalizedPrompt: String) -> Bool {
        let promptTokens = normalizedPrompt.split { !$0.isLetter && !$0.isNumber }
        let phraseTokens = phrase.lowercased().split { !$0.isLetter && !$0.isNumber }
        guard !phraseTokens.isEmpty,
              phraseTokens.count <= promptTokens.count else {
            return false
        }
        for start in 0...(promptTokens.count - phraseTokens.count) {
            let window = promptTokens[start..<(start + phraseTokens.count)]
            if zip(window, phraseTokens).allSatisfy({ $0 == $1 }) {
                return true
            }
        }
        return false
    }

    private static func textEffectSource(for prompt: String, normalized: String) -> String? {
        guard normalized.contains("word") || normalized.contains("text") || normalized.contains("write") || normalized.contains("logo") || normalized.contains("says") else {
            return nil
        }

        let text = requestedText(from: prompt)
        guard !text.isEmpty else { return nil }

        if normalized.contains("scroll") && (normalized.contains("sinus") || normalized.contains("sine")) {
            return sineScrollingText(text, prompt: prompt)
        }

        if normalized.contains("color-cycl") || normalized.contains("color cycl") || normalized.contains("colour-cycl") || normalized.contains("colour cycl") {
            return colorCyclingText(text, prompt: prompt)
        }

        if normalized.contains("center") || normalized.contains("centre") || normalized.contains("fancy font") {
            return centeredFancyText(text, prompt: prompt)
        }

        return nil
    }

    private static func requestedText(from prompt: String) -> String {
        let quotePairs: [(Character, Character)] = [("\"", "\""), ("“", "”"), ("'", "'")]

        for (openingQuote, closingQuote) in quotePairs {
            guard let start = prompt.firstIndex(of: openingQuote) else { continue }
            let contentStart = prompt.index(after: start)
            guard let end = prompt[contentStart...].firstIndex(of: closingQuote) else { continue }
            let extracted = String(prompt[contentStart..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !extracted.isEmpty {
                return sanitizedDisplayText(extracted)
            }
        }

        let lowercased = prompt.lowercased()
        guard let wordsRange = lowercased.range(of: "words ") ?? lowercased.range(of: "text ") else {
            return ""
        }

        let tail = prompt[wordsRange.upperBound...]
        let stopWords = [" scroll", " across", " in ", " with ", " at ", " on "]
        let stopIndex = stopWords
            .compactMap { tail.lowercased().range(of: $0)?.lowerBound }
            .min()
        let extracted = stopIndex.map { String(tail[..<$0]) } ?? String(tail)

        return sanitizedDisplayText(extracted.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private static func sanitizedDisplayText(_ text: String) -> String {
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,!?:;-")
        let scalarView = text.unicodeScalars.map { scalar in
            allowed.contains(scalar) ? Character(scalar) : " "
        }
        return String(scalarView)
            .replacingOccurrences(of: #" +"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func assemblyStringLiteral(_ text: String) -> String {
        sanitizedDisplayText(text)
            .uppercased()
            .replacingOccurrences(of: "\"", with: "")
    }

    private static func centeredFancyText(_ text: String, prompt: String) -> String {
        textDisplayTemplate(
            title: "Centered fancy text template.",
            requestedText: text,
            textLiteral: assemblyStringLiteral(text),
            textColor: requestedColorValue(from: prompt),
            drawRoutineCall: "DrawCenteredText",
            mainLoop: """
                        move.w     #600,d0
            .hold:
                        bsr        WaitVBlank
                        dbf        d0,.hold
            """
        )
    }

    private static func sineScrollingText(_ text: String, prompt: String) -> String {
        textDisplayTemplate(
            title: "Sinusoidal scrolling text template.",
            requestedText: text,
            textLiteral: assemblyStringLiteral(text),
            textColor: requestedColorValue(from: prompt),
            drawRoutineCall: "DrawSineText",
            mainLoop: """
            .main:
                        btst       #6,$bfe001
                        beq        .exitDemo
                        bsr        ClearScreen
                        bsr        DrawSineText
                        bsr        WaitVBlank
                        addq.w     #1,FrameTick
                        cmp.w      #3,FrameTick
                        bne.s      .main
                        clr.w      FrameTick
                        addq.w     #1,ScrollX
                        cmp.w      #54,ScrollX
                        bne.s      .main
                        clr.w      ScrollX
                        bra.s      .main
            """
        )
    }

    private static func colorCyclingText(_ text: String, prompt: String) -> String {
        textDisplayTemplate(
            title: "Color-cycling text template.",
            requestedText: text,
            textLiteral: assemblyStringLiteral(text),
            textColor: requestedColorValue(from: prompt),
            drawRoutineCall: "DrawCenteredText",
            mainLoop: """
            .main:
                        btst       #6,$bfe001
                        beq        .exitDemo
                        bsr        WaitVBlank
                        move.w     ColorIndex(pc),d0
                        lea        ColorTable(pc),a0
                        move.w     0(a0,d0.w),TextColor
                        addq.w     #2,d0
                        cmp.w      #16,d0
                        bne.s      .storeColor
                        clr.w      d0
            .storeColor:
                        move.w     d0,ColorIndex
                        bra.s      .main
            """
        )
    }

    private static let minimalExecutableDemo = """
; Minimal runnable AmigaDOS executable template.
            SECTION    Code,CODE
            XDEF       _Start
_Start:
            moveq      #0,d0
            rts
"""

    private static let registersAndStackDemo = """
; Registers and stack foundation template.
            SECTION    Code,CODE
            XDEF       _Start
_Start:
            movem.l    d2-d3/a2,-(sp)      ; save caller-visible work regs
            moveq      #7,d0                ; data register literal
            move.w     d0,d1                ; word-sized register copy
            lea        DemoData(pc),a0      ; address register points at data
            move.w     (a0),d2              ; addressing mode: memory to register
            bsr.s      AddWords             ; subroutine call pushes return address
            movem.l    (sp)+,d2-d3/a2      ; restore saved regs
            moveq      #0,d0
            rts

AddWords:
            add.w      d1,d2
            move.w     d2,d3
            rts

DemoData:   dc.w       5
"""

    private static let memoryAndAddressingDemo = """
; Memory and addressing modes foundation template.
            SECTION    Code,CODE
            XDEF       _Start
_Start:
            movem.l    d2/a2,-(sp)
            lea        ChipWords(pc),a0      ; PC-relative addressing
            move.w     (a0)+,d0              ; post-increment
            move.w     2(a0),d1              ; displacement
            lea        FastScratch(pc),a1     ; ordinary data section reference
            move.w     d0,(a1)               ; register indirect store
            add.w      d1,d0
            movem.l    (sp)+,d2/a2
            rts

ChipWords:  dc.w       3,5,8,13
ChipBuffer: ds.b       64
FastScratch: dc.w      0
"""

    private static let doubleBufferedCopperDemo = """
; Double-buffered copper list template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        CopperListA(pc),a0
            lea        CopperListB(pc),a1
            move.l     a0,$80(a6)           ; COP1LC
            move.w     #0,$88(a6)           ; COPJMP1
            move.w     #$8280,$96(a6)       ; DMAEN + COPEN
            moveq      #15,d7
.swap:
            bsr        WaitVBlank
            exg        a0,a1
            move.l     a0,$80(a6)           ; install back-buffered copper list
            move.w     #0,$88(a6)
            dbf        d7,.swap
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

CopperListA:
            dc.w       $0100,$0200
            dc.w       $5007,$fffe,$0180,$00f
            dc.w       $ffff,$fffe
CopperListB:
            dc.w       $0100,$0200
            dc.w       $5007,$fffe,$0180,$0f0
            dc.w       $ffff,$fffe
"""

    private static let fourBitplaneDisplayDemo = """
; Four-bitplane 16-color display template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Plane0(pc),a0
            move.l     a0,$e0(a6)
            lea        Plane1(pc),a0
            move.l     a0,$e4(a6)
            lea        Plane2(pc),a0
            move.l     a0,$e8(a6)
            lea        Plane3(pc),a0
            move.l     a0,$ec(a6)
            move.w     #$4200,$100(a6)      ; BPLCON0: four low-res bitplanes
            move.w     #$0000,$102(a6)      ; BPLCON1 scroll
            move.w     #$2c81,$08e(a6)      ; DIWSTRT
            move.w     #$2cc1,$090(a6)      ; DIWSTOP
            move.w     #$0038,$092(a6)      ; DDFSTRT
            move.w     #$00d0,$094(a6)      ; DDFSTOP
            move.w     #$000,$180(a6)
            move.w     #$00f,$182(a6)
            move.w     #$0f0,$184(a6)
            move.w     #$f00,$186(a6)
            move.w     #$8300,$96(a6)
            rts

Plane0:     ds.b       40*256
Plane1:     ds.b       40*256
Plane2:     ds.b       40*256
Plane3:     ds.b       40*256
"""

    private static let blitterLineModeDemo = """
; Blitter line mode template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Bitplane(pc),a0
            bsr        WaitBlitter
            move.w     #$ffff,$44(a6)
            move.w     #$ffff,$46(a6)
            move.w     #$8000,$74(a6)
            move.w     #40,$66(a6)
            move.w     #$0bca,$40(a6)       ; BLTCON0 line minterm
            move.w     #$0001,$42(a6)       ; BLTCON1 octant/sign bits
            move.l     a0,$54(a6)
            move.w     #(64*64)+1,$58(a6)
            bsr        WaitBlitterAfter
            rts

WaitBlitter:
            btst       #6,$02(a6)
            bne.s      WaitBlitter
            rts

WaitBlitterAfter:
            btst       #6,$02(a6)
            bne.s      WaitBlitterAfter
            rts

Bitplane:   ds.b       40*256
"""

    private static let fourChannelPaulaDemo = """
; Four-channel Paula waveform template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Wave0(pc),a0
            move.l     a0,$a0(a6)           ; AUD0LC
            move.w     #8,$a4(a6)
            move.w     #428,$a6(a6)
            move.w     #40,$a8(a6)
            move.l     a0,$b0(a6)           ; AUD1LC
            move.w     #8,$b4(a6)
            move.w     #381,$b6(a6)
            move.w     #32,$b8(a6)
            move.l     a0,$c0(a6)           ; AUD2LC
            move.w     #8,$c4(a6)
            move.w     #340,$c6(a6)
            move.w     #28,$c8(a6)
            move.l     a0,$d0(a6)           ; AUD3LC
            move.w     #8,$d4(a6)
            move.w     #320,$d6(a6)
            move.w     #24,$d8(a6)
            move.w     #$8780,$96(a6)       ; DMAEN + AUD0-3
            rts

Wave0:      dc.b       0,48,96,127,96,48,0,-48
            dc.b       -96,-127,-96,-48,0,48,96,127
"""

    private static let modReplayScaffoldDemo = """
; CIA-timed MOD replay scaffold template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            move.b     #$7f,$bfdd00         ; CIA-B interrupt mask
            move.b     #$21,$bfdf00         ; CIA Timer B force-load placeholder
            move.b     #$81,$bfdd00         ; enable timer source
            move.b     $bfe001,d2           ; CIA port sample for input/timer sanity
            clr.w      ModRow
            move.w     #6,TickDivider
            bsr        ModTick
            rts

ModTick:
            subq.w     #1,TickDivider
            bne.s      .done
            move.w     #6,TickDivider
            move.w     ModRow(pc),d0
            add.w      d0,d0
            lea        ModPattern(pc),a0
            move.w     (a0,d0.w),d1
            lea        PeriodTable(pc),a1
            move.w     (a1,d1.w),$a6(a6)    ; AUD0PER
            lea        Sample(pc),a2
            move.l     a2,$a0(a6)           ; AUD0LC
            move.w     #8,$a4(a6)           ; AUD0LEN
            move.w     #48,$a8(a6)          ; AUD0VOL
            move.w     #$8201,$96(a6)       ; DMAEN + AUD0
            addq.w     #1,ModRow
            and.w      #$0007,ModRow
.done:
            rts

TickDivider: dc.w      6
ModRow:     dc.w       0
PeriodTable: dc.w      428,381,340,320
ModPattern: dc.w       0,2,4,6,4,2,0,6
Sample:     dc.b       0,64,127,64,0,-64,-127,-64
            dc.b       0,64,127,64,0,-64,-127,-64
"""

    private static let interpolationMathDemo = """
; Fixed-point interpolation and perspective scaling template.
            SECTION    Code,CODE
            XDEF       _Start
_Start:
            move.w     #$0100,d0            ; 8.8 fixed start
            move.w     #$0020,d1            ; interpolation step
            moveq      #7,d7
            lea        ScaleTable(pc),a0
.step:
            move.w     d0,(a0)+
            add.w      d1,d0
            dbf        d7,.step
            rts

ScaleTable: ds.w       8
"""

    private static let plasmaPaletteDemo = """
; Plasma palette effect template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)
            move.w     #0,$88(a6)
            move.w     #$8280,$96(a6)
            lea        SinePalette(pc),a0
            moveq      #7,d7
.patch:
            move.w     (a0)+,ColorPatch
            dbf        d7,.patch
            rts

SinePalette:
            dc.w       $008,$04a,$08c,$0ce,$0ef,$0ac,$068,$024
CopperList:
            dc.w       $0100,$0200
            dc.w       $4007,$fffe,$0180
ColorPatch: dc.w       $008
            dc.w       $ffff,$fffe
"""

    private static let twisterBlitterDemo = """
; Twister effect sine blitter slices template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Screen(pc),a0
            move.l     a0,$e0(a6)
            move.w     #$1200,$100(a6)
            move.w     #$8300,$96(a6)
            lea        Slice(pc),a1
            lea        SineOffsets(pc),a2
            moveq      #7,d7
.slice:
            bsr        WaitBlitter
            move.w     #$09f0,$40(a6)
            move.w     #$0000,$42(a6)
            move.w     #0,$64(a6)
            move.w     #38,$66(a6)
            move.l     a1,$50(a6)
            move.l     a0,$54(a6)
            move.w     #(8*64)+1,$58(a6)
            bsr        WaitBlitterAfter
            move.w     (a2)+,d0
            adda.w     d0,a0
            dbf        d7,.slice
            rts

WaitBlitter:
            btst       #6,$02(a6)
            bne.s      WaitBlitter
            rts

WaitBlitterAfter:
            btst       #6,$02(a6)
            bne.s      WaitBlitterAfter
            rts

SineOffsets: dc.w      0,2,4,6,4,2,0,-2
Slice:      dc.w       $ffff,$7ffe,$3ffc,$1ff8,$0ff0,$1ff8,$3ffc,$7ffe
Screen:     ds.b       40*256
"""

    private static let rotozoomLiteDemo = """
; Rotozoom-lite fixed-point bitplane template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Bitplane(pc),a0
            move.l     a0,$e0(a6)
            move.w     #$1200,$100(a6)
            move.w     #$8300,$96(a6)
            lea        Texture(pc),a1
            move.w     #$0100,d0            ; u
            move.w     #$0020,d1            ; du
            moveq      #15,d7
.sample:
            move.b     (a1),d2
            add.w      d1,d0
            dbf        d7,.sample
            rts

Texture:    dc.b       $00,$ff,$33,$cc,$0f,$f0,$55,$aa
Bitplane:   ds.b       40*256
"""

    private static let parallaxLogoSceneDemo = """
; Parallax logo scene template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        BackPlane(pc),a0
            move.l     a0,$e0(a6)
            move.w     #$2200,$100(a6)
            move.w     #$0000,$102(a6)      ; BPLCON1 scroll register
            move.w     #$8300,$96(a6)
            move.w     #$000f,LogoColor
            addq.w     #1,BackScroll
            addq.w     #2,LogoScroll
            rts

BackScroll: dc.w       0
LogoScroll: dc.w       0
LogoColor:  dc.w       0
BackPlane:  ds.b       40*256
LogoPlane:  ds.b       40*256
"""

    private static let menuNavigationDemo = """
; Menu navigation and input shell template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            move.w     $0c(a6),d0           ; JOY1DAT
            btst       #6,$bfe001           ; CIA left mouse/fire
            bne.s      .noSelect
            addq.w     #1,SelectedScene
            and.w      #$0003,SelectedScene
.noSelect:
            lea        SceneTable(pc),a0
            move.w     SelectedScene(pc),d1
            add.w      d1,d1
            move.w     (a0,d1.w),d0
            rts

SelectedScene: dc.w    0
SceneTable: dc.w       0,1,2,3
"""

    private static let customChipRegisterMapDemo = """
; Custom chip register map tour template.
CUSTOM      equ        $dff000
DMACON      equ        $096
INTENA      equ        $09a
BPLCON0     equ        $100
BPL1PTH     equ        $0e0
COLOR00     equ        $180
SPR0PTH     equ        $120
AUD0LCH     equ        $0a0
JOY1DAT     equ        $00c
VPOSR       equ        $004

            SECTION    Code,CODE
            XDEF       _Start
_Start:
            lea        CUSTOM,a6
            move.w     VPOSR(a6),d0         ; beam position/high vpos bits
            move.w     JOY1DAT(a6),d1       ; joystick register
            lea        Bitplane(pc),a0
            move.l     a0,$e0(a6)           ; BPL1PTH/BPL1PTL pointer
            move.w     #$0200,$100(a6)      ; BPLCON0 display mode register
            lea        Sprite0(pc),a0
            move.l     a0,$120(a6)          ; SPR0PTH/SPR0PTL pointer
            lea        Pulse(pc),a0
            move.l     a0,$a0(a6)           ; AUD0LCH/AUD0LCL pointer
            move.w     #8,$a4(a6)           ; AUD0LEN
            move.w     #214,$a6(a6)         ; AUD0PER
            move.w     #32,$a8(a6)          ; AUD0VOL
            move.w     #$000,$180(a6)       ; COLOR00 background palette entry
            move.w     #$7fff,INTENA(a6)    ; interrupt mask reference
            move.w     #$83a1,$96(a6)       ; DMACON DMA bit reference
            moveq      #0,d0
            rts

            ALIGN      4
Bitplane:   ds.b       40*256
Sprite0:    dc.w       $5080,$7000
            dc.w       $ffff,$ffff
            dc.w       $0000,$0000
Pulse:      dc.b       127,64,0,-64,-127,-64,0,64
            dc.b       127,64,0,-64,-127,-64,0,64
"""

    private static func backgroundColorDemo(prompt: String) -> String {
        """
; Background color hardware sample.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            movem.l    d2/a0/a6,-(sp)
            lea        $dff000,a6
            lea        Bitplane,a0
            move.l     a0,$e0(a6)           ; BPL1PT
            move.w     #$1200,$100(a6)      ; BPLCON0: one low-res bitplane
            move.w     #$0000,$102(a6)      ; BPLCON1
            move.w     #$0000,$104(a6)      ; BPLCON2
            move.w     #\(requestedColorValue(from: prompt)),$180(a6)
            move.w     #$0fff,$182(a6)
            move.w     #$8300,$96(a6)       ; master DMA + bitplane DMA

            move.w     #300,d2
.hold:
            bsr.s      WaitVBlank
            dbf        d2,.hold

            move.w     #$0100,$96(a6)       ; clear bitplane DMA
            movem.l    (sp)+,d2/a0/a6
            moveq      #0,d0
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

            SECTION    ChipData,DATA,CHIP
Bitplane:   ds.b       40*256
"""
    }

    private static let blitterClearDemo = """
; Blitter clear screen hardware sample.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Bitplane,a0
            move.l     a0,$e0(a6)           ; BPL1PT
            move.w     #$1200,$100(a6)      ; BPLCON0: one low-res bitplane
            move.w     #$0000,$102(a6)      ; BPLCON1
            move.w     #$0000,$104(a6)      ; BPLCON2

.waitBefore:
            btst       #6,$02(a6)           ; DMACONR blitter busy
            bne.s      .waitBefore

            move.w     #$0100,$40(a6)       ; BLTCON0: D channel clear/fill
            move.w     #$0000,$42(a6)       ; BLTCON1
            move.w     #$0000,$66(a6)       ; BLTDMOD
            move.l     a0,$54(a6)           ; BLTDPTH
            move.w     #(256*64)+20,$58(a6) ; BLTSIZE: 256 lines, 40 bytes

.waitAfter:
            btst       #6,$02(a6)
            bne.s      .waitAfter
            moveq      #0,d0
            rts

            SECTION    ChipData,DATA,CHIP
Bitplane:   ds.b       40*256
"""

    private static let blitterMaskedCopyDemo = """
; Blitter masked copy cookie-cut template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Source(pc),a0
            lea        Mask(pc),a1
            lea        Destination(pc),a2
            bsr.s      WaitBlitter
            move.w     #$0fca,$40(a6)       ; A/B/C -> D cookie-cut minterm
            move.w     #$0000,$42(a6)
            move.w     #0,$64(a6)           ; BLTAMOD
            move.w     #0,$62(a6)           ; BLTBMOD
            move.w     #0,$60(a6)           ; BLTCMOD
            move.w     #0,$66(a6)           ; BLTDMOD
            move.l     a1,$50(a6)           ; A = mask
            move.l     a0,$4c(a6)           ; B = source
            move.l     a2,$48(a6)           ; C = old destination
            move.l     a2,$54(a6)           ; D = destination
            move.w     #(16*64)+1,$58(a6)
.waitAfter:
            btst       #6,$02(a6)
            bne.s      .waitAfter
            moveq      #0,d0
            rts

WaitBlitter:
            btst       #6,$02(a6)
            bne.s      WaitBlitter
            rts

Source:     ds.w       16
Mask:       ds.w       16
Destination: ds.w      16
"""

    private static let blitterBOBCollisionBoundsDemo = """
; Blitter BOB collision bounds template.
; Effect: bounded masked BOB with rectangle collision color
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            movem.l    d2-d7/a2-a6,-(sp)
            lea        $dff000,a6
            lea        Bitplane,a0
            move.l     a0,$e0(a6)           ; BPL1PT
            move.w     #$1200,$100(a6)      ; BPLCON0: one low-res bitplane
            move.w     #$0000,$102(a6)
            move.w     #$0000,$104(a6)
            move.w     #$000,$180(a6)       ; COLOR00 background
            move.w     #$0f0,$182(a6)       ; COLOR01 non-collision object
            move.w     #$8300,$96(a6)       ; DMAEN + bitplane DMA

.main:
            btst       #6,$bfe001
            beq        .done
            bsr        WaitVBlank
            bsr        UpdateBOBPosition
            bsr        CheckCollision
            bsr        DrawBOB
            bra        .main

.done:
            move.w     #$0100,$96(a6)
            movem.l    (sp)+,d2-d7/a2-a6
            moveq      #0,d0
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

UpdateBOBPosition:
            move.w     BOBX(pc),d0
            add.w      BOBDX(pc),d0
            cmp.w      #16,d0
            bge.s      .rightBound
            move.w     #16,d0
            neg.w      BOBDX
.rightBound:
            cmp.w      #288,d0
            ble.s      .storeX
            move.w     #288,d0
            neg.w      BOBDX
.storeX:
            move.w     d0,BOBX
            move.w     BOBY(pc),d1
            add.w      BOBDY(pc),d1
            cmp.w      #32,d1
            bge.s      .bottomBound
            move.w     #32,d1
            neg.w      BOBDY
.bottomBound:
            cmp.w      #176,d1
            ble.s      .storeY
            move.w     #176,d1
            neg.w      BOBDY
.storeY:
            move.w     d1,BOBY
            rts

CheckCollision:
            clr.w      CollisionState
            move.w     BOBX(pc),d0
            cmp.w      TargetRight(pc),d0
            bgt.s      .noCollision
            add.w      #16,d0
            cmp.w      TargetLeft(pc),d0
            blt.s      .noCollision
            move.w     BOBY(pc),d1
            cmp.w      TargetBottom(pc),d1
            bgt.s      .noCollision
            add.w      #16,d1
            cmp.w      TargetTop(pc),d1
            blt.s      .noCollision
            move.w     #1,CollisionState
            move.w     #$f00,$182(a6)       ; COLOR01 collision evidence
            rts
.noCollision:
            move.w     #$0f0,$182(a6)
            rts

DrawBOB:
            bsr        WaitBlitter
            move.w     BOBY(pc),d0
            mulu       #40,d0
            move.w     BOBX(pc),d1
            lsr.w      #3,d1
            add.w      d1,d0
            lea        Bitplane,a2
            adda.w     d0,a2
            lea        BOBMask(pc),a0
            lea        BOBImage(pc),a1
            move.w     #$ffff,$44(a6)       ; BLTAFWM
            move.w     #$ffff,$46(a6)       ; BLTALWM
            move.w     #$0fca,$40(a6)       ; cookie-cut A/B/C to D
            move.w     #$0000,$42(a6)
            move.w     #0,$64(a6)           ; BLTAMOD
            move.w     #0,$62(a6)           ; BLTBMOD
            move.w     #38,$60(a6)          ; BLTCMOD
            move.w     #38,$66(a6)          ; BLTDMOD
            move.l     a0,$50(a6)           ; A = mask
            move.l     a1,$4c(a6)           ; B = image
            move.l     a2,$48(a6)           ; C = destination
            move.l     a2,$54(a6)           ; D = destination
            move.w     #(16*64)+1,$58(a6)   ; BLTSIZE: 16 rows, one word
.waitAfter:
            btst       #6,$02(a6)
            bne.s      .waitAfter
            rts

WaitBlitter:
            btst       #6,$02(a6)
            bne.s      WaitBlitter
            rts

BOBX:           dc.w       24
BOBY:           dc.w       48
BOBDX:          dc.w       2
BOBDY:          dc.w       1
TargetLeft:     dc.w       128
TargetTop:      dc.w       72
TargetRight:    dc.w       176
TargetBottom:   dc.w       120
CollisionState: dc.w       0

BOBMask:
            dc.w       $07e0,$1ff8,$3ffc,$7ffe
            dc.w       $7ffe,$ffff,$ffff,$ffff
            dc.w       $ffff,$ffff,$7ffe,$7ffe
            dc.w       $3ffc,$1ff8,$07e0,$0000
BOBImage:
            dc.w       $0180,$0660,$0ff0,$1998
            dc.w       $3ffc,$2664,$5ffa,$599a
            dc.w       $599a,$5ffa,$2664,$3ffc
            dc.w       $1998,$0ff0,$0660,$0180

            SECTION    ChipData,DATA,CHIP
Bitplane:   ds.b       40*256
"""

    private static let attachedSpriteDemo = """
; Attached sprite pair logo template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Sprite0(pc),a0
            lea        Sprite1(pc),a1
            move.l     a0,$120(a6)          ; SPR0PTH/L
            move.l     a1,$124(a6)          ; SPR1PTH/L
            move.w     #$8220,$96(a6)       ; DMAEN + sprite DMA
            moveq      #120,d0
.hold:
            bsr.s      WaitVBlank
            dbra       d0,.hold
            moveq      #0,d0
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

Sprite0:
            dc.b       $50,$70,$70,$80      ; attach bit lives in control word
            dc.w       $1818,$3c3c,$7e7e,$ffff
            dc.w       $0000,$0000
Sprite1:
            dc.b       $50,$70,$70,$00
            dc.w       $ffff,$7e7e,$3c3c,$1818
            dc.w       $0000,$0000
"""

    private static let miniDemoMegamixDemo = """
; Mini demo megamix composition template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)
            lea        Sprite0(pc),a0
            move.l     a0,$120(a6)
            lea        Pulse(pc),a0
            move.l     a0,$a0(a6)
            move.w     #8,$a4(a6)
            move.w     #214,$a6(a6)
            move.w     #64,$a8(a6)
            move.w     #0,$88(a6)
            move.w     #$83a1,$96(a6)       ; DMAEN+COPEN+BPLEN+SPRITE+AUD0
            moveq      #127,d7
.main:
            bsr.s      WaitVBlank
            addq.w     #1,Frame
            move.w     Frame(pc),d0
            and.w      #$000f,d0
            add.w      d0,d0
            lea        Palette(pc),a0
            move.w     (a0,d0.w),ColorPatch
            dbra       d7,.main
            moveq      #0,d0
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

Frame:      dc.w       0
Palette:    dc.w       $00f,$02f,$04f,$06f,$08f,$0af,$0cf,$0ff
            dc.w       $0fc,$0f8,$0f4,$0f0,$8f0,$cf0,$f80,$f40
CopperList:
            dc.w       $0100,$0200
            dc.w       $5007,$fffe,$0180
ColorPatch: dc.w       $00f
            dc.w       $9007,$fffe,$0180,$f40
            dc.w       $ffff,$fffe
Sprite0:
            dc.b       $48,$90,$68,$00
            dc.w       $1818,$3c3c,$7e7e,$ffff
            dc.w       $0000,$0000
Pulse:
            dc.b       127,127,64,0,-64,-127,-64,0
            dc.b       127,64,0,-64,-127,-64,0,64
"""

    private static let audioPulseDemo = """
; Paula audio channel 0 pulse sample.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            movem.l    d2/a0/a6,-(sp)
            lea        $dff000,a6
            lea        Pulse(pc),a0
            move.l     a0,$a0(a6)           ; AUD0LC
            move.w     #8,$a4(a6)           ; AUD0LEN in words
            move.w     #214,$a6(a6)         ; AUD0PER
            move.w     #64,$a8(a6)          ; AUD0VOL
            move.w     #$8201,$96(a6)       ; master DMA + AUD0EN

            move.w     #120,d2
.hold:
            bsr.s      WaitVBlank
            dbf        d2,.hold

            move.w     #$0001,$96(a6)       ; clear AUD0EN
            movem.l    (sp)+,d2/a0/a6
            moveq      #0,d0
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

            ALIGN      4
Pulse:
            dc.b       127,127,127,127,0,0,0,0
            dc.b       -127,-127,-127,-127,0,0,0,0
"""

    private static let waitForVBlankMouseExitDemo = """
; VBlank wait loop with left mouse exit sample.
            SECTION    Code,CODE
            XDEF       _Start
_Start:
            lea        $dff000,a6
.main:
            bsr.s      WaitVBlank
            btst       #6,$bfe001           ; left mouse button, 0 when pressed
            bne.s      .main
            moveq      #0,d0
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts
"""

    private static let inputReaderDemo = """
; Joystick and mouse input reader sample.
            SECTION    Code,CODE
            XDEF       _Start
_Start:
            lea        $dff000,a6
            move.w     $0c(a6),d0           ; JOY1DAT
            move.w     d0,d1
            lsr.w      #1,d1
            eor.w      d1,d0
            and.w      #$0303,d0            ; direction bits
            btst       #6,$bfe001           ; left mouse button state
            moveq      #0,d0
            rts
"""

    private static let rasterSplitDemo = """
; Raster split copper list template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)           ; COP1LC
            move.w     #$0000,$88(a6)       ; COPJMP1
            move.w     #$8280,$96(a6)       ; DMAEN + COPEN

            move.w     #300,d0
.hold:
            bsr.s      WaitVBlank
            dbf        d0,.hold

            move.w     #$0080,$96(a6)       ; clear copper DMA
            moveq      #0,d0
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

            ALIGN      2
CopperList:
            dc.w       $0100,$0200          ; no bitplanes, COLOR00 only
            dc.w       $2c07,$fffe,$0180,$0000
            dc.w       $3807,$fffe,$0180,$0222
            dc.w       $4807,$fffe,$0180,$0444
            dc.w       $5807,$fffe,$0180,$0666
            dc.w       $6807,$fffe,$0180,$0888
            dc.w       $7807,$fffe,$0180,$0aaa
            dc.w       $8807,$fffe,$0180,$0ccc
            dc.w       $9807,$fffe,$0180,$0eee
            dc.w       $ffff,$fffe
"""

    private static let frameSyncedAudioIntroDemo = """
; Frame-synced audio intro loop template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            movem.l    d2/a0/a6,-(sp)
            lea        $dff000,a6
            lea        Pulse(pc),a0
            move.l     a0,$a0(a6)           ; AUD0LC
            move.w     #8,$a4(a6)           ; AUD0LEN
            move.w     #214,$a6(a6)         ; AUD0PER
            move.w     #48,$a8(a6)          ; AUD0VOL
            move.w     #$8201,$96(a6)       ; master DMA + AUD0EN
            move.w     #$0000,$180(a6)

            moveq      #0,d2
.main:
            btst       #6,$bfe001
            beq.s      .done
            bsr.s      WaitVBlank
            addq.w     #2,d2
            and.w      #$000e,d2
            lea        ColorTable(pc),a0
            move.w     0(a0,d2.w),$180(a6)
            bra.s      .main

.done:
            move.w     #$0001,$96(a6)       ; clear AUD0EN
            movem.l    (sp)+,d2/a0/a6
            moveq      #0,d0
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

            ALIGN      2
ColorTable:
            dc.w       $0000,$0003,$0006,$0009,$000c,$000f,$033f,$066f
Pulse:
            dc.b       127,127,127,127,0,0,0,0
            dc.b       -127,-127,-127,-127,0,0,0,0
"""

    private static func textDisplayTemplate(title: String, requestedText: String, textLiteral: String, textColor: String, drawRoutineCall: String, mainLoop: String) -> String {
        """
; \(title)
; Requested text: \(sanitizedDisplayText(requestedText).lowercased())
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            bra        HardwareStart

HardwareStart:
            movem.l    d2-d7/a2-a6,-(sp)
            bsr        TakeOverDisplay
            tst.l      GfxBase
            beq        ExitProgram
            bsr        ClearScreen
            bsr        \(drawRoutineCall)

            lea        ScreenBuffer,a0
            move.l     a0,d0
            move.w     d0,Bpl1PTLValue
            swap       d0
            move.w     d0,Bpl1PTHValue
            move.l     a0,$e0(a5)           ; BPL1PT
            move.w     #$1200,$100(a5)      ; BPLCON0: 1 bitplane, low-res color display
            move.w     #$0000,$102(a5)      ; BPLCON1
            move.w     #$0000,$104(a5)      ; BPLCON2
            lea        CopperList(pc),a0
            move.l     a0,$80(a5)           ; COP1LC
            move.w     #$0000,$88(a5)       ; COPJMP1
            move.w     #$8380,$96(a5)       ; master DMA + BPLEN + COPEN

\(mainLoop)

.exitDemo:
            bsr        RestoreDisplay
ExitProgram:
            movem.l    (sp)+,d2-d7/a2-a6
            moveq      #0,d0
            rts

TakeOverDisplay:
            move.l     $4.w,a6              ; ExecBase
            lea        gfxName(pc),a1
            moveq      #0,d0
            jsr        -552(a6)             ; OpenLibrary
            move.l     d0,GfxBase
            beq.s      .takeoverFailed

            move.l     d0,a6
            move.l     34(a6),oldView       ; GfxBase->ActiView
            sub.l      a1,a1
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; WaitTOF()

            lea        $dff000,a5
            move.w     #$7fff,$9a(a5)       ; disable interrupts while this hardware demo owns the display
            move.w     #$7fff,$96(a5)       ; clear existing DMA enables before installing our display
            rts
.takeoverFailed:
            rts

RestoreDisplay:
            move.l     GfxBase(pc),d0
            beq.s      .restoreDone
            move.l     d0,a6
            move.l     oldView(pc),a1
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)
            jsr        -270(a6)
            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary
.restoreDone:
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a5)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a5)
            beq.s      .leave
            rts

ClearScreen:
            lea        ScreenBuffer,a0
            moveq      #0,d0
            move.w     #2559,d1
.clear:
            move.l     d0,(a0)+
            dbf        d1,.clear
            rts

DrawCenteredText:
            lea        TextString(pc),a1
            moveq      #13,d6               ; centered byte column for 13 glyphs
            moveq      #116,d5
            bra.s      DrawLinearText

DrawSineText:
            lea        TextString(pc),a1
            lea        SineOffsets(pc),a3
            moveq      #39,d6
            sub.w      ScrollX(pc),d6
            moveq      #0,d4
.nextSineChar:
            move.b     (a1)+,d0
            beq.s      .doneSine
            moveq      #0,d5
            move.b     0(a3,d4.w),d5
            ext.w      d5
            add.w      #104,d5
            tst.w      d6
            bmi.s      .skipSineGlyph
            cmp.w      #39,d6
            bgt.s      .skipSineGlyph
            bsr.s      DrawOneGlyph
.skipSineGlyph:
            addq.w     #1,d6
            addq.w     #1,d4
            bra.s      .nextSineChar
.doneSine:
            rts

DrawLinearText:
            move.b     (a1)+,d0
            beq.s      .doneLinear
            bsr.s      DrawOneGlyph
            addq.w     #1,d6
            bra.s      DrawLinearText
.doneLinear:
            rts

DrawOneGlyph:
            movem.l    d0-d2/a0/a2,-(sp)
            bsr        GlyphForChar
            lea        ScreenBuffer,a0
            move.w     d5,d1
            mulu       #40,d1
            add.w      d1,a0
            add.w      d6,a0
            moveq      #7,d2
.row:
            move.b     (a2)+,(a0)
            lea        40(a0),a0
            dbf        d2,.row
            movem.l    (sp)+,d0-d2/a0/a2
            rts

GlyphForChar:
            cmpi.b     #32,d0
            beq.s      .space
            cmpi.b     #65,d0
            beq.s      .letterA
            cmpi.b     #67,d0
            beq.s      .letterC
            cmpi.b     #69,d0
            beq.s      .letterE
            cmpi.b     #70,d0
            beq.s      .letterF
            cmpi.b     #71,d0
            beq.s      .letterG
            cmpi.b     #73,d0
            beq.s      .letterI
            cmpi.b     #76,d0
            beq.s      .letterL
            cmpi.b     #77,d0
            beq.s      .letterM
            cmpi.b     #78,d0
            beq.s      .letterN
            cmpi.b     #82,d0
            beq.s      .letterR
            cmpi.b     #83,d0
            beq.s      .letterS
            cmpi.b     #85,d0
            beq.s      .letterU
            cmpi.b     #89,d0
            beq.s      .letterY
.space:
            lea        GlyphSpace(pc),a2
            rts
.letterA:
            lea        GlyphA(pc),a2
            rts
.letterC:
            lea        GlyphC(pc),a2
            rts
.letterE:
            lea        GlyphE(pc),a2
            rts
.letterF:
            lea        GlyphF(pc),a2
            rts
.letterG:
            lea        GlyphG(pc),a2
            rts
.letterI:
            lea        GlyphI(pc),a2
            rts
.letterL:
            lea        GlyphL(pc),a2
            rts
.letterM:
            lea        GlyphM(pc),a2
            rts
.letterN:
            lea        GlyphN(pc),a2
            rts
.letterR:
            lea        GlyphR(pc),a2
            rts
.letterS:
            lea        GlyphS(pc),a2
            rts
.letterU:
            lea        GlyphU(pc),a2
            rts
.letterY:
            lea        GlyphY(pc),a2
            rts

            ALIGN      2
gfxName:    dc.b       "graphics.library",0
            EVEN
GfxBase:    dc.l       0
oldView:    dc.l       0

CopperList:
            dc.w       $008e,$2c81,$0090,$2cc1
            dc.w       $0092,$0038,$0094,$00d0
            dc.w       $00e0
Bpl1PTHValue:
            dc.w       $0000
            dc.w       $00e2
Bpl1PTLValue:
            dc.w       $0000
            dc.w       $0100,$1200,$0102,$0000,$0104,$0000
            dc.w       $0108,$0000,$010a,$0000
            dc.w       $0180,$0000,$0182
TextColor:  dc.w       \(textColor)
            dc.w       $ffff,$fffe

TextString:
            dc.b       "\(textLiteral)",0
SineOffsets:
            dc.b       0,4,8,11,12,11,8,4,0,-4,-8,-11,-12,0
            EVEN
ScrollX:
            dc.w       0
FrameTick:
            dc.w       0
ColorIndex:
            dc.w       0
ColorTable:
            dc.w       $0f00,$0ff0,$00f0,$00ff,$000f,$0f0f,$0fff,$0fa0

GlyphSpace: dc.b       %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
GlyphA:     dc.b       %00111100,%01100110,%11000011,%11000011,%11111111,%11000011,%11000011,%00000000
GlyphC:     dc.b       %00111110,%01100011,%11000000,%11000000,%11000000,%01100011,%00111110,%00000000
GlyphE:     dc.b       %11111111,%11000000,%11000000,%11111100,%11000000,%11000000,%11111111,%00000000
GlyphF:     dc.b       %11111111,%11000000,%11000000,%11111100,%11000000,%11000000,%11000000,%00000000
GlyphG:     dc.b       %00111110,%01100011,%11000000,%11001111,%11000011,%01100011,%00111110,%00000000
GlyphI:     dc.b       %01111110,%00011000,%00011000,%00011000,%00011000,%00011000,%01111110,%00000000
GlyphL:     dc.b       %11000000,%11000000,%11000000,%11000000,%11000000,%11000000,%11111111,%00000000
GlyphM:     dc.b       %11000011,%11100111,%11111111,%11011011,%11000011,%11000011,%11000011,%00000000
GlyphN:     dc.b       %11000011,%11100011,%11110011,%11011011,%11001111,%11000111,%11000011,%00000000
GlyphR:     dc.b       %11111100,%11000110,%11000110,%11111100,%11011000,%11001100,%11000110,%00000000
GlyphS:     dc.b       %00111110,%01100000,%01100000,%00111100,%00000110,%00000110,%01111100,%00000000
GlyphU:     dc.b       %11000011,%11000011,%11000011,%11000011,%11000011,%11000011,%01111110,%00000000
GlyphY:     dc.b       %11000011,%11000011,%01100110,%00111100,%00011000,%00011000,%00011000,%00000000
            EVEN
            SECTION    ChipData,DATA,CHIP
ScreenBuffer:
            ds.b       10240
"""
    }

    static let starfieldDemo = """
; Starfield template.
; Effect: starfield
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            bra        HardwareStart

HardwareStart:
            movem.l    d2-d7/a2-a6,-(sp)
            bsr        TakeOverDisplay
            tst.l      GfxBase
            beq        ExitProgram
            bsr        ClearScreen
            bsr        DrawStars

            lea        ScreenBuffer,a0
            move.l     a0,d0
            move.w     d0,Bpl1PTLValue
            swap       d0
            move.w     d0,Bpl1PTHValue
            move.l     a0,$e0(a5)           ; BPL1PT
            lea        CopperList(pc),a0
            move.l     a0,$80(a5)           ; COP1LC
            move.w     #$0000,$88(a5)       ; COPJMP1
            move.w     #$8380,$96(a5)       ; master DMA + BPLEN + COPEN

.main:
            btst       #6,$bfe001
            beq.s      .exitDemo
            bsr        WaitVBlank
            bsr        TwinkleStars
            bra.s      .main

.exitDemo:
            bsr        RestoreDisplay
ExitProgram:
            movem.l    (sp)+,d2-d7/a2-a6
            moveq      #0,d0
            rts

TakeOverDisplay:
            move.l     $4.w,a6              ; ExecBase
            lea        gfxName(pc),a1
            moveq      #0,d0
            jsr        -552(a6)             ; OpenLibrary
            move.l     d0,GfxBase
            beq.s      .takeoverFailed

            move.l     d0,a6
            move.l     34(a6),oldView       ; GfxBase->ActiView
            sub.l      a1,a1
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; WaitTOF()

            lea        $dff000,a5
            move.w     #$7fff,$9a(a5)       ; disable interrupts while this hardware demo owns the display
            move.w     #$7fff,$96(a5)       ; clear existing DMA enables before installing our display
            rts
.takeoverFailed:
            rts

RestoreDisplay:
            move.l     GfxBase(pc),d0
            beq.s      .restoreDone
            move.l     d0,a6
            move.l     oldView(pc),a1
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)
            jsr        -270(a6)
            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary
.restoreDone:
            rts

WriteConsoleMessage:
            movem.l    d1-d3/a0-a1/a6,-(sp)
            move.l     $4.w,a6
            lea        DosName(pc),a1
            moveq      #0,d0
            jsr        -552(a6)             ; OpenLibrary
            move.l     d0,DosBase
            beq.s      .consoleDone
            move.l     d0,a6
            jsr        -60(a6)              ; Output()
            move.l     d0,d1
            lea        ConsoleMessage(pc),a0
            move.l     a0,d2
            move.l     #ConsoleMessageEnd-ConsoleMessage,d3
            move.l     DosBase(pc),a6
            jsr        -48(a6)              ; Write()
            move.l     $4.w,a6
            move.l     DosBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary
.consoleDone:
            movem.l    (sp)+,d1-d3/a0-a1/a6
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a5)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a5)
            beq.s      .leave
            rts

ClearScreen:
            lea        ScreenBuffer,a0
            moveq      #0,d0
            move.w     #2559,d1
.clear:
            move.l     d0,(a0)+
            dbf        d1,.clear
            rts

DrawStars:
            lea        ScreenBuffer,a0
            lea        StarOffsets(pc),a1
            moveq      #15,d7
.plot:
            move.w     (a1)+,d0
            move.b     (a1)+,d1
            move.b     d1,0(a0,d0.w)
            dbf        d7,.plot
            rts

TwinkleStars:
            lea        ScreenBuffer,a0
            lea        TwinkleOffsets(pc),a1
            moveq      #7,d7
.twinkle:
            move.w     (a1)+,d0
            eori.b     #%10000000,0(a0,d0.w)
            dbf        d7,.twinkle
            rts

            ALIGN      2
gfxName:    dc.b       "graphics.library",0
DosName:    dc.b       "dos.library",0
            EVEN
GfxBase:    dc.l       0
oldView:    dc.l       0
DosBase:    dc.l       0
ConsoleMessage:
            dc.b       10,10,10,10,10,10,10,10
            dc.b       "                    *       *          *",10
            dc.b       "                         *        *",10
            dc.b       "              *     STARFIELD DEMO      *",10
            dc.b       "                       *          *",10
            dc.b       "                  *          *       *",10
ConsoleMessageEnd:
            EVEN

CopperList:
            dc.w       $008e,$2c81,$0090,$2cc1
            dc.w       $0092,$0038,$0094,$00d0
            dc.w       $00e0
Bpl1PTHValue:
            dc.w       $0000
            dc.w       $00e2
Bpl1PTLValue:
            dc.w       $0000
            dc.w       $0100,$1200,$0102,$0000,$0104,$0000
            dc.w       $0108,$0000,$010a,$0000
            dc.w       $0180,$0000,$0182,$0fff
            dc.w       $ffff,$fffe

StarOffsets:
            dc.w       84
            dc.b       %10000000
            dc.w       316
            dc.b       %00100000
            dc.w       548
            dc.b       %00001000
            dc.w       780
            dc.b       %00000010
            dc.w       1214
            dc.b       %01000000
            dc.w       1648
            dc.b       %00010000
            dc.w       2082
            dc.b       %00000100
            dc.w       2516
            dc.b       %00000001
            dc.w       3150
            dc.b       %10000000
            dc.w       3784
            dc.b       %00100000
            dc.w       4418
            dc.b       %00001000
            dc.w       5052
            dc.b       %00000010
            dc.w       5886
            dc.b       %01000000
            dc.w       6720
            dc.b       %00010000
            dc.w       7554
            dc.b       %00000100
            dc.w       8388
            dc.b       %00000001
            EVEN
TwinkleOffsets:
            dc.w       84,548,1214,2082,3150,4418,5886,7554
            EVEN
            SECTION    ChipData,DATA,CHIP
ScreenBuffer:
            ds.b       10240
"""

    static func mouseSpriteMultiplexDemo() throws -> String {
        let model = AmigaProgramModel(
            id: "mouse-sprite-multiplex",
            kind: .effect,
            routines: [
                AmigaProgramModel.Routine(id: "start", label: "_Start", purpose: "Installs a mouse-controlled two-sprite display and keeps it active until left mouse exits.", calls: ["WaitVBlank", "ReadMouseSprite", "UpdateSprites"]),
                AmigaProgramModel.Routine(id: "wait_vblank", label: "WaitVBlank", purpose: "Paces mouse sampling and sprite control-word updates to vertical blank."),
                AmigaProgramModel.Routine(id: "read_mouse", label: "ReadMouseSprite", purpose: "Samples JOY0DAT and updates bounded mouse X/Y state."),
                AmigaProgramModel.Routine(id: "update_sprites", label: "UpdateSprites", purpose: "Writes sprite control bytes for the primary sprite and a second offset copy.")
            ],
            stateVariables: [
                AmigaProgramModel.StateVariable(id: "mouse_x", symbol: "MouseX", purpose: "Current mouse-controlled sprite X position.", initialValue: "128"),
                AmigaProgramModel.StateVariable(id: "mouse_y", symbol: "MouseY", purpose: "Current mouse-controlled sprite Y position.", initialValue: "80"),
                AmigaProgramModel.StateVariable(id: "mouse_raw_x", symbol: "MouseRawX", purpose: "Previous raw JOY0DAT X counter.", initialValue: "128"),
                AmigaProgramModel.StateVariable(id: "mouse_raw_y", symbol: "MouseRawY", purpose: "Previous raw JOY0DAT Y counter.", initialValue: "80"),
                AmigaProgramModel.StateVariable(id: "follower_x_offset", symbol: "FollowerXOffset", purpose: "Horizontal offset applied to the multiplexed follower sprite.", initialValue: "28"),
                AmigaProgramModel.StateVariable(id: "follower_y_offset", symbol: "FollowerYOffset", purpose: "Vertical offset applied to the multiplexed follower sprite.", initialValue: "24"),
                AmigaProgramModel.StateVariable(id: "follower_wrap_enabled", symbol: "FollowerWrapEnabled", purpose: "One enables horizontal wrapping for the multiplexed follower sprite.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "follower_lag_enabled", symbol: "FollowerLagEnabled", purpose: "One makes the multiplexed follower use the previous frame mouse position.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "lag_mouse_x", symbol: "LagMouseX", purpose: "Previous frame mouse X position for follower lag.", initialValue: "128"),
                AmigaProgramModel.StateVariable(id: "lag_mouse_y", symbol: "LagMouseY", purpose: "Previous frame mouse Y position for follower lag.", initialValue: "80"),
                AmigaProgramModel.StateVariable(id: "sprite_color", symbol: "SpriteColor1", purpose: "Primary hardware sprite COLOR17 value.", initialValue: "$0ff0"),
                AmigaProgramModel.StateVariable(id: "sprite_color_2", symbol: "SpriteColor2", purpose: "Secondary hardware sprite COLOR18 value.", initialValue: "$00f0"),
                AmigaProgramModel.StateVariable(id: "sprite_color_3", symbol: "SpriteColor3", purpose: "Tertiary hardware sprite COLOR19 value.", initialValue: "$0fff"),
                AmigaProgramModel.StateVariable(id: "exit_delay", symbol: "ExitDelay", purpose: "Initial vblank countdown before honoring left mouse exit.", initialValue: "120")
            ],
            hardware: [.sprites, .cia, .copper, .bitplanes],
            verificationExpectations: [
                "SPR0PT and SPR1PT are both programmed for primary and multiplexed sprite copies.",
                "JOY0DAT mouse deltas update bounded MouseX and MouseY state.",
                "WaitVBlank paces sprite control-word updates.",
                "SpriteData0 and SpriteData1 terminate with zero control words.",
                "Left mouse click exits cleanly after the startup grace period."
            ]
        )

        return """
\(try AmigaSourceIndexer.modelRegion(for: model))
; Mouse-controlled sprite with offset multiplex copy.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
            bra.w      _Start
            ; @amiga:region controls begin
            ; @amiga:region controls end
            ; @amiga:region draw_controls begin
            ; @amiga:region draw_controls end
            ; @amiga:region hit_test begin
WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

ReadMouseSprite:
            move.w     $0a(a6),d0           ; JOY0DAT mouse counters
            move.w     d0,d1
            and.w      #$00ff,d1            ; raw X counter
            move.w     d1,d2
            sub.w      MouseRawX(pc),d2
            cmp.w      #127,d2
            ble.s      .xNoPositiveWrap
            sub.w      #256,d2
.xNoPositiveWrap:
            cmp.w      #-128,d2
            bge.s      .xDeltaReady
            add.w      #256,d2
.xDeltaReady:
            move.w     d1,MouseRawX
            add.w      MouseX(pc),d2
            cmp.w      #64,d2
            bge.s      .xNotLow
            move.w     #64,d2
.xNotLow:
            cmp.w      #220,d2
            ble.s      .storeX
            move.w     #220,d2
.storeX:
            move.w     d2,MouseX
            lsr.w      #8,d0
            and.w      #$00ff,d0            ; raw Y counter
            move.w     d0,d2
            sub.w      MouseRawY(pc),d2
            cmp.w      #127,d2
            ble.s      .yNoPositiveWrap
            sub.w      #256,d2
.yNoPositiveWrap:
            cmp.w      #-128,d2
            bge.s      .yDeltaReady
            add.w      #256,d2
.yDeltaReady:
            move.w     d0,MouseRawY
            add.w      MouseY(pc),d2
            cmp.w      #40,d2
            bge.s      .yNotLow
            move.w     #40,d2
.yNotLow:
            cmp.w      #180,d2
            ble.s      .storeY
            move.w     #180,d2
.storeY:
            move.w     d2,MouseY
            rts
            ; @amiga:region hit_test end

            ; @amiga:region input_dispatch begin
            ; @amiga:region input_dispatch end

            ; @amiga:region routines begin
_Start:
            movem.l    d2-d7/a2-a6,-(sp)
            lea        $dff000,a6
            move.w     #$7fff,$9a(a6)       ; disable interrupts for hardware-owned frame
            move.w     #$7fff,$9c(a6)       ; clear pending interrupts
            move.w     #$7fff,$96(a6)       ; clear inherited DMA before display setup
            lea        BackdropBitplane,a0
            move.l     a0,d0
            move.w     d0,CopperBplLo
            swap       d0
            move.w     d0,CopperBplHi
            move.l     a0,$e0(a6)           ; BPL1PT visible backdrop
            move.w     #$1200,$100(a6)      ; BPLCON0: one low-res bitplane
            move.w     #$0000,$102(a6)
            move.w     #$0000,$104(a6)
            move.w     #$0000,$180(a6)      ; COLOR00
            move.w     #$0333,$182(a6)      ; COLOR01 backdrop
            move.w     SpriteColor1(pc),d0
            move.w     d0,$1a2(a6)          ; sprite color 1
            move.w     SpriteColor2(pc),d0
            move.w     d0,$1a4(a6)          ; sprite color 2
            move.w     SpriteColor3(pc),d0
            move.w     d0,$1a6(a6)          ; sprite color 3
            lea        SpriteData0,a0
            move.l     a0,$120(a6)          ; SPR0PT primary mouse sprite
            lea        SpriteData1,a0
            move.l     a0,$124(a6)          ; SPR1PT multiplexed offset copy
            lea        CopperList,a0
            move.l     a0,$80(a6)           ; COP1LC
            move.w     #$0000,$88(a6)       ; COPJMP1
            move.w     #$83a0,$96(a6)       ; DMAEN + bitplane + copper + sprite DMA
.main:
            bsr        WaitVBlank
            tst.w      ExitDelay
            beq.s      .checkMouse
            subq.w     #1,ExitDelay
            bra.s      .update
.checkMouse:
            btst       #6,$bfe001           ; left mouse exits
            beq.s      .done
.update:
            bsr        ReadMouseSprite
            bsr        UpdateSprites
            bra.s      .main
.done:
            move.w     #$7fff,$96(a6)
            movem.l    (sp)+,d2-d7/a2-a6
            moveq      #0,d0
            rts

UpdateSprites:
            move.w     MouseY(pc),d0
            move.b     d0,Sprite0VStart
            add.w      #16,d0
            move.b     d0,Sprite0VStop
            move.w     MouseX(pc),d1
            move.b     d1,Sprite0HStart
            tst.w      FollowerLagEnabled
            beq.s      .copyUsesCurrentY
            move.w     LagMouseY(pc),d0
            bra.s      .copyYBaseReady
.copyUsesCurrentY:
            move.w     MouseY(pc),d0
.copyYBaseReady:
            add.w      FollowerYOffset(pc),d0
            cmp.w      #196,d0
            ble.s      .copyYReady
            move.w     #196,d0
.copyYReady:
            move.b     d0,Sprite1VStart
            add.w      #16,d0
            move.b     d0,Sprite1VStop
            tst.w      FollowerLagEnabled
            beq.s      .copyUsesCurrentX
            move.w     LagMouseX(pc),d1
            bra.s      .copyXBaseReady
.copyUsesCurrentX:
            move.w     MouseX(pc),d1
.copyXBaseReady:
            add.w      FollowerXOffset(pc),d1
            tst.w      FollowerWrapEnabled
            beq.s      .copyClampX
            cmp.w      #240,d1
            ble.s      .copyXReady
            sub.w      #176,d1
            bra.s      .copyXReady
.copyClampX:
            cmp.w      #240,d1
            ble.s      .copyXReady
            move.w     #240,d1
.copyXReady:
            move.b     d1,Sprite1HStart
            move.w     MouseX(pc),LagMouseX
            move.w     MouseY(pc),LagMouseY
            rts
            ; @amiga:region routines end

            ; @amiga:region state begin
MouseX:     dc.w       128
MouseY:     dc.w       80
MouseRawX:  dc.w       128
MouseRawY:  dc.w       80
FollowerXOffset: dc.w  28
FollowerYOffset: dc.w  24
FollowerWrapEnabled: dc.w 0
FollowerLagEnabled: dc.w 0
LagMouseX:  dc.w       128
LagMouseY:  dc.w       80
SpriteColor1: dc.w     $0ff0                ; yellow sprite COLOR17
SpriteColor2: dc.w     $00f0                ; green sprite COLOR18
SpriteColor3: dc.w     $0fff                ; white sprite COLOR19
ExitDelay:  dc.w       120
            ; @amiga:region state end

            ALIGN      2
            ; @amiga:region chip_data begin
CopperList:
            dc.w       $008e,$2c81,$0090,$f4c1
            dc.w       $0092,$0038,$0094,$00d0
            dc.w       $00e0
CopperBplHi:
            dc.w       $0000
            dc.w       $00e2
CopperBplLo:
            dc.w       $0000
            dc.w       $0100,$1200,$0102,$0000,$0104,$0000
            dc.w       $0180,$0000,$0182,$0333,$01a2,$0ff0,$01a4,$00f0,$01a6,$0fff
            dc.w       $ffff,$fffe

BackdropBitplane:
            dcb.l      2560,$55555555

SpriteData0:
Sprite0VStart:
            dc.b       80
Sprite0HStart:
            dc.b       $80
Sprite0VStop:
            dc.b       96
Sprite0Ctl:
            dc.b       $00
            dc.w       %0001100000011000,%0011110000111100
            dc.w       %0111111001111110,%1111111111111111
            dc.w       %1110011111100111,%1100001111000011
            dc.w       %1111111111111111,%0111111001111110
            dc.w       %0011110000111100,%0001100000011000
            dc.w       %0000000000000000,%0000000000000000
            dc.w       $0000,$0000

SpriteData1:
Sprite1VStart:
            dc.b       104
Sprite1HStart:
            dc.b       $9c
Sprite1VStop:
            dc.b       120
Sprite1Ctl:
            dc.b       $00
            dc.w       %0001100000011000,%0001100000011000
            dc.w       %0011110000111100,%0111111001111110
            dc.w       %1111111111111111,%1110011111100111
            dc.w       %1100001111000011,%1110011111100111
            dc.w       %0111111001111110,%0011110000111100
            dc.w       %0001100000011000,%0000000000000000
            dc.w       $0000,$0000
            ; @amiga:region chip_data end
"""
    }

    static let bouncingSpriteDemo = """
; Bouncing sprite template.
; Effect: bouncing sprite object
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            bra        HardwareStart

HardwareStart:
            movem.l    d2-d7/a2-a6,-(sp)
            bsr        TakeOverDisplay
            tst.l      GfxBase
            beq        ExitProgram
            lea        EmptyBitplane,a0
            move.l     a0,$e0(a5)           ; BPL1PT
            move.w     #$1200,$100(a5)      ; BPLCON0: one blank bitplane behind sprite
            lea        SpriteData,a0
            move.l     a0,d0
            move.w     d0,Spr0PTLValue
            swap       d0
            move.w     d0,Spr0PTHValue
            move.l     a0,$120(a5)          ; SPR0PT
            lea        CopperList(pc),a0
            move.l     a0,$80(a5)           ; COP1LC
            move.w     #$0000,$88(a5)       ; COPJMP1
            move.w     #$82a0,$96(a5)       ; master DMA + SPRTEN + COPEN

.main:
            btst       #6,$bfe001
            beq.s      .done
            bsr        WaitVBlank
            move.b     SpriteY(pc),d0
            add.b      SpriteDY(pc),d0
            cmp.b      #70,d0
            beq.s      .flip
            cmp.b      #170,d0
            bne.s      .store
.flip:
            neg.b      SpriteDY
.store:
            move.b     d0,SpriteY
            move.b     d0,SpriteData
            addi.b     #16,d0
            move.b     d0,SpriteEnd
            bra.s      .main

.done:
            bsr        RestoreDisplay
ExitProgram:
            movem.l    (sp)+,d2-d7/a2-a6
            moveq      #0,d0
            rts

TakeOverDisplay:
            move.l     $4.w,a6              ; ExecBase
            lea        gfxName(pc),a1
            moveq      #0,d0
            jsr        -552(a6)             ; OpenLibrary
            move.l     d0,GfxBase
            beq.s      .takeoverFailed

            move.l     d0,a6
            move.l     34(a6),oldView       ; GfxBase->ActiView
            sub.l      a1,a1
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; WaitTOF()

            lea        $dff000,a5
            move.w     #$7fff,$9a(a5)       ; disable interrupts while this hardware demo owns the display
            move.w     #$7fff,$96(a5)       ; clear existing DMA enables before installing our display
            rts
.takeoverFailed:
            rts

RestoreDisplay:
            move.l     GfxBase(pc),d0
            beq.s      .restoreDone
            move.l     d0,a6
            move.l     oldView(pc),a1
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)
            jsr        -270(a6)
            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary
.restoreDone:
            rts

WriteConsoleMessage:
            movem.l    d1-d3/a0-a1/a6,-(sp)
            move.l     $4.w,a6
            lea        DosName(pc),a1
            moveq      #0,d0
            jsr        -552(a6)             ; OpenLibrary
            move.l     d0,DosBase
            beq.s      .consoleDone
            move.l     d0,a6
            jsr        -60(a6)              ; Output()
            move.l     d0,d1
            lea        ConsoleMessage(pc),a0
            move.l     a0,d2
            move.l     #ConsoleMessageEnd-ConsoleMessage,d3
            move.l     DosBase(pc),a6
            jsr        -48(a6)              ; Write()
            move.l     $4.w,a6
            move.l     DosBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary
.consoleDone:
            movem.l    (sp)+,d1-d3/a0-a1/a6
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a5)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a5)
            beq.s      .leave
            rts

            ALIGN      2
gfxName:    dc.b       "graphics.library",0
DosName:    dc.b       "dos.library",0
            EVEN
GfxBase:    dc.l       0
oldView:    dc.l       0
DosBase:    dc.l       0
ConsoleMessage:
            dc.b       10,10,10,10,10,10,10,10,10
            dc.b       "                         BOUNCING SPRITE",10
            dc.b       "                              /\\\\",10
            dc.b       "                             <  >",10
            dc.b       "                              \\\\/",10
ConsoleMessageEnd:
            EVEN

CopperList:
            dc.w       $008e,$2c81,$0090,$f4c1
            dc.w       $0092,$0038,$0094,$00d0
            dc.w       $0120
Spr0PTHValue:
            dc.w       $0000
            dc.w       $0122
Spr0PTLValue:
            dc.w       $0000
            dc.w       $0100,$0200,$0102,$0000,$0104,$0000
            dc.w       $0180,$0000,$01a2,$0ff0,$01a4,$0f00,$01a6,$0fff
            dc.w       $ffff,$fffe

SpriteY:
            dc.b       80
SpriteDY:
            dc.b       1
            EVEN
            SECTION    ChipData,DATA,CHIP
EmptyBitplane:
            ds.b       40*256
SpriteData:
            dc.b       80,$80              ; VSTART, HSTART
SpriteEnd:
            dc.b       96,$00              ; VSTOP, control
            dc.w       %0001100000011000,%0011110000111100
            dc.w       %0111111001111110,%1111111111111111
            dc.w       %1110011111100111,%1100001111000011
            dc.w       %1110011111100111,%1111111111111111
            dc.w       %0111111001111110,%0011110000111100
            dc.w       %0001100000011000,%0000000000000000
            dc.w       %0000000000000000,%0000000000000000
            dc.w       %0000000000000000,%0000000000000000
            dc.w       $0000,$0000         ; sprite data terminator
"""

    static let staticCopperListDemo = """
; Static multi-color copper list demo.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)           ; COP1LC
            move.w     #$0000,$88(a6)       ; COPJMP1
            move.w     #$8280,$96(a6)       ; DMAEN + COPEN

            move.w     #120,d0
.delay:
            bsr        WaitVBlank
            dbf        d0,.delay

            move.w     #$0080,$96(a6)       ; clear copper DMA enable bit for demo exit
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

            ALIGN      2
CopperList:
            dc.w       $0100,$0200          ; no bitplanes, color 0 only
            dc.w       $3007,$fffe,$0180,$0f00
            dc.w       $4007,$fffe,$0180,$0ff0
            dc.w       $5007,$fffe,$0180,$00f0
            dc.w       $6007,$fffe,$0180,$00ff
            dc.w       $7007,$fffe,$0180,$000f
            dc.w       $8007,$fffe,$0180,$0f0f
            dc.w       $ffff,$fffe
"""

    static let bouncingMulticolorCopperList: String = {
        let model = AmigaProgramModel(
            id: "bouncing-copper-bars",
            kind: .effect,
            routines: [
                AmigaProgramModel.Routine(id: "start", label: "_Start", purpose: "Installs the copper list and animates raster bar WAIT positions until left mouse exits.", calls: ["ApplyPalette", "WaitVBlank"]),
                AmigaProgramModel.Routine(id: "apply_palette", label: "ApplyPalette", purpose: "Copies model-owned color state into the copper list color words.", clobbers: ["d4"]),
                AmigaProgramModel.Routine(id: "wait_vblank", label: "WaitVBlank", purpose: "Paces copper WAIT updates to vertical blank.")
            ],
            stateVariables: [
                AmigaProgramModel.StateVariable(id: "bar_count", symbol: "BarCount", purpose: "Visible raster bar count for model-backed follow-up edits.", initialValue: "6"),
                AmigaProgramModel.StateVariable(id: "bar_spacing", symbol: "BarSpacing", purpose: "Vertical distance between adjacent animated copper bars.", initialValue: "8"),
                AmigaProgramModel.StateVariable(id: "bar_step", symbol: "BarStep", purpose: "Signed initial pixels-per-frame bounce velocity.", initialValue: "2"),
                AmigaProgramModel.StateVariable(id: "status_band_color", symbol: "StatusBandColor", purpose: "Top status band COLOR00 value.", initialValue: "$0000"),
                AmigaProgramModel.StateVariable(id: "band_color_1", symbol: "BandColor1", purpose: "First raster bar COLOR00 value.", initialValue: "$0f00"),
                AmigaProgramModel.StateVariable(id: "band_color_2", symbol: "BandColor2", purpose: "Second raster bar COLOR00 value.", initialValue: "$0ff0"),
                AmigaProgramModel.StateVariable(id: "band_color_3", symbol: "BandColor3", purpose: "Third raster bar COLOR00 value.", initialValue: "$00f0"),
                AmigaProgramModel.StateVariable(id: "band_color_4", symbol: "BandColor4", purpose: "Fourth raster bar COLOR00 value.", initialValue: "$00ff"),
                AmigaProgramModel.StateVariable(id: "band_color_5", symbol: "BandColor5", purpose: "Fifth raster bar COLOR00 value.", initialValue: "$000f"),
                AmigaProgramModel.StateVariable(id: "band_color_6", symbol: "BandColor6", purpose: "Sixth raster bar COLOR00 value.", initialValue: "$0f0f"),
                AmigaProgramModel.StateVariable(id: "band_color_7", symbol: "BandColor7", purpose: "Seventh raster bar COLOR00 value used when eight bars are enabled.", initialValue: "$0000"),
                AmigaProgramModel.StateVariable(id: "band_color_8", symbol: "BandColor8", purpose: "Eighth raster bar COLOR00 value used when eight bars are enabled.", initialValue: "$0000")
            ],
            hardware: [.copper, .cia],
            verificationExpectations: [
                "COP1LC and COPJMP1 install the owned copper list.",
                "Copper DMA is enabled before the main loop.",
                "WaitVBlank paces Bar1Wait through Bar8Wait updates.",
                "Distinct copper COLOR00 words create visible raster bands.",
                "Left mouse click exits cleanly.",
                "Copper bar count is 6.",
                "Copper bar spacing is 8 pixels.",
                "Copper bar bounce step is 2 pixels per frame.",
                "Copper palette is multicolor.",
                "Top status band is disabled."
            ]
        )

        return """
\(try! AmigaSourceIndexer.modelRegion(for: model))
; Bouncing multi-color copper bars.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
            bra.w      _Start
            ; @amiga:region controls begin
            ; @amiga:region controls end
            ; @amiga:region draw_controls begin
            ; @amiga:region draw_controls end
            ; @amiga:region hit_test begin
WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts
            ; @amiga:region hit_test end

            ; @amiga:region input_dispatch begin
            ; @amiga:region input_dispatch end

            ; @amiga:region routines begin
_Start:
            lea        $dff000,a6
            bsr        ApplyPalette
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)           ; COP1LC
            move.w     #$0000,$88(a6)       ; COPJMP1
            move.w     #$8280,$96(a6)       ; DMAEN + COPEN

            moveq      #64,d0               ; top bar position
            move.w     BarStep(pc),d1       ; signed direction and speed
            move.w     #120,d3              ; ignore startup mouse state for runtime capture

.main:
            bsr        WaitVBlank
            tst.w      d3
            beq.s      .checkMouse
            subq.w     #1,d3
            bra.s      .animate
.checkMouse:
            btst       #6,$bfe001           ; left mouse exits
            beq.s      .done

.animate:
            move.w     d0,d2
            move.b     d2,Bar1Wait
            add.w      BarSpacing(pc),d2
            move.b     d2,Bar2Wait
            add.w      BarSpacing(pc),d2
            move.b     d2,Bar3Wait
            add.w      BarSpacing(pc),d2
            move.b     d2,Bar4Wait
            add.w      BarSpacing(pc),d2
            move.b     d2,Bar5Wait
            add.w      BarSpacing(pc),d2
            move.b     d2,Bar6Wait
            add.w      BarSpacing(pc),d2
            move.b     d2,Bar7Wait
            add.w      BarSpacing(pc),d2
            move.b     d2,Bar8Wait

            add.w      d1,d0
            cmp.w      #152,d0
            beq.s      .flip
            cmp.w      #48,d0
            bne.s      .main
.flip:
            neg.w      d1
            bra.s      .main

.done:
            rts

ApplyPalette:
            move.w     StatusBandColor(pc),d4
            move.w     d4,StatusBandColorWord+2
            move.w     BandColor1(pc),d4
            move.w     d4,Bar1Color+2
            move.w     BandColor2(pc),d4
            move.w     d4,Bar2Color+2
            move.w     BandColor3(pc),d4
            move.w     d4,Bar3Color+2
            move.w     BandColor4(pc),d4
            move.w     d4,Bar4Color+2
            move.w     BandColor5(pc),d4
            move.w     d4,Bar5Color+2
            move.w     BandColor6(pc),d4
            move.w     d4,Bar6Color+2
            move.w     BandColor7(pc),d4
            move.w     d4,Bar7Color+2
            move.w     BandColor8(pc),d4
            move.w     d4,Bar8Color+2
            rts
            ; @amiga:region routines end

            ; @amiga:region state begin
BarCount:   dc.w       6
BarSpacing: dc.w       8
BarStep:    dc.w       2
StatusBandColor: dc.w  $0000
BandColor1: dc.w       $0f00
BandColor2: dc.w       $0ff0
BandColor3: dc.w       $00f0
BandColor4: dc.w       $00ff
BandColor5: dc.w       $000f
BandColor6: dc.w       $0f0f
BandColor7: dc.w       $0000
BandColor8: dc.w       $0000
            ; @amiga:region state end

            ALIGN      2
            ; @amiga:region chip_data begin
CopperList:
            dc.w       $0100,$0200          ; no bitplanes, color 0 only
            dc.w       $2007,$fffe
StatusBandColorWord:
            dc.w       $0180,$0000          ; optional top status band
Bar1Wait:   dc.b       64,$07
            dc.w       $fffe
Bar1Color:  dc.w       $0180,$0f00          ; red
Bar2Wait:   dc.b       72,$07
            dc.w       $fffe
Bar2Color:  dc.w       $0180,$0ff0          ; yellow
Bar3Wait:   dc.b       80,$07
            dc.w       $fffe
Bar3Color:  dc.w       $0180,$00f0          ; green
Bar4Wait:   dc.b       88,$07
            dc.w       $fffe
Bar4Color:  dc.w       $0180,$00ff          ; cyan
Bar5Wait:   dc.b       96,$07
            dc.w       $fffe
Bar5Color:  dc.w       $0180,$000f          ; blue
Bar6Wait:   dc.b       104,$07
            dc.w       $fffe
Bar6Color:  dc.w       $0180,$0f0f          ; purple
Bar7Wait:   dc.b       112,$07
            dc.w       $fffe
Bar7Color:  dc.w       $0180,$0000          ; disabled until eight bars
Bar8Wait:   dc.b       120,$07
            dc.w       $fffe
Bar8Color:  dc.w       $0180,$0000          ; disabled until eight bars
            dc.w       $c007,$fffe,$0180,$0000
            dc.w       $ffff,$fffe
            ; @amiga:region chip_data end
"""
    }()
}

struct PromptTemplateVisualSmokeResult: Equatable {
    let success: Bool
    let artifactDirectory: String
    let framePath: String
    let nonBlackPixels: Int
    let brightBandPixels: Int
    let summary: String
}

struct PromptTemplateRuntimeSmokeResult: Equatable {
    let success: Bool
    let artifactDirectory: String
    let screenshotPath: String
    let launchSummary: String
    let nonBlackPixels: Int
    let brightBandPixels: Int
    let darkPixels: Int
    let brightnessRange: Int
    let uniqueColorBuckets: Int
    let maxChannelSpread: Int
    let summary: String
}

struct PromptTemplateFrameAnalysis: Equatable {
    let nonBlackPixels: Int
    let brightBandPixels: Int
    let darkPixels: Int
    let brightnessRange: Int
    let uniqueColorBuckets: Int
    let maxChannelSpread: Int
    let neutralGrayPixels: Int
    let workbenchBluePixels: Int
    let sampledPixels: Int
}

enum PromptTemplateRuntimeSmokeValidator {
    static func runEmulatorSmoke(
        config: EmulatorLaunchConfig,
        match: AssistantPromptTemplateMatch,
        prompt: String,
        outputRoot: URL = defaultOutputRoot(),
        captureDelay: TimeInterval = 4.0
    ) throws -> PromptTemplateRuntimeSmokeResult {
        let runID = "\(timestamp())-\(match.id)-\(UUID().uuidString.prefix(8))"
        let runURL = outputRoot.appendingPathComponent(runID, isDirectory: true)
        try FileManager.default.createDirectory(at: runURL, withIntermediateDirectories: true)
        let fsUAEScreenshotDirectory = runURL.appendingPathComponent("fs-uae-screenshots", isDirectory: true)
        if config.backend == .fsUAE {
            try FileManager.default.createDirectory(at: fsUAEScreenshotDirectory, withIntermediateDirectories: true)
        }

        let existingFSUAEPIDs = runningApplicationPIDs(bundleIdentifier: "no.fengestad.fs-uae")
        let existingVAmigaPIDs = runningApplicationPIDs(bundleIdentifier: "dirkwhoffmann.vAmiga")
        var patchedVAmigaConfig: VAmigaServerConfig?
        let preferredScreenshotURL = runURL.appendingPathComponent("emulator-screenshot.png")
        let launchConfig = try smokeCaptureConfig(
            from: config,
            screenshotDirectory: fsUAEScreenshotDirectory,
            preferredScreenshotURL: preferredScreenshotURL,
            captureDelay: captureDelay,
            patchedVAmigaConfig: &patchedVAmigaConfig
        )
        if launchConfig.backend == .vAmiga {
            try writeVAmigaLaunchDiagnostics(config: launchConfig, runURL: runURL, phase: "after-config-patch")
        }
        let launchResult = launch(config: launchConfig)
        defer {
            terminateNewApplications(bundleIdentifier: "no.fengestad.fs-uae", excluding: existingFSUAEPIDs)
            terminateNewApplications(bundleIdentifier: "dirkwhoffmann.vAmiga", excluding: existingVAmigaPIDs)
            if let patchedVAmigaConfig {
                VAmigaServerConfigPatcher().restore(config: patchedVAmigaConfig)
            }
        }

        var vAmigaTranscript = ""
        if launchResult.success, launchConfig.backend == .vAmiga {
            if let scriptedCapturePath = launchConfig.vAmigaScriptScreenshotBasePath {
                vAmigaTranscript = "vAmiga scripted capture enabled: the launch RetroShell script boots the ADF and saves \(scriptedCapturePath) after the capture delay."
            } else {
                vAmigaTranscript = try prepareVAmigaRuntime(config: launchConfig)
            }
        }
        Thread.sleep(forTimeInterval: captureDelay)
        let screenshotURL = try captureEmulatorFrame(
            to: preferredScreenshotURL,
            backend: config.backend,
            fsUAEDirectory: fsUAEScreenshotDirectory,
            config: launchConfig
        )
        let analysis = try analyzeFrame(at: screenshotURL, expectsTextBand: match.id.contains("text"))
        let success = launchResult.success && hasRuntimeVisualEvidence(analysis, expectsTextBand: match.id.contains("text"))
        let summary = success
            ? "Runtime visual smoke passed: emulator launched, screenshot captured, and visible pixels were detected."
            : "Runtime visual smoke failed: emulator launch or screenshot visibility evidence was insufficient."

        let manifest = """
        {
          "prompt": "\(jsonEscaped(prompt))",
          "template": "\(jsonEscaped(match.name))",
          "backend": "\(config.backend.rawValue)",
          "screenshot": "\(jsonEscaped(screenshotURL.path))",
          "launchSuccess": \(launchResult.success),
          "launchSummary": "\(jsonEscaped(launchResult.message))",
          "vAmigaTranscript": "\(jsonEscaped(vAmigaTranscript))",
          "nonBlackPixels": \(analysis.nonBlackPixels),
          "brightBandPixels": \(analysis.brightBandPixels),
          "darkPixels": \(analysis.darkPixels),
          "brightnessRange": \(analysis.brightnessRange),
          "uniqueColorBuckets": \(analysis.uniqueColorBuckets),
          "maxChannelSpread": \(analysis.maxChannelSpread),
          "neutralGrayPixels": \(analysis.neutralGrayPixels),
          "workbenchBluePixels": \(analysis.workbenchBluePixels),
          "sampledPixels": \(analysis.sampledPixels),
          "likelyCheckerboardPlaceholder": \(isLikelyCheckerboardPlaceholder(analysis)),
          "likelyWorkbenchOrAmigaDOS": \(isLikelyWorkbenchOrAmigaDOS(analysis)),
          "success": \(success)
        }
        """
        try manifest.write(to: runURL.appendingPathComponent("manifest.json"), atomically: true, encoding: .utf8)

        let markdown = """
        # Prompt Runtime Visual Smoke

        - Prompt: `\(prompt)`
        - Template: \(match.name)
        - Backend: \(config.backend.displayName)
        - Launch: \(launchResult.success ? "passed" : "failed")
        - Screenshot: `\(screenshotURL.path)`
        - Non-black pixels: \(analysis.nonBlackPixels)
        - Bright band pixels: \(analysis.brightBandPixels)
        - Dark pixels: \(analysis.darkPixels)
        - Brightness range: \(analysis.brightnessRange)
        - Unique color buckets: \(analysis.uniqueColorBuckets)
        - Max channel spread: \(analysis.maxChannelSpread)
        - Neutral gray pixels: \(analysis.neutralGrayPixels)
        - Workbench blue pixels: \(analysis.workbenchBluePixels)
        - Likely checkerboard placeholder: \(isLikelyCheckerboardPlaceholder(analysis) ? "yes" : "no")
        - Likely Workbench/AmigaDOS: \(isLikelyWorkbenchOrAmigaDOS(analysis) ? "yes" : "no")
        - Result: \(success ? "passed" : "failed")

        \(summary)

        ## Launch Summary

        \(launchResult.message)

        \(vAmigaTranscript.isEmpty ? "" : "## vAmiga RetroShell Transcript\n\n```text\n\(vAmigaTranscript)\n```")
        """
        try markdown.write(to: runURL.appendingPathComponent("summary.md"), atomically: true, encoding: .utf8)

        return PromptTemplateRuntimeSmokeResult(
            success: success,
            artifactDirectory: runURL.path,
            screenshotPath: screenshotURL.path,
            launchSummary: launchResult.message,
            nonBlackPixels: analysis.nonBlackPixels,
            brightBandPixels: analysis.brightBandPixels,
            darkPixels: analysis.darkPixels,
            brightnessRange: analysis.brightnessRange,
            uniqueColorBuckets: analysis.uniqueColorBuckets,
            maxChannelSpread: analysis.maxChannelSpread,
            summary: summary
        )
    }

    static func analyzeScreenshot(at url: URL, expectsTextBand: Bool) throws -> PromptTemplateFrameAnalysis {
        try analyzeFrame(at: url, expectsTextBand: expectsTextBand)
    }

    static func analyzeFrame(at url: URL, expectsTextBand: Bool) throws -> PromptTemplateFrameAnalysis {
        if url.pathExtension.lowercased() == "raw" {
            return try analyzeRawFrame(at: url, expectsTextBand: expectsTextBand)
        }

        guard let image = NSImage(contentsOf: url),
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not load frame at \(url.path)"])
        }

        var nonBlack = 0
        var brightBand = 0
        var dark = 0
        var minBrightness = Int.max
        var maxBrightness = 0
        var maxChannelSpread = 0
        var colorBuckets = Set<Int>()
        var neutralGray = 0
        var workbenchBlue = 0
        var sampledPixels = 0
        let minY = expectsTextBand ? bitmap.pixelsHigh / 3 : 0
        let maxY = expectsTextBand ? (bitmap.pixelsHigh * 2) / 3 : bitmap.pixelsHigh
        let minX = expectsTextBand ? bitmap.pixelsWide / 4 : 0
        let maxX = expectsTextBand ? (bitmap.pixelsWide * 3) / 4 : bitmap.pixelsWide

        for y in stride(from: 0, to: bitmap.pixelsHigh, by: 2) {
            for x in stride(from: 0, to: bitmap.pixelsWide, by: 2) {
                guard let color = bitmap.colorAt(x: x, y: y) else { continue }
                let red = color.redComponent
                let green = color.greenComponent
                let blue = color.blueComponent
                let redByte = max(0, min(255, Int((red * 255.0).rounded())))
                let greenByte = max(0, min(255, Int((green * 255.0).rounded())))
                let blueByte = max(0, min(255, Int((blue * 255.0).rounded())))
                let brightness = redByte + greenByte + blueByte
                sampledPixels += 1
                minBrightness = min(minBrightness, brightness)
                maxBrightness = max(maxBrightness, brightness)
                let channelSpread = max(redByte, greenByte, blueByte) - min(redByte, greenByte, blueByte)
                maxChannelSpread = max(maxChannelSpread, channelSpread)
                colorBuckets.insert(((redByte / 32) << 16) | ((greenByte / 32) << 8) | (blueByte / 32))
                if channelSpread <= 12 && brightness >= 96 && brightness <= 690 {
                    neutralGray += 1
                }
                if blueByte >= 120 && blueByte > redByte + 35 && blueByte >= greenByte + 8 && redByte <= 150 && greenByte <= 190 {
                    workbenchBlue += 1
                }
                if brightness > 90 {
                    nonBlack += 1
                }
                if brightness < 90 {
                    dark += 1
                }
                if x >= minX, x < maxX, y >= minY, y < maxY, brightness > 420 {
                    brightBand += 1
                }
            }
        }

        return PromptTemplateFrameAnalysis(
            nonBlackPixels: nonBlack,
            brightBandPixels: brightBand,
            darkPixels: dark,
            brightnessRange: maxBrightness - (minBrightness == Int.max ? 0 : minBrightness),
            uniqueColorBuckets: colorBuckets.count,
            maxChannelSpread: maxChannelSpread,
            neutralGrayPixels: neutralGray,
            workbenchBluePixels: workbenchBlue,
            sampledPixels: sampledPixels
        )
    }

    static func hasRuntimeVisualEvidence(_ analysis: PromptTemplateFrameAnalysis, expectsTextBand: Bool) -> Bool {
        guard !isLikelyCheckerboardPlaceholder(analysis), !isLikelyWorkbenchOrAmigaDOS(analysis) else {
            return false
        }

        let hasContrast = analysis.brightnessRange >= 80 && analysis.uniqueColorBuckets >= 2
        let hasSolidColor = analysis.maxChannelSpread >= 32
        if expectsTextBand {
            return analysis.nonBlackPixels > 0
                && analysis.brightBandPixels > 0
                && analysis.darkPixels > 0
                && hasContrast
        }
        return analysis.nonBlackPixels > 0 && (hasSolidColor || (analysis.darkPixels > 0 && hasContrast))
    }

    static func isLikelyWorkbenchOrAmigaDOS(_ analysis: PromptTemplateFrameAnalysis) -> Bool {
        guard analysis.sampledPixels > 0 else { return false }
        let neutralRatio = Double(analysis.neutralGrayPixels) / Double(analysis.sampledPixels)
        let blueRatio = Double(analysis.workbenchBluePixels) / Double(analysis.sampledPixels)
        return neutralRatio >= 0.42
            && blueRatio >= 0.01
            && analysis.darkPixels > 20
            && analysis.brightnessRange >= 120
    }

    static func isLikelyCheckerboardPlaceholder(_ analysis: PromptTemplateFrameAnalysis) -> Bool {
        guard analysis.sampledPixels > 0 else { return false }
        let neutralRatio = Double(analysis.neutralGrayPixels) / Double(analysis.sampledPixels)
        return neutralRatio >= 0.90
            && analysis.uniqueColorBuckets <= 2
            && analysis.maxChannelSpread <= 12
            && analysis.darkPixels == 0
    }

    private static func analyzeRawFrame(at url: URL, expectsTextBand: Bool) throws -> PromptTemplateFrameAnalysis {
        let data = try Data(contentsOf: url)
        guard let frame = inferRawFrameFormat(byteCount: data.count) else {
            throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not infer raw vAmiga frame dimensions for \(url.path)"])
        }

        var nonBlack = 0
        var brightBand = 0
        var dark = 0
        var minBrightness = Int.max
        var maxBrightness = 0
        var maxChannelSpread = 0
        var colorBuckets = Set<Int>()
        var neutralGray = 0
        var workbenchBlue = 0
        var sampledPixels = 0
        let width = frame.width
        let height = frame.height
        let bytesPerPixel = frame.bytesPerPixel
        let minY = expectsTextBand ? height / 3 : 0
        let maxY = expectsTextBand ? (height * 2) / 3 : height
        let minX = expectsTextBand ? width / 4 : 0
        let maxX = expectsTextBand ? (width * 3) / 4 : width
        let bytes = [UInt8](data)

        for y in stride(from: 0, to: height, by: 2) {
            for x in stride(from: 0, to: width, by: 2) {
                let offset = (y * width + x) * bytesPerPixel
                guard offset + 2 < bytes.count else { continue }
                let redByte = Int(bytes[offset])
                let greenByte = Int(bytes[offset + 1])
                let blueByte = Int(bytes[offset + 2])
                let brightness = redByte + greenByte + blueByte
                sampledPixels += 1
                minBrightness = min(minBrightness, brightness)
                maxBrightness = max(maxBrightness, brightness)
                let channelSpread = max(redByte, greenByte, blueByte) - min(redByte, greenByte, blueByte)
                maxChannelSpread = max(maxChannelSpread, channelSpread)
                colorBuckets.insert(((redByte / 32) << 16) | ((greenByte / 32) << 8) | (blueByte / 32))
                if channelSpread <= 12 && brightness >= 96 && brightness <= 690 {
                    neutralGray += 1
                }
                if blueByte >= 120 && blueByte > redByte + 35 && blueByte >= greenByte + 8 && redByte <= 150 && greenByte <= 190 {
                    workbenchBlue += 1
                }
                if brightness > 90 {
                    nonBlack += 1
                }
                if brightness < 90 {
                    dark += 1
                }
                if x >= minX, x < maxX, y >= minY, y < maxY, brightness > 420 {
                    brightBand += 1
                }
            }
        }

        return PromptTemplateFrameAnalysis(
            nonBlackPixels: nonBlack,
            brightBandPixels: brightBand,
            darkPixels: dark,
            brightnessRange: maxBrightness - (minBrightness == Int.max ? 0 : minBrightness),
            uniqueColorBuckets: colorBuckets.count,
            maxChannelSpread: maxChannelSpread,
            neutralGrayPixels: neutralGray,
            workbenchBluePixels: workbenchBlue,
            sampledPixels: sampledPixels
        )
    }

    private static func inferRawFrameFormat(byteCount: Int) -> (width: Int, height: Int, bytesPerPixel: Int)? {
        guard byteCount > 0 else { return nil }
        var best: (width: Int, height: Int, bytesPerPixel: Int, score: Double)?

        for bytesPerPixel in [3, 4] {
            guard byteCount % bytesPerPixel == 0 else { continue }
            let pixels = byteCount / bytesPerPixel
            for height in 120...1200 {
                guard pixels % height == 0 else { continue }
                let width = pixels / height
                guard width >= height, width <= 3000 else { continue }
                let aspect = Double(width) / Double(height)
                guard aspect >= 1.2, aspect <= 3.0 else { continue }
                let expectedAspect = bytesPerPixel == 3 ? 2.51 : 1.88
                let score = abs(aspect - expectedAspect) + abs(Double(height - 285)) / 2000.0
                if best == nil || score < best!.score {
                    best = (width, height, bytesPerPixel, score)
                }
            }
        }

        guard let best else { return nil }
        return (best.width, best.height, best.bytesPerPixel)
    }

    private static func launch(config: EmulatorLaunchConfig) -> EmulatorLaunchResult {
        let semaphore = DispatchSemaphore(value: 0)
        var launchResult = EmulatorLaunchResult(
            success: false,
            backend: config.backend,
            message: "Emulator launch did not complete.",
            tracePath: nil
        )
        var didComplete = false

        EmulatorService.shared.launchEmulator(config: config) { result in
            launchResult = result
            didComplete = true
            semaphore.signal()
        }
        if Thread.isMainThread {
            let deadline = Date().addingTimeInterval(15)
            while !didComplete && Date() < deadline {
                RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))
            }
        } else {
            _ = semaphore.wait(timeout: .now() + 15)
        }
        return launchResult
    }

    private static func smokeCaptureConfig(
        from config: EmulatorLaunchConfig,
        screenshotDirectory: URL,
        preferredScreenshotURL: URL,
        captureDelay: TimeInterval,
        patchedVAmigaConfig: inout VAmigaServerConfig?
    ) throws -> EmulatorLaunchConfig {
        if config.backend == .vAmiga {
            let serverConfig = try VAmigaServerConfigPatcher().apply(config: config.vAmigaServerConfig)
            patchedVAmigaConfig = serverConfig
            return EmulatorLaunchConfig(
                backend: config.backend,
                adfPath: config.adfPath,
                romRelativePath: config.romRelativePath,
                model: config.model,
                chipRamMb: config.chipRamMb,
                fastRamMb: config.fastRamMb,
                cpu: config.cpu,
                jit: config.jit,
                customArgs: config.customArgs,
                vAmigaExecutablePath: config.vAmigaExecutablePath,
                vAmigaCustomArgs: config.vAmigaCustomArgs,
                vAmigaServerConfig: serverConfig,
                vAmigaScriptScreenshotBasePath: nil,
                vAmigaScriptWaitSeconds: config.vAmigaScriptWaitSeconds,
                vAmigaTraceCommandsEnabled: false
            )
        }

        guard config.backend == .fsUAE else {
            return config
        }

        let captureArgs = [
            "--screenshots_output_dir=\(quotedCommandLineValue(screenshotDirectory.path))",
            "--screenshots_output_mask=3",
            "--keyboard_key_f12=action_screenshot"
        ].joined(separator: " ")

        return EmulatorLaunchConfig(
            backend: config.backend,
            adfPath: config.adfPath,
            romRelativePath: config.romRelativePath,
            model: config.model,
            chipRamMb: config.chipRamMb,
            fastRamMb: config.fastRamMb,
            cpu: config.cpu,
            jit: config.jit,
            customArgs: [config.customArgs, captureArgs].filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.joined(separator: " "),
            vAmigaExecutablePath: config.vAmigaExecutablePath,
            vAmigaCustomArgs: config.vAmigaCustomArgs,
            vAmigaServerConfig: config.vAmigaServerConfig,
            vAmigaScriptScreenshotBasePath: config.vAmigaScriptScreenshotBasePath,
            vAmigaScriptWaitSeconds: config.vAmigaScriptWaitSeconds,
            vAmigaTraceCommandsEnabled: config.vAmigaTraceCommandsEnabled
        )
    }

    private static func captureEmulatorFrame(to url: URL, backend: EmulatorBackend, fsUAEDirectory: URL, config: EmulatorLaunchConfig) throws -> URL {
        if backend == .fsUAE {
            let captureStarted = Date()
            var newestScreenshot: URL?
            for _ in 0..<6 {
                try? requestFSUAEScreenshot()
                Thread.sleep(forTimeInterval: 1.0)
                if let internalScreenshot = latestFSUAEScreenshot(in: fsUAEDirectory, modifiedAfter: captureStarted) {
                    newestScreenshot = internalScreenshot
                }
            }
            if let newestScreenshot {
                try FileManager.default.copyItem(at: newestScreenshot, to: url)
                return url
            }
        }

        if backend == .vAmiga {
            return try captureVAmigaRawFrame(preferredURL: url, config: config)
        }

        try captureScreen(to: url)
        return url
    }

    private static func captureVAmigaRawFrame(preferredURL: URL, config: EmulatorLaunchConfig) throws -> URL {
        let baseURL = preferredURL.deletingPathExtension()
        let rawURL = baseURL.appendingPathExtension("raw")
        if let scriptedBasePath = config.vAmigaScriptScreenshotBasePath {
            let scriptedRawURL = URL(fileURLWithPath: scriptedBasePath).deletingPathExtension().appendingPathExtension("raw")
            let deadline = Date().addingTimeInterval(Double(max(2, config.vAmigaScriptWaitSeconds)) + 8.0)
            while Date() < deadline {
                if FileManager.default.fileExists(atPath: scriptedRawURL.path) {
                    return scriptedRawURL
                }
                Thread.sleep(forTimeInterval: 0.2)
            }
            throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 4, userInfo: [NSLocalizedDescriptionKey: "vAmiga did not create a scripted raw screenshot at \(scriptedRawURL.path)."])
        }

        try? FileManager.default.removeItem(at: rawURL)

        let command = "screenshot save \(quotedRetroShellPath(baseURL.path))"
        let writeDeadline = Date().addingTimeInterval(8.0)
        var lastError: Error?
        while Date() < writeDeadline {
            for port in retroShellCandidatePorts(config: config) {
                do {
                    let client = VAmigaRawRetroShellClient(port: port, timeout: 2.0)
                    _ = try client.send(command: command, readDuration: 4.0)
                    lastError = nil
                    break
                } catch {
                    lastError = error
                }
            }
            if lastError == nil {
                break
            }
            Thread.sleep(forTimeInterval: 0.4)
        }

        let deadline = Date().addingTimeInterval(5.0)
        while Date() < deadline {
            if FileManager.default.fileExists(atPath: rawURL.path) {
                return rawURL
            }
            Thread.sleep(forTimeInterval: 0.2)
        }

        throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 4, userInfo: [NSLocalizedDescriptionKey: "vAmiga did not create a raw screenshot at \(rawURL.path). Last RetroShell error: \(lastError?.localizedDescription ?? "none")"])
    }

    private static func requestVAmigaRetroShellScreenshot(basePath: String, config: EmulatorLaunchConfig) throws {
        let command = "screenshot save \(quotedRetroShellPath(basePath))"
        let deadline = Date().addingTimeInterval(10.0)
        var lastError: Error?
        while Date() < deadline {
            for port in retroShellCandidatePorts(config: config) {
                do {
                    let client = VAmigaRawRetroShellClient(port: port, timeout: 2.0)
                    _ = try client.send(command: command, readDuration: 1.0)
                    return
                } catch {
                    lastError = error
                }
            }
            Thread.sleep(forTimeInterval: 0.4)
        }

        throw lastError ?? NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 10, userInfo: [NSLocalizedDescriptionKey: "Failed to request vAmiga screenshot through RetroShell."])
    }

    private static func prepareVAmigaRuntime(config: EmulatorLaunchConfig) throws -> String {
        var commands: [String] = []
        commands.append("amiga init \(EmulatorService.shared.vAmigaInitPreset(for: config.model))")
        if let romPath = EmulatorService.shared.resolveRomPathForValidation(config.romRelativePath) {
            commands.append("mem load rom \(quotedRetroShellPath(romPath))")
        }
        commands.append(contentsOf: [
            "df0 eject",
            "df0 insert \(quotedRetroShellPath(config.adfPath))",
            "amiga power on",
            "amiga reset"
        ])

        let deadline = Date().addingTimeInterval(30.0)
        var lastError: Error?
        while Date() < deadline {
            for port in retroShellCandidatePorts(config: config) {
                do {
                    let client = VAmigaRawRetroShellClient(port: port, timeout: 2.0)
                    let responses = try client.send(commands: commands, readDuration: 0.8)
                    var transcript: [String] = ["# Connected to vAmiga RetroShell on port \(port)"]
                    for (command, response) in responses {
                        transcript.append("$ \(command)")
                        let cleanedResponse = cleanedRetroShellResponse(response)
                        if !cleanedResponse.isEmpty {
                            transcript.append(cleanedResponse)
                        }
                        if retroShellResponseIndicatesFailure(response) {
                            throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 8, userInfo: [NSLocalizedDescriptionKey: "vAmiga rejected RetroShell command `\(command)`: \(cleanedResponse)"])
                        }
                    }
                    return transcript.joined(separator: "\n")
                } catch {
                    lastError = error
                }
            }
            Thread.sleep(forTimeInterval: 0.4)
        }

        throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 6, userInfo: [NSLocalizedDescriptionKey: "Timed out preparing vAmiga through RetroShell on ports \(retroShellCandidatePorts(config: config).map(String.init).joined(separator: ", ")). Last error: \(lastError?.localizedDescription ?? "none")"])
    }

    private static func sendVAmigaCommand(_ command: String, config: EmulatorLaunchConfig, initialClient: VAmigaRawRetroShellClient) throws -> String {
        let deadline = Date().addingTimeInterval(6.0)
        var lastError: Error?
        var client = initialClient

        while Date() < deadline {
            do {
                let response = try client.send(command: command, readDuration: 0.7)
                if retroShellResponseIndicatesFailure(response) {
                    throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 8, userInfo: [NSLocalizedDescriptionKey: "vAmiga rejected RetroShell command `\(command)`: \(cleanedRetroShellResponse(response))"])
                }
                return response
            } catch {
                lastError = error
                Thread.sleep(forTimeInterval: 0.4)
                client = VAmigaRawRetroShellClient(port: client.port, timeout: 2.0)
            }
        }

        throw lastError ?? NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 7, userInfo: [NSLocalizedDescriptionKey: "Failed to send vAmiga RetroShell command: \(command)"])
    }

    private static func retroShellResponseIndicatesFailure(_ response: String) -> Bool {
        let failureMarkers = [
            "Too few arguments",
            "Too many arguments",
            "Syntax error",
            " is not a valid key",
            "Error:",
            "error:"
        ]
        return failureMarkers.contains { response.contains($0) }
    }

    private static func cleanedRetroShellResponse(_ response: String) -> String {
        response
            .replacingOccurrences(of: "\u{001B}[A", with: "")
            .replacingOccurrences(of: "\u{001B}[2K", with: "")
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !$0.hasPrefix("vAmiga%") }
            .joined(separator: "\n")
    }

    private static func waitForVAmigaRetroShell(config: EmulatorLaunchConfig, timeout: TimeInterval) throws -> VAmigaRawRetroShellClient {
        let deadline = Date().addingTimeInterval(timeout)
        var lastError: Error?

        while Date() < deadline {
            for port in retroShellCandidatePorts(config: config) {
                let client = VAmigaRawRetroShellClient(port: port, timeout: 2.0)
                do {
                    try client.connect()
                    return client
                } catch {
                    lastError = error
                }
            }
            Thread.sleep(forTimeInterval: 0.4)
        }

        throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 6, userInfo: [NSLocalizedDescriptionKey: "Timed out waiting for vAmiga RetroShell on ports \(retroShellCandidatePorts(config: config).map(String.init).joined(separator: ", ")). Last error: \(lastError?.localizedDescription ?? "none")"])
    }

    private static func writeVAmigaLaunchDiagnostics(config: EmulatorLaunchConfig, runURL: URL, phase: String) throws {
        let configText = (try? String(contentsOfFile: config.vAmigaServerConfig.configPath, encoding: .utf8)) ?? "<unreadable>"
        let sanitizedConfig = configText
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .filter { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                return trimmed == "[SRV]"
                    || trimmed.hasPrefix("AUTORUN")
                    || trimmed.hasPrefix("ENABLE")
                    || trimmed.hasPrefix("PORT")
                    || trimmed.hasPrefix("PROTOCOL")
                    || trimmed.hasPrefix("VERBOSE")
            }
            .joined(separator: "\n")
        let diagnostics = """
        phase=\(phase)
        configPath=\(config.vAmigaServerConfig.configPath)
        backupPath=\(config.vAmigaServerConfig.backupPath ?? "")
        remoteShellPort=\(config.vAmigaServerConfig.remoteShellPort)
        rpcPort=\(config.vAmigaServerConfig.rpcPort)
        candidatePorts=\(retroShellCandidatePorts(config: config).map(String.init).joined(separator: ","))

        \(sanitizedConfig)
        """
        try diagnostics.write(
            to: runURL.appendingPathComponent("vamiga-launch-diagnostics-\(phase).txt"),
            atomically: true,
            encoding: .utf8
        )
    }

    private static func retroShellCandidatePorts(config: EmulatorLaunchConfig) -> [Int] {
        var ports: [Int] = []
        func append(_ port: Int) {
            guard (1...65535).contains(port), !ports.contains(port) else { return }
            ports.append(port)
        }

        // vAmiga 4.4+ uses RSH index 0; vAmiga 4.2.x uses index 1.
        append(config.vAmigaServerConfig.remoteShellPort)
        append(config.vAmigaServerConfig.rpcPort)
        append(8081)
        append(8080)
        return ports
    }

    private static func requestFSUAEScreenshot() throws {
        if triggerFSUAEScreenshotWithAppleScript() {
            return
        }

        let fsUAEApplication = NSRunningApplication.runningApplications(withBundleIdentifier: "no.fengestad.fs-uae").last
        fsUAEApplication?.activate(options: [.activateAllWindows])
        Thread.sleep(forTimeInterval: 0.3)

        let source = CGEventSource(stateID: .hidSystemState)
        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 111, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 111, keyDown: false) else {
            throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create F12 key events for FS-UAE screenshot trigger."])
        }
        if let fsUAEApplication {
            keyDown.postToPid(fsUAEApplication.processIdentifier)
            Thread.sleep(forTimeInterval: 0.1)
            keyUp.postToPid(fsUAEApplication.processIdentifier)
            Thread.sleep(forTimeInterval: 0.2)
        }
        keyDown.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 0.1)
        keyUp.post(tap: .cghidEventTap)
    }

    private static func triggerFSUAEScreenshotWithAppleScript() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = [
            "-e", #"tell application id "no.fengestad.fs-uae" to activate"#,
            "-e", "delay 0.2",
            "-e", #"tell application "System Events" to key code 111"#
        ]
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    private static func latestFSUAEScreenshot(in directory: URL, modifiedAfter minimumDate: Date? = nil) -> URL? {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        let screenshots = files.filter { file in
            guard file.pathExtension.lowercased() == "png" else { return false }
            guard let minimumDate else { return true }
            let modified = (try? file.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return modified >= minimumDate
        }
        let croppedScreenshots = screenshots.filter { $0.lastPathComponent.contains("crop") }
        return newestFile(in: croppedScreenshots.isEmpty ? screenshots : croppedScreenshots)
    }

    private static func newestFile(in files: [URL]) -> URL? {
        files.max { lhs, rhs in
            let leftDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let rightDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return leftDate < rightDate
        }
    }

    private static func captureScreen(to url: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = ["-x", url.path]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "screencapture failed with status \(process.terminationStatus)"])
        }
    }

    private static func quotedRetroShellPath(_ path: String) -> String {
        "\"\(path.replacingOccurrences(of: "\"", with: "\\\""))\""
    }

    private static func runningApplicationPIDs(bundleIdentifier: String) -> Set<pid_t> {
        Set(NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).map(\.processIdentifier))
    }

    private static func terminateNewApplications(bundleIdentifier: String, excluding existingPIDs: Set<pid_t>) {
        let launchedApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
            .filter { !existingPIDs.contains($0.processIdentifier) }

        for app in launchedApps {
            app.terminate()
        }
    }

    private static func defaultOutputRoot() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("AmigaPlayground/template-runtime-smoke", isDirectory: true)
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }

    private static func jsonEscaped(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    private static func quotedCommandLineValue(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
    }
}

final class VAmigaRawRetroShellClient {
    let host: String
    let port: Int
    let timeout: TimeInterval

    init(host: String = "127.0.0.1", port: Int = 8081, timeout: TimeInterval = 6.0) {
        self.host = host
        self.port = port
        self.timeout = timeout
    }

    func connect() throws {
        var inputStream: InputStream?
        var outputStream: OutputStream?
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        guard let inputStream, let outputStream else {
            throw NSError(domain: "VAmigaRawRetroShellClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create RetroShell streams for \(host):\(port)"])
        }

        inputStream.open()
        outputStream.open()
        defer {
            inputStream.close()
            outputStream.close()
        }

        try waitUntilOpen(inputStream: inputStream, outputStream: outputStream)
    }

    func send(command: String, readDuration: TimeInterval = 2.0) throws -> String {
        var inputStream: InputStream?
        var outputStream: OutputStream?
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        guard let inputStream, let outputStream else {
            throw NSError(domain: "VAmigaRawRetroShellClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create RetroShell streams for \(host):\(port)"])
        }

        inputStream.open()
        outputStream.open()
        defer {
            inputStream.close()
            outputStream.close()
        }

        try waitUntilOpen(inputStream: inputStream, outputStream: outputStream)
        let request = [UInt8]((command + "\n").utf8)
        var offset = 0
        let writeDeadline = Date().addingTimeInterval(timeout)
        while offset < request.count, Date() < writeDeadline {
            if outputStream.hasSpaceAvailable {
                let written = request.withUnsafeBufferPointer { buffer in
                    outputStream.write(buffer.baseAddress!.advanced(by: offset), maxLength: request.count - offset)
                }
                if written > 0 {
                    offset += written
                } else if written < 0 {
                    throw outputStream.streamError ?? NSError(domain: "VAmigaRawRetroShellClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to write RetroShell command to \(host):\(port)"])
                }
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.03))
        }
        guard offset == request.count else {
            throw NSError(domain: "VAmigaRawRetroShellClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "Timed out writing RetroShell command to \(host):\(port)"])
        }

        let deadline = Date().addingTimeInterval(readDuration)
        var response = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while Date() < deadline {
            if inputStream.hasBytesAvailable {
                let count = inputStream.read(&buffer, maxLength: buffer.count)
                if count > 0 {
                    response.append(buffer, count: count)
                } else if count < 0 {
                    throw inputStream.streamError ?? NSError(domain: "VAmigaRawRetroShellClient", code: 3, userInfo: [NSLocalizedDescriptionKey: "RetroShell stream read failed"])
                }
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.03))
        }

        return String(data: response, encoding: .utf8) ?? ""
    }

    func send(commands: [String], readDuration: TimeInterval = 2.0) throws -> [(command: String, response: String)] {
        var inputStream: InputStream?
        var outputStream: OutputStream?
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        guard let inputStream, let outputStream else {
            throw NSError(domain: "VAmigaRawRetroShellClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create RetroShell streams for \(host):\(port)"])
        }

        inputStream.open()
        outputStream.open()
        defer {
            inputStream.close()
            outputStream.close()
        }

        try waitUntilOpen(inputStream: inputStream, outputStream: outputStream)
        var output: [(command: String, response: String)] = []
        for command in commands {
            try write(command: command, to: outputStream)
            let response = try read(from: inputStream, duration: readDuration)
            output.append((command, response))
        }
        return output
    }

    private func write(command: String, to outputStream: OutputStream) throws {
        let request = [UInt8]((command + "\n").utf8)
        var offset = 0
        let writeDeadline = Date().addingTimeInterval(timeout)
        while offset < request.count, Date() < writeDeadline {
            if outputStream.hasSpaceAvailable {
                let written = request.withUnsafeBufferPointer { buffer in
                    outputStream.write(buffer.baseAddress!.advanced(by: offset), maxLength: request.count - offset)
                }
                if written > 0 {
                    offset += written
                } else if written < 0 {
                    throw outputStream.streamError ?? NSError(domain: "VAmigaRawRetroShellClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to write RetroShell command to \(host):\(port)"])
                }
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.03))
        }
        guard offset == request.count else {
            throw NSError(domain: "VAmigaRawRetroShellClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "Timed out writing RetroShell command to \(host):\(port)"])
        }
    }

    private func read(from inputStream: InputStream, duration: TimeInterval) throws -> String {
        let deadline = Date().addingTimeInterval(duration)
        var response = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while Date() < deadline {
            if inputStream.hasBytesAvailable {
                let count = inputStream.read(&buffer, maxLength: buffer.count)
                if count > 0 {
                    response.append(buffer, count: count)
                } else if count < 0 {
                    throw inputStream.streamError ?? NSError(domain: "VAmigaRawRetroShellClient", code: 3, userInfo: [NSLocalizedDescriptionKey: "RetroShell stream read failed"])
                }
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.03))
        }
        return String(data: response, encoding: .utf8) ?? ""
    }

    private func waitUntilOpen(inputStream: InputStream, outputStream: OutputStream) throws {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if inputStream.streamStatus == .open && outputStream.streamStatus == .open {
                return
            }
            if inputStream.streamStatus == .error || outputStream.streamStatus == .error {
                throw inputStream.streamError ?? outputStream.streamError ?? NSError(domain: "VAmigaRawRetroShellClient", code: 4, userInfo: [NSLocalizedDescriptionKey: "RetroShell stream open failed"])
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.03))
        }
        throw NSError(domain: "VAmigaRawRetroShellClient", code: 5, userInfo: [NSLocalizedDescriptionKey: "Timed out connecting to vAmiga RetroShell on \(host):\(port)"])
    }
}

enum PromptTemplateVisualSmokeValidator {
    static func validate(match: AssistantPromptTemplateMatch, prompt: String, outputRoot: URL = defaultOutputRoot()) throws -> PromptTemplateVisualSmokeResult {
        let runID = "\(Self.timestamp())-\(match.id)-\(UUID().uuidString.prefix(8))"
        let runURL = outputRoot.appendingPathComponent(runID, isDirectory: true)
        try FileManager.default.createDirectory(at: runURL, withIntermediateDirectories: true)

        let frame = expectedFrame(for: match)
        let frameURL = runURL.appendingPathComponent("expected-frame.pgm")
        try frame.pgm.write(to: frameURL, atomically: true, encoding: .utf8)

        let brightBandPixels = frame.brightBandPixels
        let success = frame.nonBlackPixels > 0 && (!isTextTemplate(match) || brightBandPixels > 0)
        let summary = success
            ? "Visual smoke passed: generated frame contains non-black pixels and expected bright region evidence."
            : "Visual smoke failed: generated frame did not contain the expected visible evidence."

        let manifest = """
        {
          "prompt": "\(jsonEscaped(prompt))",
          "template": "\(jsonEscaped(match.name))",
          "mode": "expected-frame",
          "frame": "\(jsonEscaped(frameURL.path))",
          "nonBlackPixels": \(frame.nonBlackPixels),
          "brightBandPixels": \(brightBandPixels),
          "success": \(success)
        }
        """
        try manifest.write(to: runURL.appendingPathComponent("manifest.json"), atomically: true, encoding: .utf8)

        let markdown = """
        # Prompt Visual Smoke

        - Prompt: `\(prompt)`
        - Template: \(match.name)
        - Mode: expected-frame
        - Non-black pixels: \(frame.nonBlackPixels)
        - Bright band pixels: \(brightBandPixels)
        - Result: \(success ? "passed" : "failed")

        \(summary)
        """
        try markdown.write(to: runURL.appendingPathComponent("summary.md"), atomically: true, encoding: .utf8)

        return PromptTemplateVisualSmokeResult(
            success: success,
            artifactDirectory: runURL.path,
            framePath: frameURL.path,
            nonBlackPixels: frame.nonBlackPixels,
            brightBandPixels: brightBandPixels,
            summary: summary
        )
    }

    private struct ExpectedFrame {
        let pgm: String
        let nonBlackPixels: Int
        let brightBandPixels: Int
    }

    private static func expectedFrame(for match: AssistantPromptTemplateMatch) -> ExpectedFrame {
        let width = 64
        let height = 48
        var pixels = Array(repeating: Array(repeating: 0, count: width), count: height)

        switch match.id {
        case "static-copper-bars":
            for row in stride(from: 6, through: 36, by: 6) {
                fillBand(row: row, height: 3, value: 180 + row, pixels: &pixels)
            }
        case "bouncing-copper-bars":
            for row in [10, 16, 22, 28, 34, 40] {
                fillBand(row: row, height: 2, value: 220, pixels: &pixels)
            }
        case "raster-splits":
            for row in stride(from: 4, through: 40, by: 6) {
                fillBand(row: row, height: 4, value: 140 + row, pixels: &pixels)
            }
        case "background-color":
            for y in 0..<height {
                for x in 0..<width {
                    pixels[y][x] = 96
                }
            }
        case "starfield":
            for (x, y) in [(6, 5), (18, 9), (45, 7), (12, 18), (30, 20), (52, 22), (8, 34), (39, 37), (58, 42)] {
                pixels[y][x] = 255
            }
        case "bouncing-sprite":
            for y in 16..<28 {
                for x in 26..<38 {
                    if x == 26 || x == 37 || y == 16 || y == 27 || (x + y).isMultiple(of: 5) {
                        pixels[y][x] = 240
                    }
                }
            }
        case "double-buffer-bitplane":
            for y in 10..<38 {
                for x in 8..<56 where (x / 4 + y / 4).isMultiple(of: 2) {
                    pixels[y][x] = 230
                }
            }
        case "frame-synced-audio-intro":
            for y in 18..<30 {
                for x in 0..<width {
                    pixels[y][x] = (x / 8).isMultiple(of: 2) ? 210 : 80
                }
            }
        default:
            let baseY = match.id == "sinusoidal-text" ? 18 : 23
            let textWidth = max(8, min(40, (match.parameters["text"]?.count ?? 8) * 3))
            for index in 0..<textWidth {
                let x = 12 + index
                guard x < width - 2 else { break }
                let yOffset = match.id == "sinusoidal-text" ? Int((Double(index) / 3.0).rounded()).isMultiple(of: 2) ? -3 : 3 : 0
                for y in (baseY + yOffset)..<(baseY + yOffset + 5) where y >= 0 && y < height {
                    pixels[y][x] = 245
                }
            }
        }

        let nonBlack = pixels.flatMap { $0 }.filter { $0 > 0 }.count
        let brightBand = pixels.enumerated().reduce(0) { partial, row in
            let y = row.offset
            guard (16...30).contains(y) else { return partial }
            return partial + row.element.filter { $0 > 200 }.count
        }
        let body = pixels.map { row in row.map(String.init).joined(separator: " ") }.joined(separator: "\n")
        return ExpectedFrame(pgm: "P2\n\(width) \(height)\n255\n\(body)\n", nonBlackPixels: nonBlack, brightBandPixels: brightBand)
    }

    private static func fillBand(row: Int, height: Int, value: Int, pixels: inout [[Int]]) {
        guard !pixels.isEmpty else { return }
        for y in row..<min(row + height, pixels.count) {
            for x in 0..<pixels[y].count {
                pixels[y][x] = min(value, 255)
            }
        }
    }

    private static func isTextTemplate(_ match: AssistantPromptTemplateMatch) -> Bool {
        match.id.contains("text")
    }

    private static func defaultOutputRoot() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("AmigaPlayground/template-visual-smoke", isDirectory: true)
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }

    private static func jsonEscaped(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}

struct PromptTemplateBenchmarkRow: Equatable {
    let prompt: String
    let template: String
    let compile: String
    let semantic: String
    let adf: String
    let emulatorSmoke: String
    let result: String
}

enum PromptTemplateBenchmarkReporter {
    static func markdown(rows: [PromptTemplateBenchmarkRow]) -> String {
        let header = "| prompt | template | compile | semantic | ADF | emulator smoke | result |\n| --- | --- | --- | --- | --- | --- | --- |"
        let body = rows.map { row in
            "| \(cell(row.prompt)) | \(cell(row.template)) | \(row.compile) | \(row.semantic) | \(row.adf) | \(row.emulatorSmoke) | \(row.result) |"
        }.joined(separator: "\n")
        return "# Prompt Template Benchmark\n\n\(header)\n\(body)\n"
    }

    static func write(rows: [PromptTemplateBenchmarkRow], to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try markdown(rows: rows).write(to: url, atomically: true, encoding: .utf8)
    }

    private static func cell(_ text: String) -> String {
        text.replacingOccurrences(of: "|", with: "\\|")
    }
}

enum AssemblySourceFormatter {
    private static let directiveNames: Set<String> = [
        "SECTION", "XDEF", "XREF", "ALIGN", "EVEN", "CNOP", "END",
        "DC.B", "DC.W", "DC.L", "DS.B", "DS.W", "DS.L", "INCLUDE", "INCBIN"
    ]

    private static let instructionNames: Set<String> = [
        "ABCD", "ADD", "ADDA", "ADDI", "ADDQ", "ADDX", "AND", "ANDI",
        "ASL", "ASR", "BCC", "BCHG", "BCLR", "BCS", "BEQ", "BGE",
        "BGT", "BHI", "BLE", "BLS", "BLT", "BMI", "BNE", "BPL",
        "BRA", "BSET", "BSR", "BTST", "BVC", "BVS", "CHK", "CLR",
        "CMP", "CMPA", "CMPI", "CMPM", "DBCC", "DBCS", "DBEQ", "DBF",
        "DBGE", "DBGT", "DBHI", "DBLE", "DBLS", "DBLT", "DBMI", "DBNE",
        "DBPL", "DBRA", "DBT", "DBVC", "DBVS", "DIVS", "DIVU", "EOR",
        "EORI", "EXG", "EXT", "ILLEGAL", "JMP", "JSR", "LEA", "LINK",
        "LSL", "LSR", "MOVE", "MOVEA", "MOVEM", "MOVEP", "MOVEQ", "MULS",
        "MULU", "NBCD", "NEG", "NEGX", "NOP", "NOT", "OR", "ORI",
        "PEA", "RESET", "ROL", "ROR", "ROXL", "ROXR", "RTE", "RTR",
        "RTS", "SBCD", "SCC", "SCS", "SEQ", "SF", "SGE", "SGT",
        "SHI", "SLE", "SLS", "SLT", "SMI", "SNE", "SPL", "ST",
        "STOP", "SUB", "SUBA", "SUBI", "SUBQ", "SUBX", "SVC", "SVS",
        "SWAP", "TAS", "TRAP", "TRAPV", "TST", "UNLK"
    ]

    static func vasmReadySource(from source: String) -> String {
        normalizeHexLiterals(in: source)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { rawLine -> String in
                let line = String(rawLine)
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                let tokens = trimmed.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
                guard line == trimmed, let firstToken = tokens.first else {
                    return line
                }

                if tokens.count >= 3, tokens[1].uppercased() == "EQU" {
                    let padding = String(repeating: " ", count: max(1, 12 - tokens[0].count))
                    return "\(tokens[0])\(padding)\(tokens[1]) \(tokens.dropFirst(2).joined(separator: " "))"
                }

                let mnemonic = firstToken.split(separator: ".", maxSplits: 1).first.map(String.init) ?? firstToken
                if directiveNames.contains(firstToken.uppercased()) || instructionNames.contains(mnemonic.uppercased()) {
                    return "            " + line
                }

                return line
            }
            .joined(separator: "\n")
    }

    private static func normalizeHexLiterals(in source: String) -> String {
        let pattern = #"(?i)#0x([0-9a-f]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return source }
        var result = source
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        for match in regex.matches(in: source, range: range).reversed() {
            guard match.numberOfRanges == 2,
                  let matchRange = Range(match.range(at: 0), in: result),
                  let digitsRange = Range(match.range(at: 1), in: result) else {
                continue
            }
            result.replaceSubrange(matchRange, with: "#$\(result[digitsRange])")
        }
        return result
    }

    static func indentedSource(from source: String) -> String {
        looksLikeC(source) ? indentC(source) : indentAssembly(source)
    }

    static func commentedSource(from source: String) -> String {
        guard AmigaSourceIndexer.index(source).model == nil else {
            return source
        }
        return looksLikeC(source) ? commentC(source) : commentAssembly(source)
    }

    static func looksLikeC(_ source: String) -> Bool {
        let lowercased = source.lowercased()
        return lowercased.contains("#include") ||
            lowercased.contains("int main") ||
            lowercased.contains("void ") ||
            lowercased.contains("struct ") ||
            lowercased.contains("/*")
    }

    private static func indentAssembly(_ source: String) -> String {
        source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { rawLine -> String in
                let line = String(rawLine)
                let trimmed = line.trimmingCharacters(in: .whitespaces)

                guard !trimmed.isEmpty else { return "" }
                guard !trimmed.hasPrefix(";") else { return trimmed }
                guard !trimmed.hasSuffix(":") else { return trimmed }

                if let colonIndex = trimmed.firstIndex(of: ":") {
                    let label = trimmed[...colonIndex]
                    let remainder = trimmed[trimmed.index(after: colonIndex)...]
                        .trimmingCharacters(in: .whitespaces)
                    guard !remainder.isEmpty else { return String(label) }
                    return "\(label)    \(remainder)"
                }

                return "            \(trimmed)"
            }
            .joined(separator: "\n")
    }

    private static func indentC(_ source: String) -> String {
        var depth = 0

        return source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { rawLine -> String in
                let trimmed = String(rawLine).trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return "" }

                if trimmed.hasPrefix("}") {
                    depth = max(depth - 1, 0)
                }

                let line = String(repeating: "    ", count: depth) + trimmed

                let opens = trimmed.filter { $0 == "{" }.count
                let closes = trimmed.filter { $0 == "}" }.count
                depth = max(depth + opens - closes, 0)

                return line
            }
            .joined(separator: "\n")
    }

    private static func commentAssembly(_ source: String) -> String {
        source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { rawLine -> String in
                let line = String(rawLine)
                let trimmed = line.trimmingCharacters(in: .whitespaces)

                guard !trimmed.isEmpty else { return line }
                guard !trimmed.hasPrefix(";") else { return line }
                guard !line.contains(";") else { return line }

                return "\(line) ; \(assemblyComment(for: trimmed))"
            }
            .joined(separator: "\n")
    }

    private static func assemblyComment(for trimmedLine: String) -> String {
        if trimmedLine.hasSuffix(":") {
            return "defines the \(trimmedLine.dropLast()) label"
        }

        let tokens = trimmedLine.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
        guard let firstToken = tokens.first else { return "keeps this source line in place" }
        let mnemonic = firstToken.split(separator: ".", maxSplits: 1).first.map { String($0).uppercased() } ?? firstToken.uppercased()

        switch mnemonic {
        case "SECTION":
            return "selects the output section for following code or data"
        case "XDEF":
            return "exports the named symbol for the linker"
        case "XREF":
            return "declares an external symbol reference"
        case "INCLUDE":
            return "includes definitions from another source file"
        case "LEA":
            return "loads an effective address into an address register"
        case "MOVE", "MOVEA", "MOVEQ", "MOVEM", "MOVEP":
            return "moves data between registers or memory"
        case "ADD", "ADDA", "ADDI", "ADDQ", "ADDX":
            return "adds a value to the destination operand"
        case "SUB", "SUBA", "SUBI", "SUBQ", "SUBX":
            return "subtracts a value from the destination operand"
        case "CLR":
            return "clears the destination operand"
        case "CMP", "CMPA", "CMPI", "CMPM":
            return "compares operands and updates condition codes"
        case "BTST":
            return "tests a bit and updates condition codes"
        case "BRA":
            return "branches unconditionally"
        case "BSR":
            return "calls a local subroutine"
        case "BNE", "BEQ", "BMI", "BPL", "BGT", "BGE", "BLT", "BLE", "BHI", "BLS", "BCC", "BCS", "BVC", "BVS":
            return "branches when the condition is met"
        case "DBF", "DBRA", "DBEQ", "DBNE", "DBGT", "DBGE", "DBLT", "DBLE":
            return "decrements a counter and branches while active"
        case "JSR":
            return "jumps to a subroutine"
        case "JMP":
            return "jumps to the target address"
        case "RTS":
            return "returns from the current subroutine"
        case "DC.B", "DC.W", "DC.L":
            return "defines constant data"
        case "DS.B", "DS.W", "DS.L":
            return "reserves storage"
        case "EVEN", "ALIGN", "CNOP":
            return "aligns following data or code"
        default:
            return "executes this \(firstToken) statement"
        }
    }

    private static func commentC(_ source: String) -> String {
        source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { rawLine -> String in
                let line = String(rawLine)
                let trimmed = line.trimmingCharacters(in: .whitespaces)

                guard !trimmed.isEmpty else { return line }
                guard !trimmed.hasPrefix("//"), !trimmed.hasPrefix("/*"), !trimmed.hasPrefix("*") else { return line }
                guard !line.contains("//"), !line.contains("/*") else { return line }

                return "\(line) // \(cComment(for: trimmed))"
            }
            .joined(separator: "\n")
    }

    private static func cComment(for trimmedLine: String) -> String {
        if trimmedLine.hasPrefix("#include") {
            return "includes declarations from the named header"
        }
        if trimmedLine.hasPrefix("#define") {
            return "defines a preprocessor constant or macro"
        }
        if trimmedLine.hasPrefix("return") {
            return "returns a value from the current function"
        }
        if trimmedLine.hasPrefix("if") {
            return "starts a conditional branch"
        }
        if trimmedLine.hasPrefix("for") || trimmedLine.hasPrefix("while") {
            return "starts a loop"
        }
        if trimmedLine == "{" || trimmedLine == "}" {
            return "marks a block boundary"
        }
        return "keeps this C statement in place"
    }
}
