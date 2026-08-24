import Joy1
#if canImport(Joy1UI)
import Joy1UI
#endif
import SwiftUI

@main
struct Joy1App: App {
    @State private var model: PendantModel

    init() {
        if CommandLine.arguments.contains("--snapshot") {
            MainActor.assumeIsolated {
                WindowSnapshot.write()
            }
        }
        let scanned = PortDetector.scan()
        let path = PortDetector.pickArm(from: scanned)?.path
        _model = State(
            initialValue: PendantModel(
                arm: HuenitArm(transport: SerialPort(path: path ?? "/dev/null")),
                detector: { PortDetector.scan() }
            )
        )
    }

    var body: some Scene {
        WindowGroup("Joy1") {
            ContentView(model: model)
        }
    }
}
