import ArmageddonCore
import SwiftUI

@main
struct ArmageddonApp: App {
    @NSApplicationDelegateAdaptor(FixtureLaunchDelegate.self) private var fixtureLaunchDelegate
    private let launch: Result<LaunchArguments, Error>

    init() {
        let processArguments = ProcessInfo.processInfo.arguments
        launch = Result {
            let arguments = try LaunchArguments.parse(processArguments)
            try ScopeBootstrap.prepare(arguments.scope)
            return arguments
        }
    }

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 12) {
                Text(ArmageddonCore.productName)
                    .font(.title)
                switch launch {
                case .success(let arguments):
                    Text(arguments.profile.title)
                        .accessibilityIdentifier("launch.profile.\(arguments.profile.rawValue)")
                    Text("Fixture state ready")
                        .accessibilityIdentifier("launch.ready")
                case .failure:
                    Text("Fixture configuration failed")
                        .accessibilityIdentifier("launch.failed")
                }
            }
            .padding(32)
        }
        .defaultLaunchBehavior(.presented)
    }
}
