import Joy1
import SwiftUI

struct ConnectionBar: View {
    @Bindable var model: PilotModel

    private var pendant: PendantModel { model.pendant }

    var body: some View {
        PendantCard(title: "Connect") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    deviceTile(
                        title: "Main",
                        detail: pendant.portPath ?? "No arm port",
                        live: pendant.isConnected
                    )
                    deviceTile(
                        title: "Stick",
                        detail: model.stickConnected ? "Speedlink Competition Pro" : (model.stickMessage ?? "No stick"),
                        live: model.stickConnected
                    )
                }

                HStack {
                    Text("Motor")
                        .foregroundStyle(.secondary)
                    Picker("Motor", selection: Binding(
                        get: { pendant.motorsOn },
                        set: { on in Task { await pendant.setMotors(on) } }
                    )) {
                        Text("On").tag(true)
                        Text("Off").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 160)
                    .disabled(!pendant.isConnected)
                    .labelsHidden()
                    .accessibilityLabel("Motors")
                }

                HStack(spacing: 8) {
                    Button(pendant.isConnected ? "Disconnect" : "Auto Connect") {
                        Task {
                            if pendant.isConnected {
                                await pendant.disconnect()
                            } else {
                                await pendant.connect()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Rescan") { pendant.refreshPorts() }
                    Spacer(minLength: 0)
                    Circle()
                        .fill(pendant.isConnected ? PendantChrome.connected : Color.secondary.opacity(0.35))
                        .frame(width: 8, height: 8)
                    Text(pendant.isConnected ? "Linked" : "Idle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let lastError = pendant.lastError, !lastError.isEmpty {
                    Text(lastError)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                }
                if let reject = model.lastGuardReject {
                    Text(reject.message)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                if let stickMessage = model.stickMessage, !model.stickConnected {
                    Text(stickMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func deviceTile(title: String, detail: String, live: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                Spacer()
                Circle()
                    .fill(live ? PendantChrome.connected : Color.secondary.opacity(0.3))
                    .frame(width: 7, height: 7)
            }
            Text(detail)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .truncationMode(.middle)
                .help(detail)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
