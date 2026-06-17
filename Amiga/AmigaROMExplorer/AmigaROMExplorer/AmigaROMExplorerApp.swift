import SwiftUI

@main
struct AmigaROMExplorerApp: App {
    @Environment(\.openWindow) private var openWindow
    @State private var viewModel = ExplorerViewModel()
    private let updaterController = UpdaterController(startingUpdater: !UITestingSupport.isActive)

    init() {
        if CommandLine.arguments.contains("--export-bundled-cache") {
            runBundledCacheExport()
        }
    }

    var body: some Scene {
        WindowGroup {
            rootView
                .environment(viewModel)
                .preferredColorScheme(.dark)
        }
        .defaultSize(width: 1280, height: 820)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Amiga ROM Explorer") {
                    openWindow(id: "about")
                }
            }

            UpdaterCommands(updaterController: updaterController)

            CommandGroup(replacing: .newItem) {}

            CommandGroup(after: .appSettings) {
                Button("Show Setup Wizard") {
                    viewModel.showOnboarding = true
                }
            }
        }

        Settings {
            SettingsView()
                .environment(viewModel)
        }

        Window("About Amiga ROM Explorer", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
    }

    @ViewBuilder
    private var rootView: some View {
        if viewModel.showOnboarding {
            OnboardingWizardView()
        } else {
            ContentView()
        }
    }

    private func runBundledCacheExport() {
        guard let outputIndex = CommandLine.arguments.firstIndex(of: "--export-bundled-cache"),
              CommandLine.arguments.count > outputIndex + 1 else {
            fputs("Usage: AmigaROMExplorer --export-bundled-cache <output-directory>\n", stderr)
            return
        }

        let output = URL(fileURLWithPath: CommandLine.arguments[outputIndex + 1], isDirectory: true)
        let manifestSource = URL(
            fileURLWithPath: "/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware/manifest.tsv",
            isDirectory: false
        )

        do {
            try BundledCacheExporter.export(from: manifestSource, to: output)
        } catch {
            fputs("Export failed: \(error.localizedDescription)\n", stderr)
        }
        exit(0)
    }
}