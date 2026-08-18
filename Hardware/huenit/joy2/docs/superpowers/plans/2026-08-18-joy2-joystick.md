# Joy2 Speedlink Stick Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a macOS Lab-style pendant in `Hardware/huenit/joy2` that jogs the HUENIT arm from a Speedlink Competition Pro Extra and lights the same pad cells the stick is using, without sending anything that can wreck the arm.

**Architecture:** `Joy2` is a Swift library with no Joy1 or serial dependency (HID sample, mapper, guard, highlights). `Joy2App` depends on `Joy2` and `Joy1` (`../joy1`). `PilotModel` wraps Joy1 `PendantModel` for arm I/O and runs mapper → guard → pendant. Views copy the Joy1 Lab layout and take a `Set<PadCell>` for pressed styling.

**Tech Stack:** macOS 15+, Swift 6, SwiftUI, Swift Testing, IOKit HID. Joy1 local package. No third-party packages.

**Spec:** `docs/superpowers/specs/2026-08-18-joy2-joystick-design.md`

---

## File map

```
Package.swift
Sources/Joy2/PadCell.swift
Sources/Joy2/JoystickSample.swift
Sources/Joy2/PilotIntent.swift
Sources/Joy2/HighlightSet.swift
Sources/Joy2/JoystickMapper.swift
Sources/Joy2/IntentGuard.swift
Sources/Joy2/JoystickSourcing.swift
Sources/Joy2/JoystickDevice.swift
Sources/Joy2App/App/Joy2App.entitlements
Sources/Joy2App/App/Joy2App.swift
Sources/Joy2App/Pilot/PilotModel.swift
Sources/Joy2App/Theme/PendantChrome.swift
Sources/Joy2App/Views/ContentView.swift
Sources/Joy2App/Views/LabPad.swift
Sources/Joy2App/Views/ConnectionBar.swift
Sources/Joy2App/Views/ModuleCard.swift
Sources/Joy2App/Views/PoseHUD.swift
Sources/Joy2App/Views/StopButton.swift
Sources/Joy2App/Views/SpeedSlider.swift
Sources/Joy2App/Views/VacuumToggle.swift
Sources/Joy2App/Views/HoldButton.swift
Tests/Joy2Tests/MapperTests.swift
Tests/Joy2Tests/GuardTests.swift
Tests/Joy2Tests/HighlightTests.swift
Tests/Joy2Tests/Live/LiveStickTests.swift
README.md
```

Working directory for every command: `/Volumes/AIWork/code/littlethings/Hardware/huenit/joy2`

Do not edit Joy1App. Do not send `G28`. Do not invent a workspace box. Do not send `M1111`–`M1114` or `M1401`. Suction is `pendant.setVacuum` only (Joy1 already sends `M1400`).

---

### Task 1: Package + mapper types

**Files:**
- Create: `Package.swift`
- Create: `Sources/Joy2/PadCell.swift`
- Create: `Sources/Joy2/JoystickSample.swift`
- Create: `Sources/Joy2/PilotIntent.swift`
- Create: `Sources/Joy2/HighlightSet.swift`
- Create: `Tests/Joy2Tests/MapperTests.swift`

- [ ] **Step 1: Write failing mapper tests that need the types**

Create `Tests/Joy2Tests/MapperTests.swift`:

```swift
import Testing
@testable import Joy2

struct MapperTests {
    @Test func stickRightIsXPlusOnly() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.e, leftFire: false, rightFire: false))
        #expect(result.intent == .jog(JogVector(dx: 1, dy: 0, dz: 0, de: 0)))
        #expect(result.highlights.cells == [.xPlus])
    }

    @Test func stickAwayIsYPlus() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.n, leftFire: false, rightFire: false))
        #expect(result.intent == .jog(JogVector(dx: 0, dy: 1, dz: 0, de: 0)))
        #expect(result.highlights.cells == [.yPlus])
    }

    @Test func diagonalNorthEastHighlightsBoth() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.ne, leftFire: false, rightFire: false))
        #expect(result.intent == .jog(JogVector(dx: 1, dy: 1, dz: 0, de: 0)))
        #expect(result.highlights.cells == [.xPlus, .yPlus, .xyNE])
    }

    @Test func leftFireForwardIsZPlus() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.n, leftFire: true, rightFire: false))
        #expect(result.intent == .jog(JogVector(dx: 0, dy: 0, dz: 1, de: 0)))
        #expect(result.highlights.cells == [.zPlus, .zAngleMode])
    }

    @Test func leftFireRightIsEPlus() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.e, leftFire: true, rightFire: false))
        #expect(result.intent == .jog(JogVector(dx: 0, dy: 0, dz: 0, de: 1)))
        #expect(result.highlights.cells == [.ePlus, .zAngleMode])
    }

    @Test func centerClearsJogHighlights() {
        var mapper = JoystickMapper()
        _ = mapper.map(.deflected(.e, leftFire: false, rightFire: false))
        let result = mapper.map(.idle)
        #expect(result.intent == .none)
        #expect(result.highlights.cells.isEmpty)
    }

    @Test func leftFireHeldAtCenterIsModeOnly() {
        var mapper = JoystickMapper()
        let result = mapper.map(JoystickSample(connected: true, direction: .center, leftFire: true, rightFire: false))
        #expect(result.intent == .none)
        #expect(result.highlights.cells == [.zAngleMode])
    }

    @Test func rightFireIsEdgeToggle() {
        var mapper = JoystickMapper()
        let down = mapper.map(JoystickSample(connected: true, direction: .center, leftFire: false, rightFire: true))
        #expect(down.intent == .toggleVacuum)
        #expect(down.highlights.cells.contains(.suction))
        let held = mapper.map(JoystickSample(connected: true, direction: .center, leftFire: false, rightFire: true))
        #expect(held.intent == .none)
        let up = mapper.map(.idle)
        #expect(up.intent == .none)
    }

    @Test func bothFiresDoNotInventHomeOrStop() {
        var mapper = JoystickMapper()
        let result = mapper.map(JoystickSample(connected: true, direction: .center, leftFire: true, rightFire: true))
        #expect(result.intent == .toggleVacuum)
        #expect(!result.highlights.cells.contains { cell in
            switch cell {
            case .xPlus, .xMinus, .yPlus, .yMinus, .xyNE, .xyNW, .xySE, .xySW,
                 .zPlus, .zMinus, .ePlus, .eMinus, .suction, .zAngleMode:
                return false
            }
        })
        if case .stop = result.intent { Issue.record("stop is not a stick gesture") }
    }

    @Test func disconnectedSampleIsNone() {
        var mapper = JoystickMapper()
        let result = mapper.map(JoystickSample(connected: false, direction: .e, leftFire: true, rightFire: true))
        #expect(result.intent == .none)
        #expect(result.highlights.cells.isEmpty)
    }
}

extension JoystickSample {
    static var idle: JoystickSample {
        JoystickSample(connected: true, direction: .center, leftFire: false, rightFire: false)
    }

    static func deflected(_ direction: StickDirection, leftFire: Bool, rightFire: Bool) -> JoystickSample {
        JoystickSample(connected: true, direction: direction, leftFire: leftFire, rightFire: rightFire)
    }
}
```

- [ ] **Step 2: Add Package.swift so the test target exists**

`Package.swift`:

```swift
// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Joy2",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "Joy2", targets: ["Joy2"]),
        .executable(name: "Joy2App", targets: ["Joy2App"]),
    ],
    dependencies: [
        .package(path: "../joy1"),
    ],
    targets: [
        .target(name: "Joy2"),
        .executableTarget(
            name: "Joy2App",
            dependencies: [
                "Joy2",
                .product(name: "Joy1", package: "joy1"),
            ],
            exclude: ["App/Joy2App.entitlements"]
        ),
        .testTarget(name: "Joy2Tests", dependencies: ["Joy2"]),
    ]
)
```

Create `Sources/Joy2App/App/Joy2App.swift` so the executable target is valid:

```swift
import SwiftUI

@main
struct Joy2App: App {
    var body: some Scene {
        WindowGroup("Joy2") {
            Text("Joy2")
        }
    }
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `swift test --filter MapperTests`
Expected: FAIL because `JoystickMapper` / types are missing.

- [ ] **Step 4: Add the types (mapper still missing is OK if types compile; add a stub mapper that fails tests)**

`Sources/Joy2/PadCell.swift`:

```swift
public enum PadCell: String, Equatable, Sendable, Hashable, CaseIterable {
    case xPlus, xMinus, yPlus, yMinus
    case xyNE, xyNW, xySE, xySW
    case zPlus, zMinus, ePlus, eMinus
    case suction, zAngleMode
}
```

`Sources/Joy2/JoystickSample.swift`:

```swift
public enum StickDirection: Equatable, Sendable {
    case center, n, ne, e, se, s, sw, w, nw
}

public struct JoystickSample: Equatable, Sendable {
    public var connected: Bool
    public var direction: StickDirection
    public var leftFire: Bool
    public var rightFire: Bool

    public init(connected: Bool, direction: StickDirection, leftFire: Bool, rightFire: Bool) {
        self.connected = connected
        self.direction = direction
        self.leftFire = leftFire
        self.rightFire = rightFire
    }
}
```

`Sources/Joy2/PilotIntent.swift`:

```swift
public struct JogVector: Equatable, Sendable {
    public var dx: Int
    public var dy: Int
    public var dz: Int
    public var de: Int

    public init(dx: Int, dy: Int, dz: Int, de: Int) {
        self.dx = dx
        self.dy = dy
        self.dz = dz
        self.de = de
    }

    public var isZero: Bool { dx == 0 && dy == 0 && dz == 0 && de == 0 }
}

public enum PilotIntent: Equatable, Sendable {
    case none
    case jog(JogVector)
    case toggleVacuum
    case stop
}
```

`Sources/Joy2/HighlightSet.swift`:

```swift
public struct HighlightSet: Equatable, Sendable {
    public var cells: Set<PadCell>

    public init(_ cells: Set<PadCell> = []) {
        self.cells = cells
    }

    public func contains(_ cell: PadCell) -> Bool { cells.contains(cell) }
}
```

`Sources/Joy2/JoystickMapper.swift` (stub):

```swift
public struct JoystickMapper: Sendable {
    public init() {}

    public mutating func map(_ sample: JoystickSample) -> (intent: PilotIntent, highlights: HighlightSet) {
        (intent: .none, highlights: HighlightSet())
    }
}
```

- [ ] **Step 5: Run tests — they compile and fail on `#expect`**

Run: `swift test --filter MapperTests`
Expected: FAIL on `stickRightIsXPlusOnly` (intent is `.none`).

- [ ] **Step 6: Commit**

```bash
git add Package.swift Sources/Joy2 Sources/Joy2App/App/Joy2App.swift Tests/Joy2Tests/MapperTests.swift
git commit -m "test(joy2): add mapper cases and core stick types"
```

---

### Task 2: Implement JoystickMapper

**Files:**
- Modify: `Sources/Joy2/JoystickMapper.swift`
- Test: `Tests/Joy2Tests/MapperTests.swift`
- Test: `Tests/Joy2Tests/HighlightTests.swift`

- [ ] **Step 1: Write the mapper**

Replace `Sources/Joy2/JoystickMapper.swift`:

```swift
public struct JoystickMapper: Sendable {
    private var previousRightFire = false

    public init() {}

    public mutating func map(_ sample: JoystickSample) -> (intent: PilotIntent, highlights: HighlightSet) {
        guard sample.connected else {
            previousRightFire = false
            return (.none, HighlightSet())
        }

        var cells = Set<PadCell>()
        var intent: PilotIntent = .none

        if sample.leftFire {
            cells.insert(.zAngleMode)
        }

        let risingRight = sample.rightFire && !previousRightFire
        previousRightFire = sample.rightFire
        if sample.rightFire {
            cells.insert(.suction)
        }
        if risingRight {
            intent = .toggleVacuum
        }

        let vector = sample.leftFire ? zAngleVector(sample.direction) : xyVector(sample.direction)
        if !vector.isZero {
            if risingRight == false {
                intent = .jog(vector)
            } else {
                intent = .toggleVacuum
            }
            cells.formUnion(highlights(for: vector, zMode: sample.leftFire))
        }

        return (intent, HighlightSet(cells))
    }

    private func xyVector(_ d: StickDirection) -> JogVector {
        switch d {
        case .center: JogVector(dx: 0, dy: 0, dz: 0, de: 0)
        case .n: JogVector(dx: 0, dy: 1, dz: 0, de: 0)
        case .ne: JogVector(dx: 1, dy: 1, dz: 0, de: 0)
        case .e: JogVector(dx: 1, dy: 0, dz: 0, de: 0)
        case .se: JogVector(dx: 1, dy: -1, dz: 0, de: 0)
        case .s: JogVector(dx: 0, dy: -1, dz: 0, de: 0)
        case .sw: JogVector(dx: -1, dy: -1, dz: 0, de: 0)
        case .w: JogVector(dx: -1, dy: 0, dz: 0, de: 0)
        case .nw: JogVector(dx: -1, dy: 1, dz: 0, de: 0)
        }
    }

    private func zAngleVector(_ d: StickDirection) -> JogVector {
        switch d {
        case .center: JogVector(dx: 0, dy: 0, dz: 0, de: 0)
        case .n: JogVector(dx: 0, dy: 0, dz: 1, de: 0)
        case .s: JogVector(dx: 0, dy: 0, dz: -1, de: 0)
        case .e: JogVector(dx: 0, dy: 0, dz: 0, de: 1)
        case .w: JogVector(dx: 0, dy: 0, dz: 0, de: -1)
        case .ne: JogVector(dx: 0, dy: 0, dz: 1, de: 1)
        case .nw: JogVector(dx: 0, dy: 0, dz: 1, de: -1)
        case .se: JogVector(dx: 0, dy: 0, dz: -1, de: 1)
        case .sw: JogVector(dx: 0, dy: 0, dz: -1, de: -1)
        }
    }

    private func highlights(for vector: JogVector, zMode: Bool) -> Set<PadCell> {
        var cells = Set<PadCell>()
        if zMode {
            if vector.dz > 0 { cells.insert(.zPlus) }
            if vector.dz < 0 { cells.insert(.zMinus) }
            if vector.de > 0 { cells.insert(.ePlus) }
            if vector.de < 0 { cells.insert(.eMinus) }
            cells.insert(.zAngleMode)
        } else {
            if vector.dx > 0 { cells.insert(.xPlus) }
            if vector.dx < 0 { cells.insert(.xMinus) }
            if vector.dy > 0 { cells.insert(.yPlus) }
            if vector.dy < 0 { cells.insert(.yMinus) }
            if vector.dx > 0 && vector.dy > 0 { cells.insert(.xyNE) }
            if vector.dx < 0 && vector.dy > 0 { cells.insert(.xyNW) }
            if vector.dx > 0 && vector.dy < 0 { cells.insert(.xySE) }
            if vector.dx < 0 && vector.dy < 0 { cells.insert(.xySW) }
        }
        return cells
    }
}
```

When right fire rises **and** the stick is deflected, prefer `toggleVacuum` that tick (no Home/Stop). Jog resumes next tick while held.

- [ ] **Step 2: Add highlight-only file repeating the spec examples**

`Tests/Joy2Tests/HighlightTests.swift`:

```swift
import Testing
@testable import Joy2

struct HighlightTests {
    @Test func stickRightHighlightsXPlusOnly() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.e, leftFire: false, rightFire: false))
        #expect(result.highlights.cells == [.xPlus])
    }

    @Test func leftPlusForwardHighlightsZPlusAndMode() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.n, leftFire: true, rightFire: false))
        #expect(result.highlights.cells == [.zPlus, .zAngleMode])
    }
}
```

- [ ] **Step 3: Run mapper and highlight tests**

Run: `swift test --filter MapperTests --filter HighlightTests`
Expected: PASS (if Swift Testing does not AND filters, run `swift test --skip LiveStickTests` once Live exists; until then `swift test`).

- [ ] **Step 4: Commit**

```bash
git add Sources/Joy2/JoystickMapper.swift Tests/Joy2Tests
git commit -m "feat(joy2): map Speedlink stick to XY, Z/E, and suction"
```

---

### Task 3: IntentGuard

**Files:**
- Create: `Sources/Joy2/IntentGuard.swift`
- Create: `Tests/Joy2Tests/GuardTests.swift`

- [ ] **Step 1: Write failing guard tests**

```swift
import Testing
@testable import Joy2

struct GuardTests {
    let jog = PilotIntent.jog(JogVector(dx: 1, dy: 0, dz: 0, de: 0))
    let idle = GuardState(armConnected: true, motorsOn: true, busy: false)

    @Test func allowsLegalJog() {
        let decision = IntentGuard.decide(jog, state: idle)
        #expect(decision.accepted == jog)
        #expect(decision.reject == nil)
    }

    @Test func blocksWhenDisconnected() {
        let decision = IntentGuard.decide(jog, state: GuardState(armConnected: false, motorsOn: true, busy: false))
        #expect(decision.accepted == nil)
        #expect(decision.reject == .notConnected)
    }

    @Test func blocksWhenBusy() {
        let decision = IntentGuard.decide(jog, state: GuardState(armConnected: true, motorsOn: true, busy: true))
        #expect(decision.accepted == nil)
        #expect(decision.reject == .busy)
    }

    @Test func blocksJogWhenMotorsOff() {
        let decision = IntentGuard.decide(jog, state: GuardState(armConnected: true, motorsOn: false, busy: false))
        #expect(decision.accepted == nil)
        #expect(decision.reject == .motorsOff)
    }

    @Test func stopAlwaysAccepted() {
        let decision = IntentGuard.decide(.stop, state: GuardState(armConnected: false, motorsOn: false, busy: true))
        #expect(decision.accepted == .stop)
        #expect(decision.reject == nil)
    }

    @Test func noneAlwaysAccepted() {
        let decision = IntentGuard.decide(.none, state: GuardState(armConnected: false, motorsOn: false, busy: true))
        #expect(decision.accepted == .none)
    }

    @Test func toggleVacuumRequiresConnectNotMotors() {
        let off = GuardState(armConnected: true, motorsOn: false, busy: false)
        let decision = IntentGuard.decide(.toggleVacuum, state: off)
        #expect(decision.accepted == .toggleVacuum)
    }

    @Test func intentHasNoG28Case() {
        let intents: [PilotIntent] = [
            .none,
            .jog(JogVector(dx: 1, dy: 0, dz: 0, de: 0)),
            .toggleVacuum,
            .stop,
        ]
        for intent in intents {
            switch intent {
            case .none, .jog, .toggleVacuum, .stop:
                break
            }
        }
    }
}
```

- [ ] **Step 2: Run to verify fail**

Run: `swift test --filter GuardTests`
Expected: FAIL (`IntentGuard` missing).

- [ ] **Step 3: Implement guard**

`Sources/Joy2/IntentGuard.swift`:

```swift
public struct GuardState: Equatable, Sendable {
    public var armConnected: Bool
    public var motorsOn: Bool
    public var busy: Bool

    public init(armConnected: Bool, motorsOn: Bool, busy: Bool) {
        self.armConnected = armConnected
        self.motorsOn = motorsOn
        self.busy = busy
    }
}

public enum GuardReject: String, Equatable, Sendable {
    case notConnected
    case motorsOff
    case busy

    public var message: String {
        switch self {
        case .notConnected: "not connected"
        case .motorsOff: "motors off"
        case .busy: "still moving"
        }
    }
}

public struct GuardDecision: Equatable, Sendable {
    public var accepted: PilotIntent?
    public var reject: GuardReject?

    public init(accepted: PilotIntent?, reject: GuardReject?) {
        self.accepted = accepted
        self.reject = reject
    }
}

public enum IntentGuard: Sendable {
    public static func decide(_ intent: PilotIntent, state: GuardState) -> GuardDecision {
        switch intent {
        case .none, .stop:
            return GuardDecision(accepted: intent, reject: nil)
        case .toggleVacuum:
            if !state.armConnected { return GuardDecision(accepted: nil, reject: .notConnected) }
            if state.busy { return GuardDecision(accepted: nil, reject: .busy) }
            return GuardDecision(accepted: intent, reject: nil)
        case .jog:
            if !state.armConnected { return GuardDecision(accepted: nil, reject: .notConnected) }
            if !state.motorsOn { return GuardDecision(accepted: nil, reject: .motorsOff) }
            if state.busy { return GuardDecision(accepted: nil, reject: .busy) }
            return GuardDecision(accepted: intent, reject: nil)
        }
    }
}
```

- [ ] **Step 4: Run guard tests**

Run: `swift test --filter GuardTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Joy2/IntentGuard.swift Tests/Joy2Tests/GuardTests.swift
git commit -m "feat(joy2): reject unsafe stick intents before the arm"
```

---

### Task 4: JoystickDevice (VID/PID only)

**Files:**
- Create: `Sources/Joy2/JoystickSourcing.swift`
- Create: `Sources/Joy2/JoystickDevice.swift`
- Create: `Tests/Joy2Tests/DeviceDirectionTests.swift`

- [ ] **Step 1: Write tests for digital 8-way conversion (no hardware)**

`Tests/Joy2Tests/DeviceDirectionTests.swift`:

```swift
import Testing
@testable import Joy2

struct DeviceDirectionTests {
    @Test func centerStaysCenter() {
        #expect(StickDirection.fromAxes(x: 0.5, y: 0.5) == .center)
    }

    @Test func rightIsEast() {
        #expect(StickDirection.fromAxes(x: 1.0, y: 0.5) == .e)
    }

    @Test func upIsNorth() {
        // HID Y often grows downward; device passes already-flipped y where 1 = away/north
        #expect(StickDirection.fromAxes(x: 0.5, y: 1.0) == .n)
    }

    @Test func northEastDiagonal() {
        #expect(StickDirection.fromAxes(x: 1.0, y: 1.0) == .ne)
    }

    @Test func deadzoneIgnoresChatter() {
        #expect(StickDirection.fromAxes(x: 0.55, y: 0.48) == .center)
    }
}
```

- [ ] **Step 2: Run — fail on missing `fromAxes`**

Run: `swift test --filter DeviceDirectionTests`
Expected: FAIL.

- [ ] **Step 3: Implement direction helper + sourcing protocol + HID device**

Add to `Sources/Joy2/JoystickSample.swift`:

```swift
extension StickDirection {
    /// `x`/`y` in 0...1, 0.5 is center. `y` is already north-positive.
    public static func fromAxes(x: Double, y: Double, deadzone: Double = 0.28) -> StickDirection {
        let dx = x - 0.5
        let dy = y - 0.5
        let hx: Int
        if dx > deadzone { hx = 1 }
        else if dx < -deadzone { hx = -1 }
        else { hx = 0 }
        let hy: Int
        if dy > deadzone { hy = 1 }
        else if dy < -deadzone { hy = -1 }
        else { hy = 0 }
        switch (hx, hy) {
        case (0, 0): return .center
        case (0, 1): return .n
        case (1, 1): return .ne
        case (1, 0): return .e
        case (1, -1): return .se
        case (0, -1): return .s
        case (-1, -1): return .sw
        case (-1, 0): return .w
        case (-1, 1): return .nw
        default: return .center
        }
    }
}
```

`Sources/Joy2/JoystickSourcing.swift`:

```swift
public protocol JoystickSourcing: AnyObject, Sendable {
    func currentSample() -> JoystickSample
}

public final class FakeJoystick: JoystickSourcing, @unchecked Sendable {
    public var sample = JoystickSample(connected: false, direction: .center, leftFire: false, rightFire: false)
    public init() {}
    public func currentSample() -> JoystickSample { sample }
}
```

`Sources/Joy2/JoystickDevice.swift`:

```swift
import Foundation
import IOKit.hid

public enum SpeedlinkIDs {
    public static let vendorID = 0x0079
    public static let productID = 0x181C
}

public final class JoystickDevice: JoystickSourcing, @unchecked Sendable {
    private let manager: IOHIDManager
    private let lock = NSLock()
    private var sample = JoystickSample(connected: false, direction: .center, leftFire: false, rightFire: false)
    private var axisX = 0.5
    private var axisY = 0.5

    public init() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let match: [String: Any] = [
            kIOHIDVendorIDKey as String: SpeedlinkIDs.vendorID,
            kIOHIDProductIDKey as String: SpeedlinkIDs.productID,
        ]
        IOHIDManagerSetDeviceMatching(manager, match as CFDictionary)
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, _, _, _ in
            guard let context else { return }
            Unmanaged<JoystickDevice>.fromOpaque(context).takeUnretainedValue().setConnected(true)
        }, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, _, _, _ in
            guard let context else { return }
            Unmanaged<JoystickDevice>.fromOpaque(context).takeUnretainedValue().setConnected(false)
        }, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerRegisterInputValueCallback(manager, { context, _, _, value in
            guard let context else { return }
            Unmanaged<JoystickDevice>.fromOpaque(context).takeUnretainedValue().handle(value)
        }, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    deinit {
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    public func currentSample() -> JoystickSample {
        lock.lock()
        defer { lock.unlock() }
        return sample
    }

    private func setConnected(_ connected: Bool) {
        lock.lock()
        defer { lock.unlock() }
        if connected {
            sample.connected = true
        } else {
            sample = JoystickSample(connected: false, direction: .center, leftFire: false, rightFire: false)
            axisX = 0.5
            axisY = 0.5
        }
    }

    private func handle(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        let usagePage = IOHIDElementGetUsagePage(element)
        let usage = IOHIDElementGetUsage(element)
        let integer = IOHIDValueGetIntegerValue(value)
        let min = IOHIDElementGetLogicalMin(element)
        let max = IOHIDElementGetLogicalMax(element)

        lock.lock()
        defer { lock.unlock() }
        sample.connected = true

        if usagePage == 0x01 && (usage == 0x30 || usage == 0x31) && max > min {
            let norm = Double(integer - min) / Double(max - min)
            if usage == 0x30 { axisX = norm }
            if usage == 0x31 {
                // HID Y grows down; flip so 1 = north/away
                axisY = 1 - norm
            }
            sample.direction = StickDirection.fromAxes(x: axisX, y: axisY)
        } else if usagePage == 0x09 {
            let down = integer != 0
            if usage == 1 { sample.leftFire = down }
            if usage == 2 { sample.rightFire = down }
        }
    }
}
```

If live probing later shows button 1 is the **right** fire, swap the usage == 1 / 2 assignment in `handle` only. Do not guess other VID/PIDs.

- [ ] **Step 4: Run direction tests**

Run: `swift test --filter DeviceDirectionTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Joy2 Tests/Joy2Tests/DeviceDirectionTests.swift
git commit -m "feat(joy2): read Speedlink 0x79/0x181c as an 8-way stick"
```

---

### Task 5: PilotModel

**Files:**
- Create: `Sources/Joy2App/Pilot/PilotModel.swift`
- Create: `Sources/Joy2App/App/Joy2App.entitlements`
- Modify: `Sources/Joy2App/App/Joy2App.swift`
- Modify: `Package.swift` if the entitlements exclude path is already set

`PilotModel` lives in the app target. Do **not** reimplement serial. Wrap Joy1 `PendantModel`.

- [ ] **Step 1: Implement PilotModel**

`Sources/Joy2App/Pilot/PilotModel.swift`:

```swift
import Foundation
import Joy1
import Joy2
import Observation

@MainActor
@Observable
final class PilotModel {
    let pendant: PendantModel
    private(set) var highlights = Set<PadCell>()
    private(set) var stickConnected = false
    private(set) var stickMessage: String? = "Plug in the Speedlink stick"
    private(set) var lastGuardReject: GuardReject?

    private var mapper = JoystickMapper()
    private let stick: any JoystickSourcing
    private var tickTask: Task<Void, Never>?
    private var busy = false
    private var stepArmed = true
    private var lastStickConnected = false

    init(pendant: PendantModel, stick: any JoystickSourcing) {
        self.pendant = pendant
        self.stick = stick
    }

    func start() {
        pendant.refreshPorts()
        pendant.startJogLoop()
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.tick()
                try? await Task.sleep(for: .milliseconds(16))
            }
        }
    }

    func stopTick() {
        tickTask?.cancel()
        tickTask = nil
    }

    func emergencyStop() async {
        mapper = JoystickMapper()
        highlights = []
        lastGuardReject = nil
        await pendant.stop()
    }

    func tick() async {
        let sample = stick.currentSample()
        if lastStickConnected && !sample.connected {
            await emergencyStop()
            stickConnected = false
            stickMessage = "Plug in the Speedlink stick"
            lastStickConnected = false
            return
        }
        lastStickConnected = sample.connected
        stickConnected = sample.connected
        stickMessage = sample.connected ? nil : "Plug in the Speedlink stick"

        let mapped = mapper.map(sample)
        highlights = mapped.highlights.cells

        if sample.direction == .center {
            stepArmed = true
        }

        let state = GuardState(
            armConnected: pendant.isConnected,
            motorsOn: pendant.motorsOn,
            busy: busy
        )
        let decision = IntentGuard.decide(mapped.intent, state: state)
        lastGuardReject = decision.reject
        if decision.reject != nil {
            if pendant.lastError == nil || pendant.lastError == GuardReject.busy.message
                || pendant.lastError == GuardReject.notConnected.message
                || pendant.lastError == GuardReject.motorsOff.message {
                // surface guard text without wiping a serial error
            }
        }
        guard let accepted = decision.accepted else { return }
        await apply(accepted)
    }

    private func apply(_ intent: PilotIntent) async {
        switch intent {
        case .none:
            applyHold(JogVector(dx: 0, dy: 0, dz: 0, de: 0))
            return
        case .stop:
            await emergencyStop()
        case .toggleVacuum:
            await pendant.setVacuum(!pendant.vacuumOn)
        case .jog(let vector):
            if pendant.controlMode == .step {
                guard stepArmed else { return }
                stepArmed = false
                await runStep(vector)
            } else {
                applyHold(vector)
            }
        }
    }

    private func applyHold(_ vector: JogVector) {
        pendant.setHeld(.x, .pos, down: vector.dx > 0)
        pendant.setHeld(.x, .neg, down: vector.dx < 0)
        pendant.setHeld(.y, .pos, down: vector.dy > 0)
        pendant.setHeld(.y, .neg, down: vector.dy < 0)
        pendant.setHeld(.z, .pos, down: vector.dz > 0)
        pendant.setHeld(.z, .neg, down: vector.dz < 0)
        if vector.de > 0 {
            Task { await pendant.jogModule(sign: .pos) }
        } else if vector.de < 0 {
            Task { await pendant.jogModule(sign: .neg) }
        }
    }

    private func runStep(_ vector: JogVector) async {
        busy = true
        defer { busy = false }
        if vector.dx != 0 || vector.dy != 0 || vector.dz != 0 {
            await pendant.step(dx: Double(vector.dx), dy: Double(vector.dy), dz: Double(vector.dz))
            if pendant.lastError != nil {
                await pendant.stop()
            }
        }
        if vector.de != 0 {
            await pendant.jogModule(sign: vector.de > 0 ? .pos : .neg)
        }
    }
}
```

Joy1 `PendantModel` public API to call (do not invent names): `setHeld`, `step(dx:dy:dz:)`, `jogModule(sign:)`, `setVacuum`, `startJogLoop`, `stop`, `home`, `zeroZ`, `moveToTarget`, `setMotors`, `refreshPorts`. `clearHolds()` is private — release the stick by `setHeld(..., down: false)` on every axis. **Do not add `G28`.** Do not change Joy1 behavior.

- [ ] **Step 2: Entitlements + app entry**

`Sources/Joy2App/App/Joy2App.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<false/>
</dict>
</plist>
```

`Sources/Joy2App/App/Joy2App.swift`:

```swift
import Joy1
import Joy2
import SwiftUI

@main
struct Joy2App: App {
    @State private var model: PilotModel

    init() {
        let scanned = PortDetector.scan()
        let path = PortDetector.pickArm(from: scanned)?.path
        let pendant = PendantModel(
            arm: HuenitArm(transport: SerialPort(path: path ?? "/dev/null")),
            detector: { PortDetector.scan() }
        )
        _model = State(initialValue: PilotModel(pendant: pendant, stick: JoystickDevice()))
    }

    var body: some Scene {
        WindowGroup("Joy2") {
            ContentView(model: model)
        }
    }
}
```

Leave `ContentView` as a stub if it does not exist yet:

```swift
import SwiftUI

struct ContentView: View {
    var model: PilotModel
    var body: some View { Text("Joy2") }
}
```

- [ ] **Step 3: Compile**

Run: `swift build --product Joy2App`
Expected: build succeeds after `PilotModel` matches `PendantModel`’s real API. Fix compile errors against Joy1; do not change Joy1 behavior.

- [ ] **Step 4: Run offline tests again**

Run: `swift test`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Joy2App Package.swift
git commit -m "feat(joy2): drive Joy1 pendant from mapped stick intents"
```

---

### Task 6: Lab-style window + highlight

**Files:**
- Create: `Sources/Joy2App/Theme/PendantChrome.swift` (copy Joy1 chrome; extend `PadKeyStyle` with `lit`)
- Create: `Sources/Joy2App/Views/ContentView.swift`
- Create: `Sources/Joy2App/Views/LabPad.swift`
- Create: `Sources/Joy2App/Views/ConnectionBar.swift`
- Create: `Sources/Joy2App/Views/ModuleCard.swift`
- Create: `Sources/Joy2App/Views/PoseHUD.swift`
- Create: `Sources/Joy2App/Views/StopButton.swift`
- Create: `Sources/Joy2App/Views/SpeedSlider.swift`
- Create: `Sources/Joy2App/Views/VacuumToggle.swift`
- Create: `Sources/Joy2App/Views/HoldButton.swift`

Copy layout from `../joy1/Sources/Joy1App/Views/` and `Theme/PendantChrome.swift`. Bind pad **actions** to `model.pendant` (same methods LabPad already calls). Bind **pressed styling** to `model.highlights`.

- [ ] **Step 1: Extend PadKeyStyle with `lit`**

In `PadKeyStyle` add `var lit = false`. Fill when `lit || configuration.isPressed` uses the pressed opacity so a stick-held cell looks held.

```swift
private func fill(_ pressed: Bool) -> Color {
    let on = pressed || lit
    if destructive { return PendantChrome.stop.opacity(on ? 0.85 : 1) }
    if emphasized { return Color.accentColor.opacity(on ? 0.28 : 0.16) }
    return Color.primary.opacity(on ? 0.14 : 0.06)
}
```

- [ ] **Step 2: Lab pad cells pass `lit`**

Map:

| Button | `PadCell` |
|---|---|
| X+ | `.xPlus` |
| X− | `.xMinus` |
| Y+ | `.yPlus` |
| Y− | `.yMinus` |
| ↗︎ | `.xyNE` |
| ↖︎ | `.xyNW` |
| ↘︎ | `.xySE` |
| ↙︎ | `.xySW` |
| Z+ / Z− | `.zPlus` / `.zMinus` |
| E+ / E− | `.ePlus` / `.eMinus` |
| Suction | `.suction` |

Home, Z0, Move Now: no stick highlight.

When `highlights.contains(.zAngleMode)`, draw a caption under the pad: `Z / angle` so the left fire is visible even at stick center.

- [ ] **Step 3: Connection strip shows stick + guard**

Under the Joy1 port row add:

- Green/gray: stick connected / `model.stickMessage`
- If `model.lastGuardReject != nil`, show `lastGuardReject.message`

Pad remains usable with no stick.

- [ ] **Step 4: ContentView STOP + resign**

```swift
.onAppear { model.start() }
.onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
    Task { await model.emergencyStop() }
}
```

STOP button calls `model.emergencyStop()`. Esc: `.onKeyPress(.escape) { Task { await model.emergencyStop() }; return .handled }`.

- [ ] **Step 5: Build and run**

Run: `swift build --product Joy2App && swift run Joy2App`
Expected: window matches Joy1 Lab layout; with stick plugged, X+ lights when you push right; left fire lights Z/angle mode; right fire lights suction.

If left/right fires are swapped on this unit, swap usage 1/2 in `JoystickDevice.handle` and retest.

- [ ] **Step 6: Commit**

```bash
git add Sources/Joy2App
git commit -m "feat(joy2): Lab pad lights the cells the stick is using"
```

---

### Task 7: Safety pass (no-break)

**Files:**
- Modify: `Sources/Joy2App/Pilot/PilotModel.swift`
- Modify: `Sources/Joy2/JoystickMapper.swift` only if needed

- [ ] **Step 1: Confirm these invariants in code**

1. No string `"G28"` in `Hardware/huenit/joy2`.
2. Home is only `pendant.home()` from the ⌂ button.
3. Unplug path calls `emergencyStop()` (Task 5 already).
4. `busy` prevents a second `runStep` (guard `.busy`).
5. Hold mode does not queue: `setHeld` bits replace, they do not append.
6. Firmware throw in `runStep` calls `pendant.stop()` and does not retry that deflection until center then re-deflect (`stepArmed`).
7. Launch does not connect automatically beyond Joy1’s existing Auto Connect **if** you wire a button; do **not** jog on appear.

- [ ] **Step 2: grep**

Run: `rg -n "G28" Sources Tests || true`
Expected: no matches.

- [ ] **Step 3: Commit if anything changed**

```bash
git add Sources/Joy2App Sources/Joy2
git commit -m "fix(joy2): stop on unplug and never send G28"
```

Skip the commit if the working tree is clean.

---

### Task 8: Live tests (skip without arm)

**Files:**
- Create: `Tests/Joy2Tests/Live/LiveStickTests.swift`
- Modify: `Package.swift` — live tests only need `Joy2` plus a **new** test target if they must import Joy1. Prefer adding Joy1 to `Joy2Tests` for this file only:

```swift
.testTarget(
    name: "Joy2Tests",
    dependencies: [
        "Joy2",
        .product(name: "Joy1", package: "joy1"),
    ]
)
```

- [ ] **Step 1: Write skipped-by-default live suite**

`Tests/Joy2Tests/Live/LiveStickTests.swift`:

```swift
import Testing
import Joy1
@testable import Joy2

struct LiveStickTests {
    @Test func mapperThenTinyXYUndo() async throws {
        guard PortDetector.pickArm(from: PortDetector.scan()) != nil else {
            return
        }
        let ports = PortDetector.scan()
        guard let path = PortDetector.pickArm(from: ports)?.path else { return }
        let arm = HuenitArm(transport: SerialPort(path: path))
        try await arm.connect()
        let before = try await arm.queryPose()
        var mapper = JoystickMapper()
        let mapped = mapper.map(
            JoystickSample(connected: true, direction: .e, leftFire: false, rightFire: false)
        )
        guard case .jog(let vector) = mapped.intent else {
            Issue.record("expected jog")
            await arm.disconnect()
            return
        }
        #expect(vector.dx == 1)
        try await arm.step(dx: 1, dy: 0, dz: 0, feedMmPerMin: 300)
        try await arm.flush()
        try await arm.step(dx: -1, dy: 0, dz: 0, feedMmPerMin: 300)
        try await arm.flush()
        let after = try await arm.queryPose()
        #expect(abs(after.cartesian.x - before.cartesian.x) < 2)
        await arm.stop()
        await arm.disconnect()
    }
}
```

Never call `G28`. Undo the 1 mm step. Skip when no HUEARM.

- [ ] **Step 2: Run default tests (arm may be present; 1 mm undo is the only motion)**

Run: `swift test`
Expected: offline tests PASS; live test skips or undoes.

- [ ] **Step 3: Commit**

```bash
git add Package.swift Tests/Joy2Tests/Live
git commit -m "test(joy2): optional live XY jog from a synthetic stick sample"
```

---

### Task 9: README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write operator README**

```markdown
# Joy2

macOS Lab pad for a HUENIT arm, driven by a Speedlink Competition Pro Extra joystick.

## Stick

- Stick: X/Y on the table
- Hold left fire: stick is Z (forward/back) and cup angle (left/right)
- Right fire: suction on/off
- The pad lights the cell that is active

## Run

```bash
swift run Joy2App
```

Requires the Joy1 package next door (`../joy1`). Connect the arm USB-C (`HUENIT_HUEARM`). Do not home with `G28`.

See [docs/superpowers/specs/2026-08-18-joy2-joystick-design.md](docs/superpowers/specs/2026-08-18-joy2-joystick-design.md).
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs(joy2): operator README for the Speedlink pendant"
```

---

## Self-review

| Spec item | Task |
|---|---|
| New package in `joy2`, Joy1 path dep | 1 |
| Joy2 library has no serial / no Joy1 | 1–4 |
| `PilotModel` only type that talks to both | 5 |
| VID `0x0079` PID `0x181c` | 4 |
| Map table + highlights | 2 |
| Right fire edge, no chord Home/Stop | 2 |
| Hold vs step | 5 |
| Guard: connected / busy / motors / stop | 3 |
| Lab pad + lit cells + Z/angle caption | 6 |
| Stick message, pad works without stick | 6 |
| STOP, Esc, resign, unplug | 5–6 |
| No G28, official home click-only | 5–7 |
| Offline tests | 1–4 |
| Live tiny undo | 8 |
| Errors in strip | 3, 6 |

No TBD. Types: `PadCell`, `JoystickSample`, `StickDirection`, `JogVector`, `PilotIntent`, `HighlightSet`, `JoystickMapper`, `GuardState`, `GuardReject`, `GuardDecision`, `IntentGuard`, `JoystickSourcing`, `FakeJoystick`, `JoystickDevice`, `PilotModel`.
