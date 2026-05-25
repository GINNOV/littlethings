import Foundation
import Combine

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

enum AssistantPromptTemplate {
    static func source(for prompt: String) -> String? {
        let normalized = prompt.lowercased()
        guard normalized.contains("copper") else { return nil }

        if normalized.contains("bounc"),
           normalized.contains("multi color") || normalized.contains("multicolor") || normalized.contains("multi-color") {
            return bouncingMulticolorCopperList
        }

        if normalized.contains("static") || normalized.contains("tiny") || normalized.contains("demo") {
            return staticCopperListDemo
        }

        return nil
    }

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
            bsr.s      WaitVBlank
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
            bsr.s      WaitVBlank

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
