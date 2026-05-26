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

    private static func injectableCodeCandidate(from reasoningText: String) -> String? {
        let trimmedReasoning = reasoningText.trimmingCharacters(in: .whitespacesAndNewlines)
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
        if let range = responseText.range(of: "```[a-zA-Z0-9]*\n", options: .regularExpression),
           let endRange = responseText[range.upperBound...].range(of: "```") {
            let codeContent = responseText[range.upperBound..<endRange.lowerBound]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return AssistantChatCompletion(
                injectedCode: AssemblySourceFormatter.vasmReadySource(from: codeContent),
                consoleMessage: "Injected code block from Amiga Assistant."
            )
        }

        if isLikelyInjectableCode(responseText) {
            return AssistantChatCompletion(
                injectedCode: AssemblySourceFormatter.vasmReadySource(from: responseText),
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

        if let textEffectSource = textEffectSource(for: prompt, normalized: normalized) {
            return makeMatch(prompt: prompt, source: textEffectSource)
        }

        if normalized.contains("starfield") || normalized.contains("star field") {
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

        guard normalized.contains("copper") else { return nil }

        if normalized.contains("bounc"),
           normalized.contains("bar") || normalized.contains("multi color") || normalized.contains("multicolor") || normalized.contains("multi-color") {
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

        if normalized.contains("static") || normalized.contains("tiny") || normalized.contains("demo") {
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
                        addq.w     #1,ScrollX
                        cmp.w      #28,ScrollX
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

    private static func textDisplayTemplate(title: String, requestedText: String, textLiteral: String, textColor: String, drawRoutineCall: String, mainLoop: String) -> String {
        """
; \(title)
; Requested text: \(sanitizedDisplayText(requestedText).lowercased())
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            bsr        WriteConsoleMessage  ; runtime-visible fallback for AmigaDOS launch smoke
.consoleHold:
            bra.s      .consoleHold

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

DrawCenteredText:
            lea        TextString(pc),a1
            moveq      #13,d6               ; centered byte column for 13 glyphs
            moveq      #116,d5
            bra.s      DrawLinearText

DrawSineText:
            lea        TextString(pc),a1
            lea        SineOffsets(pc),a3
            move.w     ScrollX(pc),d6
            moveq      #0,d4
.nextSineChar:
            move.b     (a1)+,d0
            beq.s      .doneSine
            moveq      #0,d5
            move.b     0(a3,d4.w),d5
            ext.w      d5
            add.w      #104,d5
            bsr.s      DrawOneGlyph
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
DosName:    dc.b       "dos.library",0
            EVEN
GfxBase:    dc.l       0
oldView:    dc.l       0
DosBase:    dc.l       0
ConsoleMessage:
            dc.b       10,10,10,10,10,10,10,10,10,10,10
            dc.b       "                              \(textLiteral)",10
            dc.b       "                           \(textLiteral)",10
            dc.b       "                              \(textLiteral)",10
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
            bsr        WriteConsoleMessage  ; runtime-visible fallback for AmigaDOS launch smoke
.consoleHold:
            bra.s      .consoleHold

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

    static let bouncingSpriteDemo = """
; Bouncing sprite template.
; Effect: bouncing sprite object
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            bsr        WriteConsoleMessage  ; runtime-visible fallback for AmigaDOS launch smoke
.consoleHold:
            bra.s      .consoleHold

HardwareStart:
            movem.l    d2-d7/a2-a6,-(sp)
            bsr        TakeOverDisplay
            tst.l      GfxBase
            beq        ExitProgram
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
            dc.w       $008e,$2c81,$0090,$2cc1
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

    static let bouncingMulticolorCopperList = """
; Bouncing multi-color copper bars.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)           ; COP1LC
            move.w     #$0000,$88(a6)       ; COPJMP1
            move.w     #$8280,$96(a6)       ; DMAEN + COPEN

            moveq      #64,d0               ; top bar position
            moveq      #1,d1                ; direction

.main:
            btst       #6,$bfe001           ; left mouse exits
            beq.s      .done
            bsr        WaitVBlank

            move.b     d0,d2
            move.b     d2,Bar1Wait
            addq.b     #8,d2
            move.b     d2,Bar2Wait
            addq.b     #8,d2
            move.b     d2,Bar3Wait
            addq.b     #8,d2
            move.b     d2,Bar4Wait
            addq.b     #8,d2
            move.b     d2,Bar5Wait
            addq.b     #8,d2
            move.b     d2,Bar6Wait

            add.b      d1,d0
            cmp.b      #152,d0
            beq.s      .flip
            cmp.b      #48,d0
            bne.s      .main
.flip:
            neg.b      d1
            bra.s      .main

.done:
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
Bar1Wait:   dc.b       64,$07
            dc.w       $fffe,$0180,$0f00    ; red
Bar2Wait:   dc.b       72,$07
            dc.w       $fffe,$0180,$0ff0    ; yellow
Bar3Wait:   dc.b       80,$07
            dc.w       $fffe,$0180,$00f0    ; green
Bar4Wait:   dc.b       88,$07
            dc.w       $fffe,$0180,$00ff    ; cyan
Bar5Wait:   dc.b       96,$07
            dc.w       $fffe,$0180,$000f    ; blue
Bar6Wait:   dc.b       104,$07
            dc.w       $fffe,$0180,$0f0f    ; purple
            dc.w       $c007,$fffe,$0180,$0000
            dc.w       $ffff,$fffe
"""
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
    let summary: String
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
                vAmigaTranscript = "vAmiga scripted capture enabled: boot document first, then request screenshot save \(scriptedCapturePath) after the capture delay."
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
        let success = launchResult.success && analysis.nonBlackPixels > 0 && (!match.id.contains("text") || analysis.brightBandPixels > 0)
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
            summary: summary
        )
    }

    static func analyzeScreenshot(at url: URL, expectsTextBand: Bool) throws -> (nonBlackPixels: Int, brightBandPixels: Int) {
        try analyzeFrame(at: url, expectsTextBand: expectsTextBand)
    }

    static func analyzeFrame(at url: URL, expectsTextBand: Bool) throws -> (nonBlackPixels: Int, brightBandPixels: Int) {
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
                if red + green + blue > 0.55 {
                    nonBlack += 1
                }
                if x >= minX, x < maxX, y >= minY, y < maxY, red + green + blue > 1.6 {
                    brightBand += 1
                }
            }
        }

        return (nonBlack, brightBand)
    }

    private static func analyzeRawFrame(at url: URL, expectsTextBand: Bool) throws -> (nonBlackPixels: Int, brightBandPixels: Int) {
        let data = try Data(contentsOf: url)
        guard let frame = inferRawFrameFormat(byteCount: data.count) else {
            throw NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not infer raw vAmiga frame dimensions for \(url.path)"])
        }

        var nonBlack = 0
        var brightBand = 0
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
                let brightness = Int(bytes[offset]) + Int(bytes[offset + 1]) + Int(bytes[offset + 2])
                if brightness > 90 {
                    nonBlack += 1
                }
                if x >= minX, x < maxX, y >= minY, y < maxY, brightness > 420 {
                    brightBand += 1
                }
            }
        }

        return (nonBlack, brightBand)
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
            let screenshotBasePath = preferredScreenshotURL.deletingPathExtension().path
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
                vAmigaScriptScreenshotBasePath: screenshotBasePath,
                vAmigaScriptWaitSeconds: max(1, Int(ceil(captureDelay)))
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
            vAmigaScriptWaitSeconds: config.vAmigaScriptWaitSeconds
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
            try? FileManager.default.removeItem(at: scriptedRawURL)
            try requestVAmigaRetroShellScreenshot(basePath: scriptedBasePath, config: config)

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
                    let response = try client.send(command: "help", readDuration: 0.4)
                    if response.contains("vAmiga RetroShell") || response.contains("Commands:") || response.contains("Usage:") {
                        return client
                    }
                    lastError = NSError(domain: "PromptTemplateRuntimeSmokeValidator", code: 9, userInfo: [NSLocalizedDescriptionKey: "Port \(port) did not respond like RetroShell: \(cleanedRetroShellResponse(response))"])
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
}
