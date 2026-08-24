import Joy1UI
import SwiftUI

struct GoWorkspaceView: View {
    @Environment(AppModel.self) private var appModel
    var stopAction: @MainActor () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
                Text("Go play")
                    .font(DesignTokens.Typography.workspaceTitle)
                    .bold()
                Text("Same Joy1 pendant as the teaching app: Auto Connect, jog, vacuum, STOP. Save poses, then I moved → confirm place. Never G28.")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.secondary)

                ContentView(model: appModel.pendant, embedded: true, onStop: stopAction)
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("go.pendant")

                teachCard
                playCard

                if let goPlayMessage = appModel.goPlayMessage {
                    Text(goPlayMessage)
                        .font(.caption)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("go.message")
                }
            }
            .padding(DesignTokens.Spacing.roomy)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.Colors.workspace)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("workspace.go")
        .onAppear { appModel.refreshSerialPorts() }
    }

    private var teachCard: some View {
        let ws = appModel.workspace
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
            Text("Teach this pose")
                .font(DesignTokens.Typography.sectionTitle)
            Text(String(
                format: "Bowl (%.1f, %.1f, %.1f)  origin (%.1f, %.1f)  step (%.1f, %.1f)  Z safe %.1f pick %.1f place %.1f",
                ws.bowlX, ws.bowlY, ws.bowlZ, ws.originX, ws.originY, ws.stepX, ws.stepY, ws.safeZ, ws.pickZ, ws.placeZ
            ))
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
            teachButton("Save as stone bowl", id: "go.teach.bowl") {
                await appModel.teachBowl()
            }
            teachButton("Save as board origin (0,0)", id: "go.teach.origin") {
                await appModel.teachOrigin()
            }
            teachButton("Save as far corner (8,8)", id: "go.teach.far") {
                await appModel.teachFarCorner()
            }
            HStack {
                teachButton("Save safe Z", id: "go.teach.safe-z") { await appModel.teachSafeZ() }
                teachButton("Save pick Z", id: "go.teach.pick-z") { await appModel.teachPickZ() }
                teachButton("Save place Z", id: "go.teach.place-z") { await appModel.teachPlaceZ() }
            }
        }
        .padding(DesignTokens.Spacing.standard)
        .canvasCard(cornerRadius: DesignTokens.Spacing.standard)
    }

    private var playCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
            Text("Play")
                .font(DesignTokens.Typography.sectionTitle)
            HStack {
                Button("Start game") {
                    Task { await appModel.startGoGame() }
                }
                .accessibilityIdentifier("go.start")
                Button("I moved") {
                    Task { await appModel.humanMovedOnBoard() }
                }
                .accessibilityIdentifier("go.i-moved")
                Button("Confirm place") {
                    Task { await appModel.confirmGoPlace() }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("go.confirm")
            }
            .buttonStyle(.bordered)
        }
        .padding(DesignTokens.Spacing.standard)
        .canvasCard(cornerRadius: DesignTokens.Spacing.standard)
    }

    private func teachButton(_ title: String, id: String, action: @escaping @MainActor () async -> Void) -> some View {
        Button(title) {
            Task { await action() }
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier(id)
    }
}
