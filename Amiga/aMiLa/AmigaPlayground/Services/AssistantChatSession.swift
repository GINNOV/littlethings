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

    func complete(fullResponse: String, streamedResponse: String, reasoningResponse: String = "") -> AssistantChatCompletion {
        isGenerating = false

        let responseText = fullResponse.isEmpty ? streamedResponse : fullResponse
        let trimmedResponse = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalReasoning = reasoningResponse.isEmpty ? currentThinking : reasoningResponse

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
                reasoning: finalReasoning
            ))
            currentGeneration = ""
            currentThinking = ""
            return AssistantChatCompletion(injectedCode: nil, consoleMessage: nil)
        }

        messages.append(OllamaService.ChatMessage(role: "assistant", content: responseText, reasoning: finalReasoning))
        currentGeneration = ""

        return extractCodeForEditor(from: responseText)
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

enum AssemblySourceFormatter {
    private static let directiveNames: Set<String> = [
        "SECTION", "XDEF", "XREF", "ALIGN", "EVEN", "CNOP", "END",
        "DC.B", "DC.W", "DC.L", "DS.B", "DS.W", "DS.L", "INCLUDE", "INCBIN"
    ]

    static func vasmReadySource(from source: String) -> String {
        source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { rawLine -> String in
                let line = String(rawLine)
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard line == trimmed,
                      let firstToken = trimmed.split(whereSeparator: { $0 == " " || $0 == "\t" }).first,
                      directiveNames.contains(firstToken.uppercased()) else {
                    return line
                }

                return "            " + line
            }
            .joined(separator: "\n")
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
