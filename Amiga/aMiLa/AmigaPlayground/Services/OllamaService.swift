import Foundation
import Combine

class OllamaService: ObservableObject {
    static let shared = OllamaService()
    
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
            case .lmStudio: return "default_model"
            }
        }

        var connectionStatusLabel: String {
            switch self {
            case .ollama: return "Ollama Connected"
            case .lmStudio: return "LM Studio/MLX Connected"
            }
        }
    }
    
    @Published var provider: Provider = .lmStudio
    @Published var customUrl: String = ""
    @Published var modelName: String = Provider.lmStudio.defaultModelName
    var urlSessionConfiguration: URLSessionConfiguration = .default
    
    var apiUrl: String {
        if !customUrl.isEmpty { return customUrl }
        return provider.defaultUrl
    }

    var requestModelName: String {
        let trimmedName = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return provider.defaultModelName
        }

        if provider == .lmStudio && trimmedName == Provider.ollama.defaultModelName {
            return provider.defaultModelName
        }

        return trimmedName
    }
    
    // For normal chat history
    struct ChatMessage: Identifiable, Codable {
        let id: UUID
        let role: String
        var content: String
        
        init(id: UUID = UUID(), role: String, content: String) {
            self.id = id
            self.role = role
            self.content = content
        }
    }
    
    func streamChat(messages: [ChatMessage], onChunk: @escaping (String) -> Void, onCompletion: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        let endpoint = provider == .ollama ? "\(apiUrl)/api/chat" : "\(apiUrl)/v1/chat/completions"
        guard let url = URL(string: endpoint) else {
            onError(NSError(domain: "OllamaService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Format body depending on API spec
        var body: [String: Any] = [:]
        
        if provider == .ollama {
            let formattedMessages = messages.map { ["role": $0.role, "content": $0.content] }
            body = [
                "model": requestModelName,
                "messages": formattedMessages,
                "stream": true
            ]
        } else {
            // LM Studio (OpenAI Compatible)
            let formattedMessages = messages.map { ["role": $0.role, "content": $0.content] }
            body = [
                "model": requestModelName,
                "messages": formattedMessages,
                "stream": true
            ]
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            onError(error)
            return
        }
        
        let session = URLSession(configuration: urlSessionConfiguration, delegate: StreamingDelegate(onChunk: onChunk, onCompletion: onCompletion, onError: onError), delegateQueue: nil)
        let task = session.dataTask(with: request)
        task.resume()
    }
}

// Delegate helper to handle event-driven SSE streaming
class StreamingDelegate: NSObject, URLSessionDataDelegate {
    let onChunk: (String) -> Void
    let onCompletion: (String) -> Void
    let onError: (Error) -> Void
    
    var fullResponse = ""
    private var lineBuffer = ""
    private var didFinish = false
    private var didFail = false
    
    init(onChunk: @escaping (String) -> Void, onCompletion: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        self.onChunk = onChunk
        self.onCompletion = onCompletion
        self.onError = onError
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
                    self.onCompletion(self.fullResponse)
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
            if let delta = first["delta"] as? [String: Any],
               let content = delta["content"] as? String {
                appendChunk(content)
            } else if let message = first["message"] as? [String: Any],
                      let content = message["content"] as? String {
                appendChunk(content)
            } else if let text = first["text"] as? String {
                appendChunk(text)
            }
        } else if let message = dict["message"] as? [String: Any],
                  let content = message["content"] as? String {
            appendChunk(content)
        } else if let response = dict["response"] as? String {
            appendChunk(response)
        } else if let content = dict["content"] as? String {
            appendChunk(content)
        }
    }

    private func appendChunk(_ content: String) {
        guard !content.isEmpty else { return }
        fullResponse += content
        DispatchQueue.main.async {
            self.onChunk(content)
        }
    }
}
