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
    }
    
    @Published var provider: Provider = .ollama
    @Published var customUrl: String = ""
    @Published var modelName: String = "antigravity-amiga-68k"
    
    var apiUrl: String {
        if !customUrl.isEmpty { return customUrl }
        return provider.defaultUrl
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
                "model": modelName,
                "messages": formattedMessages,
                "stream": true
            ]
        } else {
            // LM Studio (OpenAI Compatible)
            let formattedMessages = messages.map { ["role": $0.role, "content": $0.content] }
            body = [
                "model": modelName,
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
        
        let session = URLSession(configuration: .default, delegate: StreamingDelegate(onChunk: onChunk, onCompletion: onCompletion, onError: onError), delegateQueue: nil)
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
    
    init(onChunk: @escaping (String) -> Void, onCompletion: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        self.onChunk = onChunk
        self.onCompletion = onCompletion
        self.onError = onError
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let rawStr = String(data: data, encoding: .utf8) else { return }
        
        // Parse lines for Server-Sent Events (SSE) or newlines
        let lines = rawStr.components(separatedBy: "\n")
        
        for line in lines {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanLine.isEmpty { continue }
            
            // Ollama NDJSON format: {"model":"...","message":{"role":"assistant","content":"word"},"done":false}
            // OpenAI/LM Studio SSE format: data: {"choices":[{"delta":{"content":"word"}}]}
            
            if cleanLine.hasPrefix("data: ") {
                let dataPayload = String(cleanLine.dropFirst(6))
                if dataPayload == "[DONE]" { continue }
                if let dict = try? JSONSerialization.jsonObject(with: dataPayload.data(using: .utf8) ?? Data()) as? [String: Any],
                   let choices = dict["choices"] as? [[String: Any]],
                   let first = choices.first,
                   let delta = first["delta"] as? [String: Any],
                   let content = delta["content"] as? String {
                    
                    fullResponse += content
                    DispatchQueue.main.async {
                        self.onChunk(content)
                    }
                }
            } else if cleanLine.hasPrefix("{") {
                // Try to parse as Ollama NDJSON or raw JSON
                if let dict = try? JSONSerialization.jsonObject(with: cleanLine.data(using: .utf8) ?? Data()) as? [String: Any] {
                    if let message = dict["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        fullResponse += content
                        DispatchQueue.main.async {
                            self.onChunk(content)
                        }
                    } else if let response = dict["response"] as? String {
                        // Ollama old generate api
                        fullResponse += response
                        DispatchQueue.main.async {
                            self.onChunk(response)
                        }
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.onError(error)
            }
        } else {
            DispatchQueue.main.async {
                self.onCompletion(self.fullResponse)
            }
        }
    }
}
