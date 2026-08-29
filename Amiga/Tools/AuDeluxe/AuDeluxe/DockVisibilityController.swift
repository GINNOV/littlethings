import AppKit

@MainActor
final class DockVisibilityController: ObservableObject {
    static let shared = DockVisibilityController()

    @Published private(set) var isMinimized = false

    private(set) weak var hiddenWindow: NSWindow?
    private let setActivationPolicy: (NSApplication.ActivationPolicy) -> Void

    init(setActivationPolicy: @escaping (NSApplication.ActivationPolicy) -> Void = { policy in
        NSApplication.shared.setActivationPolicy(policy)
    }) {
        self.setActivationPolicy = setActivationPolicy
    }

    func handleMinimize(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        hiddenWindow = window
        isMinimized = true
        window.orderOut(nil)
        setActivationPolicy(.accessory)
    }

    func handleRestore() {
        isMinimized = false
    }

    func showMainWindow() {
        isMinimized = false
        setActivationPolicy(.regular)
        let window = hiddenWindow ?? NSApplication.shared.windows.first { $0.canBecomeMain }
        window?.deminiaturize(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        hiddenWindow = nil
    }
}
