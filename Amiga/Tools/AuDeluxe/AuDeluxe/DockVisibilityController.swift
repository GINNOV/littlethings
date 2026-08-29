import AppKit

@MainActor
final class DockVisibilityController {
    static let shared = DockVisibilityController()

    private weak var hiddenWindow: NSWindow?

    private init() {}

    func handleMinimize(_ notification: Notification, enabled: Bool) {
        guard enabled, let window = notification.object as? NSWindow else { return }
        hiddenWindow = window
        window.orderOut(nil)
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    func showMainWindow() {
        NSApplication.shared.setActivationPolicy(.regular)
        let window = hiddenWindow ?? NSApplication.shared.windows.first { $0.canBecomeMain }
        window?.deminiaturize(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        hiddenWindow = nil
    }
}
