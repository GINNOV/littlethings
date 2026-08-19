import SwiftUI

@MainActor
final class FixtureLaunchDelegate: NSObject, NSApplicationDelegate {
    private var fixtureWindow: NSWindow?
    private var keyMonitor: Any?
    private var shellModel: AppShellModel?

    func model(requestedDestination: String?) -> AppShellModel {
        if let shellModel {
            return shellModel
        }
        let model = AppShellModel(requestedDestination: requestedDestination)
        shellModel = model
        return model
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard ProcessInfo.processInfo.arguments.contains("-ui-testing"), NSApplication.shared.windows.isEmpty else { return }
        let arguments = try? LaunchArguments.parse(ProcessInfo.processInfo.arguments)
        switch arguments?.interfaceStyle {
        case "Dark":
            NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
        case "Light":
            NSApplication.shared.appearance = NSAppearance(named: .aqua)
        default:
            break
        }
        let model = model(requestedDestination: arguments?.requestedDestination)
        let actions = AppActions(
            navigate: model.select,
            requestRecovery: model.requestRecovery,
            stop: model.stop
        )
        let size = arguments?.windowSize ?? .standard
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: NSSize(width: size.width, height: size.height)),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Armageddon"
        window.minSize = NSSize(
            width: DesignTokens.Layout.minimumWindowWidth,
            height: DesignTokens.Layout.minimumWindowHeight
        )
        window.contentView = NSHostingView(
            rootView: RootSplitView(
                model: model,
                actions: actions,
                profile: arguments?.profile,
                preferenceSuite: arguments?.paths?.preferenceSuite
            )
        )
        window.center()
        fixtureWindow = window
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKey(event) ?? event
        }
        NSApplication.shared.activate()
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
        }
    }

    private func handleKey(_ event: NSEvent) -> NSEvent? {
        if event.keyCode == 53 {
            shellModel?.stop()
            return nil
        }
        guard event.modifierFlags.contains(.command),
              let character = event.charactersIgnoringModifiers,
              let shortcut = Int(character),
              AppDestination.allCases.indices.contains(shortcut - 1) else {
            return event
        }
        shellModel?.select(AppDestination.allCases[shortcut - 1])
        return nil
    }
}
