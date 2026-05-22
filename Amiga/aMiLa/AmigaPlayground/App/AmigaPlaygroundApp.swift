import SwiftUI
import AppKit

@main
struct AmigaPlaygroundApp: App {
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("Amiga Playground")
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Amiga Playground") {
                    openWindow(id: "about")
                }
            }

            AmigaPlaygroundCommands()
        }

        Settings {
            SettingsView()
        }

        Window("About Amiga Playground", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
    }
}

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)

            Text("Amiga Playground")
                .font(.title2.weight(.semibold))

            Text("Version \(appVersion) (\(buildNumber))")
                .foregroundStyle(.secondary)

            Link("Mario Esposito", destination: URL(string: "https://github.com/GINNOV")!)

            Divider()

            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                GridRow {
                    Text("Compiler")
                        .foregroundStyle(.secondary)
                    Link("vasm", destination: URL(string: "http://sun.hasenbraten.de/vasm/")!)
                }
                GridRow {
                    Text("Emulator")
                        .foregroundStyle(.secondary)
                    Link("FS-UAE", destination: URL(string: "https://fs-uae.net/")!)
                }
                GridRow {
                    Text("Emulator")
                        .foregroundStyle(.secondary)
                    Link("vAmiga", destination: URL(string: "https://github.com/dirkwhoffmann/vAmiga")!)
                }
                GridRow {
                    Text("Source")
                        .foregroundStyle(.secondary)
                    Link("littlethings", destination: URL(string: "https://github.com/GINNOV/littlethings")!)
                }
            }
            .font(.callout)
        }
        .padding(28)
        .frame(width: 360)
    }
}
