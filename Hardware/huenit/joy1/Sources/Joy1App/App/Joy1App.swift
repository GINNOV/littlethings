import Joy1
import SwiftUI

@main
struct Joy1App: App {
    @State private var model: PendantModel

    init() {
        let scanned = PortDetector.scan()
        let path = PortDetector.pickArm(from: scanned)?.path ?? "/dev/cu.usbserial-3120"
        _model = State(
            initialValue: PendantModel(
                arm: HuenitArm(transport: SerialPort(path: path)),
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
