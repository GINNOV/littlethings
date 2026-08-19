import SwiftUI

@MainActor
final class FixtureLaunchDelegate: NSObject, NSApplicationDelegate {
    private var fixtureWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard ProcessInfo.processInfo.arguments.contains("-ui-testing"), NSApplication.shared.windows.isEmpty else { return }
        let arguments = try? LaunchArguments.parse(ProcessInfo.processInfo.arguments)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 320), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "Armageddon"
        window.contentView = NSHostingView(rootView: FixtureLaunchView(profile: arguments?.profile))
        window.center()
        fixtureWindow = window
        NSApplication.shared.activate()
        window.makeKeyAndOrderFront(nil)
    }
}
