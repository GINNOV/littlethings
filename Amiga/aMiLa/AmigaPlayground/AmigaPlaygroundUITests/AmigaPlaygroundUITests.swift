import XCTest

final class AmigaPlaygroundUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [
            "-ApplePersistenceIgnoreState", "YES",
            "-UITestMode", "YES"
        ]
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 8))
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testMainWindowVisualContract() {
        let window = app.windows.firstMatch
        XCTAssertTrue(window.staticTexts["Amiga Playground"].waitForExistence(timeout: 3))

        let runButtons = window.buttons.matching(NSPredicate(format: "label == %@", "Run Emulator [F6]"))
        XCTAssertEqual(runButtons.count, 1, "The main UI must expose one default-emulator run button.")
        XCTAssertEqual(runButtons.firstMatch.label, "Run Emulator [F6]")

        XCTAssertFalse(window.buttons["Run in FS-UAE [F6]"].exists)
        XCTAssertFalse(window.buttons["Validate vAmiga [F8]"].exists)
        XCTAssertFalse(window.buttons["Web Emulator [F7]"].exists)

        XCTAssertTrue(window.buttons["Assemble [F5]"].exists)
        XCTAssertTrue(window.buttons["Export Bootable ADF"].exists)
        XCTAssertTrue(window.descendants(matching: .any)["goldExamplesMenu"].exists)
        XCTAssertTrue(window.descendants(matching: .any)["assistantPromptField"].exists)
        XCTAssertTrue(window.buttons["Send"].exists)

        let screenshot = XCTAttachment(screenshot: window.screenshot())
        screenshot.name = "Main Window Visual Contract"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testIdleIndicatorStaysLightBlueAndRightAligned() {
        let window = app.windows.firstMatch
        let idleLabels = window.staticTexts.matching(NSPredicate(format: "label == %@", "IDLE"))
        XCTAssertGreaterThanOrEqual(idleLabels.count, 1)
        let indicator = idleLabels.firstMatch

        let runButton = window.buttons["Run Emulator [F6]"]
        XCTAssertTrue(runButton.exists)
        XCTAssertGreaterThan(indicator.frame.minX, runButton.frame.maxX)
        XCTAssertGreaterThan(indicator.frame.maxX, window.frame.maxX - 150)
    }

    func testMenusExposeSettingsAndEmulatorCommandsOnce() {
        let menuBar = app.menuBars.firstMatch
        XCTAssertTrue(menuBar.waitForExistence(timeout: 3))

        XCTAssertTrue(menuBar.menuBarItems["Playground"].exists)
        XCTAssertTrue(menuBar.menuBarItems["Emulator"].exists)
        XCTAssertFalse(menuBar.menuBarItems["Examples"].exists)

        XCTAssertTrue(menuBar.menuBarItems["Amiga Playground"].exists)
        menuBar.menuBarItems["Amiga Playground"].click()
        let settingsItems = menuBar.menuBarItems["Amiga Playground"].menuItems.matching(
            NSPredicate(format: "title BEGINSWITH %@", "Settings")
        )
        XCTAssertEqual(settingsItems.count, 1, "The app menu must expose one Settings item.")
        XCTAssertTrue(menuBar.menuBarItems["Amiga Playground"].menuItems["Check for Updates..."].exists)

        menuBar.menuBarItems["Emulator"].click()
        XCTAssertTrue(menuBar.menuBarItems["Emulator"].menuItems["Run Default Emulator"].exists)
        XCTAssertTrue(menuBar.menuBarItems["Emulator"].menuItems["Validate with vAmiga"].exists)
        XCTAssertTrue(menuBar.menuBarItems["Emulator"].menuItems["Run Web Emulator"].exists)

        app.typeKey(",", modifierFlags: .command)
        XCTAssertTrue(app.windows.element(boundBy: 1).waitForExistence(timeout: 5), "Command-comma must open Settings.")
    }

    func testSettingsWindowUsesExpectedTabs() {
        app.typeKey(",", modifierFlags: .command)

        XCTAssertTrue(app.windows.element(boundBy: 1).waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["General"].exists)
        XCTAssertTrue(app.buttons["AI"].exists)
        XCTAssertTrue(app.buttons["Hardware"].exists)
        XCTAssertTrue(app.buttons["FS-UAE"].exists)
        XCTAssertTrue(app.buttons["vAmiga"].exists)

        app.buttons["AI"].click()
        XCTAssertTrue(app.staticTexts["Model name"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Custom API URL"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["activeEndpointLabel"].exists)

        let screenshot = XCTAttachment(screenshot: app.windows.element(boundBy: 1).screenshot())
        screenshot.name = "Settings Tabs Visual Contract"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testSettingsExposeEmulatorPresetsAndApplySelections() {
        app.typeKey(",", modifierFlags: .command)

        let settingsWindow = app.windows.element(boundBy: 1)
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 5))

        app.buttons["Hardware"].click()
        let hardwarePreset = app.descendants(matching: .any)["hardwarePresetPicker"]
        XCTAssertTrue(
            hardwarePreset.waitForExistence(timeout: 2),
            "Hardware Settings must expose the emulator preset combo."
        )
        hardwarePreset.click()
        app.menuItems["A1200 Kickstart 3.1"].click()
        XCTAssertEqual(app.descendants(matching: .any)["emulatorModelPicker"].value as? String, "A1200")
        XCTAssertEqual(app.descendants(matching: .any)["emulatorCpuPicker"].value as? String, "68020")
        XCTAssertEqual(app.descendants(matching: .any)["emulatorChipRamPicker"].value as? String, "2 MB")

        let hardwareScreenshot = XCTAttachment(screenshot: settingsWindow.screenshot())
        hardwareScreenshot.name = "Hardware Emulator Preset Settings"
        hardwareScreenshot.lifetime = .keepAlways
        add(hardwareScreenshot)

        app.buttons["FS-UAE"].click()
        let launchPreset = app.descendants(matching: .any)["fsUaeArgumentPresetPicker"]
        XCTAssertTrue(
            launchPreset.waitForExistence(timeout: 2),
            "FS-UAE Settings must expose the launch-argument preset combo."
        )
        launchPreset.click()
        app.menuItems["Classic CRT look"].click()
        XCTAssertEqual(
            app.descendants(matching: .any)["fsUaeCustomArgumentsField"].value as? String,
            "--scanlines=1 --keep_aspect=1"
        )

        let screenshot = XCTAttachment(screenshot: settingsWindow.screenshot())
        screenshot.name = "Emulator Preset Settings"
        screenshot.lifetime = .keepAlways
        add(screenshot)

        app.terminate()
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 8))
        app.typeKey(",", modifierFlags: .command)
        XCTAssertTrue(app.windows.element(boundBy: 1).waitForExistence(timeout: 5))

        app.buttons["Hardware"].click()
        XCTAssertEqual(
            app.descendants(matching: .any)["hardwarePresetPicker"].value as? String,
            "A1200 Kickstart 3.1",
            "The selected hardware preset must survive an app relaunch."
        )

        app.buttons["FS-UAE"].click()
        XCTAssertEqual(
            app.descendants(matching: .any)["fsUaeArgumentPresetPicker"].value as? String,
            "Classic CRT look",
            "The selected FS-UAE preset must survive an app relaunch."
        )
    }
}
