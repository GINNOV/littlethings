import Darwin
import XCTest

final class LaunchProfileTests: XCTestCase {
    func testAllFixtureProfilesReachStableUI() throws {
        let profiles = ["no-devices", "permission-denied", "camera-disconnected", "all-connected", "model-failed", "calibrated-dry-run", "stop-unconfirmed"]
        for profile in profiles {
            let root = try privateRoot(profile: profile)
            addTeardownBlock { try FileManager.default.removeItem(at: root) }
            let paths = try isolatedPaths(root: root)
            let app = XCUIApplication()
            app.launchEnvironment = ["CFFIXED_USER_HOME": paths.home.path]
            app.launchArguments = ["-ui-testing", "-fixture-profile", profile, "-qa-preference-suite", "com.huenit.ArmageddonUITests.\(profile)", "-qa-application-support-root", paths.support.path, "-qa-cache-root", paths.cache.path, "-qa-temp-root", paths.temporary.path, "-qa-fixture-root", paths.fixtures.path]

            app.launch()
            app.activate()

            XCTAssertTrue(app.descendants(matching: .any)["launch.profile.\(profile)"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.descendants(matching: .any)["launch.ready"].exists)
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "launch-profile-\(profile)"
            attachment.lifetime = .keepAlways
            add(attachment)
            app.terminate()
        }
        try awaitObservationGateIfRequested()
    }

    private func privateRoot(profile: String) throws -> URL {
        let template = FileManager.default.temporaryDirectory.appending(path: "armageddon-ui-\(profile).XXXXXX").path
        var buffer = Array(template.utf8CString)
        guard let created = mkdtemp(&buffer) else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        return URL(fileURLWithPath: String(cString: created))
    }

    private func isolatedPaths(root: URL) throws -> (home: URL, support: URL, cache: URL, temporary: URL, fixtures: URL) {
        let names = ["home", "support", "cache", "temporary", "fixtures"]
        let urls = names.map { root.appending(path: $0) }
        for url in urls {
            guard mkdir(url.path, 0o700) == 0 else { throw CocoaError(.fileWriteUnknown) }
        }
        return (urls[0], urls[1], urls[2], urls[3], urls[4])
    }

    private func awaitObservationGateIfRequested() throws {
        guard let rawGate = ProcessInfo.processInfo.environment["ARMAGEDDON_QA_OBSERVATION_GATE"] else { return }
        let gate = URL(fileURLWithPath: rawGate).standardizedFileURL
        let ready = gate.deletingLastPathComponent().appending(path: "observation-ready.json")
        let value = Data("{\"hardwareUsed\":false,\"journey\":\"six-launch-profiles\",\"schemaVersion\":1}\n".utf8)
        let descriptor = open(ready.path, O_WRONLY | O_CREAT | O_EXCL, 0o600)
        guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { close(descriptor) }
        guard value.withUnsafeBytes({ write(descriptor, $0.baseAddress, $0.count) }) == value.count, fsync(descriptor) == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        let gateDescriptor = open(gate.path, O_RDONLY)
        guard gateDescriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { close(gateDescriptor) }
        var token: UInt8 = 0
        guard read(gateDescriptor, &token, 1) == 1, token == 49 else { throw CocoaError(.fileReadCorruptFile) }
    }
}
