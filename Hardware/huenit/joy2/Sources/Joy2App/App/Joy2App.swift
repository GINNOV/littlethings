import Joy1
import Joy2
import SwiftUI

@main
struct Joy2App: App {
    @State private var model: PilotModel

    init() {
        let scanned = PortDetector.scan()
        let path = PortDetector.pickArm(from: scanned)?.path
        let pendant = PendantModel(
            arm: HuenitArm(transport: SerialPort(path: path ?? "/dev/null")),
            detector: { PortDetector.scan() }
        )
        _model = State(initialValue: PilotModel(pendant: pendant, stick: JoystickDevice()))
    }

    var body: some Scene {
        WindowGroup("Joy2") {
            ContentView(model: model)
        }
    }
}
