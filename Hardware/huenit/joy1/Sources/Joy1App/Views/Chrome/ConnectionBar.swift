import Joy1
import SwiftUI

struct ConnectionBar: View {
    @Bindable var model: PendantModel

    var body: some View {
        PendantCard(title: "Connect") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    deviceTile(
                        title: "Main",
                        detail: model.portPath ?? "No arm port",
                        live: model.isConnected
                    )
                    deviceTile(
                        title: "AI camera",
                        detail: "Serial only in Lab / OS",
                        live: false
                    )
                }

                HStack {
                    Text("Motor")
                        .foregroundStyle(.secondary)
                    Picker("Motor", selection: Binding(
                        get: { model.motorsOn },
                        set: { on in Task { await model.setMotors(on) } }
                    )) {
                        Text("On").tag(true)
                        Text("Off").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 160)
                    .disabled(!model.isConnected)
                    .labelsHidden()
                    .accessibilityLabel("Motors")
                }

                HStack(spacing: 8) {
                    Button(model.isConnected ? "Disconnect" : "Auto Connect") {
                        Task {
                            if model.isConnected {
                                await model.disconnect()
                            } else {
                                await model.connect()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Rescan") { model.refreshPorts() }
                    Spacer(minLength: 0)
                    Circle()
                        .fill(model.isConnected ? PendantChrome.connected : Color.secondary.opacity(0.35))
                        .frame(width: 8, height: 8)
                    Text(model.isConnected ? "Linked" : "Idle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let lastError = model.lastError, !lastError.isEmpty {
                    Text(lastError)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
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
