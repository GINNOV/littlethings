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
    @Published private(set) var isGenerating = false

    func submit(_ rawPrompt: String) -> AssistantChatRequest? {
        let prompt = rawPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isGenerating else { return nil }

        let userMessage = OllamaService.ChatMessage(role: "user", content: prompt)
        messages.append(userMessage)
        currentGeneration = ""
        isGenerating = true

        return AssistantChatRequest(messages: messages)
    }

    func complete(fullResponse: String, streamedResponse: String) -> AssistantChatCompletion {
        isGenerating = false

        let responseText = fullResponse.isEmpty ? streamedResponse : fullResponse
        let trimmedResponse = responseText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedResponse.isEmpty else {
            messages.append(OllamaService.ChatMessage(
                role: "assistant",
                content: "No response text was returned by the LLM server. Check the selected provider, model name, and server logs."
            ))
            currentGeneration = ""
            return AssistantChatCompletion(injectedCode: nil, consoleMessage: nil)
        }

        messages.append(OllamaService.ChatMessage(role: "assistant", content: responseText))
        currentGeneration = ""

        return extractCodeForEditor(from: responseText)
    }

    private func extractCodeForEditor(from responseText: String) -> AssistantChatCompletion {
        if let range = responseText.range(of: "```[a-zA-Z0-9]*\n", options: .regularExpression),
           let endRange = responseText[range.upperBound...].range(of: "```") {
            let codeContent = responseText[range.upperBound..<endRange.lowerBound]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return AssistantChatCompletion(
                injectedCode: codeContent,
                consoleMessage: "Injected code block from Amiga Assistant."
            )
        }

        if isLikelyInjectableCode(responseText) {
            return AssistantChatCompletion(
                injectedCode: responseText.trimmingCharacters(in: .whitespacesAndNewlines),
                consoleMessage: "Injected full assistant text block."
            )
        }

        return AssistantChatCompletion(injectedCode: nil, consoleMessage: nil)
    }

    func fail(_ error: Error) {
        isGenerating = false
        currentGeneration = ""
        messages.append(OllamaService.ChatMessage(
            role: "assistant",
            content: "Connection Error: \(error.localizedDescription)\nEnsure your LLM server (Ollama/LM Studio) is running on the specified port."
        ))
    }

    func appendChunk(_ chunk: String) {
        currentGeneration += chunk
    }

    func reusablePrompt(from message: OllamaService.ChatMessage) -> String? {
        guard message.role == "user" else { return nil }

        let prompt = message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return prompt.isEmpty ? nil : prompt
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
