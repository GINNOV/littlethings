import Darwin

actor SerialPriorityStopTransport: PriorityStopTransport {
    private let path: String
    private var fd: Int32 = -1
    private let clock = ContinuousStopClock()

    init(path: String) {
        self.path = path
    }

    deinit {
        if fd >= 0 { Darwin.close(fd) }
    }

    func urgentWrite(_ frame: StopFrame, deadlineNanoseconds: UInt64) async -> UrgentWriteOutcome {
        guard clock.nowNanoseconds() < deadlineNanoseconds else { return .deadlineExceeded }
        guard ensureOpen() else { return .transportUnavailable }
        let line: String
        switch frame {
        case .vacuumOff: line = "M1400 A0\n"
        case .motionStop: line = "M410\n"
        case .motorDisable: line = "M84\n"
        }
        let bytes = Array(line.utf8)
        var offset = 0
        while offset < bytes.count {
            if clock.nowNanoseconds() >= deadlineNanoseconds {
                return offset == 0 ? .deadlineExceeded : .partialWrite(bytes: offset)
            }
            let count = bytes.withUnsafeBytes { buffer in
                Darwin.write(fd, buffer.baseAddress!.advanced(by: offset), bytes.count - offset)
            }
            if count > 0 {
                offset += count
                continue
            }
            if count < 0, errno == EAGAIN || errno == EWOULDBLOCK {
                await Task.yield()
                continue
            }
            if count < 0 {
                return offset == 0 ? .transportUnavailable : .partialWrite(bytes: offset)
            }
        }
        return .writeConfirmed
    }

    private func ensureOpen() -> Bool {
        if fd >= 0 { return true }
        let opened = Darwin.open(path, O_WRONLY | O_NOCTTY | O_NONBLOCK)
        guard opened >= 0 else { return false }
        fd = opened
        var term = termios()
        guard tcgetattr(fd, &term) == 0 else { closeAndInvalidate(); return false }
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
        guard tcsetattr(fd, TCSANOW, &term) == 0 else { closeAndInvalidate(); return false }
        return true
    }

    private func closeAndInvalidate() {
        if fd >= 0 { Darwin.close(fd) }
        fd = -1
    }
}
