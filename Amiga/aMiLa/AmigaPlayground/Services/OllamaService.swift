import Foundation
import Combine

class OllamaService: ObservableObject {
    static let shared = OllamaService()

    enum PreferenceKey {
        static let contextWindow = "assistantContextWindow"
        static let systemPrompt = "assistantSystemPrompt"
        static let provider = "assistantProvider"
        static let customUrl = "assistantCustomUrl"
        static let modelName = "assistantModelName"
    }

    /// Canonical OpenAI/Ollama model id for the bundled MLX Playground runtime.
    static let playgroundModelId = "amiga-playground-asm"

    /// Retired ids that must never ship in the UI or leave the machine as request models.
    static let legacyModelIds: Set<String> = [
        "default_model",
        "antigravity-amiga-68k",
        "mlx-community/antigravity",
        "amiga-rc-cappella-asm-qwen25"
    ]

    static let defaultSystemPrompt = """
You are the Amiga Playground ASM assistant: an elite Amiga 68000 Motorola assembly programmer. Write highly optimized, clean, and 100% compilable Motorola 68k assembly code.

CRITICAL DIRECTIVES:
- DO NOT leak C-style preprocessor directives (#define, #include, #ifdef) into assembly code.
- DO NOT use C-style comments (// or /* */). All assembly comments MUST start with a semicolon (;).
- Use VASM-compatible include statements (e.g., 'include "exec/types.i"') instead of C header includes like "amiga.h".
- Ensure all directives (SECTION, MOVE, DC, DS, RTS) have leading spaces so they are not treated as compiler labels.
"""
    
    enum Provider: String, CaseIterable, Identifiable {
        case ollama = "Ollama (Port 11434)"
        case lmStudio = "LM Studio (Port 1234)"
        
        var id: String { self.rawValue }
        
        var defaultUrl: String {
            switch self {
            case .ollama: return "http://localhost:11434"
            case .lmStudio: return "http://localhost:1234"
            }
        }

        var defaultModelName: String {
            OllamaService.playgroundModelId
        }

        var displayName: String {
            switch self {
            case .ollama: return "Ollama"
            case .lmStudio: return "LM Studio"
            }
        }

        var healthCheckPath: String {
            switch self {
            case .ollama: return "/api/tags"
            case .lmStudio: return "/v1/models"
            }
        }
    }

    enum ConnectionStatus: Equatable {
        case unchecked
        case checking
        case connected
        case disconnected(String)

        func label(for provider: Provider) -> String {
            switch self {
            case .unchecked:
                return "\(provider.displayName) Not Checked"
            case .checking:
                return "\(provider.displayName) Checking..."
            case .connected:
                return "\(provider.displayName) Connected"
            case .disconnected:
                return "\(provider.displayName) Not Connected"
            }
        }
    }
    
    @Published var provider: Provider {
        didSet {
            userDefaults.set(provider.rawValue, forKey: PreferenceKey.provider)
        }
    }
    @Published var customUrl: String {
        didSet {
            userDefaults.set(customUrl, forKey: PreferenceKey.customUrl)
        }
    }
    @Published var modelName: String {
        didSet {
            userDefaults.set(modelName, forKey: PreferenceKey.modelName)
        }
    }
    @Published var contextWindow: Int {
        didSet {
            if contextWindow < 1 {
                contextWindow = 1
            } else {
                userDefaults.set(contextWindow, forKey: PreferenceKey.contextWindow)
            }
        }
    }
    @Published var systemPrompt: String {
        didSet {
            userDefaults.set(systemPrompt, forKey: PreferenceKey.systemPrompt)
        }
    }
    @Published private(set) var connectionStatus: ConnectionStatus = .unchecked
    var urlSessionConfiguration: URLSessionConfiguration = .default

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let storedContextWindow = userDefaults.object(forKey: PreferenceKey.contextWindow) as? Int ?? 4096
        self.contextWindow = max(1, storedContextWindow)
        self.systemPrompt = userDefaults.string(forKey: PreferenceKey.systemPrompt) ?? Self.defaultSystemPrompt

        if let rawProvider = userDefaults.string(forKey: PreferenceKey.provider),
           let storedProvider = Provider(rawValue: rawProvider) {
            self.provider = storedProvider
        } else {
            self.provider = .lmStudio
        }

        self.customUrl = userDefaults.string(forKey: PreferenceKey.customUrl) ?? ""

        let storedModel = userDefaults.string(forKey: PreferenceKey.modelName) ?? Self.playgroundModelId
        self.modelName = Self.resolvedModelName(storedModel, fallback: Self.playgroundModelId)

        // Persist the migrated value so the next launch never reloads a dead id.
        if storedModel != modelName {
            userDefaults.set(modelName, forKey: PreferenceKey.modelName)
        }
    }
    
    var apiUrl: String {
        if !customUrl.isEmpty { return customUrl }
        return provider.defaultUrl
    }

    var requestModelName: String {
        Self.resolvedModelName(modelName, fallback: provider.defaultModelName)
    }

    /// True when the UI field is already the product model (or empty → product).
    var isUsingPlaygroundModel: Bool {
        let trimmed = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty || trimmed == Self.playgroundModelId
    }

    var connectionStatusLabel: String {
        connectionStatus.label(for: provider)
    }

    var sanitizedContextWindow: Int {
        max(1, contextWindow)
    }

    /// Wire the app to the bundled MLX server: LM Studio port 1234 + product model id.
    func applyPlaygroundConnectionDefaults() {
        provider = .lmStudio
        customUrl = ""
        modelName = Self.playgroundModelId
    }

    /// Rewrite retired model ids in the UI field (call when Settings appears).
    @discardableResult
    func migrateLegacyModelNameIfNeeded() -> Bool {
        let trimmed = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolved = Self.resolvedModelName(trimmed, fallback: Self.playgroundModelId)
        guard resolved != modelName else { return false }
        modelName = resolved
        return true
    }

    static func resolvedModelName(_ raw: String, fallback: String = playgroundModelId) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || legacyModelIds.contains(trimmed) {
            return fallback
        }
        return trimmed
    }

    func refreshConnectionStatus() {
        let providerSnapshot = provider
        let apiUrlSnapshot = apiUrl
        let configurationSnapshot = urlSessionConfiguration

        guard let url = URL(string: apiUrlSnapshot + providerSnapshot.healthCheckPath) else {
            connectionStatus = .disconnected("Invalid API URL")
            return
        }

        connectionStatus = .checking

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 2.0

        let session = URLSession(configuration: configurationSnapshot)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                guard self.provider == providerSnapshot, self.apiUrl == apiUrlSnapshot else {
                    return
                }

                if let error {
                    self.connectionStatus = .disconnected(error.localizedDescription)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.connectionStatus = .disconnected("No HTTP response")
                    return
                }

                if (200..<300).contains(httpResponse.statusCode) {
                    self.connectionStatus = .connected
                } else {
                    self.connectionStatus = .disconnected("HTTP \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    func markConnected() {
        connectionStatus = .connected
    }

    func markDisconnected(_ error: Error) {
        connectionStatus = .disconnected(error.localizedDescription)
    }

    // For normal chat history
    struct ChatMessage: Identifiable, Codable {
        let id: UUID
        let role: String
        var content: String
        var reasoning: String?
        
        init(id: UUID = UUID(), role: String, content: String, reasoning: String? = nil) {
            self.id = id
            self.role = role
            self.content = content
            self.reasoning = reasoning
        }
    }
    
    @discardableResult
    func streamChat(messages: [ChatMessage], onChunk: @escaping (String) -> Void, onCompletion: @escaping (String) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
        return streamChat(
            messages: messages,
            onContentChunk: onChunk,
            onReasoningChunk: onChunk,
            onCompletion: { content, reasoning in
                let combined = content.isEmpty ? reasoning : content
                onCompletion(combined)
            },
            onError: onError
        )
    }

    @discardableResult
    func streamChat(
        messages: [ChatMessage],
        onContentChunk: @escaping (String) -> Void,
        onReasoningChunk: @escaping (String) -> Void,
        onCompletion: @escaping (String, String) -> Void,
        onError: @escaping (Error) -> Void
    ) -> URLSessionDataTask? {
        let endpoint = provider == .ollama ? "\(apiUrl)/api/chat" : "\(apiUrl)/v1/chat/completions"
        guard let url = URL(string: endpoint) else {
            onError(NSError(domain: "OllamaService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"]))
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Format body depending on API spec
        var body: [String: Any] = [:]
        
        let formattedMessages = requestMessages(from: messages)

        if provider == .ollama {
            body = [
                "model": requestModelName,
                "messages": formattedMessages,
                "stream": true,
                "options": [
                    "num_ctx": sanitizedContextWindow
                ]
            ]
        } else {
            // LM Studio (OpenAI Compatible)
            body = [
                "model": requestModelName,
                "messages": formattedMessages,
                "stream": true,
                "max_tokens": sanitizedContextWindow
            ]
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            onError(error)
            return nil
        }
        
        let delegate = StreamingDelegate(
            onContentChunk: onContentChunk,
            onReasoningChunk: onReasoningChunk,
            onCompletion: onCompletion,
            onError: onError
        )
        let session = URLSession(configuration: urlSessionConfiguration, delegate: delegate, delegateQueue: nil)
        let task = session.dataTask(with: request)
        task.resume()
        return task
    }

    private func requestMessages(from messages: [ChatMessage]) -> [[String: String]] {
        var formattedMessages: [[String: String]] = []
        let trimmedSystemPrompt = systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedSystemPrompt.isEmpty {
            formattedMessages.append(["role": "system", "content": trimmedSystemPrompt])
        }

        formattedMessages.append(contentsOf: messages.map { ["role": $0.role, "content": $0.content] })
        return formattedMessages
    }
}

// Delegate helper to handle event-driven SSE streaming
class StreamingDelegate: NSObject, URLSessionDataDelegate {
    let onContentChunk: (String) -> Void
    let onReasoningChunk: (String) -> Void
    let onCompletion: (String, String) -> Void
    let onError: (Error) -> Void
    
    var fullContentResponse = ""
    var fullReasoningResponse = ""
    var fullResponse = "" // For backwards compatibility
    private var lineBuffer = ""
    private var didFinish = false
    private var didFail = false
    
    init(onContentChunk: @escaping (String) -> Void, onReasoningChunk: @escaping (String) -> Void, onCompletion: @escaping (String, String) -> Void, onError: @escaping (Error) -> Void) {
        self.onContentChunk = onContentChunk
        self.onReasoningChunk = onReasoningChunk
        self.onCompletion = onCompletion
        self.onError = onError
    }
    
    convenience init(onChunk: @escaping (String) -> Void, onCompletion: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        self.init(
            onContentChunk: onChunk,
            onReasoningChunk: onChunk,
            onCompletion: { content, reasoning in
                let combined = content.isEmpty ? reasoning : content
                onCompletion(combined)
            },
            onError: onError
        )
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let rawStr = String(data: data, encoding: .utf8) else { return }
        
        lineBuffer += rawStr
        let lines = lineBuffer.components(separatedBy: "\n")
        lineBuffer = lines.last ?? ""
        
        for line in lines.dropLast() {
            parseLine(line)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            didFail = true
            DispatchQueue.main.async {
                self.onError(error)
            }
        } else if !didFail {
            if !lineBuffer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                parseLine(lineBuffer)
                lineBuffer = ""
            }
            if !didFail {
                DispatchQueue.main.async {
                    self.onCompletion(self.fullContentResponse, self.fullReasoningResponse)
                }
            }
        }
    }

    private func parseLine(_ line: String) {
        let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanLine.isEmpty || didFinish { return }

        // Ollama NDJSON format: {"model":"...","message":{"role":"assistant","content":"word"},"done":false}
        // OpenAI/LM Studio SSE format: data: {"choices":[{"delta":{"content":"word"}}]}
        if cleanLine.hasPrefix("data:") {
            let payloadStart = cleanLine.index(cleanLine.startIndex, offsetBy: 5)
            let dataPayload = String(cleanLine[payloadStart...]).trimmingCharacters(in: .whitespaces)
            if dataPayload == "[DONE]" {
                didFinish = true
                return
            }
            parseJSONPayload(dataPayload)
        } else if cleanLine.hasPrefix("{") {
            parseJSONPayload(cleanLine)
        }
    }

    private func parseJSONPayload(_ payload: String) {
        guard let data = payload.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }

        if let error = dict["error"] {
            didFail = true
            DispatchQueue.main.async {
                self.onError(NSError(domain: "OllamaService", code: 502, userInfo: [NSLocalizedDescriptionKey: "\(error)"]))
            }
            return
        }

        if let choices = dict["choices"] as? [[String: Any]],
           let first = choices.first {
            if let delta = first["delta"] as? [String: Any] {
                if let content = delta["content"] as? String {
                    appendContentChunk(content)
                } else if let reasoning = delta["reasoning"] as? String {
                    appendReasoningChunk(reasoning)
                } else if let reasoningContent = delta["reasoning_content"] as? String {
                    appendReasoningChunk(reasoningContent)
                }
            } else if let message = first["message"] as? [String: Any] {
                if let content = message["content"] as? String {
                    appendContentChunk(content)
                } else if let reasoning = message["reasoning"] as? String {
                    appendReasoningChunk(reasoning)
                } else if let reasoningContent = message["reasoning_content"] as? String {
                    appendReasoningChunk(reasoningContent)
                }
            } else if let text = first["text"] as? String {
                appendContentChunk(text)
            }
        } else if let message = dict["message"] as? [String: Any],
                  let content = message["content"] as? String {
            appendContentChunk(content)
        } else if let response = dict["response"] as? String {
            appendContentChunk(response)
        } else if let content = dict["content"] as? String {
            appendContentChunk(content)
        }
    }

    private func appendContentChunk(_ content: String) {
        guard !content.isEmpty else { return }
        fullContentResponse += content
        fullResponse += content
        DispatchQueue.main.async {
            self.onContentChunk(content)
        }
    }

    private func appendReasoningChunk(_ content: String) {
        guard !content.isEmpty else { return }
        fullReasoningResponse += content
        fullResponse += content
        DispatchQueue.main.async {
            self.onReasoningChunk(content)
        }
    }
}
