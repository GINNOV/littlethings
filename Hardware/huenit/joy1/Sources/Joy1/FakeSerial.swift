import Foundation

public actor FakeSerial: SerialTransport {
    public private(set) var written: [String] = []
    public private(set) var replies: [String] = []

    private var pending = ""
    private var isOpen = false

    public init() {}

    public func setReplies(_ replies: [String]) {
        self.replies = replies
    }

    public func open() async throws {
        isOpen = true
    }

    public func close() async {
        isOpen = false
    }

    public func writeLine(_ line: String) async throws {
        if !isOpen {
            try await open()
        }
        written.append(line)
        if !replies.isEmpty {
            pending += replies.removeFirst()
        }
    }

    public func readUntilOk(timeout: Duration) async throws -> String {
        let clock = ContinuousClock()
        let deadline = clock.now + timeout
        while true {
            if containsOk(pending) {
                let result = pending
                pending = ""
                return result
            }
            if clock.now >= deadline {
                throw ArmError.timeout
            }
            let remaining = deadline - clock.now
            let slice = min(remaining, .milliseconds(5))
            if slice <= .zero {
                throw ArmError.timeout
            }
            try await Task.sleep(for: slice)
        }
    }
}

func containsOk(_ text: String) -> Bool {
    guard let regex = try? NSRegularExpression(pattern: #"\bok\b"#, options: .caseInsensitive) else {
        return false
    }
    let range = NSRange(text.startIndex..., in: text)
    return regex.firstMatch(in: text, range: range) != nil
}
