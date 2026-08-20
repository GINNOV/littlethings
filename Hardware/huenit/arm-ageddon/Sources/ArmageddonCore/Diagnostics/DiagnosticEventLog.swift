import Foundation

public actor DiagnosticEventLog {
    private let limit: Int
    private var events: [DiagnosticEvent] = []
    private var nextID: UInt64 = 0

    public init(limit: Int = 100_000) throws {
        guard (1...100_000).contains(limit) else { throw DiagnosticsError.invalidLimit }
        self.limit = limit
    }

    @discardableResult
    public func append(
        occurredAt: MonotonicInstant,
        generation: UInt64,
        category: DiagnosticCategory,
        severity: DiagnosticSeverity,
        code: String,
        message: String,
        metadata: [String: String] = [:]
    ) -> DiagnosticEvent {
        let event = DiagnosticEvent(
            id: nextID,
            occurredAt: occurredAt,
            generation: generation,
            category: category,
            severity: severity,
            code: code,
            message: message,
            metadata: metadata
        )
        nextID &+= 1
        events.append(event)
        if events.count > limit { events.removeFirst(events.count - limit) }
        return event
    }

    public func snapshot() -> [DiagnosticEvent] { events }
    public func count() -> Int { events.count }
    public func clear() { events.removeAll(keepingCapacity: true) }
}
