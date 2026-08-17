import Darwin
import Foundation

public actor SerialPort: SerialTransport {
    private let path: String
    private var fd: Int32 = -1
    private var pending = ""

    public init(path: String) {
        self.path = path
    }

    deinit {
        if fd >= 0 {
            Darwin.close(fd)
        }
    }

    public func open() async throws {
        if fd >= 0 { return }

        let opened = Darwin.open(path, O_RDWR | O_NOCTTY | O_NONBLOCK)
        guard opened >= 0 else {
            let err = errno
            throw ArmError.connectFailed("open \(path) failed: \(err)")
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

    public func close() async {
        if fd >= 0 {
            Darwin.close(fd)
            fd = -1
        }
        pending = ""
    }

    public func writeLine(_ line: String) async throws {
        if fd < 0 {
            throw ArmError.disconnected
        }
        let payload = line.hasSuffix("\n") ? line : line + "\n"
        let bytes = Array(payload.utf8)
        var offset = 0
        while offset < bytes.count {
            let n = bytes.withUnsafeBytes { buf -> Int in
                Darwin.write(fd, buf.baseAddress!.advanced(by: offset), bytes.count - offset)
            }
            if n < 0 {
                let err = errno
                if err == EAGAIN || err == EWOULDBLOCK {
                    try await Task.sleep(for: .milliseconds(5))
                    continue
                }
                throw ArmError.disconnected
            }
            offset += n
        }
    }

    public func readUntilOk(timeout: Duration) async throws -> String {
        if fd < 0 {
            throw ArmError.disconnected
        }
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
            let slice = min(remaining, .milliseconds(10))
            if slice <= .zero {
                pending = ""
                throw ArmError.timeout
            }
            try await Task.sleep(for: slice)
        }
    }

    private func configureTermios() throws {
        var term = termios()
        guard tcgetattr(fd, &term) == 0 else {
            let err = errno
            throw ArmError.connectFailed("tcgetattr failed: \(err)")
        }

        cfmakeraw(&term)
        term.c_cflag &= ~tcflag_t(CRTSCTS)
        cfsetspeed(&term, speed_t(B115200))
        term.c_cflag |= tcflag_t(CS8 | CLOCAL | CREAD)
        term.c_cflag &= ~tcflag_t(PARENB | CSTOPB)

        withUnsafeMutablePointer(to: &term.c_cc) { tuple in
            tuple.withMemoryRebound(to: cc_t.self, capacity: Int(NCCS)) { slots in
                slots[Int(VMIN)] = 0
                slots[Int(VTIME)] = 0
            }
        }

        guard tcsetattr(fd, TCSANOW, &term) == 0 else {
            let err = errno
            throw ArmError.connectFailed("tcsetattr failed: \(err)")
        }
    }

    private func readAvailable() throws {
        var chunk = [UInt8](repeating: 0, count: 256)
        let n = chunk.withUnsafeMutableBytes { buf in
            Darwin.read(fd, buf.baseAddress, buf.count)
        }
        if n > 0 {
            pending += String(decoding: chunk.prefix(n), as: UTF8.self)
        } else if n == 0 {
            Darwin.close(fd)
            fd = -1
            pending = ""
            throw ArmError.disconnected
        } else if n < 0 {
            let err = errno
            if err != EAGAIN, err != EWOULDBLOCK {
                throw ArmError.disconnected
            }
        }
    }
}
