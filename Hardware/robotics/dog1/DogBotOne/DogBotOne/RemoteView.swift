import SwiftUI
import CoreBluetooth
import AppKit

struct RemoteView: View {
    @StateObject private var bleManager = BLEManager()
    @State private var rawCommand = ""
    @State private var showDeveloperTools = false
    @State private var commandSearch = ""
    @State private var newestFirst = true

    var body: some View {
        VStack(spacing: 24) {
            header

            if bleManager.status == "Connected" {
                connectedRemote
            } else {
                connectionCard
            }

            developerTools
        }
        .padding(28)
        .frame(minWidth: 900, minHeight: 650)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "dog.fill")
                .font(.system(size: 30))
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 3) {
                Text("Robot Dog Remote")
                    .font(.title.bold())
                Text("DogBotOne")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusBadge(status: bleManager.status)

            Button("Reconnect", action: bleManager.reconnect)
                .disabled(bleManager.status == "Connected")
        }
    }

    private var connectedRemote: some View {
        HStack(alignment: .top, spacing: 24) {
            movementCard
            actionCard
        }
    }

    private var movementCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Drive", subtitle: "Movement controls")

            JogWheel(action: bleManager.send)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .cardStyle()
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Actions", subtitle: "Make your dog do something")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ActionButton(title: "Sit", systemImage: "figure.seated.side") { bleManager.send(.sit) }
                ActionButton(title: "Greet", systemImage: "hand.wave") { bleManager.send(.greet) }
                ActionButton(title: "Dance", systemImage: "music.note") { bleManager.send(.dance) }
                ActionButton(title: "Patrol", systemImage: "figure.walk.motion") { bleManager.send(.patrol) }
                ActionButton(title: "Kung Fu", systemImage: "figure.martial.arts") { bleManager.send(.kungFu) }
                ActionButton(title: "Push-up", systemImage: "figure.strengthtraining.traditional") { bleManager.send(.pushUp) }
            }
        }
        .cardStyle()
    }

    private var connectionCard: some View {
        VStack(spacing: 14) {
            Image(systemName: bleManager.status == "Bluetooth Off" ? "bolt.horizontal.circle" : "dot.radiowaves.left.and.right")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text(bleManager.status == "Bluetooth Off" ? "Bluetooth is off" : "Looking for your robot dog")
                .font(.title2.bold())

            Text(bleManager.status == "Bluetooth Off"
                 ? "Turn on Bluetooth to connect to DogBotOne."
                 : "Keep the dog nearby and switched on. We’ll connect automatically when it appears.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 500)

            Button("Try again", action: bleManager.reconnect)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .cardStyle()
    }

    private var developerTools: some View {
        DisclosureGroup("Developer mode", isExpanded: $showDeveloperTools) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    rawCommandSection
                    serviceDiscoverySection
                }
                sentCommandsSection
            }
            .font(.caption)
            .padding(.top, 8)
        }
    }

    private var rawCommandSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Raw command")
                .font(.caption.bold())

            HStack {
                TextField("Raw hex command", text: $rawCommand)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.caption, design: .monospaced))
                Button("Send") {
                    bleManager.sendHex(rawCommand)
                }
                .disabled(bleManager.status != "Connected" || rawCommand.isEmpty)
            }

            Text("Raw commands remain available for protocol discovery. They are not consumer controls.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(10)
        .background(.background.secondary)
        .clipShape(.rect(cornerRadius: 8))
    }

    private var serviceDiscoverySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Service discovery")
                .font(.caption.bold())

            labeledUUID("Service", bleManager.serviceUUID.uuidString)
            labeledUUID("Characteristic", bleManager.characteristicUUID.uuidString)
            labeledUUID("Discovered writable", bleManager.discoveredCharacteristic)

            Button("Open BLE developer documentation") {
                NSWorkspace.shared.open(developerDocumentationURL)
            }
            .disabled(!FileManager.default.fileExists(atPath: developerDocumentationURL.path))
            .help(developerDocumentationURL.path)
            .accessibilityLabel("Open BLE developer documentation")
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(10)
        .background(.background.secondary)
        .clipShape(.rect(cornerRadius: 8))
    }

    private var sentCommandsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Commands sent")
                    .font(.caption.bold())

                Spacer()

                TextField("Search commands", text: $commandSearch)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 220)
                    .accessibilityLabel("Search sent commands")

                Button {
                    newestFirst.toggle()
                } label: {
                    Label(
                        newestFirst ? "Newest first" : "Oldest first",
                        systemImage: newestFirst ? "arrow.down" : "arrow.up"
                    )
                }
                .help(newestFirst ? "Showing newest first. Click to show oldest first." : "Showing oldest first. Click to show newest first.")
                .accessibilityLabel(newestFirst ? "Sort oldest first" : "Sort newest first")
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    if displayedSentCommands.isEmpty {
                        Text(commandSearch.isEmpty ? "No commands sent yet." : "No commands match the search.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(displayedSentCommands) { command in
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
                                Text(SentCommand.timestampFormatter.string(from: command.time))
                                    .foregroundStyle(.secondary)
                                    .font(.system(.caption, design: .monospaced))
                                Text(command.description)
                                    .foregroundStyle(.primary)
                                Text(command.hex)
                                    .foregroundStyle(.secondary)
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 140)
            .padding(8)
            .background(.background.secondary)
            .clipShape(.rect(cornerRadius: 8))
        }
    }

    private var displayedSentCommands: [SentCommand] {
        let query = commandSearch.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered: [SentCommand]
        if query.isEmpty {
            filtered = bleManager.sentCommands
        } else {
            filtered = bleManager.sentCommands.filter { command in
                command.description.localizedCaseInsensitiveContains(query)
                    || command.hex.localizedCaseInsensitiveContains(query)
            }
        }
        return newestFirst ? filtered.reversed() : filtered
    }

    private func labeledUUID(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(title):")
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
        }
    }

    private var developerDocumentationURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("deveinfo.md")
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.title3.bold())
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

}

private struct StatusBadge: View {
    let status: String

    var body: some View {
        Label(status, systemImage: status == "Connected" ? "checkmark.circle.fill" : "circle.dashed")
            .foregroundStyle(status == "Connected" ? .green : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.quaternary)
            .clipShape(.capsule)
    }
}

private struct JogWheel: View {
    let action: (RobotCommand) -> Void
    @State private var dragOffset = CGSize.zero
    @State private var activeCommand: RobotCommand?

    private enum Metrics {
        static let ringSize: CGFloat = 190
        static let knobSize: CGFloat = 72
        static let rimPadding: CGFloat = 14
        static let labelExtent: CGFloat = 250
        static var maxTravel: CGFloat { (ringSize - knobSize) / 2 - rimPadding }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.quaternary)
                .frame(width: Metrics.ringSize, height: Metrics.ringSize)

            Circle()
                .stroke(.tertiary, lineWidth: 2)
                .frame(width: Metrics.ringSize, height: Metrics.ringSize)

            Circle()
                .fill(.tint)
                .frame(width: Metrics.knobSize, height: Metrics.knobSize)
                .overlay {
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = boundedOffset(value.translation)
                            let command = movementCommand(for: value.translation)
                            if command != activeCommand {
                                activeCommand = command
                                action(command)
                            }
                        }
                        .onEnded { _ in
                            dragOffset = .zero
                            activeCommand = nil
                            action(.stop)
                        }
                )

            VStack {
                Text("FORWARD")
                Spacer()
                Text("STOP")
            }
            .font(.caption2.bold())
            .foregroundStyle(.secondary)
            .frame(height: Metrics.labelExtent)

            HStack {
                Text("LEFT")
                Spacer()
                Text("RIGHT")
            }
            .font(.caption2.bold())
            .foregroundStyle(.secondary)
            .frame(width: Metrics.labelExtent)
        }
        .frame(width: Metrics.labelExtent, height: Metrics.labelExtent)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Movement jog wheel")
        .accessibilityHint("Drag up, left, or right to move; drag down, return to center, or release to stop")
        .accessibilityAction(named: "Forward") {
            action(.forward)
        }
        .accessibilityAction(named: "Left") {
            action(.left)
        }
        .accessibilityAction(named: "Right") {
            action(.right)
        }
        .accessibilityAction(named: "Stop") {
            action(.stop)
        }
    }

    private func boundedOffset(_ translation: CGSize) -> CGSize {
        let limit = Metrics.maxTravel
        let radius = (translation.width * translation.width + translation.height * translation.height).squareRoot()
        guard radius > limit else { return translation }
        let scale = limit / radius
        return CGSize(width: translation.width * scale, height: translation.height * scale)
    }

    private func movementCommand(for translation: CGSize) -> RobotCommand {
        let distance = (translation.width * translation.width + translation.height * translation.height).squareRoot()
        if distance < 16 {
            return .stop
        }

        if abs(translation.width) > abs(translation.height) {
            return translation.width < 0 ? .left : .right
        }
        return translation.height < 0 ? .forward : .stop
    }
}

private struct ActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}

private struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(22)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.background.secondary)
            .clipShape(.rect(cornerRadius: 16))
    }
}

private extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
