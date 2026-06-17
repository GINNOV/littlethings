import Foundation

struct OllamaClient {
    let baseURL: URL
    let model: String

    init(baseURL: String = AppSettings.defaultOllamaBaseURL, model: String = AppSettings.defaultOllamaModel) {
        self.baseURL = URL(string: baseURL) ?? URL(string: AppSettings.defaultOllamaBaseURL)!
        self.model = model
    }

    func isAvailable() async -> Bool {
        var request = URLRequest(url: baseURL.appendingPathComponent("api/tags"))
        request.timeoutInterval = 2
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

    func researchROM(item: ROMCatalogItem, baseline: ROMResearch) async throws -> ROMResearch {
        let prompt = researchPrompt(item: item, baseline: baseline)
        let body: [String: Any] = [
            "model": model,
            "stream": false,
            "format": "json",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ]
        ]

        var request = URLRequest(url: baseURL.appendingPathComponent("api/chat"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 120

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw OllamaError.badResponse
        }

        let decoded = try JSONDecoder().decode(OllamaChatResponse.self, from: data)
        guard let content = decoded.message.content.data(using: .utf8) else {
            throw OllamaError.invalidPayload
        }

        let payload = try JSONDecoder().decode(ResearchPayload.self, from: content)
        return ROMResearch(
            romID: item.id,
            title: payload.title.isEmpty ? item.displayTitle : payload.title,
            summary: payload.summary,
            contentsDescription: payload.contentsDescription,
            purpose: payload.purpose,
            hardwareIDs: payload.hardwareIDs.isEmpty ? item.parsed.hardwareTokens : payload.hardwareIDs,
            history: payload.history,
            technicalInsights: payload.technicalInsights,
            notableLibraries: payload.notableLibraries,
            compatibilityNotes: payload.compatibilityNotes,
            researchSource: .subAgent,
            researchedAt: Date()
        )
    }

    private var systemPrompt: String {
        """
        You are an Amiga firmware historian and preservation expert. Respond ONLY with valid JSON matching the requested schema. Be precise about hardware models, ROM purposes, and technical details. Never invent file sizes or checksums.
        """
    }

    private func researchPrompt(item: ROMCatalogItem, baseline: ROMResearch) -> String {
        """
        Deep-research this Amiga ROM entry.

        Manifest source archive: \(item.manifest.source)
        Destination path: \(item.manifest.destination)
        Status: \(item.manifest.status.label)
        Parsed title: \(item.displayTitle)
        Category: \(item.category.title)
        Version: \(item.versionLabel)
        Variant: \(item.variantLabel)
        Machines: \(item.machines.map(\.name).joined(separator: ", "))
        File size bytes: \(item.fileInfo?.byteCount ?? 0)
        MD5: \(item.fileInfo?.md5 ?? "unknown")

        Baseline summary for refinement:
        \(baseline.summary)

        Return JSON with keys:
        title, summary, contentsDescription, purpose, hardwareIDs (array of ids like a500, a1200, cd32), history, technicalInsights (array), notableLibraries (array), compatibilityNotes
        """
    }

    enum OllamaError: Error {
        case badResponse
        case invalidPayload
    }
}

private struct OllamaChatResponse: Decodable {
    struct Message: Decodable {
        let content: String
    }

    let message: Message
}

private struct ResearchPayload: Decodable {
    let title: String
    let summary: String
    let contentsDescription: String
    let purpose: String
    let hardwareIDs: [String]
    let history: String
    let technicalInsights: [String]
    let notableLibraries: [String]
    let compatibilityNotes: String
}