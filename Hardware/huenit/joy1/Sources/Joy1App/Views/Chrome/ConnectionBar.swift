import Joy1
import SwiftUI

struct ConnectionBar: View {
    @Bindable var model: PendantModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text(model.portPath ?? "No port")
                    .font(.body.monospaced())
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .help(model.portPath ?? "No port")
                if model.isConnected {
                    Button("Disconnect") {
                        Task { await model.disconnect() }
                    }
                } else {
                    Button("Connect") {
                        Task {
                            await model.connect(path: model.portPath ?? "/dev/cu.usbserial-3120")
                        }
                    }
                }
                Button("Rescan") {
                    model.refreshPorts()
                }
                Spacer(minLength: 0)
                Text(model.isConnected ? "Connected" : "Disconnected")
                    .foregroundStyle(model.isConnected ? .green : .secondary)
            }
            if let lastError = model.lastError, !lastError.isEmpty {
                Text(lastError)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
        }
    }
}
