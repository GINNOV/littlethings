# Bundled MLX Helper Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace direct SwiftUI app process management of `uv run python -m mlx_lm.server` with a bundled helper executable that owns MLX server startup, shutdown, logging, readiness reporting, and user-actionable environment diagnostics.

**Architecture:** Add a Swift command-line helper target named `MLXServerHelper`, package it into `AmigaPlayground.app/Contents/Helpers`, and have the main app launch that helper instead of launching Python directly. The helper remains compatible with the current MLX-LM Python backend, but isolates runtime orchestration behind a stable app-owned executable and reports clear setup guidance when the runtime environment is missing or misconfigured.

**Tech Stack:** SwiftPM, Swift `Process`, Foundation JSON, SwiftUI Settings, XCTest, existing MLX-LM/uv runtime.

---

## File Structure

- Create `aMiLa/AmigaPlayground/Helpers/MLXServerHelper/main.swift`
  - Command-line helper entrypoint.
  - Accepts `--model`, `--port`, `--log-file`, and optional `--runtime-command`.
  - Runs preflight checks for model directory, port availability, `uv`, Python environment, and importability of `mlx_lm.server`.
  - Starts MLX-LM, polls `/v1/models`, streams JSONL status to stdout, and terminates child on SIGTERM/SIGINT.

- Modify `aMiLa/AmigaPlayground/Package.swift`
  - Add executable target `MLXServerHelper`.
  - Keep `AmigaPlayground` as the main executable target.

- Modify `aMiLa/AmigaPlayground/script/build_and_run.sh`
  - Build both `AmigaPlayground` and `MLXServerHelper`.
  - Copy helper into `dist/AmigaPlayground.app/Contents/Helpers/MLXServerHelper`.

- Modify `aMiLa/AmigaPlayground/Services/MLXServerController.swift`
  - Replace direct `/usr/bin/env uv run python ...` launch with helper launch.
  - Parse helper JSONL status messages.
  - Preserve current UI-facing status enum and button behavior.
  - Surface setup instructions from helper failures without requiring users to inspect Terminal logs.

- Modify `aMiLa/AmigaPlayground/AmigaPlaygroundTests/AmigaPlaygroundTests.swift`
  - Update invocation tests to assert helper launch.
  - Add parser tests for helper JSONL status lines.

- Optional later packaging task:
  - Add a bundled runtime directory such as `aMiLa/AmigaPlayground/Runtime/mlx-lm/`.
  - This is intentionally deferred until the helper boundary and user-facing runtime diagnostics are working.

---

### Task 1: Add Helper Target Skeleton

**Files:**
- Modify: `aMiLa/AmigaPlayground/Package.swift`
- Create: `aMiLa/AmigaPlayground/Helpers/MLXServerHelper/main.swift`
- Test: `aMiLa/AmigaPlayground/AmigaPlaygroundTests/AmigaPlaygroundTests.swift`

- [ ] **Step 1: Write failing package/build test**

Add this test near the MLX server tests:

```swift
func testMLXHelperTargetExistsInPackageManifest() throws {
    let packageURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Package.swift")
    let packageText = try String(contentsOf: packageURL)

    XCTAssertTrue(packageText.contains(#"name: "MLXServerHelper""#))
    XCTAssertTrue(packageText.contains(#"path: "Helpers/MLXServerHelper""#))
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/AmigaPlayground
swift test --filter testMLXHelperTargetExistsInPackageManifest
```

Expected: FAIL because `MLXServerHelper` is not in `Package.swift`.

- [ ] **Step 3: Add helper target**

Update `Package.swift` targets:

```swift
.executableTarget(
    name: "MLXServerHelper",
    dependencies: [],
    path: "Helpers/MLXServerHelper"
),
```

Keep it separate from the main app target.

- [ ] **Step 4: Add minimal helper entrypoint**

Create `Helpers/MLXServerHelper/main.swift`:

```swift
import Foundation

struct HelperStatus: Codable {
    let event: String
    let message: String
}

func emit(_ event: String, _ message: String) {
    let status = HelperStatus(event: event, message: message)
    if let data = try? JSONEncoder().encode(status),
       let line = String(data: data, encoding: .utf8) {
        print(line)
        fflush(stdout)
    }
}

emit("ready", "MLXServerHelper installed")
```

- [ ] **Step 5: Verify build and test**

Run:

```bash
swift build --product MLXServerHelper
swift test --filter testMLXHelperTargetExistsInPackageManifest
```

Expected: both PASS.

---

### Task 2: Implement Helper Argument Parsing

**Files:**
- Modify: `aMiLa/AmigaPlayground/Helpers/MLXServerHelper/main.swift`
- Test: `aMiLa/AmigaPlayground/AmigaPlaygroundTests/AmigaPlaygroundTests.swift`

- [ ] **Step 1: Write helper argument parser tests in app test target**

Because helper code is executable-only, keep parser behavior mirrored through a small public app-side value used to build helper invocations:

```swift
func testMLXHelperInvocationBuildsExpectedArguments() {
    let config = MLXServerController.Configuration(
        workingDirectory: URL(fileURLWithPath: "/tmp/fine_tuning", isDirectory: true),
        modelDirectoryName: "fused_model",
        port: 1234,
        logFileName: "server.log"
    )

    let invocation = MLXServerController.buildInvocation(configuration: config)

    XCTAssertEqual(invocation.arguments, [
        "--model", "/tmp/fine_tuning/fused_model",
        "--port", "1234",
        "--log-file", "/tmp/fine_tuning/server.log",
        "--runtime-command", "uv run python -m mlx_lm.server"
    ])
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
swift test --filter testMLXHelperInvocationBuildsExpectedArguments
```

Expected: FAIL because current invocation still launches `/usr/bin/env uv ...`.

- [ ] **Step 3: Implement helper CLI parsing**

Replace helper `main.swift` with argument parsing that requires:

```text
--model <absolute-model-dir>
--port <port>
--log-file <absolute-log-file>
--runtime-command <command string>
--uv-path <optional absolute uv executable path>
```

Validation rules:

```swift
guard FileManager.default.fileExists(atPath: modelPath) else {
    emit("failed", "Model directory not found: \(modelPath)")
    exit(2)
}
guard (1...65535).contains(port) else {
    emit("failed", "Invalid port: \(portString)")
    exit(2)
}
```

- [ ] **Step 4: Verify helper argument behavior manually**

Run:

```bash
.build/debug/MLXServerHelper --model /does/not/exist --port 1234 --log-file /tmp/mlx.log --runtime-command "uv run python -m mlx_lm.server"
```

Expected: JSONL containing `{"event":"failed","message":"Model directory not found: /does/not/exist"}` and exit code `2`.

---

### Task 3: Move MLX-LM Child Ownership Into Helper

**Files:**
- Modify: `aMiLa/AmigaPlayground/Helpers/MLXServerHelper/main.swift`

- [ ] **Step 1: Add process launch in helper**

Helper should split `runtime-command` with `/bin/zsh -lc` to preserve current developer environment behavior:

```swift
let process = Process()
process.executableURL = URL(fileURLWithPath: "/bin/zsh")
process.arguments = [
    "-lc",
    "\(runtimeCommand) --model \(shellQuote(modelPath)) --port \(port)"
]
process.standardOutput = logHandle
process.standardError = logHandle
try process.run()
emit("started", "MLX-LM process started with pid \(process.processIdentifier)")
```

- [ ] **Step 2: Add health polling**

Poll:

```text
http://localhost:<port>/v1/models
```

Every 2 seconds for 60 seconds. Emit:

```json
{"event":"running","message":"MLX server is ready at http://localhost:1234/v1"}
```

On timeout:

```json
{"event":"failed","message":"Timed out waiting for MLX server at http://localhost:1234/v1"}
```

- [ ] **Step 3: Add signal handling**

Install SIGTERM/SIGINT handlers that terminate the child process and emit:

```json
{"event":"stopped","message":"MLX-LM process stopped"}
```

- [ ] **Step 4: Manual helper verification**

Run:

```bash
cd /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/AmigaPlayground
swift build --product MLXServerHelper
.build/debug/MLXServerHelper --model /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/fused_model --port 1234 --log-file /tmp/amiga-mlx-server.log --runtime-command "cd /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning && uv run python -m mlx_lm.server"
```

Expected: emits `started`, then `running`; `curl http://localhost:1234/v1/models` returns HTTP 200.

---

### Task 4: Add Runtime Preflight Diagnostics

**Files:**
- Modify: `aMiLa/AmigaPlayground/Helpers/MLXServerHelper/main.swift`
- Modify: `aMiLa/AmigaPlayground/Services/MLXServerController.swift`
- Test: `aMiLa/AmigaPlayground/AmigaPlaygroundTests/AmigaPlaygroundTests.swift`

- [ ] **Step 1: Add app-side parser test for actionable helper failures**

Add this test near the MLX server tests:

```swift
func testMLXHelperFailureMessageIncludesSetupAction() throws {
    let line = #"{"event":"failed","message":"uv was not found.","code":"missing_uv","action":"Install uv with `curl -LsSf https://astral.sh/uv/install.sh | sh`, then restart Amiga Playground. If uv is already installed, make sure it is available at /opt/homebrew/bin/uv, /usr/local/bin/uv, or ~/.local/bin/uv."}"#

    let status = try MLXServerController.HelperStatus.parse(line: line)

    XCTAssertEqual(status.event, .failed)
    XCTAssertEqual(status.code, "missing_uv")
    XCTAssertEqual(status.message, "uv was not found.")
    XCTAssertTrue(status.action.contains("Install uv"))
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/AmigaPlayground
swift test --filter testMLXHelperFailureMessageIncludesSetupAction
```

Expected: FAIL because `HelperStatus` does not parse `code` and `action` yet.

- [ ] **Step 3: Define helper JSON schema**

In `MLXServerController.swift`, add:

```swift
struct HelperStatus: Decodable, Equatable {
    enum Event: String, Decodable {
        case preflight
        case started
        case running
        case stopped
        case failed
    }

    let event: Event
    let message: String
    let code: String?
    let action: String?

    static func parse(line: String) throws -> HelperStatus {
        try JSONDecoder().decode(HelperStatus.self, from: Data(line.utf8))
    }
}
```

- [ ] **Step 4: Implement helper preflight checks**

Before launching MLX-LM, helper must check these conditions in order and exit with code `2` on failure:

```swift
guard FileManager.default.fileExists(atPath: modelPath) else {
    emit(
        event: "failed",
        message: "MLX model directory was not found: \(modelPath)",
        code: "missing_model",
        action: "Build or copy the fused MLX model to \(modelPath), then start the server again."
    )
    exit(2)
}

guard let uvPath = resolveUVExecutable(explicitPath: explicitUVPath) else {
    emit(
        event: "failed",
        message: "uv was not found.",
        code: "missing_uv",
        action: "Install uv with `curl -LsSf https://astral.sh/uv/install.sh | sh`, then restart Amiga Playground. If uv is already installed, make sure it is available at /opt/homebrew/bin/uv, /usr/local/bin/uv, or ~/.local/bin/uv."
    )
    exit(2)
}

guard commandSucceeds(uvPath, ["--version"]) else {
    emit(
        event: "failed",
        message: "uv exists but could not be executed at \(uvPath).",
        code: "uv_not_executable",
        action: "Check the uv installation permissions, reinstall uv, then restart Amiga Playground."
    )
    exit(2)
}

guard commandSucceeds("/bin/zsh", ["-lc", "cd \(shellQuote(workingDirectory)) && \(shellQuote(uvPath)) run python -c 'import mlx_lm.server'"]) else {
    emit(
        event: "failed",
        message: "MLX-LM is not available in the configured Python environment.",
        code: "missing_mlx_lm",
        action: "Open Terminal, run `cd \(workingDirectory) && \(uvPath) sync`, then start the server again. The required dependency is `mlx-lm>=0.20.0` from pyproject.toml."
    )
    exit(2)
}

guard !portIsBusy(port) else {
    emit(
        event: "failed",
        message: "Port \(port) is already in use.",
        code: "port_busy",
        action: "Stop the other local model server using port \(port), or change the Amiga Playground MLX server port."
    )
    exit(2)
}
```

Use helper functions:

```swift
func resolveUVExecutable(explicitPath: String?) -> String? {
    if let explicitPath {
        return FileManager.default.isExecutableFile(atPath: explicitPath) ? explicitPath : nil
    }

    var candidates = [
        "/opt/homebrew/bin/uv",
        "/usr/local/bin/uv",
        "\(FileManager.default.homeDirectoryForCurrentUser.path)/.local/bin/uv"
    ]

    if let shellPath = commandOutput("/bin/zsh", ["-lc", "command -v uv"]).trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty {
        candidates.insert(shellPath, at: 0)
    }

    return candidates.first { FileManager.default.isExecutableFile(atPath: $0) }
}

func commandSucceeds(_ executable: String, _ arguments: [String]) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    process.standardOutput = Pipe()
    process.standardError = Pipe()
    do {
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus == 0
    } catch {
        return false
    }
}

func commandOutput(_ executable: String, _ arguments: [String]) -> String {
    let pipe = Pipe()
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    process.standardOutput = pipe
    process.standardError = Pipe()
    do {
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { return "" }
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    } catch {
        return ""
    }
}

extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
```

- [ ] **Step 5: Surface failure action in the app**

When helper emits `failed`, map it to:

```swift
status = .failed(status.action.map { "\(status.message)\n\n\($0)" } ?? status.message)
```

The Settings UI already displays `status.detail`; this makes the user see the exact setup action.

- [ ] **Step 6: Verify missing-runtime behavior manually**

Run with an explicitly broken uv path:

```bash
.build/debug/MLXServerHelper --model /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/fused_model --port 1234 --log-file /tmp/amiga-mlx-server.log --runtime-command "uv run python -m mlx_lm.server" --uv-path /does/not/exist/uv
```

Expected: JSONL `failed` event with a stable `code` and a human-readable `action`.

---

### Task 5: Update App Controller To Launch Helper

**Files:**
- Modify: `aMiLa/AmigaPlayground/Services/MLXServerController.swift`
- Test: `aMiLa/AmigaPlayground/AmigaPlaygroundTests/AmigaPlaygroundTests.swift`

- [ ] **Step 1: Add helper path resolution**

Implement:

```swift
static func defaultHelperURL() -> URL {
    if let helper = Bundle.main.url(forAuxiliaryExecutable: "MLXServerHelper") {
        return helper
    }

    return URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent(".build/debug/MLXServerHelper")
}
```

- [ ] **Step 2: Update invocation builder**

Expected invocation:

```swift
Invocation(
    executableURL: helperURL,
    arguments: [
        "--model", modelDirectory.path,
        "--port", "\(configuration.port)",
        "--log-file", logFile.path,
        "--runtime-command", "cd \(configuration.workingDirectory.path) && uv run python -m mlx_lm.server"
    ],
    workingDirectory: configuration.workingDirectory,
    logFile: logFile
)
```

- [ ] **Step 3: Parse helper JSONL stdout**

Map helper events:

```swift
started -> .starting
running -> .running
failed -> .failed(action == nil ? message : "\(message)\n\n\(action!)")
stopped -> .stopped
```

- [ ] **Step 4: Verify app-side tests**

Run:

```bash
swift test --filter MLXServer
```

Expected: PASS.

---

### Task 6: Package Helper Into App Bundle

**Files:**
- Modify: `aMiLa/AmigaPlayground/script/build_and_run.sh`

- [ ] **Step 1: Update build script**

Build both products:

```bash
swift build --product AmigaPlayground
swift build --product MLXServerHelper
```

Create helper destination:

```bash
mkdir -p "$APP_BUNDLE/Contents/Helpers"
cp ".build/debug/MLXServerHelper" "$APP_BUNDLE/Contents/Helpers/MLXServerHelper"
chmod +x "$APP_BUNDLE/Contents/Helpers/MLXServerHelper"
```

- [ ] **Step 2: Verify helper exists in bundle**

Run:

```bash
./script/build_and_run.sh --verify
test -x "dist/AmigaPlayground.app/Contents/Helpers/MLXServerHelper"
```

Expected: process launches and helper executable exists.

---

### Task 7: Update Settings UI Copy And Behavior

**Files:**
- Modify: `aMiLa/AmigaPlayground/Views/ContentView.swift`

- [ ] **Step 1: Update Local MLX Server section**

Keep existing buttons, but status text should now describe helper-managed state:

```swift
Text("Managed by bundled helper")
    .font(.caption)
    .foregroundStyle(.secondary)
```

- [ ] **Step 2: Preserve current UX**

Start button must still:

```swift
llm.provider = .lmStudio
llm.customUrl = ""
llm.modelName = OllamaService.Provider.lmStudio.defaultModelName
mlxServer.start()
```

- [ ] **Step 3: Add setup guidance affordance**

When `mlxServer.status.detail` is present, show the full failure detail in the Local MLX Server section and add a setup-instruction copy button:

```swift
if let detail = mlxServer.status.detail {
    Text(detail)
        .font(.caption)
        .foregroundStyle(.red)
        .textSelection(.enabled)

    Button {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(detail, forType: .string)
    } label: {
        Label("Copy Setup Instructions", systemImage: "doc.on.doc")
    }
}
```

- [ ] **Step 4: Verify user-facing failure copy**

Temporarily configure an invalid helper runtime command in a test build and click Start MLX Server.

Expected: Settings > AI shows a specific failure such as:

```text
uv was not found.

Install uv with `curl -LsSf https://astral.sh/uv/install.sh | sh`, then restart Amiga Playground.
```

- [ ] **Step 5: Verify UI build**

Run:

```bash
swift build
```

Expected: PASS.

---

### Task 8: Verification Matrix

**Files:**
- No code changes unless failures require fixes.

- [ ] **Step 1: Unit tests**

Run:

```bash
swift test --filter AmigaPlaygroundTests
```

Expected: 45+ unit tests pass. Do not use unfiltered `swift test` until the existing SwiftPM UI-test target path issue is fixed.

- [ ] **Step 2: Build**

Run:

```bash
swift build
```

Expected: build exits 0.

- [ ] **Step 3: Helper runtime smoke test**

Run:

```bash
cd /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/AmigaPlayground
swift build --product MLXServerHelper
.build/debug/MLXServerHelper --model /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/fused_model --port 1234 --log-file /tmp/amiga-mlx-server.log --runtime-command "cd /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning && uv run python -m mlx_lm.server"
```

Expected: helper emits `running`; `curl -s http://localhost:1234/v1/models` succeeds.

- [ ] **Step 4: Missing environment smoke test**

Run helper with an explicitly bad `uv` path:

```bash
.build/debug/MLXServerHelper --model /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/fused_model --port 1234 --log-file /tmp/amiga-mlx-server.log --runtime-command "uv run python -m mlx_lm.server" --uv-path /does/not/exist/uv
```

Expected: exits non-zero and emits JSONL with `event=failed`, `code=missing_uv`, and an `action` that tells the user what to install or run.

- [ ] **Step 5: App smoke test**

Run:

```bash
./script/build_and_run.sh --verify
```

Then open Settings > AI and click Start MLX Server.

Expected: status becomes Running, assistant endpoint remains `http://localhost:1234`, and Stop terminates the helper-owned process.

---

## Follow-Up Plan: Bundled Runtime

After the helper boundary and preflight diagnostics are stable, create a separate plan for bundling or installing the MLX runtime itself. That should decide between:

1. App-managed venv under Application Support.
2. Bundled Python/uv runtime inside the app bundle.
3. User-provided runtime with first-run validation.

Do not combine full runtime bundling with the helper migration. However, user-facing runtime validation is part of this plan and must ship with the helper so compiled-app users are not left with a silent failure or Terminal-only error.
