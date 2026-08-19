import ArmageddonCore
import SwiftUI

@main
struct ArmageddonApp: App {
    @NSApplicationDelegateAdaptor(FixtureLaunchDelegate.self) private var fixtureLaunchDelegate
    private let launch: Result<LaunchArguments, Error>
    @State private var appModel: AppModel

    init() {
        let processArguments = ProcessInfo.processInfo.arguments
        let result = Result {
            let arguments = try LaunchArguments.parse(processArguments)
            try ScopeBootstrap.prepare(arguments.scope)
            return arguments
        }
        launch = result
        let coordinator = AppStateCoordinator(repository: FileAppStateRepository(fileURL: Self.appStateURL(for: result)))
        let restored = AppStateRestorer.restore(AppStateSnapshot(
            destination: "live.workspace",
            selectedDevice: nil,
            selectedModelID: nil
        ))
        _appModel = State(initialValue: AppModel(coordinator: coordinator, restoredState: restored))
    }

    var body: some Scene {
        WindowGroup {
            RootSplitView(
                model: shellModel,
                actions: actions,
                profile: isUITesting ? try? launch.get().profile : nil,
                preferenceSuite: preferenceSuite
            )
            .environment(appModel)
            .task {
                await appModel.restore()
            }
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

    private static func appStateURL(for launch: Result<LaunchArguments, Error>) -> URL {
        let root = (try? launch.get().paths?.fixtures)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return root.appendingPathComponent("Armageddon", isDirectory: true)
            .appendingPathComponent("app-state.json")
    }
}
