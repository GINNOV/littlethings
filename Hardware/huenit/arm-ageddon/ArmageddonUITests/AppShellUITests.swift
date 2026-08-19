import Darwin
import XCTest

@MainActor
final class AppShellUITests: XCTestCase {
    private let destinations = ["live", "capture", "models", "runs", "diagnostics"]

    func testSidebarAndKeyboardNavigationStopsAndCapturesAppearances() throws {
        let lightApp = try launch(style: "Light", width: 1_280, height: 800)

        for destination in destinations {
            let sidebar = lightApp.buttons["sidebar.\(destination)"]
            XCTAssertTrue(sidebar.waitForExistence(timeout: 5), "Missing sidebar control for \(destination)")
            sidebar.click()
            XCTAssertTrue(lightApp.descendants(matching: .any)["workspace.\(destination)"].waitForExistence(timeout: 2))
        }

        for (index, destination) in destinations.enumerated() {
            lightApp.typeKey(String(index + 1), modifierFlags: .command)
            XCTAssertTrue(lightApp.descendants(matching: .any)["workspace.\(destination)"].waitForExistence(timeout: 2))
        }

        lightApp.typeKey(.escape, modifierFlags: [])
        XCTAssertTrue(lightApp.staticTexts["STOP requested"].waitForExistence(timeout: 2))
        try capture(lightApp, named: "app-shell-light-1280x800")

        let canvas = lightApp.descendants(matching: .any)["live.canvas"].firstMatch
        lightApp.typeKey("1", modifierFlags: .command)
        XCTAssertTrue(canvas.waitForExistence(timeout: 2))
        XCTAssertGreaterThanOrEqual(canvas.frame.width, lightApp.windows.firstMatch.frame.width * 0.60)
        lightApp.terminate()

        let darkApp = try launch(style: "Dark", width: 1_280, height: 800)
        try capture(darkApp, named: "app-shell-dark-1280x800")
        darkApp.terminate()
    }

    func testShellFitsMinimumAndLargeWindowSizes() throws {
        for (width, height) in [(1_100, 720), (1_440, 900)] {
            let app = try launch(style: "Light", width: width, height: height)
            let window = app.windows.firstMatch
            XCTAssertTrue(window.waitForExistence(timeout: 5))
            let workspace = app.descendants(matching: .any)["workspace.live"]
            XCTAssertTrue(workspace.waitForExistence(timeout: 2))
            XCTAssertGreaterThanOrEqual(workspace.frame.minX, window.frame.minX)
            XCTAssertLessThanOrEqual(workspace.frame.maxX, window.frame.maxX)
            XCTAssertGreaterThanOrEqual(workspace.frame.minY, window.frame.minY)
            XCTAssertLessThanOrEqual(workspace.frame.maxY, window.frame.maxY)
            try capture(app, named: "app-shell-light-\(width)x\(height)")
            app.terminate()
        }
    }

    func testUnknownDestinationRecoversToLive() throws {
        let app = try launch(style: "Light", width: 1_100, height: 720, destination: "unknown.destination")

        XCTAssertTrue(app.descendants(matching: .any)["workspace.live"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Navigation recovered to Live"].waitForExistence(timeout: 2))
        try capture(app, named: "app-shell-recovered-1100x720")
        app.terminate()
    }

    func testSettingsInspectorPreferenceControlsPresentation() throws {
        let app = try launch(style: "Light", width: 1_280, height: 800)
        let inspector = app.descendants(matching: .any)["inspector.live"]
        XCTAssertTrue(inspector.waitForExistence(timeout: 5), "The inspector should be visible by default")

        app.typeKey(",", modifierFlags: .command)
        let showInspector = app.descendants(matching: .any)["settings.show-inspector"]
        XCTAssertTrue(showInspector.waitForExistence(timeout: 5), "The Settings toggle should open with Command-comma")
        showInspector.click()
        XCTAssertFalse(inspector.waitForExistence(timeout: 2), "Disabling the setting should dismiss the inspector")
        try capture(app, named: "app-shell-settings-inspector-hidden")
        app.terminate()
    }

    private func launch(style: String, width: Int, height: Int, destination: String? = nil) throws -> XCUIApplication {
        let root = try privateRoot()
        addTeardownBlock { try? FileManager.default.removeItem(at: root) }
        let paths = try isolatedPaths(root: root)
        let app = XCUIApplication()
        app.launchEnvironment = ["CFFIXED_USER_HOME": paths.home.path]
        app.launchArguments = [
            "-ui-testing", "-fixture-profile", "all-connected",
            "-qa-preference-suite", "com.huenit.ArmageddonUITests.shell.\(UUID().uuidString)",
            "-qa-application-support-root", paths.support.path,
            "-qa-cache-root", paths.cache.path,
            "-qa-temp-root", paths.temporary.path,
            "-qa-fixture-root", paths.fixtures.path,
            "-qa-window-width", String(width),
            "-qa-window-height", String(height),
            "-AppleInterfaceStyle", style,
        ]
        if let destination {
            app.launchArguments += ["-fixture-destination", destination]
        }
        app.launch()
        app.activate()
        XCTAssertTrue(app.descendants(matching: .any)["app.shell"].waitForExistence(timeout: 8))
        return app
    }

    private func capture(_ app: XCUIApplication, named name: String) throws {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let output = ProcessInfo.processInfo.environment["ARMAGEDDON_SCREENSHOT_DIR"] {
            try screenshot.pngRepresentation.write(to: URL(fileURLWithPath: output).appending(path: "\(name).png"), options: .atomic)
        }
    }

    private func privateRoot() throws -> URL {
        let template = FileManager.default.temporaryDirectory.appending(path: "armageddon-shell-ui.XXXXXX").path
        var buffer = Array(template.utf8CString)
        guard let created = mkdtemp(&buffer) else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        return URL(fileURLWithPath: String(cString: created))
    }

    private func isolatedPaths(root: URL) throws -> (home: URL, support: URL, cache: URL, temporary: URL, fixtures: URL) {
        let urls = ["home", "support", "cache", "temporary", "fixtures"].map { root.appending(path: $0) }
        for url in urls {
            guard mkdir(url.path, 0o700) == 0 else { throw CocoaError(.fileWriteUnknown) }
        }
        return (urls[0], urls[1], urls[2], urls[3], urls[4])
    }
}
