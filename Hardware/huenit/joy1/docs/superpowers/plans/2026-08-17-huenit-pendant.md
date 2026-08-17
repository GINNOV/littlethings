# HUENIT Joy1 Pendant Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a native macOS SwiftUI teach pendant that hold-to-jogs the HUENIT arm in XYZ and ABC, with speed, vacuum, live pose HUD, and hardware-in-the-loop tests on the desk arm.

**Architecture:** Swift package with a `Joy1` library (serial, arm, jog, model) and a `Joy1App` SwiftUI executable. One `HuenitArm` actor owns the port so jog steps and `M1008` polls never interleave. Cartesian motion is firmware IK via `G1 X/Y/Z`. No app-side solver. App is unsandboxed so `/dev/cu.*` works.

**Tech Stack:** macOS 15+, Swift 6, SwiftUI, Swift Testing, IOKit + termios. No third-party packages.

**Spec:** `docs/superpowers/specs/2026-08-17-huenit-pendant-design.md`

---

## File map

```
Package.swift
Sources/Joy1/Pose.swift
Sources/Joy1/ArmError.swift
Sources/Joy1/SerialTransport.swift
Sources/Joy1/FakeSerial.swift
Sources/Joy1/SerialPort.swift
Sources/Joy1/HuenitArm.swift
Sources/Joy1/PortDetector.swift
Sources/Joy1/JogEngine.swift
Sources/Joy1/PoseMonitor.swift
Sources/Joy1/PendantModel.swift
Sources/Joy1App/Joy1App.swift
Sources/Joy1App/ContentView.swift
Sources/Joy1App/ConnectionBar.swift
Sources/Joy1App/CartesianPad.swift
Sources/Joy1App/JointPad.swift
Sources/Joy1App/SpeedSlider.swift
Sources/Joy1App/VacuumToggle.swift
Sources/Joy1App/PoseHUD.swift
Sources/Joy1App/StopButton.swift
Sources/Joy1App/HoldButton.swift
Tests/Joy1Tests/PoseParsingTests.swift
Tests/Joy1Tests/HuenitArmTests.swift
Tests/Joy1Tests/PortDetectorTests.swift
Tests/Joy1Tests/JogEngineTests.swift
Tests/Joy1Tests/LiveSupport.swift
Tests/Joy1Tests/LiveArmTests.swift
```

Working directory for every command: `/Volumes/AIWork/code/littlethings/Hardware/huenit/joy1`

---

### Task 1: Swift package + pose parsers

**Files:**
- Create: `Package.swift`
- Create: `Sources/Joy1/Pose.swift`
- Create: `Sources/Joy1/ArmError.swift`
- Create: `Tests/Joy1Tests/PoseParsingTests.swift`

- [ ] **Step 1: Write the failing parse tests**

Create `Tests/Joy1Tests/PoseParsingTests.swift`:

```swift
import Testing
@testable import Joy1

struct PoseParsingTests {
    @Test func parseCartesianM1008A3() throws {
        let text = "X:-0.12 Y:233.81 Z:3.15\nok\n"
        let pose = try CartesianPose.parseM1008(text)
        #expect(abs(pose.x - (-0.12)) < 0.001)
        #expect(abs(pose.y - 233.81) < 0.001)
        #expect(abs(pose.z - 3.15) < 0.001)
    }

    @Test func parseJointsM1008A2() throws {
        let text = "A:164.97 B:60.73 C:31.64\nok\n"
        let pose = try JointPose.parseM1008(text)
        #expect(abs(pose.a - 164.97) < 0.001)
        #expect(abs(pose.b - 60.73) < 0.001)
        #expect(abs(pose.c - 31.64) < 0.001)
    }

    @Test func parseBrokenLineThrows() {
        #expect(throws: ArmError.self) {
            _ = try CartesianPose.parseM1008("garbage\nok\n")
        }
    }

    @Test func identityLooksLikeHuenit() {
        let text = "FIRMWARE_NAME:Marlin bugfix-2.0.x (Jun 28 2025 14:44:59) MACHINE_TYPE:FYSETC_E4\nok\n"
        #expect(FirmwareIdentity.parse(text).isHuenitMarlin)
    }

    @Test func identityRejectsRandom() {
        #expect(!FirmwareIdentity.parse("hello").isHuenitMarlin)
    }
}
```

- [ ] **Step 2: Add Package.swift and empty module so the test target exists**

`Package.swift`:

```swift
// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Joy1",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "Joy1", targets: ["Joy1"]),
        .executable(name: "Joy1App", targets: ["Joy1App"]),
    ],
    targets: [
        .target(name: "Joy1"),
        .executableTarget(name: "Joy1App", dependencies: ["Joy1"]),
        .testTarget(name: "Joy1Tests", dependencies: ["Joy1"]),
    ]
)
```

Create `Sources/Joy1App/Joy1App.swift` with a stub so the executable target compiles:

```swift
import SwiftUI

@main
struct Joy1App: App {
    var body: some Scene {
        WindowGroup("HUENIT Joy1") {
            Text("Joy1")
        }
    }
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `swift test --filter PoseParsingTests`
Expected: FAIL — `Joy1` has no `CartesianPose` / `JointPose` / `ArmError` / `FirmwareIdentity`.

- [ ] **Step 4: Implement parse types**

`Sources/Joy1/ArmError.swift`:

```swift
public enum ArmError: Error, Equatable, Sendable {
    case forbiddenCommand(String)
    case connectFailed(String)
    case timeout
    case parseFailed(String)
    case disconnected
    case portBusy(String)
}
```

`Sources/Joy1/Pose.swift`:

```swift
import Foundation

public struct CartesianPose: Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static func parseM1008(_ text: String) throws -> CartesianPose {
        func num(_ key: String) throws -> Double {
            let pattern = "\(key)\\s*[:=]\\s*(-?\\d+(?:\\.\\d+)?)"
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text),
                  let value = Double(text[range])
            else {
                throw ArmError.parseFailed("missing \(key) in \(text)")
            }
            return value
        }
        return try CartesianPose(x: num("X"), y: num("Y"), z: num("Z"))
    }

    public func value(for axis: Axis) -> Double {
        switch axis {
        case .x: x
        case .y: y
        case .z: z
        default: 0
        }
    }
}

public struct JointPose: Equatable, Sendable {
    public var a: Double
    public var b: Double
    public var c: Double

    public init(a: Double, b: Double, c: Double) {
        self.a = a
        self.b = b
        self.c = c
    }

    public static func parseM1008(_ text: String) throws -> JointPose {
        func num(_ key: String) throws -> Double {
            let pattern = "\(key)\\s*[:=]\\s*(-?\\d+(?:\\.\\d+)?)"
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text),
                  let value = Double(text[range])
            else {
                throw ArmError.parseFailed("missing \(key) in \(text)")
            }
            return value
        }
        return try JointPose(a: num("A"), b: num("B"), c: num("C"))
    }

    public func value(for axis: Axis) -> Double {
        switch axis {
        case .a: a
        case .b: b
        case .c: c
        default: 0
        }
    }
}

public struct ArmPose: Equatable, Sendable {
    public var cartesian: CartesianPose
    public var joints: JointPose
    public var isStale: Bool

    public init(cartesian: CartesianPose, joints: JointPose, isStale: Bool = false) {
        self.cartesian = cartesian
        self.joints = joints
        self.isStale = isStale
    }
}

public struct FirmwareIdentity: Equatable, Sendable {
    public var raw: String
    public var isHuenitMarlin: Bool

    public static func parse(_ text: String) -> FirmwareIdentity {
        let ok = text.localizedCaseInsensitiveContains("Marlin")
            && text.localizedCaseInsensitiveContains("FYSETC_E4")
        return FirmwareIdentity(raw: text, isHuenitMarlin: ok)
    }
}

public enum Axis: String, Sendable, CaseIterable {
    case x, y, z, a, b, c

    public var isCartesian: Bool {
        self == .x || self == .y || self == .z
    }

    public var gcodeLetter: String {
        rawValue.uppercased()
    }
}

public enum Sign: Int, Sendable {
    case neg = -1
    case pos = 1
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `swift test --filter PoseParsingTests`
Expected: PASS (5 tests).

- [ ] **Step 6: Commit**

```bash
git add Package.swift Sources/Joy1/Pose.swift Sources/Joy1/ArmError.swift Sources/Joy1App/Joy1App.swift Tests/Joy1Tests/PoseParsingTests.swift
git commit -m "feat(joy1): add package and M1008 pose parsers"
```

---

### Task 2: Serial transport + fake

**Files:**
- Create: `Sources/Joy1/SerialTransport.swift`
- Create: `Sources/Joy1/FakeSerial.swift`
- Create: `Sources/Joy1/SerialPort.swift`
- Modify: `Tests/Joy1Tests/HuenitArmTests.swift` (create; first tests use FakeSerial only)

- [ ] **Step 1: Write failing FakeSerial tests**

Create `Tests/Joy1Tests/HuenitArmTests.swift`:

```swift
import Testing
@testable import Joy1

struct FakeSerialTests {
    @Test func writeLineRecordsAndReadUntilOk() async throws {
        let serial = FakeSerial()
        serial.replies = ["FIRMWARE_NAME:Marlin MACHINE_TYPE:FYSETC_E4\nok\n"]
        try await serial.open()
        try await serial.writeLine("M115")
        let reply = try await serial.readUntilOk(timeout: .seconds(1))
        #expect(serial.written == ["M115"])
        #expect(reply.contains("FYSETC_E4"))
        await serial.close()
    }

    @Test func timeoutWhenNoOk() async {
        let serial = FakeSerial()
        serial.replies = ["nope\n"]
        try? await serial.open()
        try? await serial.writeLine("M115")
        await #expect(throws: ArmError.timeout) {
            _ = try await serial.readUntilOk(timeout: .milliseconds(50))
        }
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter FakeSerialTests`
Expected: FAIL — `FakeSerial` / `SerialTransport` missing.

- [ ] **Step 3: Implement protocol, fake, and live SerialPort**

`Sources/Joy1/SerialTransport.swift`:

```swift
public protocol SerialTransport: Sendable {
    func open() async throws
    func close() async
    func writeLine(_ line: String) async throws
    func readUntilOk(timeout: Duration) async throws -> String
}
```

`Sources/Joy1/FakeSerial.swift`:

```swift
public actor FakeSerial: SerialTransport {
    public var written: [String] = []
    public var replies: [String] = []
    public var isOpen = false
    private var pending = ""

    public init() {}

    public func open() async throws {
        isOpen = true
    }

    public func close() async {
        isOpen = false
    }

    public func writeLine(_ line: String) async throws {
        guard isOpen else { throw ArmError.disconnected }
        written.append(line)
        if !replies.isEmpty {
            pending += replies.removeFirst()
        }
    }

    public func readUntilOk(timeout: Duration) async throws -> String {
        let deadline = ContinuousClock.now + timeout
        while ContinuousClock.now < deadline {
            if pending.range(of: #"\bok\b"#, options: [.regularExpression, .caseInsensitive]) != nil {
                let out = pending
                pending = ""
                return out
            }
            try await Task.sleep(for: .milliseconds(5))
        }
        throw ArmError.timeout
    }
}
```

`Sources/Joy1/SerialPort.swift`:

```swift
import Foundation
import Darwin

public actor SerialPort: SerialTransport {
    public let path: String
    private var fd: Int32 = -1
    private var buffer = Data()

    public init(path: String) {
        self.path = path
    }

    public func open() async throws {
        let opened = Darwin.open(path, O_RDWR | O_NOCTTY | O_NONBLOCK)
        guard opened >= 0 else {
            throw ArmError.connectFailed("open \(path) errno=\(errno)")
        }
        fd = opened
        var term = termios()
        guard tcgetattr(fd, &term) == 0 else {
            Darwin.close(fd)
            fd = -1
            throw ArmError.connectFailed("tcgetattr \(path)")
        }
        cfmakeraw(&term)
        cfsetspeed(&term, speed_t(B115200))
        term.c_cflag |= tcflag_t(CS8 | CREAD | CLOCAL)
        term.c_cc.16 /* VMIN */ = 0
        term.c_cc.17 /* VTIME */ = 0
        guard tcsetattr(fd, TCSANOW, &term) == 0 else {
            Darwin.close(fd)
            fd = -1
            throw ArmError.connectFailed("tcsetattr \(path)")
        }
        tcflush(fd, TCIOFLUSH)
    }

    public func close() async {
        if fd >= 0 {
            Darwin.close(fd)
            fd = -1
        }
        buffer.removeAll()
    }

    public func writeLine(_ line: String) async throws {
        guard fd >= 0 else { throw ArmError.disconnected }
        let payload = line.hasSuffix("\n") ? line : line + "\n"
        try payload.withCString { ptr in
            let count = strlen(ptr)
            let written = Darwin.write(fd, ptr, count)
            if written < 0 { throw ArmError.connectFailed("write errno=\(errno)") }
        }
    }

    public func readUntilOk(timeout: Duration) async throws -> String {
        guard fd >= 0 else { throw ArmError.disconnected }
        let deadline = ContinuousClock.now + timeout
        while ContinuousClock.now < deadline {
            var chunk = [UInt8](repeating: 0, count: 1024)
            let n = Darwin.read(fd, &chunk, chunk.count)
            if n > 0 {
                buffer.append(contentsOf: chunk[0..<Int(n)])
            }
            if let text = String(data: buffer, encoding: .utf8)
                ?? String(data: buffer, encoding: .isoLatin1) {
                if text.range(of: #"\bok\b"#, options: [.regularExpression, .caseInsensitive]) != nil {
                    buffer.removeAll()
                    return text
                }
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        throw ArmError.timeout
    }
}
```

Note: `term.c_cc.16` / `.17` are VMIN/VTIME on Darwin. If the compiler rejects tuple index, use `term.c_cc.2` after checking `MemoryLayout` — VMIN is 16 on macOS.

- [ ] **Step 4: Run FakeSerial tests**

Run: `swift test --filter FakeSerialTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Joy1/SerialTransport.swift Sources/Joy1/FakeSerial.swift Sources/Joy1/SerialPort.swift Tests/Joy1Tests/HuenitArmTests.swift
git commit -m "feat(joy1): add serial transport, fake, and 115200 port"
```

---

### Task 3: HuenitArm connect, G28 reject, vacuum, pose query

**Files:**
- Create: `Sources/Joy1/HuenitArm.swift`
- Modify: `Tests/Joy1Tests/HuenitArmTests.swift`

- [ ] **Step 1: Write failing HuenitArm tests**

Append to `Tests/Joy1Tests/HuenitArmTests.swift`:

```swift
struct HuenitArmTests {
    @Test func connectAcceptsMarlinE4() async throws {
        let serial = FakeSerial()
        serial.replies = [
            "FIRMWARE_NAME:Marlin bugfix-2.0.x MACHINE_TYPE:FYSETC_E4\nok\n",
            "ok\n",
            "ok\n",
        ]
        let arm = HuenitArm(transport: serial)
        try await arm.connect()
        #expect(await arm.isConnected)
        let written = await serial.written
        #expect(written.contains("M115"))
        #expect(written.contains("G21"))
        #expect(written.contains("G91"))
    }

    @Test func connectRejectsNonMarlin() async {
        let serial = FakeSerial()
        serial.replies = ["hello\nok\n"]
        let arm = HuenitArm(transport: serial)
        await #expect(throws: ArmError.self) {
            try await arm.connect()
        }
        #expect(await arm.isConnected == false)
    }

    @Test func rejectsG28() async {
        let serial = FakeSerial()
        let arm = HuenitArm(transport: serial)
        await #expect(throws: ArmError.forbiddenCommand("G28")) {
            try await arm.send("G28")
        }
        let written = await serial.written
        #expect(!written.contains(where: { $0.contains("G28") }))
    }

    @Test func queryPoseParsesBothSpaces() async throws {
        let serial = FakeSerial()
        serial.replies = [
            "X:-0.12 Y:233.81 Z:3.15\nok\n",
            "A:164.97 B:60.73 C:31.64\nok\n",
        ]
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        let pose = try await arm.queryPose()
        #expect(abs(pose.cartesian.y - 233.81) < 0.001)
        #expect(abs(pose.joints.a - 164.97) < 0.001)
        #expect(pose.isStale == false)
        let written = await serial.written
        #expect(written == ["M1008 A3", "M1008 A2"])
    }

    @Test func vacuumCommands() async throws {
        let serial = FakeSerial()
        serial.replies = ["ok\n", "ok\n"]
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        try await arm.setVacuum(true)
        try await arm.setVacuum(false)
        let written = await serial.written
        #expect(written == ["M1400 A1023", "M1400 A0"])
    }

    @Test func jogStepSendsRelativeG1() async throws {
        let serial = FakeSerial()
        serial.replies = ["ok\n"]
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        try await arm.jogCartesian(axis: .x, deltaMm: 3, feedMmPerMin: 1200)
        let written = await serial.written
        #expect(written.count == 1)
        #expect(written[0].hasPrefix("G1 X"))
        #expect(written[0].contains("F1200"))
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `swift test --filter HuenitArmTests`
Expected: FAIL — `HuenitArm` missing.

- [ ] **Step 3: Implement HuenitArm**

`Sources/Joy1/HuenitArm.swift`:

```swift
public actor HuenitArm {
    private let transport: any SerialTransport
    public private(set) var isConnected = false
    public var jointCommandFormat: String = "G1 {A}{delta} F{F}"

    public init(transport: any SerialTransport) {
        self.transport = transport
    }

    public func connect() async throws {
        try await transport.open()
        do {
            let identity = try await send("M115")
            guard FirmwareIdentity.parse(identity).isHuenitMarlin else {
                await transport.close()
                isConnected = false
                throw ArmError.connectFailed("not HUENIT Marlin: \(identity)")
            }
            _ = try await send("G21")
            _ = try await send("G91")
            isConnected = true
        } catch {
            await transport.close()
            isConnected = false
            throw error
        }
    }

    public func disconnect() async {
        await transport.close()
        isConnected = false
    }

    public func forceConnectedForTests() {
        isConnected = true
    }

    @discardableResult
    public func send(_ line: String) async throws -> String {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.uppercased().contains("G28") {
            throw ArmError.forbiddenCommand("G28")
        }
        guard isConnected || trimmed == "M115" || trimmed == "G21" || trimmed == "G91" else {
            throw ArmError.disconnected
        }
        try await transport.writeLine(trimmed)
        return try await transport.readUntilOk(timeout: .seconds(2))
    }

    public func queryPose() async throws -> ArmPose {
        let xyzText = try await send("M1008 A3")
        let abcText = try await send("M1008 A2")
        return ArmPose(
            cartesian: try CartesianPose.parseM1008(xyzText),
            joints: try JointPose.parseM1008(abcText),
            isStale: false
        )
    }

    public func setVacuum(_ on: Bool) async throws {
        _ = try await send(on ? "M1400 A1023" : "M1400 A0")
    }

    public func flush() async throws {
        _ = try await send("M400")
    }

    public func stop() async throws {
        _ = try? await send("M1400 A0")
        do {
            _ = try await send("M410")
        } catch {
            _ = try? await send("M84")
        }
    }

    public func jogCartesian(axis: Axis, deltaMm: Double, feedMmPerMin: Double) async throws {
        precondition(axis.isCartesian)
        let line = String(format: "G1 \(axis.gcodeLetter)%.4f F%.1f", deltaMm, feedMmPerMin)
        _ = try await send(line)
    }

    public func jogJoint(axis: Axis, deltaDeg: Double, feedMmPerMin: Double) async throws {
        precondition(!axis.isCartesian)
        let line = jointCommandFormat
            .replacingOccurrences(of: "{A}", with: axis.gcodeLetter)
            .replacingOccurrences(of: "{delta}", with: String(format: "%.4f", deltaDeg))
            .replacingOccurrences(of: "{F}", with: String(format: "%.1f", feedMmPerMin))
        _ = try await send(line)
    }
}
```

`connect()` currently calls `send("M115")` while `isConnected` is false. The guard allows `M115`/`G21`/`G91` before the flag flips. `FakeSerial.open()` must be called — `connect()` does that. Tests that use `forceConnectedForTests()` skip `open()`; `FakeSerial.writeLine` requires `isOpen`. Fix FakeSerial to allow writes when used from unit tests without open, **or** have `forceConnectedForTests` not needed if tests call a test helper that opens.

Update `FakeSerial.writeLine` to open lazily:

```swift
public func writeLine(_ line: String) async throws {
    if !isOpen { isOpen = true }
    written.append(line)
    if !replies.isEmpty {
        pending += replies.removeFirst()
    }
}
```

- [ ] **Step 4: Run tests**

Run: `swift test --filter HuenitArmTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Joy1/HuenitArm.swift Sources/Joy1/FakeSerial.swift Tests/Joy1Tests/HuenitArmTests.swift
git commit -m "feat(joy1): add HuenitArm connect, pose, vacuum, G28 guard"
```

---

### Task 4: Port detector

**Files:**
- Create: `Sources/Joy1/PortDetector.swift`
- Create: `Tests/Joy1Tests/PortDetectorTests.swift`

- [ ] **Step 1: Write failing detector tests**

```swift
import Testing
@testable import Joy1

struct PortDetectorTests {
    @Test func prefersHuearmOverHuecam() {
        let ports = [
            SerialCandidate(path: "/dev/cu.usbserial-834440", product: "HUENIT_CAM", serial: "D30GSA95_HUECAM", vid: 0x0403, pid: 0x6015),
            SerialCandidate(path: "/dev/cu.usbserial-3120", product: "HUENIT_HUEARM", serial: "D30GQRUV_HUEARM", vid: 0x0403, pid: 0x6015),
            SerialCandidate(path: "/dev/cu.Bluetooth-Incoming-Port", product: nil, serial: nil, vid: nil, pid: nil),
        ]
        let picked = PortDetector.pickArm(from: ports)
        #expect(picked?.path == "/dev/cu.usbserial-3120")
    }

    @Test func refusesCameraOnly() {
        let ports = [
            SerialCandidate(path: "/dev/cu.usbserial-834440", product: "HUENIT_CAM", serial: "HUECAM", vid: 0x0403, pid: 0x6015),
        ]
        #expect(PortDetector.pickArm(from: ports) == nil)
    }
}
```

- [ ] **Step 2: Run to verify fail**

Run: `swift test --filter PortDetectorTests`
Expected: FAIL — types missing.

- [ ] **Step 3: Implement detector**

`Sources/Joy1/PortDetector.swift`:

```swift
import Foundation
import IOKit
import IOKit.serial

public struct SerialCandidate: Equatable, Sendable {
    public var path: String
    public var product: String?
    public var serial: String?
    public var vid: Int?
    public var pid: Int?

    public init(path: String, product: String?, serial: String?, vid: Int?, pid: Int?) {
        self.path = path
        self.product = product
        self.serial = serial
        self.vid = vid
        self.pid = pid
    }

    public var isCamera: Bool {
        let blob = "\(product ?? "") \(serial ?? "")".uppercased()
        return blob.contains("HUECAM") || blob.contains("HUENIT_CAM")
    }

    public var isArm: Bool {
        let blob = "\(product ?? "") \(serial ?? "")".uppercased()
        return blob.contains("HUEARM") || blob.contains("HUENIT_HUEARM")
    }

    public var score: Int {
        if isCamera { return -100 }
        var s = 0
        if isArm { s += 10 }
        if vid == 0x0403 && pid == 0x6015 { s += 3 }
        if path.contains("usbserial") { s += 1 }
        return s
    }
}

public enum PortDetector {
    public static func pickArm(from ports: [SerialCandidate]) -> SerialCandidate? {
        ports.filter { $0.score > 0 }.max(by: { $0.score < $1.score })
    }

    public static func scan() -> [SerialCandidate] {
        var results: [SerialCandidate] = []
        let matching = IOServiceMatching(kIOSerialBSDServiceValue)
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return results
        }
        defer { IOObjectRelease(iterator) }
        var service = IOIteratorNext(iterator)
        while service != 0 {
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }
            let path = string(service, kIOCalloutDeviceKey)
            guard let path else { continue }
            let product = walkString(service, "USB Product Name")
            let serial = walkString(service, "USB Serial Number")
            let vid = walkInt(service, "idVendor")
            let pid = walkInt(service, "idProduct")
            results.append(SerialCandidate(path: path, product: product, serial: serial, vid: vid, pid: pid))
        }
        return results
    }

    private static func string(_ service: io_object_t, _ key: String) -> String? {
        let unmanaged = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)
        return unmanaged?.takeRetainedValue() as? String
    }

    private static func walkString(_ service: io_object_t, _ key: String) -> String? {
        let unmanaged = IORegistryEntrySearchCFProperty(
            service, kIOServicePlane, key as CFString, kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateParents | kIORegistryIterateRecursively)
        )
        return unmanaged?.takeRetainedValue() as? String
    }

    private static func walkInt(_ service: io_object_t, _ key: String) -> Int? {
        let unmanaged = IORegistryEntrySearchCFProperty(
            service, kIOServicePlane, key as CFString, kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateParents | kIORegistryIterateRecursively)
        )
        guard let value = unmanaged?.takeRetainedValue() else { return nil }
        if let n = value as? NSNumber { return n.intValue }
        return nil
    }
}
```

If `kIOMainPortDefault` is unavailable, use `kIOMasterPortDefault`.

- [ ] **Step 4: Run tests**

Run: `swift test --filter PortDetectorTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Joy1/PortDetector.swift Tests/Joy1Tests/PortDetectorTests.swift
git commit -m "feat(joy1): detect HUEARM and refuse HUECAM"
```

---

### Task 5: JogEngine

**Files:**
- Create: `Sources/Joy1/JogEngine.swift`
- Create: `Tests/Joy1Tests/JogEngineTests.swift`

- [ ] **Step 1: Write failing jog tests**

```swift
import Testing
@testable import Joy1

struct JogEngineTests {
    @Test func holdXPlusEmitsStep() {
        var engine = JogEngine(speedMmPerSec: 10, speedDegPerSec: 10)
        engine.setHeld(.x, .pos, down: true)
        let steps = engine.tick(dt: 0.1)
        #expect(steps.count == 1)
        #expect(steps[0].axis == .x)
        #expect(abs(steps[0].delta - 1.0) < 0.0001)
        #expect(abs(steps[0].feedMmPerMin - 600) < 0.1)
    }

    @Test func releaseStopsStepsAndRequestsFlushAfterIdle() {
        var engine = JogEngine(speedMmPerSec: 10, speedDegPerSec: 10)
        engine.setHeld(.x, .pos, down: true)
        _ = engine.tick(dt: 0.1)
        engine.setHeld(.x, .pos, down: false)
        let immediate = engine.tick(dt: 0.1)
        #expect(immediate.isEmpty)
        #expect(engine.wantsFlush == false)
        _ = engine.tick(dt: 0.6)
        #expect(engine.wantsFlush == true)
        engine.didFlush()
        #expect(engine.wantsFlush == false)
    }

    @Test func twoAxesHeldEmitTwoSteps() {
        var engine = JogEngine(speedMmPerSec: 10, speedDegPerSec: 10)
        engine.setHeld(.x, .pos, down: true)
        engine.setHeld(.y, .neg, down: true)
        let steps = engine.tick(dt: 0.1)
        #expect(steps.count == 2)
        #expect(steps.contains(where: { $0.axis == .x && $0.delta > 0 }))
        #expect(steps.contains(where: { $0.axis == .y && $0.delta < 0 }))
    }

    @Test func stopClearsHolds() {
        var engine = JogEngine(speedMmPerSec: 10, speedDegPerSec: 10)
        engine.setHeld(.a, .pos, down: true)
        engine.clearAll()
        #expect(engine.tick(dt: 0.1).isEmpty)
    }
}
```

- [ ] **Step 2: Run to verify fail**

Run: `swift test --filter JogEngineTests`
Expected: FAIL.

- [ ] **Step 3: Implement JogEngine**

`Sources/Joy1/JogEngine.swift`:

```swift
public struct JogStep: Equatable, Sendable {
    public var axis: Axis
    public var delta: Double
    public var feedMmPerMin: Double
}

public struct JogEngine: Sendable {
    public var speedMmPerSec: Double
    public var speedDegPerSec: Double
    public private(set) var wantsFlush = false

    private var holds: [Axis: Sign] = [:]
    private var idleFor: Double = 0
    private var hadMotion = false

    public init(speedMmPerSec: Double, speedDegPerSec: Double) {
        self.speedMmPerSec = speedMmPerSec
        self.speedDegPerSec = speedDegPerSec
    }

    public mutating func setHeld(_ axis: Axis, _ sign: Sign, down: Bool) {
        if down {
            holds[axis] = sign
            idleFor = 0
            wantsFlush = false
        } else if holds[axis] == sign {
            holds[axis] = nil
        }
    }

    public mutating func clearAll() {
        holds.removeAll()
    }

    public mutating func didFlush() {
        wantsFlush = false
        hadMotion = false
        idleFor = 0
    }

    public mutating func tick(dt: Double) -> [JogStep] {
        if holds.isEmpty {
            if hadMotion {
                idleFor += dt
                if idleFor >= 0.6 {
                    wantsFlush = true
                }
            }
            return []
        }
        hadMotion = true
        idleFor = 0
        wantsFlush = false
        return holds.map { axis, sign in
            let speed = axis.isCartesian ? speedMmPerSec : speedDegPerSec
            let delta = speed * dt * Double(sign.rawValue)
            return JogStep(axis: axis, delta: delta, feedMmPerMin: speedMmPerSec * 60)
        }
    }
}
```

- [ ] **Step 4: Run tests**

Run: `swift test --filter JogEngineTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Joy1/JogEngine.swift Tests/Joy1Tests/JogEngineTests.swift
git commit -m "feat(joy1): add 60 Hz hold-to-jog engine"
```

---

### Task 6: PendantModel + PoseMonitor

**Files:**
- Create: `Sources/Joy1/PoseMonitor.swift`
- Create: `Sources/Joy1/PendantModel.swift`

- [ ] **Step 1: Write a model test with FakeSerial**

Add to `Tests/Joy1Tests/HuenitArmTests.swift` or create `Tests/Joy1Tests/PendantModelTests.swift`:

```swift
import Testing
@testable import Joy1

@MainActor
struct PendantModelTests {
    @Test func connectUpdatesPoseAndHoldSendsJog() async throws {
        let serial = FakeSerial()
        serial.replies = [
            "FIRMWARE_NAME:Marlin MACHINE_TYPE:FYSETC_E4\nok\n",
            "ok\n",
            "ok\n",
            "X:1 Y:2 Z:3\nok\n",
            "A:10 B:20 C:30\nok\n",
            "ok\n",
        ]
        let arm = HuenitArm(transport: serial)
        let model = PendantModel(arm: arm, detector: { [] })
        try await model.connect(path: "/dev/cu.usbserial-3120")
        #expect(model.isConnected)
        #expect(model.pose?.cartesian.x == 1)
        model.setHeld(.x, .pos, down: true)
        await model.tickJog(dt: 0.1)
        let written = await serial.written
        #expect(written.contains(where: { $0.hasPrefix("G1 X") }))
    }

    @Test func stopClearsHoldsAndSendsVacuumOff() async throws {
        let serial = FakeSerial()
        serial.replies = Array(repeating: "ok\n", count: 20)
        let arm = HuenitArm(transport: serial)
        await arm.forceConnectedForTests()
        let model = PendantModel(arm: arm, detector: { [] })
        model.isConnected = true
        model.setHeld(.x, .pos, down: true)
        await model.stop()
        #expect(model.held.isEmpty)
        let written = await serial.written
        #expect(written.contains("M1400 A0"))
    }
}
```

- [ ] **Step 2: Run to verify fail**

Run: `swift test --filter PendantModelTests`
Expected: FAIL.

- [ ] **Step 3: Implement model + monitor**

`Sources/Joy1/PoseMonitor.swift`:

```swift
public actor PoseMonitor {
    private let arm: HuenitArm
    private var task: Task<Void, Never>?

    public init(arm: HuenitArm) {
        self.arm = arm
    }

    public func start(onUpdate: @escaping @Sendable (Result<ArmPose, Error>) async -> Void) {
        task?.cancel()
        task = Task {
            while !Task.isCancelled {
                do {
                    let pose = try await arm.queryPose()
                    await onUpdate(.success(pose))
                } catch {
                    await onUpdate(.failure(error))
                }
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }

    public func stop() {
        task?.cancel()
        task = nil
    }
}
```

`Sources/Joy1/PendantModel.swift`:

```swift
import Foundation
import Observation

@MainActor
@Observable
public final class PendantModel {
    public var isConnected = false
    public var portPath: String?
    public var lastError: String?
    public var pose: ArmPose?
    public var vacuumOn = false
    public var speedMmPerSec: Double = 20
    public var held: [Axis: Sign] = [:]
    public var candidates: [SerialCandidate] = []

    public let arm: HuenitArm
    private var engine: JogEngine
    private let detector: @Sendable () -> [SerialCandidate]
    private var monitor: PoseMonitor?

    public init(arm: HuenitArm, detector: @escaping @Sendable () -> [SerialCandidate]) {
        self.arm = arm
        self.detector = detector
        self.engine = JogEngine(speedMmPerSec: 20, speedDegPerSec: 20)
    }

    public func refreshPorts() {
        candidates = detector()
        portPath = PortDetector.pickArm(from: candidates)?.path
    }

    public func connect(path: String) async throws {
        lastError = nil
        let live = HuenitArm(transport: SerialPort(path: path))
        // Tests pass a prebuilt FakeSerial arm; only replace when path is real and arm not already fake-connected.
        try await arm.connect()
        isConnected = true
        portPath = path
        do {
            pose = try await arm.queryPose()
        } catch {
            lastError = String(describing: error)
        }
        let monitor = PoseMonitor(arm: arm)
        self.monitor = monitor
        await monitor.start { [weak self] result in
            await self?.applyPose(result)
        }
    }

    public func disconnect() async {
        await stop()
        await monitor?.stop()
        await arm.disconnect()
        isConnected = false
    }

    public func applyPose(_ result: Result<ArmPose, Error>) {
        switch result {
        case .success(let pose):
            self.pose = pose
        case .failure(let error):
            if var current = pose {
                current.isStale = true
                pose = current
            }
            lastError = String(describing: error)
            if case ArmError.timeout = error {
                isConnected = false
            }
        }
    }

    public func setHeld(_ axis: Axis, _ sign: Sign, down: Bool) {
        guard isConnected else { return }
        if down { held[axis] = sign } else { held[axis] = nil }
        engine.setHeld(axis, sign, down: down)
    }

    public func setSpeed(_ value: Double) {
        speedMmPerSec = value
        engine.speedMmPerSec = value
        engine.speedDegPerSec = value
    }

    public func setVacuum(_ on: Bool) async {
        do {
            try await arm.setVacuum(on)
            vacuumOn = on
        } catch {
            lastError = String(describing: error)
        }
    }

    public func tickJog(dt: Double) async {
        engine.speedMmPerSec = speedMmPerSec
        engine.speedDegPerSec = speedMmPerSec
        let steps = engine.tick(dt: dt)
        for step in steps {
            do {
                if step.axis.isCartesian {
                    try await arm.jogCartesian(axis: step.axis, deltaMm: step.delta, feedMmPerMin: step.feedMmPerMin)
                } else {
                    try await arm.jogJoint(axis: step.axis, deltaDeg: step.delta, feedMmPerMin: step.feedMmPerMin)
                }
            } catch {
                lastError = String(describing: error)
                engine.clearAll()
                held.removeAll()
                return
            }
        }
        if engine.wantsFlush {
            try? await arm.flush()
            engine.didFlush()
        }
    }

    public func startJogLoop() {
        Task { [weak self] in
            let period = 1.0 / 60.0
            while let self, self.isConnected {
                let t0 = ContinuousClock.now
                await self.tickJog(dt: period)
                let elapsed = (ContinuousClock.now - t0)
                let ns = elapsed.components.seconds * 1_000_000_000 + elapsed.components.attoseconds / 1_000_000_000
                let used = Double(ns) / 1_000_000_000
                let remaining = period - used
                if remaining > 0 {
                    try? await Task.sleep(for: .seconds(remaining))
                }
            }
        }
    }

    public func stop() async {
        engine.clearAll()
        held.removeAll()
        vacuumOn = false
        try? await arm.stop()
    }
}
```

`connect(path:)` in tests uses the injected `arm` (already FakeSerial). Do **not** construct a second `HuenitArm` from `SerialPort` inside `connect` when tests pass a fake. Implementation: `connect(path:)` always uses the injected `arm`. The app constructs `PendantModel(arm: HuenitArm(transport: SerialPort(path: picked)), ...)`. `connect(path:)` only calls `arm.connect()`; the app rebuilds the model when the port changes, or `PendantModel` is created after pick.

Simplify `connect(path:)` to only `try await arm.connect()` plus pose + monitor. The unused `live` local in the snippet above must not be shipped.

- [ ] **Step 4: Run tests**

Run: `swift test --filter PendantModelTests`
Expected: PASS. If `connect` double-opens, fix as above.

- [ ] **Step 5: Commit**

```bash
git add Sources/Joy1/PoseMonitor.swift Sources/Joy1/PendantModel.swift Tests/Joy1Tests/PendantModelTests.swift
git commit -m "feat(joy1): add pendant model and pose monitor"
```

---

### Task 7: SwiftUI pendant UI

**Files:**
- Modify: `Sources/Joy1App/Joy1App.swift`
- Create: `Sources/Joy1App/ContentView.swift`
- Create: `Sources/Joy1App/ConnectionBar.swift`
- Create: `Sources/Joy1App/CartesianPad.swift`
- Create: `Sources/Joy1App/JointPad.swift`
- Create: `Sources/Joy1App/SpeedSlider.swift`
- Create: `Sources/Joy1App/VacuumToggle.swift`
- Create: `Sources/Joy1App/PoseHUD.swift`
- Create: `Sources/Joy1App/StopButton.swift`
- Create: `Sources/Joy1App/HoldButton.swift`

- [ ] **Step 1: Implement HoldButton and pads**

`Sources/Joy1App/HoldButton.swift`:

```swift
import SwiftUI
import Joy1

struct HoldButton: View {
    let title: String
    let axis: Axis
    let sign: Sign
    let model: PendantModel

    var body: some View {
        let down = model.held[axis] == sign
        Text(title)
            .frame(minWidth: 56, minHeight: 40)
            .padding(.horizontal, 8)
            .background(down ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in model.setHeld(axis, sign, down: true) }
                    .onEnded { _ in model.setHeld(axis, sign, down: false) }
            )
            .accessibilityLabel(title)
    }
}
```

`Sources/Joy1App/CartesianPad.swift`:

```swift
import SwiftUI
import Joy1

struct CartesianPad: View {
    let model: PendantModel

    var body: some View {
        VStack(spacing: 8) {
            Text("Task space").font(.headline)
            HStack { HoldButton(title: "Y+", axis: .y, sign: .pos, model: model) }
            HStack {
                HoldButton(title: "X−", axis: .x, sign: .neg, model: model)
                HoldButton(title: "X+", axis: .x, sign: .pos, model: model)
            }
            HStack { HoldButton(title: "Y−", axis: .y, sign: .neg, model: model) }
            HStack {
                HoldButton(title: "Z+", axis: .z, sign: .pos, model: model)
                HoldButton(title: "Z−", axis: .z, sign: .neg, model: model)
            }
        }
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Cartesian jog")
    }
}
```

`Sources/Joy1App/JointPad.swift`:

```swift
import SwiftUI
import Joy1

struct JointPad: View {
    let model: PendantModel

    var body: some View {
        VStack(spacing: 8) {
            Text("Joint space").font(.headline)
            ForEach([Axis.a, .b, .c], id: \.self) { axis in
                HStack {
                    HoldButton(title: "\(axis.gcodeLetter)−", axis: axis, sign: .neg, model: model)
                    HoldButton(title: "\(axis.gcodeLetter)+", axis: axis, sign: .pos, model: model)
                }
            }
        }
        .padding()
        .accessibilityLabel("Joint jog")
    }
}
```

`Sources/Joy1App/SpeedSlider.swift`:

```swift
import SwiftUI
import Joy1

struct SpeedSlider: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Speed \(model.speedMmPerSec, specifier: "%.0f") mm/s  ·  °/s")
            Slider(value: Binding(
                get: { model.speedMmPerSec },
                set: { model.setSpeed($0) }
            ), in: 1...80, step: 1)
        }
        .padding()
    }
}
```

`Sources/Joy1App/VacuumToggle.swift`:

```swift
import SwiftUI
import Joy1

struct VacuumToggle: View {
    let model: PendantModel

    var body: some View {
        Toggle("Vacuum", isOn: Binding(
            get: { model.vacuumOn },
            set: { on in Task { await model.setVacuum(on) } }
        ))
        .padding()
        .disabled(!model.isConnected)
    }
}
```

`Sources/Joy1App/PoseHUD.swift`:

```swift
import SwiftUI
import Joy1

struct PoseHUD: View {
    let pose: ArmPose?

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 4) {
            GridRow {
                Text("Task").bold()
                Text(format(pose?.cartesian.x, "X"))
                Text(format(pose?.cartesian.y, "Y"))
                Text(format(pose?.cartesian.z, "Z"))
            }
            GridRow {
                Text("Joints").bold()
                Text(format(pose?.joints.a, "A"))
                Text(format(pose?.joints.b, "B"))
                Text(format(pose?.joints.c, "C"))
            }
        }
        .monospacedDigit()
        .foregroundStyle(pose?.isStale == true ? .secondary : .primary)
        .padding()
        .accessibilityLabel(poseLabel)
    }

    private func format(_ value: Double?, _ name: String) -> String {
        guard let value else { return "\(name): ----" }
        return String(format: "%@: %+.2f", name, value)
    }

    private var poseLabel: String {
        guard let pose else { return "No pose" }
        return "Tip X \(pose.cartesian.x) Y \(pose.cartesian.y) Z \(pose.cartesian.z), joints A \(pose.joints.a) B \(pose.joints.b) C \(pose.joints.c)"
    }
}
```

`Sources/Joy1App/StopButton.swift`:

```swift
import SwiftUI
import Joy1

struct StopButton: View {
    let model: PendantModel

    var body: some View {
        Button("Stop", role: .destructive) {
            Task { await model.stop() }
        }
        .keyboardShortcut(.cancelAction)
        .controlSize(.large)
        .padding()
    }
}
```

`Sources/Joy1App/ConnectionBar.swift`:

```swift
import SwiftUI
import Joy1

struct ConnectionBar: View {
    let model: PendantModel

    var body: some View {
        HStack {
            Text(model.portPath ?? "No HUEARM")
                .monospaced()
            Button(model.isConnected ? "Disconnect" : "Connect") {
                Task {
                    if model.isConnected {
                        await model.disconnect()
                    } else if let path = model.portPath {
                        do { try await model.connect(path: path) }
                        catch { model.lastError = String(describing: error) }
                    }
                }
            }
            .disabled(model.portPath == nil && !model.isConnected)
            Button("Rescan") { model.refreshPorts() }
            if let error = model.lastError {
                Text(error).foregroundStyle(.red).lineLimit(2)
            }
        }
        .padding()
    }
}
```

`Sources/Joy1App/ContentView.swift`:

```swift
import SwiftUI
import Joy1

struct ContentView: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ConnectionBar(model: model)
            PoseHUD(pose: model.pose)
            HStack(alignment: .top) {
                CartesianPad(model: model)
                JointPad(model: model)
                VStack {
                    SpeedSlider(model: model)
                    VacuumToggle(model: model)
                    StopButton(model: model)
                }
            }
        }
        .padding()
        .frame(minWidth: 720, minHeight: 420)
        .onAppear {
            model.refreshPorts()
            model.startJogLoop()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            Task { await model.stop() }
        }
    }
}
```

Need `import AppKit` for `NSApplication` in ContentView.

`Sources/Joy1App/Joy1App.swift`:

```swift
import SwiftUI
import Joy1

@main
struct Joy1App: App {
    @State private var model = PendantModel(
        arm: HuenitArm(transport: SerialPort(path: "/dev/cu.usbserial-3120")),
        detector: { PortDetector.scan() }
    )

    var body: some Scene {
        WindowGroup("HUENIT Joy1") {
            ContentView(model: model)
        }
    }
}
```

`refreshPorts()` overwrites `portPath` from the detector. The initial SerialPort path is only used after Connect if the detector finds the same device. After Rescan, if the path differs from the arm’s transport, reconstruct: on Connect, if `model.portPath !=` the SerialPort path, the app should build a new `HuenitArm(transport: SerialPort(path:))`. Cleaner: `PendantModel.connect(path:)` creates the `SerialPort` itself when the injected transport is a live port factory.

Add to `PendantModel`:

```swift
public var makeTransport: @Sendable (String) -> any SerialTransport = { SerialPort(path: $0) }
```

And `connect(path:)`:

```swift
public func connect(path: String) async throws {
    lastError = nil
    // Tests inject FakeSerial via arm already connected to that fake.
    // App sets makeTransport. For tests, skip rebuilding.
    try await arm.connect()
    ...
}
```

Keep tests working: they call `connect(path:)` on a model whose `arm` already wraps FakeSerial. `arm.connect()` opens the fake. Do not swap transport in tests.

For the app, `Joy1App` should construct the model **after** scan, or `connect(path:)` should be:

```swift
public func connect(path: String) async throws {
    lastError = nil
    if !usesInjectedTransport {
        // cannot rebind actor transport; app creates arm with correct path in refreshPorts
    }
    try await arm.connect()
}
```

Simplest working app approach: `refreshPorts` + Connect only uses the path if it matches the `SerialPort` created at launch after a scan in `init`:

```swift
@main
struct Joy1App: App {
    @State private var model: PendantModel = {
        let ports = PortDetector.scan()
        let path = PortDetector.pickArm(from: ports)?.path ?? "/dev/cu.usbserial-3120"
        return PendantModel(arm: HuenitArm(transport: SerialPort(path: path)), detector: { PortDetector.scan() })
    }()
}
```

- [ ] **Step 2: Build the app**

Run: `swift build --product Joy1App`
Expected: success.

- [ ] **Step 3: Commit**

```bash
git add Sources/Joy1App Sources/Joy1/PendantModel.swift
git commit -m "feat(joy1): add macOS pendant UI"
```

---

### Task 8: Live hardware tests + joint command lock

**Files:**
- Create: `Tests/Joy1Tests/LiveSupport.swift`
- Create: `Tests/Joy1Tests/LiveArmTests.swift`
- Modify: `Sources/Joy1/HuenitArm.swift` (set `jointCommandFormat` from probe)

- [ ] **Step 1: Write live support + read-only tests first**

`Tests/Joy1Tests/LiveSupport.swift`:

```swift
import Foundation
@testable import Joy1

enum LiveArm {
    static func open() async throws -> HuenitArm {
        let ports = PortDetector.scan()
        guard let armPort = PortDetector.pickArm(from: ports) else {
            throw ArmError.connectFailed("no HUEARM")
        }
        if armPort.isCamera { throw ArmError.connectFailed("refused camera") }
        let arm = HuenitArm(transport: SerialPort(path: armPort.path))
        try await arm.connect()
        return arm
    }
}
```

`Tests/Joy1Tests/LiveArmTests.swift`:

```swift
import Testing
import Foundation
@testable import Joy1

struct LiveArmTests {
    @Test func identityAndDetector() async throws {
        let ports = PortDetector.scan()
        let armPort = try #require(PortDetector.pickArm(from: ports), "HUEARM not plugged in — skip by failing require only when we want hard fail")
        #expect(armPort.isArm)
        #expect(!armPort.isCamera)
        #expect(ports.filter(\.isCamera).allSatisfy { PortDetector.pickArm(from: [$0]) == nil })

        let arm = try await LiveArm.open()
        defer { Task { await arm.disconnect() } }
        let text = try await arm.send("M115")
        #expect(FirmwareIdentity.parse(text).isHuenitMarlin)
    }

    @Test func poseConsistency() async throws {
        let arm = try await LiveArm.open()
        defer { Task { await arm.disconnect() } }
        let a = try await arm.queryPose()
        try await Task.sleep(for: .milliseconds(200))
        let b = try await arm.queryPose()
        #expect(abs(a.cartesian.x - b.cartesian.x) < 0.5)
        #expect(abs(a.cartesian.y - b.cartesian.y) < 0.5)
        #expect(abs(a.cartesian.z - b.cartesian.z) < 0.5)
        #expect(abs(a.joints.a - b.joints.a) < 1.0)
    }
}
```

If the arm is unplugged, `#require` fails the test. Spec says skip if absent. Use:

```swift
guard let armPort = PortDetector.pickArm(from: PortDetector.scan()) else {
    try await skipNoArm()
    return
}

func skipNoArm() async throws {
    throw CancellationError() // better:
}
```

Swift Testing skip:

```swift
try #require(PortDetector.pickArm(from: PortDetector.scan()) != nil)
```

To skip instead of fail, wrap:

```swift
guard PortDetector.pickArm(from: PortDetector.scan()) != nil else {
    print("SKIP: no HUEARM")
    return
}
```

Use that guard at the top of every live test.

- [ ] **Step 2: Run read-only live tests**

Run: `swift test --filter LiveArmTests`
Expected: PASS with the arm plugged in. HUD numbers should match a manual `M1008`.

- [ ] **Step 3: Add motion, vacuum, stop, speed tests**

Append to `LiveArmTests.swift`:

```swift
    @Test func cartesianJogMeasuresAndUndoes() async throws {
        guard PortDetector.pickArm(from: PortDetector.scan()) != nil else { return }
        let arm = try await LiveArm.open()
        defer { Task { await arm.disconnect() } }
        for axis in [Axis.x, .y, .z] {
            let before = try await arm.queryPose()
            try await arm.jogCartesian(axis: axis, deltaMm: 3, feedMmPerMin: 600)
            try await arm.flush()
            let mid = try await arm.queryPose()
            let delta = mid.cartesian.value(for: axis) - before.cartesian.value(for: axis)
            #expect(abs(delta - 3) < 1.5)
            try await arm.jogCartesian(axis: axis, deltaMm: -3, feedMmPerMin: 600)
            try await arm.flush()
        }
    }

    @Test func vacuumOk() async throws {
        guard PortDetector.pickArm(from: PortDetector.scan()) != nil else { return }
        let arm = try await LiveArm.open()
        defer { Task { await arm.disconnect() } }
        try await arm.setVacuum(true)
        try await arm.setVacuum(false)
    }

    @Test func stopSettles() async throws {
        guard PortDetector.pickArm(from: PortDetector.scan()) != nil else { return }
        let arm = try await LiveArm.open()
        defer { Task { await arm.disconnect() } }
        try await arm.jogCartesian(axis: .x, deltaMm: 1, feedMmPerMin: 300)
        try await arm.stop()
        let a = try await arm.queryPose()
        try await Task.sleep(for: .milliseconds(300))
        let b = try await arm.queryPose()
        #expect(abs(a.cartesian.x - b.cartesian.x) < 0.4)
    }

    @Test func fasterFeedTakesLessTime() async throws {
        guard PortDetector.pickArm(from: PortDetector.scan()) != nil else { return }
        let arm = try await LiveArm.open()
        defer { Task { await arm.disconnect() } }
        func timed(_ feed: Double) async throws -> Double {
            let t0 = ContinuousClock.now
            try await arm.jogCartesian(axis: .y, deltaMm: 4, feedMmPerMin: feed)
            try await arm.flush()
            try await arm.jogCartesian(axis: .y, deltaMm: -4, feedMmPerMin: feed)
            try await arm.flush()
            return (ContinuousClock.now - t0) / Duration.seconds(1)
        }
        // Duration division may not exist — use components instead if needed.
        let slow = try await timed(300)
        let fast = try await timed(1800)
        #expect(fast < slow)
    }
```

Fix duration math if it does not compile: capture `CFAbsoluteTimeGetCurrent()` around each pair.

- [ ] **Step 4: Probe joint increment on the live arm**

Write a one-off in the live test (or a `swift test --filter jointProbe` test printed to stdout):

Try, one at a time, a **+2°** intent, then undo, reading `M1008 A2` after `M400`:

1. `G91` already set. `G1 A2 F300`
2. `G1 I2 F300`
3. `M1007 A2`
4. `M114` after each to log firmware echo

Keep the first command that changes joint A by more than 0.5° and does not throw. Set

```swift
await arm.setJointCommandFormat("<working format>")
```

and persist the working format as the default in `HuenitArm.jointCommandFormat`.

Then add:

```swift
    @Test func jointJogMeasuresAndUndoes() async throws {
        guard PortDetector.pickArm(from: PortDetector.scan()) != nil else { return }
        let arm = try await LiveArm.open()
        defer { Task { await arm.disconnect() } }
        for axis in [Axis.a, .b, .c] {
            let before = try await arm.queryPose()
            try await arm.jogJoint(axis: axis, deltaDeg: 2, feedMmPerMin: 300)
            try await arm.flush()
            let mid = try await arm.queryPose()
            let delta = mid.joints.value(for: axis) - before.joints.value(for: axis)
            #expect(abs(delta) > 0.4, "joint \(axis) did not move; format=\(await arm.jointCommandFormat)")
            try await arm.jogJoint(axis: axis, deltaDeg: -2, feedMmPerMin: 300)
            try await arm.flush()
        }
    }
```

If no joint G-code works, stop and record the firmware replies in the test output; do not invent motion via unsafe Cartesian coupling.

- [ ] **Step 5: Run the full live suite**

Run: `swift test --filter LiveArmTests`
Expected: all live tests PASS on the desk arm. Arm returns near the start pose.

- [ ] **Step 6: Commit**

```bash
git add Tests/Joy1Tests/LiveSupport.swift Tests/Joy1Tests/LiveArmTests.swift Sources/Joy1/HuenitArm.swift
git commit -m "test(joy1): hardware-in-the-loop identity, jog, vacuum, stop"
```

---

### Task 9: Manual app check + unplug

**Files:** none required unless a bug fix.

- [ ] **Step 1: Run the app against the arm**

Run: `swift run Joy1App`

Manual script:

1. Window shows HUEARM path. Connect. HUD updates (~2 Hz).
2. Hold X+ briefly (~3 mm), release. HUD X changes. Joints change (firmware IK).
3. Hold A+ briefly. Joint A changes. XYZ updates.
4. Toggle vacuum on, then off (listen for pump).
5. Hold X+, hit Stop. Motion ends, vacuum off.
6. Leave the window (app resigns active) while holding a pad — motion stops.
7. Disconnect. Pads do nothing.

- [ ] **Step 2: Unplug test**

With the app connected and idle, unplug the arm USB. Next HUD poll should mark pose stale / disconnected and must not crash. Replug + Rescan + Connect works.

- [ ] **Step 3: Commit any fixes**

```bash
git add -u Sources Tests
git commit -m "fix(joy1): pendant behaviour found on desk"
```

Only commit if there are fixes.

---

## Self-review (plan vs spec)

| Spec item | Task |
|---|---|
| macOS SwiftUI pendant | 1, 7 |
| Hold-to-jog XYZ + ABC + speed | 5, 6, 7 |
| Vacuum M1400 | 3, 7, 8 |
| Firmware IK G1, no app solver | 3, 7 |
| Live HUD M1008 both spaces | 3, 6, 7 |
| Port detect HUEARM, refuse HUECAM | 4, 8 |
| Never G28 | 3 |
| Stop / resign active / no auto-move | 6, 7 |
| Serial actor serialization | 2, 3 |
| HIL identity, pose, jog measure, vacuum, stop, speed | 8 |
| Unplug manual | 9 |
| Joint G-code locked on desk | 8 step 4 |

No TBD left except the joint format string, which Task 8 step 4 locks on hardware before the joint test is required to pass.
