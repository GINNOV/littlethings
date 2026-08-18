import AppKit
import Joy1
import SwiftUI

struct ContentView: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ConnectionBar(model: model)
            PoseHUD(pose: model.pose)
            HStack(alignment: .top, spacing: 32) {
                CartesianPad(model: model)
                JointPad(model: model)
            }
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
        .frame(minWidth: 720, minHeight: 420)
        .onAppear {
            model.refreshPorts()
            model.startJogLoop()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            Task { await model.stop() }
        }
    }
}
