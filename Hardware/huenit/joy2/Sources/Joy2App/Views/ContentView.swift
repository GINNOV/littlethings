import AppKit
import Joy1
import SwiftUI

struct ContentView: View {
    @Bindable var model: PilotModel
    @State private var showCheatsheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ConnectionBar(model: model, showCheatsheet: $showCheatsheet)

            if model.pendant.isConnected {
                HStack(alignment: .top, spacing: 16) {
                    ModuleCard(model: model)
                        .frame(minWidth: 280, maxWidth: 360)

                    VStack(spacing: 16) {
                        HStack(alignment: .top, spacing: 12) {
                            PoseHUD(pose: model.pendant.pose)
                            StopButton {
                                Task { await model.emergencyStop() }
                            }
                        }
                        .frame(height: 120)
                        LabPad(model: model)
                    }
                }
            } else {
                PendantCard(title: "Ready") {
                    Text("Connect the arm to show the pad, suction, and stick motion.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .background(PendantChrome.canvas)
        .frame(minWidth: 720, minHeight: 420)
        .sheet(isPresented: $showCheatsheet) {
            StickCheatsheet()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Close") { showCheatsheet = false }
                    }
                }
        }
        .onAppear { model.start() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            Task { await model.emergencyStop() }
        }
        .onKeyPress(.escape) {
            Task { await model.emergencyStop() }
            return .handled
        }
    }
}
