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
        let isUITesting = processArguments.contains("-ui-testing")
        let profile = try? result.get().profile
        let authorizationClient: any CameraAuthorizationClient = if isUITesting, profile == .permissionDenied {
            DeterministicCameraAuthorizationClient(status: .denied)
        } else if isUITesting {
            DeterministicCameraAuthorizationClient(status: .authorized)
        } else {
            AVFoundationCameraAuthorizationClient()
        }
        let nativeCameraDiscovery: any NativeCameraDiscovery = if isUITesting {
            DeterministicNativeCameraDiscovery(cameras: profile == .noDevices || profile == .permissionDenied ? [] : [
                NativeCameraDevice(stableIdentifier: "fixture-camera", permission: .authorized),
            ])
        } else {
            AVFoundationCameraDiscovery(authorizationClient: authorizationClient)
        }
        let cameraCatalog = DeviceCatalog(
            nativeCameraDiscovery: nativeCameraDiscovery,
            serialDeviceDiscovery: DeterministicSerialDeviceDiscovery(devices: [])
        )
        let cameraLifecycle = NativeCameraLifecycleController(
            authorizationClient: authorizationClient,
            catalog: cameraCatalog
        )
        let restored = AppStateRestorer.restore(AppStateSnapshot(
            destination: "live.workspace",
            selectedDevice: nil,
            selectedModelID: nil
        ))
        let applicationModel = AppModel(
            coordinator: coordinator,
            restoredState: restored,
            cameraLifecycle: cameraLifecycle,
            modelRegistry: ModelRegistry(root: Self.modelRegistryURL(for: result)),
            calibrationProfileURL: Self.calibrationProfileURL(for: result),
            captureRoot: Self.captureRoot(for: result)
        )
        _appModel = State(initialValue: applicationModel)
        fixtureLaunchDelegate.configure(appModel: applicationModel)
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
                await appModel.refreshModels()
                await appModel.refreshK210Artifacts()
                await appModel.openCaptures()
                await appModel.refreshCameraLifecycle()
                if isUITesting {
                    let fixtureProfile = try? launch.get().profile
                    if fixtureProfile != .noDevices,
                       fixtureProfile != .permissionDenied {
                        await appModel.loadFixtureOverlay()
                    }
                    if fixtureProfile == .modelFailed {
                        await appModel.simulateModelFailureFixture()
                    }
                    if fixtureProfile != .cameraDisconnected,
                       fixtureProfile != .permissionDenied,
                       fixtureProfile != .noDevices {
                        await appModel.configureConnectedCameraFixture()
                    }
                }
                if isCameraDisconnectedFixture {
                    await appModel.configureDisconnectedCameraFixture()
                }
                appModel.startCameraLifecycleMonitoring()
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

    private var isCameraDisconnectedFixture: Bool {
        guard isUITesting, let profile = try? launch.get().profile else { return false }
        return profile == .cameraDisconnected
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

    private static func modelRegistryURL(for launch: Result<LaunchArguments, Error>) -> URL {
        let root = (try? launch.get().paths?.applicationSupport)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return root.appendingPathComponent("Armageddon", isDirectory: true)
            .appendingPathComponent("Models", isDirectory: true)
    }

    private static func captureRoot(for launch: Result<LaunchArguments, Error>) -> URL {
        let root = (try? launch.get().paths?.applicationSupport)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return root.appendingPathComponent("Armageddon", isDirectory: true)
            .appendingPathComponent("Captures", isDirectory: true)
    }

    private static func calibrationProfileURL(for launch: Result<LaunchArguments, Error>) -> URL {
        let root = (try? launch.get().paths?.applicationSupport)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return root.appendingPathComponent("Armageddon", isDirectory: true)
            .appendingPathComponent("Calibration", isDirectory: true)
            .appendingPathComponent("active-profile.json")
    }
}
