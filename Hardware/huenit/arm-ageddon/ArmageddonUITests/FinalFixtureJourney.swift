import AppKit
import CryptoKit
import Darwin
import XCTest

@MainActor
final class FinalFixtureJourney: XCTestCase {
    func testFixtureLiveDetectionTargetCaptureReview() throws {
        let app = try launch()
        waitForHealth(app, value: "Ready")

        chooseMenu(app, identifier: "live.source-picker", item: "Recorded fixture")
        waitForPicker(app, identifier: "live.source-picker", containing: "Recorded fixture")
        chooseMenu(app, identifier: "live.model-picker", item: "Recorded fixture detector")
        waitForPicker(app, identifier: "live.model-picker", containing: "Recorded fixture detector")

        let target = app.descendants(matching: .any)["live.detection.target"].firstMatch
        XCTAssertTrue(target.waitForExistence(timeout: 5), "Missing live.detection.target")
        target.click()
        XCTAssertTrue(app.descendants(matching: .any)["inspector.target"].waitForExistence(timeout: 2))

        app.buttons["live.capture"].click()
        XCTAssertTrue(app.staticTexts["Frame 1 staged for capture review."].waitForExistence(timeout: 2))

        app.buttons["sidebar.capture"].click()
        XCTAssertTrue(app.descendants(matching: .any)["workspace.capture"].waitForExistence(timeout: 3))
        let captureCard = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'capture.' AND identifier != 'capture.details' AND identifier != 'capture.export'")
        ).firstMatch
        if captureCard.waitForExistence(timeout: 3) {
            captureCard.click()
        }
        XCTAssertTrue(app.staticTexts["Capture details"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["capture.export"].waitForExistence(timeout: 2))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "final-fixture-live"
        attachment.lifetime = .keepAlways
        add(attachment)

        try completeObservationHold(app: app)
        app.terminate()
    }

    private func launch() throws -> XCUIApplication {
        let paths = try isolatedPaths()
        let app = XCUIApplication()
        app.launchEnvironment = ["CFFIXED_USER_HOME": paths.home]
        app.launchArguments = [
            "-ui-testing",
            "-fixture-profile", "all-connected",
            "-qa-preference-suite", paths.preferenceSuite,
            "-qa-application-support-root", paths.support,
            "-qa-cache-root", paths.cache,
            "-qa-temp-root", paths.temporary,
            "-qa-fixture-root", paths.fixtures,
            "-qa-window-width", "1280",
            "-qa-window-height", "800",
            "-AppleInterfaceStyle", "Light",
        ]
        app.launch()
        app.activate()
        XCTAssertTrue(app.descendants(matching: .any)["app.shell"].waitForExistence(timeout: 8))
        return app
    }

    private func isolatedPaths() throws -> (home: String, support: String, cache: String, temporary: String, fixtures: String, preferenceSuite: String) {
        if let home = environment("ARMAGEDDON_QA_FIXED_USER_HOME"),
           let support = environment("ARMAGEDDON_QA_APPLICATION_SUPPORT_ROOT"),
           let cache = environment("ARMAGEDDON_QA_CACHE_ROOT"),
           let temporary = environment("ARMAGEDDON_QA_TEMP_ROOT"),
           let fixtures = environment("ARMAGEDDON_QA_FIXTURE_ROOT") {
            let suite = environment("ARMAGEDDON_QA_PREFERENCE_SUITE") ?? "com.huenit.ArmageddonUITests.final-fixture"
            return (home, support, cache, temporary, fixtures, suite)
        }
        let root = try privateRoot()
        addTeardownBlock { try? FileManager.default.removeItem(at: root) }
        let names = ["home", "support", "cache", "temporary", "fixtures"]
        let urls = names.map { root.appending(path: $0) }
        for url in urls {
            guard mkdir(url.path, 0o700) == 0 else { throw CocoaError(.fileWriteUnknown) }
        }
        return (
            urls[0].path,
            urls[1].path,
            urls[2].path,
            urls[3].path,
            urls[4].path,
            "com.huenit.ArmageddonUITests.final-fixture.\(UUID().uuidString)"
        )
    }

    private func completeObservationHold(app: XCUIApplication) throws {
        guard let rawGate = environment("ARMAGEDDON_QA_OBSERVATION_GATE"), rawGate.hasPrefix("/") else { return }
        let gate = URL(fileURLWithPath: rawGate).standardizedFileURL
        let childRoot = gate.deletingLastPathComponent()
        let ready = childRoot.appending(path: "observation-ready.json")
        let hold = childRoot.appending(path: "observation-hold.json")
        let journeyComplete = monotonicNanos()
        let identity = try appIdentity(app)
        try exclusiveJSON(
            [
                "schemaVersion": 1,
                "kind": "observation-ready",
                "hardwareUsed": false,
                "journey": "final-fixture",
                "journeyCompleteMonotonicNs": journeyComplete,
                "app": identity,
            ],
            to: ready
        )
        let waitStart = monotonicNanos()
        try exclusiveJSON(
            [
                "schemaVersion": 1,
                "kind": "observation-hold",
                "readyReceipt": ready.path,
                "readyReceiptSHA256": sha256File(ready),
                "waitStartMonotonicNs": waitStart,
                "fifo": gate.path,
                "app": identity,
            ],
            to: hold
        )
        try writeJourneyScreenshot(app: app, to: childRoot)
        let gateDescriptor = open(gate.path, O_RDONLY)
        guard gateDescriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { close(gateDescriptor) }
        var token: UInt8 = 0
        guard read(gateDescriptor, &token, 1) == 1, token == 49 else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    private func writeJourneyScreenshot(app: XCUIApplication, to childRoot: URL) throws {
        let directory = childRoot.appending(path: "screenshots")
        if mkdir(directory.path, 0o700) != 0, errno != EEXIST {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        try exclusiveData(app.screenshot().pngRepresentation, to: directory.appending(path: "final-fixture-live.png"))
    }

    private func appIdentity(_ app: XCUIApplication) throws -> [String: Any] {
        _ = app
        let suite = environment("ARMAGEDDON_QA_PREFERENCE_SUITE")
        let candidates = NSRunningApplication.runningApplications(withBundleIdentifier: "com.huenit.ArmageddonApp")
        let running: NSRunningApplication
        if let suite, let match = candidates.first(where: { processArguments($0.processIdentifier)?.contains(suite) == true }) {
            running = match
        } else if candidates.count == 1, let only = candidates.first {
            running = only
        } else {
            throw POSIXError(.ESRCH)
        }
        let pid = running.processIdentifier
        guard let executable = processPath(pid) else {
            throw POSIXError(.ESRCH)
        }
        let executableURL = URL(fileURLWithPath: executable)
        let bundle = executableURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return [
            "pid": Int(pid),
            "path": bundle.path,
            "executable": executable,
            "executableSHA256": try sha256File(executableURL),
            "bundleSHA256": try sha256File(bundle.appending(path: "Contents/MacOS").appending(path: bundle.deletingPathExtension().lastPathComponent)),
        ]
    }

    private func waitForHealth(_ app: XCUIApplication, value: String, timeout: TimeInterval = 8) {
        let health = app.descendants(matching: .any)["live.performance-health"].firstMatch
        XCTAssertTrue(health.waitForExistence(timeout: 5), "Missing live.performance-health")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", value),
            object: health
        )
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: timeout), .completed)
    }

    private func chooseMenu(_ app: XCUIApplication, identifier: String, item: String) {
        let picker = app.descendants(matching: .any)[identifier].firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 5), "Missing \(identifier)")
        picker.click()
        let menuItem = app.menuItems[item].firstMatch
        if menuItem.waitForExistence(timeout: 2) {
            menuItem.click()
            return
        }
        let button = app.buttons[item].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 2), "Missing menu item \(item)")
        button.click()
    }

    private func waitForPicker(_ app: XCUIApplication, identifier: String, containing needle: String) {
        let picker = app.descendants(matching: .any)[identifier].firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 5), "Missing \(identifier)")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate { evaluated, _ in
                guard let element = evaluated as? XCUIElement else { return false }
                let value = element.value as? String ?? ""
                return element.label.contains(needle) || element.title.contains(needle) || value.contains(needle)
            },
            object: picker
        )
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 4), .completed)
    }

    private func environment(_ name: String) -> String? {
        let info = ProcessInfo.processInfo.environment
        return info[name] ?? info["TEST_RUNNER_\(name)"]
    }

    private func privateRoot() throws -> URL {
        let template = FileManager.default.temporaryDirectory.appending(path: "armageddon-final-fixture.XXXXXX").path
        var buffer = Array(template.utf8CString)
        guard let created = mkdtemp(&buffer) else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        return URL(fileURLWithPath: String(cString: created))
    }

    private func exclusiveJSON(_ value: [String: Any], to url: URL) throws {
        let data = try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys]) + Data("\n".utf8)
        try exclusiveData(data, to: url)
    }

    private func exclusiveData(_ data: Data, to url: URL) throws {
        let descriptor = open(url.path, O_WRONLY | O_CREAT | O_EXCL, 0o600)
        guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { close(descriptor) }
        guard data.withUnsafeBytes({ write(descriptor, $0.baseAddress, $0.count) }) == data.count, fsync(descriptor) == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        let parent = open(url.deletingLastPathComponent().path, O_RDONLY)
        guard parent >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { close(parent) }
        guard fsync(parent) == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
    }

    private func sha256File(_ url: URL) throws -> String {
        SHA256.hash(data: try Data(contentsOf: url, options: [.mappedIfSafe])).map { String(format: "%02x", $0) }.joined()
    }

    private func monotonicNanos() -> UInt64 {
        clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
    }

    private func processArguments(_ pid: pid_t) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-p", String(pid), "-o", "args="]
        let stdout = Pipe()
        process.standardOutput = stdout
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
        } catch {
            return nil
        }
        process.waitUntilExit()
        let data = stdout.fileHandleForReading.readDataToEndOfFile()
        let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return text?.isEmpty == false ? text : nil
    }

    private func processPath(_ pid: pid_t) -> String? {
        var buffer = [CChar](repeating: 0, count: Int(MAXPATHLEN) * 4)
        let result = proc_pidpath(pid, &buffer, UInt32(buffer.count))
        guard result > 0 else { return nil }
        let bytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
        return String(decoding: bytes, as: UTF8.self)
    }
}
