import ArmageddonCore
import SwiftUI

@main
struct ArmageddonApp: App {
    @NSApplicationDelegateAdaptor(FixtureLaunchDelegate.self) private var fixtureLaunchDelegate
    private let launch: Result<LaunchArguments, Error>

    init() {
        let processArguments = ProcessInfo.processInfo.arguments
        let result = Result {
            let arguments = try LaunchArguments.parse(processArguments)
            try ScopeBootstrap.prepare(arguments.scope)
            return arguments
        }
        launch = result
    }

    var body: some Scene {
        WindowGroup {
            RootSplitView(
                model: shellModel,
                actions: actions,
                profile: isUITesting ? try? launch.get().profile : nil,
                preferenceSuite: preferenceSuite
            )
        }
        .defaultLaunchBehavior(.presented)
        .defaultSize(width: windowSize.width, height: windowSize.height)
        .windowResizability(.contentMinSize)
        .commands {
            AppCommands(actions: actions)
        }

        Settings {
            SettingsView(preferenceSuite: preferenceSuite)
        }
    }

    private var actions: AppActions {
        AppActions(
            navigate: shellModel.select,
            requestRecovery: shellModel.requestRecovery,
            stop: shellModel.stop
        )
    }

    private var shellModel: AppShellModel {
        fixtureLaunchDelegate.model(requestedDestination: try? launch.get().requestedDestination)
    }

    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-ui-testing")
    }

    private var preferenceSuite: String? {
        guard let arguments = try? launch.get() else { return nil }
        return arguments.paths?.preferenceSuite
    }

    private var windowSize: WindowSize {
        (try? launch.get().windowSize) ?? .standard
    }
}
