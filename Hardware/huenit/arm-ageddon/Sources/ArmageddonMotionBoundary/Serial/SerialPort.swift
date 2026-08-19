import Darwin
import Foundation

actor SerialPort: SerialTransport {
    private let path: String
    private var fd: Int32 = -1
    private var pending = ""

    init(path: String) {
        self.path = path
    }

    deinit {
        if fd >= 0 { Darwin.close(fd) }
    }

    func open() async throws {
        if fd >= 0 { return }
        let opened = Darwin.open(path, O_RDWR | O_NOCTTY | O_NONBLOCK)
        guard opened >= 0 else {
            let err = errno
            throw ArmError.connectFailed("open failed: \(String(cString: strerror(err))) (\(err))")
        }
        fd = opened
        do {
            try configureTermios()
            tcflush(fd, TCIOFLUSH)
        } catch {
            Darwin.close(fd)
            fd = -1
            throw error
        }
    }

    func close() async {
        if fd >= 0 { Darwin.close(fd); fd = -1 }
        pending = ""
    }

    func discardInput() async {
        pending = ""
        guard fd >= 0 else { return }
        var chunk = [UInt8](repeating: 0, count: 256)
        while true {
            let count = chunk.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress, $0.count) }
            if count <= 0 { break }
        }
    }

    func writeLine(_ line: String) async throws {
        guard fd >= 0 else { throw ArmError.disconnected }
        let bytes = Array((line.hasSuffix("\n") ? line : line + "\n").utf8)
        var offset = 0
        while offset < bytes.count {
            let count = bytes.withUnsafeBytes { buffer in
                Darwin.write(fd, buffer.baseAddress!.advanced(by: offset), bytes.count - offset)
            }
            if count < 0 {
                if errno == EAGAIN || errno == EWOULDBLOCK {
                    try await Task.sleep(for: .milliseconds(5))
                    continue
                }
                throw ArmError.disconnected
            }
            offset += count
        }
    }

    func readUntilOk(timeout: Duration) async throws -> String {
        guard fd >= 0 else { throw ArmError.disconnected }
        let clock = ContinuousClock()
        let deadline = clock.now + timeout
        while true {
            try readAvailable()
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
            try await Task.sleep(for: min(remaining, .milliseconds(10)))
        }
    }

    private func configureTermios() throws {
        var term = termios()
        guard tcgetattr(fd, &term) == 0 else { throw ArmError.connectFailed("tcgetattr failed") }
        cfmakeraw(&term)
        term.c_cflag &= ~tcflag_t(CRTSCTS)
        cfsetspeed(&term, speed_t(B115200))
        term.c_cflag |= tcflag_t(CS8 | CLOCAL | CREAD)
        term.c_cflag &= ~tcflag_t(PARENB | CSTOPB)
        withUnsafeMutablePointer(to: &term.c_cc) { slots in
            slots.withMemoryRebound(to: cc_t.self, capacity: Int(NCCS)) {
                $0[Int(VMIN)] = 0
                $0[Int(VTIME)] = 0
            }
        }
        guard tcsetattr(fd, TCSANOW, &term) == 0 else { throw ArmError.connectFailed("tcsetattr failed") }
    }

    private func readAvailable() throws {
        var chunk = [UInt8](repeating: 0, count: 256)
        let count = chunk.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress, $0.count) }
        if count > 0 {
            pending += String(decoding: chunk.prefix(count), as: UTF8.self)
        } else if count < 0, errno != EAGAIN, errno != EWOULDBLOCK {
            throw ArmError.disconnected
        }
    }
}

private func containsOk(_ text: String) -> Bool {
    text.split { $0 == " " || $0 == "\n" || $0 == "\r" || $0 == "\t" }
        .contains { $0.caseInsensitiveCompare("ok") == .orderedSame }
}
