import SwiftUI

@main
struct AmigaPlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("Commodore Amiga 68k Assembly Playground")
        }
        .windowStyle(.hiddenTitleBar)
    }
}
