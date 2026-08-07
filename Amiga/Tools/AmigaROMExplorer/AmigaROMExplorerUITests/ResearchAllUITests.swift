import XCTest

final class ResearchAllUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [UITestingSupport.launchArgument]
        app.launchEnvironment["UI_TESTING"] = "1"
    }

    func testSidebarRefreshMissingResearchShowsCachedFeedback() throws {
        app.launchArguments.append(UITestingSupport.disableSubAgentsArgument)
        launchApp()

        try waitForLoadedResearchCache()

        sidebarButton(UITestingSupport.AccessibilityID.Research.refreshMissing, label: "Refresh Missing Research").click()

        let message = app.staticTexts[UITestingSupport.AccessibilityID.Research.bulkMessageSidebar]
        XCTAssertTrue(message.waitForExistence(timeout: 3))
        XCTAssertTrue(message.label.contains("already have research profiles"))
    }

    func testWelcomeResearchAllQueuesWhenSubAgentsEnabled() throws {
        launchApp()

        try waitForLoadedResearchCache()

        sidebarButton(UITestingSupport.AccessibilityID.Research.researchAll, label: "Research All").click()

        let welcomeMessage = app.staticTexts[UITestingSupport.AccessibilityID.Research.bulkMessageWelcome]
        let sidebarMessage = app.staticTexts[UITestingSupport.AccessibilityID.Research.bulkMessageSidebar]
        let inProgress = app.otherElements[UITestingSupport.AccessibilityID.Research.researchInProgress]

        let showedFeedback =
            welcomeMessage.waitForExistence(timeout: 3)
            || sidebarMessage.waitForExistence(timeout: 1)
            || inProgress.waitForExistence(timeout: 1)

        XCTAssertTrue(showedFeedback, "Expected Research All to show queue or in-progress feedback")

        if welcomeMessage.exists {
            XCTAssertTrue(
                welcomeMessage.label.contains("Queued")
                    || welcomeMessage.label.contains("Ollama")
                    || welcomeMessage.label.contains("already have research profiles")
            )
        } else if sidebarMessage.exists {
            XCTAssertTrue(
                sidebarMessage.label.contains("Queued")
                    || sidebarMessage.label.contains("Ollama")
            )
        }
    }

    func testSidebarReresearchAllQueuesForOllama() throws {
        launchApp()

        try waitForLoadedResearchCache()

        sidebarButton(UITestingSupport.AccessibilityID.Research.reresearchAll, label: "Re-research All with Ollama").click()

        let message = app.staticTexts[UITestingSupport.AccessibilityID.Research.bulkMessageSidebar]
        let inProgress = app.otherElements[UITestingSupport.AccessibilityID.Research.researchInProgress]

        XCTAssertTrue(
            message.waitForExistence(timeout: 3) || inProgress.waitForExistence(timeout: 3),
            "Expected re-research to show queue feedback or in-progress indicator"
        )

        if message.exists {
            XCTAssertTrue(message.label.contains("Queued"))
            XCTAssertTrue(message.label.contains("Ollama"))
        }
    }

    private func launchApp() {
        app.launch()
        app.activate()
        XCTAssertTrue(app.waitForExistence(timeout: 15), app.debugDescription)
    }

    private func sidebarButton(_ identifier: String, label: String) -> XCUIElement {
        let byID = app.buttons[identifier]
        if byID.waitForExistence(timeout: 5) {
            return byID
        }
        return app.buttons[label].firstMatch
    }

    private func waitForLoadedResearchCache() throws {
        let onboarding = app.buttons["Start Exploring"]
        if onboarding.waitForExistence(timeout: 2) {
            XCTFail("Onboarding wizard appeared during UI test — app did not enter main explorer UI")
            return
        }

        let explorerReady =
            app.otherElements["explorer.root"].waitForExistence(timeout: 25)
            || app.buttons["All ROMs"].waitForExistence(timeout: 5)
            || app.staticTexts["Explorer"].waitForExistence(timeout: 2)

        XCTAssertTrue(explorerReady, "Main explorer sidebar did not appear.\n\(app.debugDescription)")

        let cachedProfiles = app.staticTexts.matching(
            NSPredicate(format: "identifier == %@ OR label CONTAINS 'cached profiles'", UITestingSupport.AccessibilityID.Research.cachedProfiles)
        ).firstMatch

        XCTAssertTrue(cachedProfiles.waitForExistence(timeout: 25), "Research cache label did not appear")

        let loadedPredicate = NSPredicate(format: "label MATCHES %@ OR value MATCHES %@", "^[1-9][0-9]* cached profiles$", "^[1-9][0-9]*$")
        let loadedExpectation = XCTNSPredicateExpectation(predicate: loadedPredicate, object: cachedProfiles)
        let result = XCTWaiter().wait(for: [loadedExpectation], timeout: 25)
        XCTAssertEqual(
            result,
            XCTWaiter.Result.completed,
            "Expected non-zero cached profile count, got label: \(cachedProfiles.label), value: \(cachedProfiles.value ?? "nil")"
        )
    }
}

private enum UITestingSupport {
    static let launchArgument = "-ui-testing"
    static let disableSubAgentsArgument = "-ui-disable-sub-agents"

    enum AccessibilityID {
        enum Research {
            static let bulkMessageSidebar = "research.bulkMessage.sidebar"
            static let bulkMessageWelcome = "research.bulkMessage.welcome"
            static let refreshMissing = "research.refreshMissing"
            static let reresearchAll = "research.reresearchAll"
            static let researchAll = "research.researchAll"
            static let cachedProfiles = "research.cachedProfiles"
            static let cacheReady = "research.cacheReady"
            static let researchInProgress = "research.inProgress"
        }
    }
}