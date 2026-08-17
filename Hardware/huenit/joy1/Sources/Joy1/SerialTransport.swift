public protocol SerialTransport: Sendable {
    func open() async throws
    func close() async
    func writeLine(_ line: String) async throws
    func readUntilOk(timeout: Duration) async throws -> String
}
