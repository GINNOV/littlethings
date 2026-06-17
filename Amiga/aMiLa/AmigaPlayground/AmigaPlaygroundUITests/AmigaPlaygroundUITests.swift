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
        XCTAssertTrue(app.buttons["Code"].exists)
        XCTAssertTrue(app.buttons["Hardware"].exists)
        XCTAssertTrue(app.buttons["FS-UAE"].exists)
        XCTAssertTrue(app.buttons["vAmiga"].exists)

        app.buttons["Code"].click()
        XCTAssertTrue(app.checkBoxes["Generate comments"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.descendants(matching: .any)["generateCodeCommentsToggle"].exists)

        app.buttons["AI"].click()
        XCTAssertTrue(app.staticTexts["Model name"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Custom API URL"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["activeEndpointLabel"].exists)

        let screenshot = XCTAttachment(screenshot: app.windows.element(boundBy: 1).screenshot())
        screenshot.name = "Settings Tabs Visual Contract"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testPromptLibraryShowsGuidedProgressHeader() {
        app.typeKey("l", modifierFlags: [.command, .option])

        let promptWindow = app.windows["Prompt Library"]
        XCTAssertTrue(promptWindow.waitForExistence(timeout: 5))
        XCTAssertTrue(promptWindow.descendants(matching: .any)["promptProgressHeader"].waitForExistence(timeout: 3))
        XCTAssertEqual(promptWindow.descendants(matching: .any)["demoSchoolSequenceNumber"].label, "Lesson 1 of 30")
        XCTAssertTrue(promptWindow.staticTexts["01 Foundations - Minimal Executable"].exists)
        XCTAssertTrue(promptWindow.staticTexts["Foundations / Reference / Beginner"].exists)

        let nextButton = promptWindow.descendants(matching: .any)["demoSchoolNextButton"]
        XCTAssertTrue(nextButton.exists)
        nextButton.click()

        XCTAssertTrue(promptWindow.staticTexts["02 Foundations - Registers and Stack"].waitForExistence(timeout: 2))
        XCTAssertEqual(promptWindow.descendants(matching: .any)["demoSchoolSequenceNumber"].label, "Lesson 2 of 30")

        let screenshot = XCTAttachment(screenshot: promptWindow.screenshot())
        screenshot.name = "Prompt Library Guided Progress"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testExampleLibraryShowsGuidedProgressHeader() {
        app.typeKey("e", modifierFlags: [.command, .option])

        let exampleWindow = app.windows["Example Library"]
        XCTAssertTrue(exampleWindow.waitForExistence(timeout: 5))
        XCTAssertTrue(exampleWindow.descendants(matching: .any)["exampleProgressHeader"].waitForExistence(timeout: 3))
        XCTAssertEqual(exampleWindow.descendants(matching: .any)["demoSchoolSequenceNumber"].label, "Lesson 1 of 10")
        XCTAssertTrue(exampleWindow.staticTexts["01 ASM Clean Takeover Skeleton"].exists)
        XCTAssertTrue(exampleWindow.staticTexts["System / System / Intermediate"].exists)

        let nextButton = exampleWindow.descendants(matching: .any)["demoSchoolNextButton"]
        XCTAssertTrue(nextButton.exists)
        nextButton.click()

        XCTAssertTrue(exampleWindow.staticTexts["02 ASM Copper Rainbow Lab"].waitForExistence(timeout: 2))
        XCTAssertEqual(exampleWindow.descendants(matching: .any)["demoSchoolSequenceNumber"].label, "Lesson 2 of 10")

        let screenshot = XCTAttachment(screenshot: exampleWindow.screenshot())
        screenshot.name = "Example Library Guided Progress"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
