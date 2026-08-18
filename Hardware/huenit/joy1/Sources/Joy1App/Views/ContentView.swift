import AppKit
import Joy1
import SwiftUI

struct ContentView: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ConnectionBar(model: model)
            HStack {
                PoseHUD(pose: model.pose)
                Spacer()
                Toggle("Motors", isOn: Binding(
                    get: { model.motorsOn },
                    set: { on in Task { await model.setMotors(on) } }
                ))
                .disabled(!model.isConnected)
                .accessibilityLabel("Motors")
            }
            LabPad(model: model)
            SpeedSlider(model: model)
            HStack {
                VacuumToggle(model: model)
                Spacer()
                StopButton {
                    Task { await model.stop() }
                }
            }
        }
        .padding(20)
        .frame(minWidth: 780, minHeight: 560)
        .onAppear {
            model.refreshPorts()
            model.startJogLoop()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            Task { await model.stop() }
        }
    }
}
