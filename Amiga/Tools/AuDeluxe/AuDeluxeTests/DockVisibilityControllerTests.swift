import AppKit
import Testing
@testable import AuDeluxe

@MainActor
struct DockVisibilityControllerTests {
    @Test("Minimizing hides the app from the Dock and restoring reverses both changes")
    func minimizeAndRestoreTransition() {
        // Given
        var policies: [NSApplication.ActivationPolicy] = []
        let controller = DockVisibilityController { policies.append($0) }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        // When
        controller.handleMinimize(Notification(name: NSWindow.didMiniaturizeNotification, object: window))

        // Then
        #expect(controller.isMinimized)
        #expect(controller.hiddenWindow === window)
        #expect(policies == [.accessory])

        // When
        controller.showMainWindow()

        // Then
        #expect(controller.isMinimized == false)
        #expect(controller.hiddenWindow == nil)
        #expect(policies == [.accessory, .regular])
    }
}
