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
        lightApp.typeKey("1", modifierFlags: .command)
        XCTAssertTrue(lightApp.descendants(matching: .any)["workspace.live"].waitForExistence(timeout: 2))
        let performanceHealth = lightApp.descendants(matching: .any)["live.performance-health"].firstMatch
        XCTAssertTrue(performanceHealth.waitForExistence(timeout: 5))
        XCTAssertEqual(performanceHealth.value as? String, "Ready")
        try capture(lightApp, named: "app-shell-light-1280x800")

        let canvas = lightApp.descendants(matching: .any)["live.canvas"].firstMatch
        lightApp.typeKey("1", modifierFlags: .command)
        XCTAssertTrue(canvas.waitForExistence(timeout: 2))
        let sidebar = lightApp.descendants(matching: .any)["app.sidebar"].firstMatch
        let inspector = lightApp.descendants(matching: .any)["inspector.live"].firstMatch
        XCTAssertTrue(sidebar.waitForExistence(timeout: 2))
        XCTAssertTrue(inspector.waitForExistence(timeout: 2))
        let detailColumnWidth = lightApp.windows.firstMatch.frame.width - sidebar.frame.width - inspector.frame.width
        XCTAssertGreaterThanOrEqual(canvas.frame.width, detailColumnWidth * 0.60)
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

    func testTask30CapturesCompleteAppearanceMatrix() throws {
        let sizes = [(1_100, 720), (1_280, 800), (1_440, 900), (1_728, 1_117)]
        let appearances = [
            (name: "light", style: "Light", increaseContrast: false),
            (name: "dark", style: "Dark", increaseContrast: false),
            (name: "contrast", style: "Light", increaseContrast: true),
        ]

        for appearance in appearances {
            for (width, height) in sizes {
                let app = try launch(
                    style: appearance.style,
                    width: width,
                    height: height,
                    increaseContrast: appearance.increaseContrast
                )
                XCTAssertTrue(app.descendants(matching: .any)["workspace.live"].waitForExistence(timeout: 3))
                try capture(app, named: "task30-\(appearance.name)-\(width)x\(height)")
                app.terminate()
            }
        }
    }

    func testLiveWorkspaceSelectsPausesCapturesAndOpensManualDrawer() throws {
        let app = try launch(style: "Light", width: 1_280, height: 800)

        waitForHealth(app, value: "Ready")

        chooseMenu(app, identifier: "live.source-picker", item: "Recorded fixture")
        waitForPicker(app, identifier: "live.source-picker", containing: "Recorded fixture")

        chooseMenu(app, identifier: "live.model-picker", item: "Recorded fixture detector")
        waitForPicker(app, identifier: "live.model-picker", containing: "Recorded fixture detector")

        let target = app.descendants(matching: .any)["live.detection.target"].firstMatch
        XCTAssertTrue(target.waitForExistence(timeout: 5))
        target.click()
        XCTAssertTrue(app.descendants(matching: .any)["inspector.target"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Selected"].waitForExistence(timeout: 2))

        let pauseResume = app.buttons["live.pause-resume"]
        pauseResume.click()
        XCTAssertTrue(app.descendants(matching: .any)["live.paused"].waitForExistence(timeout: 2))
        pauseResume.click()
        app.buttons["live.capture"].click()
        XCTAssertTrue(app.staticTexts["Frame 1 staged for capture review."].waitForExistence(timeout: 2))

        let manualControls = app.descendants(matching: .any)["live.manual-controls"].firstMatch
        XCTAssertTrue(manualControls.waitForExistence(timeout: 2))
        let disclosure = app.disclosureTriangles.matching(NSPredicate(format: "label CONTAINS 'Manual'")).firstMatch
        if disclosure.waitForExistence(timeout: 1) {
            disclosure.click()
        } else {
            manualControls.click()
        }
        XCTAssertTrue(
            app.descendants(matching: .any)["live.manual.minus-x"].waitForExistence(timeout: 5)
                || app.descendants(matching: .any)["live.manual-motion-buttons"].waitForExistence(timeout: 2)
                || app.buttons["+ X"].waitForExistence(timeout: 1)
        )
        let stop = app.descendants(matching: .any)["stop.button"].firstMatch
        XCTAssertTrue(stop.waitForExistence(timeout: 2), "Missing stop.button")
        stop.click()
        XCTAssertTrue(app.staticTexts["STOP requested"].waitForExistence(timeout: 2))
        try capture(app, named: "live-workspace-core-flow")
        app.terminate()
    }

    func testLiveWorkspaceOverlayCoordinatesAtSupportedWindowSizes() throws {
        for (width, height) in [(1_100, 720), (1_280, 800), (1_440, 900)] {
            let app = try launch(style: "Light", width: width, height: height)
            waitForHealth(app, value: "Ready")
            let canvas = app.descendants(matching: .any)["live.canvas"].firstMatch
            let target = app.descendants(matching: .any)["live.detection.target"].firstMatch
            XCTAssertTrue(canvas.waitForExistence(timeout: 5))
            XCTAssertTrue(target.waitForExistence(timeout: 5))
            assertTargetFrame(target.frame, in: canvas.frame.insetBy(dx: 20, dy: 20))
            try capture(app, named: "live-overlay-\(width)x\(height)")
            app.terminate()
        }
    }

    func testCalibrationWizardValidEightPointProfile() throws {
        let app = try launch(style: "Light", width: 1_440, height: 900)
        try advanceCalibrationToPoints(app)
        for _ in 0..<8 {
            app.buttons["calibration.record-point"].click()
        }
        app.buttons["calibration.continue"].click()
        XCTAssertTrue(app.descendants(matching: .any)["calibration.residuals"].waitForExistence(timeout: 3))
        app.buttons["calibration.activate"].click()
        XCTAssertTrue(app.staticTexts["Active"].waitForExistence(timeout: 2))
        try capture(app, named: "calibration-valid-profile")
        app.terminate()
    }

    func testCalibrationWizardRefusesHighErrorProfile() throws {
        let app = try launch(style: "Light", width: 1_440, height: 900)
        try advanceCalibrationToPoints(app)
        chooseMenu(app, identifier: "calibration.fixture-quality", item: "High-error fixture")
        waitForPicker(app, identifier: "calibration.fixture-quality", containing: "High-error")
        for _ in 0..<8 {
            app.buttons["calibration.record-point"].click()
        }
        app.descendants(matching: .any)["calibration.continue"].firstMatch.click()
        XCTAssertTrue(app.descendants(matching: .any)["calibration.error"].waitForExistence(timeout: 3))
        let activate = app.descendants(matching: .any)["calibration.activate"].firstMatch
        XCTAssertTrue(activate.waitForExistence(timeout: 2))
        XCTAssertFalse(activate.isEnabled)
        try capture(app, named: "calibration-high-error-refused")
        app.terminate()
    }

    func testUnknownDestinationRecoversToLive() throws {
        let app = try launch(style: "Light", width: 1_100, height: 720, destination: "unknown.destination")

        XCTAssertTrue(app.descendants(matching: .any)["workspace.live"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Navigation recovered to Live"].waitForExistence(timeout: 2))
        try capture(app, named: "app-shell-recovered-1100x720")
        app.terminate()
    }

    func testRunsSurfaceShowsFailClosedDryRunPrerequisites() throws {
        let app = try launch(style: "Light", width: 1_280, height: 800)
        app.buttons["sidebar.runs"].click()
        XCTAssertTrue(app.descendants(matching: .any)["runs.dry-run"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["runs.prerequisites"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["runs.no-write-guarantee"].waitForExistence(timeout: 2))
        try capture(app, named: "runs-fail-closed-dry-run")
        let runsCard = app.descendants(matching: .any)["runs.dry-run"].firstMatch
        try ScreenshotContrast.assertLightOnDarkCanvas(runsCard.screenshot().pngRepresentation)
        app.terminate()
    }

    func testCaptureLibraryShowsFixtureFrameAndReadableLabels() throws {
        let app = try launch(style: "Light", width: 1_280, height: 800)
        chooseMenu(app, identifier: "live.source-picker", item: "Recorded fixture")
        waitForPicker(app, identifier: "live.source-picker", containing: "Recorded fixture")
        app.buttons["live.capture"].click()
        XCTAssertTrue(app.staticTexts["Frame 1 staged for capture review."].waitForExistence(timeout: 2))
        app.buttons["sidebar.capture"].click()
        XCTAssertTrue(app.descendants(matching: .any)["workspace.capture"].waitForExistence(timeout: 3))
        let captureCard = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier MATCHES %@", "capture\\.[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}")
        ).firstMatch
        XCTAssertTrue(captureCard.waitForExistence(timeout: 3), "Missing capture card")
        try capture(app, named: "capture-library-fixture-frame")
        let png = captureCard.screenshot().pngRepresentation
        let metrics = try ScreenshotContrast.metrics(png: png)
        try ScreenshotContrast.assertLightOnDarkCanvas(png)
        XCTAssertGreaterThan(metrics.meanLuma, 0.08, "fixture capture tile is still a black placeholder")
        app.terminate()
    }

    func testCalibratedDryRunExecutesOneSupervisedMove() throws {
        let app = try launch(style: "Light", width: 1_280, height: 800, profile: "calibrated-dry-run")
        waitForHealth(app, value: "Ready")
        chooseMenu(app, identifier: "live.source-picker", item: "Recorded fixture")
        waitForPicker(app, identifier: "live.source-picker", containing: "Recorded fixture")

        let target = app.descendants(matching: .any)["live.detection.target"].firstMatch
        XCTAssertTrue(target.waitForExistence(timeout: 5))
        target.click()
        app.buttons["sidebar.runs"].click()
        XCTAssertTrue(app.descendants(matching: .any)["runs.dry-run"].waitForExistence(timeout: 3))

        let prepare = app.buttons["runs.prepare"]
        XCTAssertTrue(prepare.waitForExistence(timeout: 2))
        XCTAssertTrue(prepare.isEnabled)
        prepare.click()
        let status = app.descendants(matching: .any)["runs.status"].firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 3))
        XCTAssertTrue(status.label.contains("Ready for confirmation") || (status.value as? String)?.contains("Ready for confirmation") == true)

        let execute = app.buttons["runs.execute"]
        XCTAssertTrue(execute.isEnabled)
        execute.click()
        let completed = XCTNSPredicateExpectation(
            predicate: NSPredicate { evaluated, _ in
                guard let element = evaluated as? XCUIElement else { return false }
                return element.label.contains("Completed") || (element.value as? String)?.contains("Completed") == true
            },
            object: status
        )
        XCTAssertEqual(XCTWaiter.wait(for: [completed], timeout: 5), .completed)
        XCTAssertTrue(app.descendants(matching: .any)["runs.timeline"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["completed"].waitForExistence(timeout: 2))
        try capture(app, named: "runs-supervised-fixture-completed")
        app.terminate()
    }

    func testModelsAndDiagnosticsWorkflowShowsBoundedLocalActions() throws {
        let app = try launch(style: "Light", width: 1_280, height: 800)

        app.buttons["sidebar.models"].click()
        XCTAssertTrue(app.descendants(matching: .any)["workspace.models"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["models.import"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["models.huenit-unsupported"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["No verified models"].waitForExistence(timeout: 2))
        try capture(app, named: "models-workspace-empty")

        app.buttons["sidebar.diagnostics"].click()
        XCTAssertTrue(app.descendants(matching: .any)["workspace.diagnostics"].waitForExistence(timeout: 3))
        let exportButton = app.descendants(matching: .any)["diagnostics.export"]
        XCTAssertTrue(exportButton.waitForExistence(timeout: 2))
        XCTAssertEqual(exportButton.elementType, .button)
        app.terminate()
    }

    func testModelsWorkspaceEmptyStateRemainsSafe() throws {
        let app = try launch(style: "Light", width: 1_100, height: 720)

        app.typeKey("3", modifierFlags: .command)
        XCTAssertTrue(app.descendants(matching: .any)["workspace.models"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["No verified models"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["models.huenit-unsupported"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.descendants(matching: .any)["model.detail.provenance"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["model.detail.activate"].exists)
        try capture(app, named: "models-workspace-empty-safe")
        app.terminate()
    }

    func testSettingsInspectorPreferenceControlsPresentation() throws {
        let appDefaults = try XCTUnwrap(UserDefaults(suiteName: "com.huenit.ArmageddonApp"))
        let previousValue = appDefaults.object(forKey: "showInspectorOnLaunch")
        appDefaults.set(false, forKey: "showInspectorOnLaunch")
        addTeardownBlock {
            if let previousValue {
                appDefaults.set(previousValue, forKey: "showInspectorOnLaunch")
            } else {
                appDefaults.removeObject(forKey: "showInspectorOnLaunch")
            }
        }

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

    func testSourceHelpDialogLoadsDocumentation() throws {
        let app = try launch(style: "Light", width: 1_280, height: 800)
        let help = app.descendants(matching: .any)["live.source-help"].firstMatch
        XCTAssertTrue(help.waitForExistence(timeout: 5), "Missing live source manual button")
        help.click()
        XCTAssertTrue(app.descendants(matching: .any)["live.source-manual"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Native camera"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Recorded fixture"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["HUENIT telemetry · detection only"].waitForExistence(timeout: 2))
        let dialog = app.descendants(matching: .any)["live.source-manual"].firstMatch
        app.buttons["live.source-manual.close"].click()
        XCTAssertTrue(dialog.waitForNonExistence(timeout: 3))
        app.terminate()
    }

    func testNativeCameraPickerListsDiscoveredFixtureCamera() throws {
        let app = try launch(style: "Light", width: 1_280, height: 800)
        XCTAssertTrue(app.descendants(matching: .any)["live.camera-device"].waitForExistence(timeout: 5))
        waitForPicker(app, identifier: "live.camera-device", containing: "Fixture camera")
        chooseMenu(app, identifier: "live.source-picker", item: "Recorded fixture")
        waitForPicker(app, identifier: "live.source-picker", containing: "Recorded fixture")
        XCTAssertFalse(app.descendants(matching: .any)["live.camera-device"].firstMatch.exists)
        try capture(app, named: "native-camera-picker-fixture")
        app.terminate()
    }

    func testCameraPermissionDeniedOffersRecoveryAction() throws {
        let app = try launch(style: "Light", width: 1_100, height: 720, profile: "permission-denied")

        XCTAssertTrue(app.descendants(matching: .any)["camera.authorization-card"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Open Camera Settings"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Allow Camera Access"].exists)
        app.terminate()
    }

    func testCameraDisconnectCancelsWorkAndOffersRescan() throws {
        let app = try launch(style: "Light", width: 1_100, height: 720, profile: "camera-disconnected")

        XCTAssertTrue(app.staticTexts["Camera disconnected"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["camera.rescan"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["camera.work-cancelled"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["live.source-stale"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["arm.status"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Arm, Disarmed"].exists)
        try capture(app, named: "live-workspace-disconnected")
        app.terminate()
    }

    func testModelFailureAndNoDeviceStatesOfferRecovery() throws {
        let failed = try launch(style: "Light", width: 1_100, height: 720, profile: "model-failed")
        waitForHealth(failed, value: "Model unavailable")
        let retry = failed.descendants(matching: .any)["live.retry-detection"].firstMatch
        XCTAssertTrue(retry.waitForExistence(timeout: 5), "Missing live.retry-detection")
        retry.click()
        waitForHealth(failed, value: "Ready")
        failed.terminate()

        let noDevices = try launch(style: "Light", width: 1_100, height: 720, profile: "no-devices")
        XCTAssertTrue(noDevices.descendants(matching: .any)["camera.authorization-card"].waitForExistence(timeout: 5))
        let rescan = noDevices.descendants(matching: .any)["camera.rescan"].firstMatch
        XCTAssertTrue(
            rescan.waitForExistence(timeout: 3) || noDevices.buttons["Rescan Cameras"].waitForExistence(timeout: 2),
            "Missing camera rescan control"
        )
        noDevices.terminate()
    }

    private func launch(
        style: String,
        width: Int,
        height: Int,
        destination: String? = nil,
        profile: String = "all-connected",
        increaseContrast: Bool = false
    ) throws -> XCUIApplication {
        let root = try privateRoot()
        addTeardownBlock { try? FileManager.default.removeItem(at: root) }
        let paths = try isolatedPaths(root: root)
        let app = XCUIApplication()
        app.launchEnvironment = ["CFFIXED_USER_HOME": paths.home.path]
        app.launchArguments = [
            "-ui-testing", "-fixture-profile", profile,
            "-qa-preference-suite", "com.huenit.ArmageddonUITests.shell.\(UUID().uuidString)",
            "-qa-application-support-root", paths.support.path,
            "-qa-cache-root", paths.cache.path,
            "-qa-temp-root", paths.temporary.path,
            "-qa-fixture-root", paths.fixtures.path,
            "-qa-window-width", String(width),
            "-qa-window-height", String(height),
            "-AppleInterfaceStyle", style,
        ]
        if increaseContrast {
            app.launchArguments += ["-AppleIncreaseContrast", "YES"]
        }
        if let destination {
            app.launchArguments += ["-fixture-destination", destination]
        }
        app.launch()
        app.activate()
        XCTAssertTrue(app.descendants(matching: .any)["app.shell"].waitForExistence(timeout: 8))
        return app
    }

    private func waitForHealth(_ app: XCUIApplication, value: String, timeout: TimeInterval = 8) {
        let health = app.descendants(matching: .any)["live.performance-health"].firstMatch
        XCTAssertTrue(health.waitForExistence(timeout: 5), "Missing live.performance-health")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", value),
            object: health
        )
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(
            result,
            .completed,
            "Expected health \(value), got \(String(describing: health.value))"
        )
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
                return element.label.contains(needle)
                    || element.title.contains(needle)
                    || value.contains(needle)
            },
            object: picker
        )
        let result = XCTWaiter.wait(for: [expectation], timeout: 4)
        XCTAssertEqual(
            result,
            .completed,
            "Expected \(identifier) to contain \(needle), got label=\(picker.label) title=\(picker.title) value=\(String(describing: picker.value))"
        )
    }

    private func capture(_ app: XCUIApplication, named name: String) throws {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let directories: [String?] = [
            ProcessInfo.processInfo.environment["ARMAGEDDON_SCREENSHOT_DIR"],
            FileManager.default.temporaryDirectory.appending(path: "armageddon-ui-screenshots").path,
        ]
        for directory in directories.compactMap({ $0 }) {
            let folder = URL(fileURLWithPath: directory, isDirectory: true)
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let file = folder.appending(path: "\(name).png")
            if (try? screenshot.pngRepresentation.write(to: file, options: .atomic)) != nil {
                break
            }
        }
    }

    private func advanceCalibrationToPoints(_ app: XCUIApplication) throws {
        XCTAssertTrue(app.descendants(matching: .any)["calibration.wizard"].waitForExistence(timeout: 5))
        for _ in 0..<3 {
            app.buttons["calibration.continue"].click()
        }
        XCTAssertTrue(app.buttons["calibration.record-point"].waitForExistence(timeout: 2))
    }

    private func assertTargetFrame(_ actual: CGRect, in overlay: CGRect) {
        // Fixture Vision boxes are oriented-image normalized (1920×1080), not model pixels.
        let oriented = CGRect(x: 0.25 * 1_920.0, y: 0.25 * 1_080.0, width: 0.2 * 1_920.0, height: 0.2 * 1_080.0)
        let viewScale = min(overlay.width / 1_920.0, overlay.height / 1_080.0)
        let xOffset = (overlay.width - 1_920.0 * viewScale) / 2
        let yOffset = (overlay.height - 1_080.0 * viewScale) / 2
        let expected = CGRect(
            x: overlay.minX + xOffset + oriented.minX * viewScale,
            y: overlay.minY + yOffset + oriented.minY * viewScale,
            width: oriented.width * viewScale,
            height: oriented.height * viewScale
        )
        XCTAssertEqual(actual.minX, expected.minX, accuracy: 1)
        XCTAssertEqual(actual.minY, expected.minY, accuracy: 1)
        XCTAssertEqual(actual.width, expected.width, accuracy: 1)
        XCTAssertEqual(actual.height, expected.height, accuracy: 1)
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
