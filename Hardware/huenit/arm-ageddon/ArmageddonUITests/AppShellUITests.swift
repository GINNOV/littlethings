import Darwin
import XCTest

@MainActor
final class AppShellUITests: XCTestCase {
    func testGoWorkspaceAndStop() throws {
        let app = try launch(style: "Light", width: 1_280, height: 800)
        XCTAssertTrue(app.descendants(matching: .any)["workspace.go"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["go.connect-arm"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["go.teach.bowl"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["sidebar.live"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["live.source-picker"].firstMatch.exists)
        let stop = app.descendants(matching: .any)["stop.button"].firstMatch
        XCTAssertTrue(stop.waitForExistence(timeout: 2))
        stop.click()
        XCTAssertTrue(app.staticTexts["STOP requested"].waitForExistence(timeout: 2))
        try capture(app, named: "go-workspace")
        app.terminate()
    }

    func testShellFitsMinimumWindow() throws {
        let app = try launch(style: "Light", width: 1_100, height: 720)
        let workspace = app.descendants(matching: .any)["workspace.go"]
        XCTAssertTrue(workspace.waitForExistence(timeout: 5))
        app.terminate()
    }

    private func launch(style: String, width: Int, height: Int) throws -> XCUIApplication {
        let root = try privateRoot()
        addTeardownBlock { try? FileManager.default.removeItem(at: root) }
        let urls = ["home", "support", "cache", "temporary", "fixtures"].map { root.appending(path: $0) }
        for url in urls {
            guard mkdir(url.path, 0o700) == 0 else { throw CocoaError(.fileWriteUnknown) }
        }
        let app = XCUIApplication()
        app.launchEnvironment = ["CFFIXED_USER_HOME": urls[0].path]
        app.launchArguments = [
            "-ui-testing", "-fixture-profile", "all-connected",
            "-qa-preference-suite", "com.huenit.ArmageddonUITests.shell.\(UUID().uuidString)",
            "-qa-application-support-root", urls[1].path,
            "-qa-cache-root", urls[2].path,
            "-qa-temp-root", urls[3].path,
            "-qa-fixture-root", urls[4].path,
            "-qa-window-width", String(width),
            "-qa-window-height", String(height),
            "-AppleInterfaceStyle", style,
        ]
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
    }

    private func privateRoot() throws -> URL {
        let template = FileManager.default.temporaryDirectory.appending(path: "armageddon-ui.XXXXXX").path
        var buffer = Array(template.utf8CString)
        guard let created = mkdtemp(&buffer) else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        return URL(fileURLWithPath: String(cString: created))
    }
}
