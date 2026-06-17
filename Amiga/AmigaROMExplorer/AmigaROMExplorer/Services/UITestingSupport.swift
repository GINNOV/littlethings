import Foundation

enum UITestingSupport {
    static let launchArgument = "-ui-testing"
    static let disableSubAgentsArgument = "-ui-disable-sub-agents"

    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains(launchArgument)
            || ProcessInfo.processInfo.environment["UI_TESTING"] == "1"
    }

    enum AccessibilityID {
        static let explorerRoot = "explorer.root"

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