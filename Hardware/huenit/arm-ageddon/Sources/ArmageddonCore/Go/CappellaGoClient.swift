import Foundation

public protocol HTTPPosting: Sendable {
    func post(url: URL, headers: [String: String], body: Data) async throws -> Data
}

public struct GoIntersection: Sendable, Equatable {
    public let row: Int
    public let column: Int

    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

public enum CappellaGoClientError: Error, Equatable, Sendable {
    case invalidURL
    case emptyResponse
    case unparseableMove
    case illegalIntersection
    case httpStatus
}

public struct URLSessionHTTPPoster: HTTPPosting {
    public init() {}

    public func post(url: URL, headers: [String: String], body: Data) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw CappellaGoClientError.httpStatus
        }
        return data
    }
}

private struct ChatRequest: Encodable {
    struct Message: Encodable {
        let role: String
        let content: String
    }

    let model: String
    let messages: [Message]
    let chat_template_kwargs: [String: Bool]
}

public actor CappellaGoClient {
    private let endpoint: URL
    private let model: String
    private let poster: any HTTPPosting

    public init(
        baseURL: URL,
        model: String,
        poster: any HTTPPosting,
        sessionPath: String = "/chat/completions"
    ) {
        let path = sessionPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.endpoint = baseURL.appending(path: path)
        self.model = model
        self.poster = poster
    }

    public func requestMove(grid: BoardGrid, toPlay: GoStone) async throws -> GoIntersection {
        let user = """
        \(grid.ascii())
        toPlay=\(toPlay.rawValue)
        Reply with ONE line {"row":n,"column":n} 0-indexed from top-left on an empty point.
        """
        let body = try JSONEncoder().encode(
            ChatRequest(
                model: model,
                messages: [.init(role: "user", content: user)],
                chat_template_kwargs: ["enable_thinking": false]
            )
        )
        let data: Data
        do {
            data = try await poster.post(
                url: endpoint,
                headers: ["Content-Type": "application/json"],
                body: body
            )
        } catch let error as CappellaGoClientError {
            throw error
        } catch {
            throw CappellaGoClientError.httpStatus
        }
        guard !data.isEmpty else {
            throw CappellaGoClientError.emptyResponse
        }
        let content = try Self.assistantContent(in: data)
        let move = try Self.parseIntersection(in: content)
        guard (0..<grid.size).contains(move.row), (0..<grid.size).contains(move.column) else {
            throw CappellaGoClientError.illegalIntersection
        }
        guard grid.stone(row: move.row, column: move.column) == .empty else {
            throw CappellaGoClientError.illegalIntersection
        }
        return move
    }

    private static func assistantContent(in data: Data) throws -> String {
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = root["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw CappellaGoClientError.unparseableMove
        }
        return content
    }

    private static func parseIntersection(in text: String) throws -> GoIntersection {
        var payload = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if payload.hasPrefix("```") {
            if let newline = payload.firstIndex(of: "\n") {
                payload = String(payload[payload.index(after: newline)...])
            }
            if let fence = payload.range(of: "```", options: .backwards) {
                payload = String(payload[..<fence.lowerBound])
            }
        }
        guard
            let start = payload.firstIndex(of: "{"),
            let end = payload.lastIndex(of: "}"),
            let json = String(payload[start...end]).data(using: .utf8),
            let object = try JSONSerialization.jsonObject(with: json) as? [String: Any]
        else {
            throw CappellaGoClientError.unparseableMove
        }
        let row = intValue(object["row"])
        let column = intValue(object["column"])
        guard let row, let column else {
            throw CappellaGoClientError.unparseableMove
        }
        return GoIntersection(row: row, column: column)
    }

    private static func intValue(_ value: Any?) -> Int? {
        if let number = value as? Int { return number }
        if let number = value as? NSNumber { return number.intValue }
        return nil
    }
}
