import Foundation

actor FakeSerial: SerialTransport {
    private(set) var written: [String] = []
    private(set) var replies: [String] = []
    private(set) var isOpen = false

    private var pending = ""
    private var writeErrors: [ArmError] = []

    func setReplies(_ replies: [String]) {
        self.replies = replies
    }

    func enqueueWriteError(_ error: ArmError) {
        writeErrors.append(error)
    }

    func open() async throws {
        isOpen = true
    }

    func close() async {
        isOpen = false
        pending = ""
    }

    func discardInput() async {
        pending = ""
    }

    func writeLine(_ line: String) async throws {
        if !isOpen { try await open() }
        written.append(line)
        if !writeErrors.isEmpty { throw writeErrors.removeFirst() }
        if !replies.isEmpty { pending += replies.removeFirst() }
    }

    func readUntilOk(timeout: Duration) async throws -> String {
        let clock = ContinuousClock()
        let deadline = clock.now + timeout
        while true {
            if containsOk(pending) {
                let result = pending
                pending = ""
                return result
            }
            if clock.now >= deadline {
                pending = ""
                throw ArmError.timeout
            }
            let remaining = deadline - clock.now
            let slice = min(remaining, .milliseconds(5))
            if slice <= .zero {
                pending = ""
                throw ArmError.timeout
            }
            try await Task.sleep(for: slice)
        }
    }
}

private func containsOk(_ text: String) -> Bool {
    text.split { $0 == " " || $0 == "\n" || $0 == "\r" || $0 == "\t" }
        .contains { $0.caseInsensitiveCompare("ok") == .orderedSame }
}
