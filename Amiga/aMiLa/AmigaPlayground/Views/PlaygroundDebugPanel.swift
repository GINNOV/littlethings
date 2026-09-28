import SwiftUI

struct PlaygroundDebugPanel: View {
    let state: PlaygroundDebugState
    let backendName: String
    let records: [VAmigaCommandRecord]
    @Binding var command: String
    let onStart: () -> Void
    let onContinue: () -> Void
    let onStep: () -> Void
    let onReset: () -> Void
    let onDisconnect: () -> Void
    let onClearHistory: () -> Void
    let onSubmit: () -> Void

    private let registerOrder = [
        "D0", "D1", "D2", "D3", "D4", "D5", "D6", "D7",
        "A0", "A1", "A2", "A3", "A4", "A5", "A6", "A7"
    ]

    private var latestTrace: CpuTraceRecord? {
        records.reversed().compactMap { record in
            record.parsedRecords.last(where: { $0.event == "cpu" || !$0.registers.isEmpty })
        }.first
    }

    private var stateColor: Color {
        switch state {
        case .idle, .disconnected:
            return .secondary
        case .starting, .sending:
            return .orange
        case .connected:
            return .green
        case .failed:
            return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            controls

            if case .failed(let message) = state {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }

            if let latestTrace {
                registerSnapshot(latestTrace)
            }

            history
            commandEntry
        }
        .background(Color.black)
        .accessibilityIdentifier("playgroundDebugPanel")
    }

    private var header: some View {
        HStack(spacing: 8) {
            Label("Debugger", systemImage: "ladybug.fill")
                .font(.headline)
                .foregroundStyle(.cyan)

            Text(backendName)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Circle()
                .fill(stateColor)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            Text(state.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(stateColor)
                .accessibilityIdentifier("debugSessionStatus")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var controls: some View {
        HStack(spacing: 6) {
            if state.isActive {
                Button("Continue", systemImage: "play.fill", action: onContinue)
                Button("Step", systemImage: "forward.frame.fill", action: onStep)
                Button("Reset", systemImage: "arrow.counterclockwise", action: onReset)
                Button("Disconnect", systemImage: "link.badge.minus", action: onDisconnect)
                    .tint(.orange)
            } else {
                Button("Start Debug", systemImage: "ladybug.fill", action: onStart)
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan)
                    .disabled(state == .starting)
            }

            Spacer()

            Button("Clear", systemImage: "trash", action: onClearHistory)
                .buttonStyle(.borderless)
                .disabled(records.isEmpty)
                .help("Clear debugger history")
        }
        .controlSize(.small)
        .disabled(state == .sending)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(red: 0.03, green: 0.08, blue: 0.14))
    }

    private func registerSnapshot(_ trace: CpuTraceRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("CPU snapshot")
                    .font(.caption.bold())
                    .foregroundStyle(.cyan)
                Spacer()
                if let pc = trace.pc {
                    Text("PC \(pc)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.orange)
                }
            }

            if let instruction = trace.instruction {
                Text(instruction)
                    .font(.caption.monospaced())
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 70), spacing: 6), count: 4), spacing: 4) {
                ForEach(registerOrder, id: \.self) { register in
                    if let value = trace.registers[register] {
                        HStack(spacing: 4) {
                            Text(register)
                                .foregroundStyle(.cyan)
                            Spacer(minLength: 2)
                            Text(value)
                                .foregroundStyle(.white)
                        }
                        .font(.caption2.monospaced())
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
        }
        .padding(10)
        .background(Color(red: 0.02, green: 0.12, blue: 0.20))
    }

    private var history: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                if records.isEmpty {
                    Text("Start a debug session to inspect the current editor source. The editor stays editable while you experiment.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                } else {
                    ForEach(Array(records.enumerated()), id: \.offset) { _, record in
                        commandCard(record)
                    }
                }
            }
            .padding(10)
        }
        .frame(maxHeight: .infinity)
        .background(Color.black)
    }

    private func commandCard(_ record: VAmigaCommandRecord) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("$ \(record.command)")
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(.cyan)
                Spacer()
                Text("\(record.durationMs) ms")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            if let error = record.error {
                Text(error)
                    .font(.caption.monospaced())
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            } else if !record.response.isEmpty {
                Text(record.response)
                    .font(.caption.monospaced())
                    .foregroundStyle(.white.opacity(0.86))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.06, green: 0.06, blue: 0.09))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(record.error == nil ? Color.white.opacity(0.08) : Color.red.opacity(0.45), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var commandEntry: some View {
        HStack(spacing: 6) {
            TextField("RetroShell command…", text: $command)
                .textFieldStyle(.roundedBorder)
                .font(.body.monospaced())
                .onSubmit(onSubmit)
                .disabled(!state.canExecute)
                .accessibilityIdentifier("debugCommandField")

            Button("Send", systemImage: "paperplane.fill", action: onSubmit)
                .buttonStyle(.borderedProminent)
                .disabled(!state.canExecute || command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("debugSendButton")
        }
        .controlSize(.small)
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}
