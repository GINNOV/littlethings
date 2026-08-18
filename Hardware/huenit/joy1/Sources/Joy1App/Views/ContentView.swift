import AppKit
import Joy1
import SwiftUI

struct ContentView: View {
    @Bindable var model: PendantModel

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 16) {
                ConnectionBar(model: model)
                ModuleCard(model: model)
            }
            .frame(minWidth: 280, maxWidth: 360)

            VStack(spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    PoseHUD(pose: model.pose)
                    StopButton {
                        Task { await model.stop() }
                    }
                }
                .frame(height: 120)
                LabPad(model: model)
            }
        }
        .padding(20)
        .background(PendantChrome.canvas)
        .frame(minWidth: 980, minHeight: 640)
        .onAppear {
            model.refreshPorts()
            model.startJogLoop()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            Task { await model.stop() }
        }
    }
}
