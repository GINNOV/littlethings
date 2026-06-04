import Foundation
import Combine

struct TokenUsage: Codable, Equatable {
    let inputTokens: Int
    let outputTokens: Int
    let totalTokens: Int

    var displayText: String {
        "Tokens: in \(inputTokens) / out \(outputTokens) / total \(totalTokens)"
    }

}

class OllamaService: ObservableObject {
    static let shared = OllamaService()
    static let publishedModelID = "bmove/antigravity-amiga-68k"
    static let publishedModelDisplayName = publishedModelID
    static let modelCardURL = URL(string: "https://huggingface.co/bmove/antigravity-amiga-68k")!
    static let mlxServerRequestModelName = "default_model"

    enum PreferenceKey {
        static let contextWindow = "assistantContextWindow"
        static let systemPrompt = "assistantSystemPrompt"
    }

    static let defaultSystemPrompt = """
You are AntigravityAmiga, an elite Amiga 68000 Motorola assembly programmer. Write highly optimized, clean, and 100% compilable Motorola 68k assembly code.

CRITICAL DIRECTIVES:
- DO NOT leak C-style preprocessor directives (#define, #include, #ifdef) into assembly code.
- DO NOT use C-style comments (// or /* */). All assembly comments MUST start with a semicolon (;).
- Use VASM-compatible include statements (e.g., 'include "exec/types.i"') instead of C header includes like "amiga.h".
- Ensure all instructions and directives (SECTION, MOVE, DC, DS, RTS) have leading spaces so they are not treated as compiler labels. Only labels may start in column 1.
- Never append size specifiers as an extra operand. Use 'move.w #0,d0', never 'move.w #0,d0,W'.
- Use real 68000 instructions only. For custom-chip or memory-mapped register writes, use standard move.b, move.w, or move.l; never emit pseudo-instructions such as 'write'.
- Never write through PC-relative operands and never rely on PC-relative offsets across separate sections. Use labels with lea label,aN or absolute/custom-chip base registers such as lea $dff000,a6.
- For copper-list programs, the copper list itself must live in Chip RAM. Configure display colors and copper timing strictly with copper WAIT/MOVE words such as dc.w $YY01,$fffe and dc.w $0180,$0f00; do not emit CPU-style writes inside the copper list.
"""

    static let generationContractPrompt = """
When the user asks you to generate Amiga code, return exactly one fenced code block tagged assembly and no prose outside the code block. The code block must contain complete VASM-compatible source, not a fragment.

General VASM/68000 rules learned from compiler validation:
- Include SECTION Code,CODE and XDEF _Start for runnable AmigaDOS executables. Do not split SECTION Code,CODE across separate SECTION and CODE lines.
- Every CPU instruction and assembler directive must start with whitespace. Only labels may start in column 1.
- Use $00ff style hexadecimal constants. Do not emit C-style 0x00ff constants.
- Do not invent symbols such as BLUE unless they are defined with EQU or labels in the same source.
- Use $dff000,a6 plus register offsets such as $180(a6), $80(a6), $88(a6), and $96(a6) when touching custom chip registers. Do not write dff000(a6), DFF180, or other bare custom-chip names as operands.
- Do not emit dec.l, wait.l, and.t, BPUSH, OUT, $fp, v0, or other non-68000/pseudo instructions. Use subq/dbf/tst/cmp/bra/beq/bne instead.
- Never append size specifiers as a third operand. Use move.w #0,d0, never move.w #0,d0,W.
- All register and memory-mapped hardware writes must use standard move.b, move.w, or move.l instructions. Do not emit a write pseudo-instruction.
- Never make PC-relative writes and never use PC-relative offsets across separate sections. Use labels with lea label,aN or $dff000-relative custom-chip offsets.
- Branches must target labels. Do not use register-comparison branches or bne.l/bra.l for simple 68000 local loops; prefer bne.s, beq.s, bra.s, or dbf.

For copper-list requests:
- Include SECTION Code,CODE,CHIP and XDEF _Start.
- Install the copper list through COP1LC ($80 from $dff000), strobe COPJMP1 ($88), and enable copper DMA with DMACON.
- Include a main loop that waits for vertical blank and exits on the left mouse button.
- For bouncing or animated copper bars, update copper wait/color words each frame; do not output only static DC.W data.
- Use real 68000/VASM instructions and copper list words only. Do not use WAIT(...) pseudocode, MOVE(...) pseudocode, COLOR_A placeholders, COLOR_B placeholders, or symbolic color placeholders.
- Copper lists must live in Chip RAM and must configure copper timing/colors with dc.w WAIT/MOVE pairs such as dc.w $2c01,$fffe and dc.w $0180,$0f00. Do not emit CPU-style register writes inside the copper list.
- Use concrete Amiga 12-bit color values such as $0f00, $00f0, $000f, $0ff0, $00ff, and $0f0f.
- End every copper list with dc.w $ffff,$fffe.

For blitter requests:
- Use the canonical DMACONR byte busy wait: btst #6,$02(a6), followed by bne.s back to the wait label.
- Do not output a wait-only routine. A valid blitter routine must set BLTCON0 at $40(a6), configure source/destination pointers or destination-only clear state, configure needed modulos, start the operation through BLTSIZE at $58(a6), and wait again after BLTSIZE.
- Prefer concrete $dff000 offsets such as $40(a6), $42(a6), $44(a6), $50(a6), $54(a6), $64(a6), $66(a6), and $58(a6). Do not use bare BLTCON0 or BLTSIZE unless you define them.
"""

    static let generateCodeCommentsPrompt = """
Code comment preference:
- Add an explanatory semicolon comment to every generated assembly code line, describing what that line does.
- Keep comments concise and VASM-compatible. Use semicolon comments only.
"""

    static let omitGeneratedCodeCommentsPrompt = """
Code comment preference:
- Do not add line-by-line explanatory comments to generated code unless the user explicitly asks for them.
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
            switch self {
            case .ollama: return "antigravity-amiga-68k"
            case .lmStudio: return OllamaService.publishedModelID
            }
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
    
    @Published var provider: Provider = .lmStudio
    @Published var customUrl: String = ""
    @Published var modelName: String = Provider.lmStudio.defaultModelName
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
    }
    
    var apiUrl: String {
        if !customUrl.isEmpty { return customUrl }
        return provider.defaultUrl
    }

    var requestModelName: String {
        let trimmedName = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            if provider == .lmStudio {
                return Self.mlxServerRequestModelName
            }

            return provider.defaultModelName
        }

        if provider == .lmStudio &&
            (trimmedName == Provider.ollama.defaultModelName || trimmedName == Self.publishedModelID) {
            return Self.mlxServerRequestModelName
        }

        return trimmedName
    }

    var connectionStatusLabel: String {
        connectionStatus.label(for: provider)
    }

    var sanitizedContextWindow: Int {
        max(1, contextWindow)
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
        var tokenUsage: TokenUsage?
        
        init(id: UUID = UUID(), role: String, content: String, reasoning: String? = nil, tokenUsage: TokenUsage? = nil) {
            self.id = id
            self.role = role
            self.content = content
            self.reasoning = reasoning
            self.tokenUsage = tokenUsage
        }
    }
    
    @discardableResult
    func streamChat(messages: [ChatMessage], adapterPath: String? = nil, onChunk: @escaping (String) -> Void, onCompletion: @escaping (String) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
        return streamChat(
            messages: messages,
            adapterPath: adapterPath,
            onContentChunk: onChunk,
            onReasoningChunk: onChunk,
            onCompletion: { content, reasoning, _ in
                let combined = content.isEmpty ? reasoning : content
                onCompletion(combined)
            },
            onError: onError
        )
    }

    @discardableResult
    func streamChat(
        messages: [ChatMessage],
        adapterPath: String? = nil,
        onContentChunk: @escaping (String) -> Void,
        onReasoningChunk: @escaping (String) -> Void,
        onCompletion: @escaping (String, String) -> Void,
        onError: @escaping (Error) -> Void
    ) -> URLSessionDataTask? {
        streamChat(
            messages: messages,
            adapterPath: adapterPath,
            onContentChunk: onContentChunk,
            onReasoningChunk: onReasoningChunk,
            onCompletion: { content, reasoning, _ in
                onCompletion(content, reasoning)
            },
            onError: onError
        )
    }

    @discardableResult
    func streamChat(
        messages: [ChatMessage],
        adapterPath: String? = nil,
        onContentChunk: @escaping (String) -> Void,
        onReasoningChunk: @escaping (String) -> Void,
        onCompletion: @escaping (String, String, TokenUsage?) -> Void,
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
            var lmStudioBody: [String: Any] = [
                "model": requestModelName,
                "messages": formattedMessages,
                "stream": true,
                "max_tokens": sanitizedContextWindow
            ]
            if let adapterPath, !adapterPath.isEmpty {
                lmStudioBody["adapters"] = adapterPath
            }
            body = lmStudioBody
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

        formattedMessages.append(["role": "system", "content": Self.generationContractPrompt])
        formattedMessages.append(["role": "system", "content": codeCommentPreferencePrompt()])

        formattedMessages.append(contentsOf: messages.map { ["role": $0.role, "content": $0.content] })
        return formattedMessages
    }

    private func codeCommentPreferencePrompt() -> String {
        let storedValue = userDefaults.object(forKey: AppPreferenceDefaults.generateCodeCommentsKey) as? Bool
        return (storedValue ?? AppPreferenceDefaults.generateCodeComments)
            ? Self.generateCodeCommentsPrompt
            : Self.omitGeneratedCodeCommentsPrompt
    }
}

// Delegate helper to handle event-driven SSE streaming
class StreamingDelegate: NSObject, URLSessionDataDelegate {
    let onContentChunk: (String) -> Void
    let onReasoningChunk: (String) -> Void
    let onCompletion: (String, String, TokenUsage?) -> Void
    let onError: (Error) -> Void
    
    var fullContentResponse = ""
    var fullReasoningResponse = ""
    var fullResponse = "" // For backwards compatibility
    var tokenUsage: TokenUsage?
    private var lineBuffer = ""
    private var didFinish = false
    private var didFail = false
    
    init(onContentChunk: @escaping (String) -> Void, onReasoningChunk: @escaping (String) -> Void, onCompletion: @escaping (String, String, TokenUsage?) -> Void, onError: @escaping (Error) -> Void) {
        self.onContentChunk = onContentChunk
        self.onReasoningChunk = onReasoningChunk
        self.onCompletion = onCompletion
        self.onError = onError
    }

    convenience init(onContentChunk: @escaping (String) -> Void, onReasoningChunk: @escaping (String) -> Void, onCompletion: @escaping (String, String) -> Void, onError: @escaping (Error) -> Void) {
        self.init(
            onContentChunk: onContentChunk,
            onReasoningChunk: onReasoningChunk,
            onCompletion: { content, reasoning, _ in
                onCompletion(content, reasoning)
            },
            onError: onError
        )
    }
    
    convenience init(onChunk: @escaping (String) -> Void, onCompletion: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        self.init(
            onContentChunk: onChunk,
            onReasoningChunk: onChunk,
            onCompletion: { content, reasoning, _ in
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
                    self.onCompletion(self.fullContentResponse, self.fullReasoningResponse, self.tokenUsage)
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

        if let parsedTokenUsage = Self.parseTokenUsage(from: dict) {
            tokenUsage = parsedTokenUsage
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
        let sanitizedContent = Self.sanitizedModelText(content)
        guard !sanitizedContent.isEmpty else { return }
        fullContentResponse += sanitizedContent
        fullResponse += sanitizedContent
        DispatchQueue.main.async {
            self.onContentChunk(sanitizedContent)
        }
    }

    private func appendReasoningChunk(_ content: String) {
        let sanitizedContent = Self.sanitizedModelText(content)
        guard !sanitizedContent.isEmpty else { return }
        fullReasoningResponse += sanitizedContent
        fullResponse += sanitizedContent
        DispatchQueue.main.async {
            self.onReasoningChunk(sanitizedContent)
        }
    }

    static func sanitizedModelText(_ text: String) -> String {
        String(text.unicodeScalars.filter { scalar in
            scalar.value == 9 ||
                scalar.value == 10 ||
                scalar.value == 13 ||
                (scalar.value >= 32 && scalar.value != 127)
        })
    }

    static func parseTokenUsage(from dict: [String: Any]) -> TokenUsage? {
        if let usage = dict["usage"] as? [String: Any],
           let inputTokens = integerValue(for: "prompt_tokens", in: usage),
           let outputTokens = integerValue(for: "completion_tokens", in: usage) {
            let totalTokens = integerValue(for: "total_tokens", in: usage) ?? inputTokens + outputTokens
            return TokenUsage(inputTokens: inputTokens, outputTokens: outputTokens, totalTokens: totalTokens)
        }

        if let inputTokens = integerValue(for: "prompt_eval_count", in: dict),
           let outputTokens = integerValue(for: "eval_count", in: dict) {
            return TokenUsage(inputTokens: inputTokens, outputTokens: outputTokens, totalTokens: inputTokens + outputTokens)
        }

        return nil
    }

    private static func integerValue(for key: String, in dict: [String: Any]) -> Int? {
        if let value = dict[key] as? Int {
            return value
        }
        if let value = dict[key] as? Double {
            return Int(value)
        }
        if let value = dict[key] as? String {
            return Int(value)
        }
        return nil
    }
}
