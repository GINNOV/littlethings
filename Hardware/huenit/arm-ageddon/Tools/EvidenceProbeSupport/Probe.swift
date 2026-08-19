import Darwin
import Foundation

public enum ProbeError: Error, CustomStringConvertible {
    case argument(String)
    case system(String, Int32)

    public var description: String {
        switch self {
        case .argument(let detail):
            "argument: \(detail)"
        case .system(let operation, let code):
            "\(operation): errno \(code)"
        }
    }
}

public enum Probe {
    private struct Receipt: Encodable {
        let command: String?
        let kind: String
        let pid: Int32?
        let socket: String
        let state: String
    }

    public static func main(kind: String, arguments: [String]) throws {
        guard let mode = arguments.first else {
            throw ProbeError.argument(help(kind: kind))
        }
        switch mode {
        case "--help", "-h":
            print(help(kind: kind))
        case "server":
            try server(kind: kind, options: parse(Array(arguments.dropFirst())))
        case "control":
            try control(kind: kind, options: parse(Array(arguments.dropFirst())))
        default:
            throw ProbeError.argument("unknown mode \(mode)\n\(help(kind: kind))")
        }
    }

    private static func help(kind: String) -> String {
        "Usage: \(kind) server --socket PATH --events PATH --ready-receipt PATH | \(kind) control --socket PATH (--flush|--stop) --ack PATH"
    }

    private static func parse(_ arguments: [String]) throws -> [String: String] {
        var values: [String: String] = [:]
        var index = 0
        while index < arguments.count {
            let name = arguments[index]
            if name == "--flush" || name == "--stop" {
                values[name] = "true"
                index += 1
            } else {
                guard name.hasPrefix("--"), index + 1 < arguments.count else {
                    throw ProbeError.argument("invalid option \(name)")
                }
                values[name] = arguments[index + 1]
                index += 2
            }
        }
        return values
    }

    private static func socketAddress(path: String) throws -> sockaddr_un {
        var address = sockaddr_un()
        address.sun_family = sa_family_t(AF_UNIX)
        let bytes = Array(path.utf8) + [0]
        guard bytes.count <= MemoryLayout.size(ofValue: address.sun_path) else {
            throw ProbeError.argument("socket path is too long")
        }
        withUnsafeMutableBytes(of: &address.sun_path) { destination in
            destination.copyBytes(from: bytes)
        }
        return address
    }

    private static func withSocketAddress<T>(_ path: String, body: (UnsafePointer<sockaddr>, socklen_t) throws -> T) throws -> T {
        var address = try socketAddress(path: path)
        let length = socklen_t(MemoryLayout<sa_family_t>.size + path.utf8.count + 1)
        return try withUnsafePointer(to: &address) { pointer in
            try pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { rebound in
                try body(rebound, length)
            }
        }
    }

    private static func openSocket() throws -> Int32 {
        let descriptor = socket(AF_UNIX, SOCK_STREAM, 0)
        guard descriptor >= 0 else { throw ProbeError.system("socket", errno) }
        return descriptor
    }

    private static func server(kind: String, options: [String: String]) throws {
        guard let socketPath = options["--socket"], let eventsPath = options["--events"], let readyPath = options["--ready-receipt"] else {
            throw ProbeError.argument("server requires --socket, --events, and --ready-receipt")
        }
        let server = try openSocket()
        defer { close(server); unlink(socketPath) }
        let events = open(eventsPath, O_WRONLY | O_CREAT | O_EXCL, 0o600)
        guard events >= 0 else { throw ProbeError.system("open events", errno) }
        defer { close(events) }
        try withSocketAddress(socketPath) { address, length in
            guard bind(server, address, length) == 0 else { throw ProbeError.system("bind", errno) }
        }
        guard listen(server, 4) == 0 else { throw ProbeError.system("listen", errno) }
        try exclusiveJSON(path: readyPath, value: Receipt(command: nil, kind: kind, pid: getpid(), socket: socketPath, state: "ready"))
        var running = true
        while running {
            let client = accept(server, nil, nil)
            guard client >= 0 else { throw ProbeError.system("accept", errno) }
            var buffer = [UInt8](repeating: 0, count: 64)
            let count = read(client, &buffer, buffer.count)
            guard count > 0 else {
                close(client)
                throw ProbeError.system("read", errno)
            }
            let command = String(decoding: buffer.prefix(count), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            let line = Data("{\"command\":\"\(command)\",\"kind\":\"\(kind)\"}\n".utf8)
            try line.withUnsafeBytes { bytes in
                guard write(events, bytes.baseAddress, bytes.count) == bytes.count else { throw ProbeError.system("write events", errno) }
            }
            guard fsync(events) == 0 else { throw ProbeError.system("fsync events", errno) }
            var response: UInt8 = 49
            guard write(client, &response, 1) == 1 else {
                close(client)
                throw ProbeError.system("write response", errno)
            }
            close(client)
            running = command != "stop"
        }
    }

    private static func control(kind: String, options: [String: String]) throws {
        guard let socketPath = options["--socket"], let ackPath = options["--ack"] else {
            throw ProbeError.argument("control requires --socket and --ack")
        }
        let command: String
        if options["--flush"] != nil, options["--stop"] == nil {
            command = "flush"
        } else if options["--stop"] != nil, options["--flush"] == nil {
            command = "stop"
        } else {
            throw ProbeError.argument("control requires exactly one of --flush or --stop")
        }
        let descriptor = try openSocket()
        defer { close(descriptor) }
        try withSocketAddress(socketPath) { address, length in
            guard connect(descriptor, address, length) == 0 else { throw ProbeError.system("connect", errno) }
        }
        guard write(descriptor, command, command.utf8.count) == command.utf8.count else { throw ProbeError.system("write command", errno) }
        var response: UInt8 = 0
        guard read(descriptor, &response, 1) == 1, response == 49 else { throw ProbeError.system("read response", errno) }
        try exclusiveJSON(path: ackPath, value: Receipt(command: command, kind: kind, pid: nil, socket: socketPath, state: "acknowledged"))
    }

    private static func exclusiveJSON(path: String, value: Receipt) throws {
        let descriptor = open(path, O_WRONLY | O_CREAT | O_EXCL, 0o600)
        guard descriptor >= 0 else { throw ProbeError.system("open receipt", errno) }
        defer { close(descriptor) }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value) + Data("\n".utf8)
        try data.withUnsafeBytes { bytes in
            guard write(descriptor, bytes.baseAddress, bytes.count) == bytes.count else { throw ProbeError.system("write receipt", errno) }
        }
        guard fsync(descriptor) == 0 else { throw ProbeError.system("fsync receipt", errno) }
        let parent = URL(fileURLWithPath: path).deletingLastPathComponent().path
        let parentDescriptor = open(parent, O_RDONLY)
        guard parentDescriptor >= 0 else { throw ProbeError.system("open parent", errno) }
        defer { close(parentDescriptor) }
        guard fsync(parentDescriptor) == 0 else { throw ProbeError.system("fsync parent", errno) }
    }
}
