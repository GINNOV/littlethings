import SwiftUI

struct RootSplitView: View {
    @Bindable var model: AppShellModel
    let actions: AppActions
    let profile: LaunchProfile?

    var body: some View {
        NavigationSplitView {
            List {
                Section("Workspaces") {
                    ForEach(AppDestination.allCases) { destination in
                        DestinationSidebarRow(
                            destination: destination,
                            isSelected: model.destination == destination,
                            action: { actions.navigate(destination) }
                        )
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Armageddon")
            .navigationSplitViewColumnWidth(DesignTokens.Layout.sidebarWidth)
            .accessibilityIdentifier("app.sidebar")
        } detail: {
            DestinationWorkspaceView(
                destination: model.destination,
                recoveryAction: actions.requestRecovery
            )
        }
        .inspector(isPresented: .constant(true)) {
            ContextualInspectorView(destination: model.destination)
                .inspectorColumnWidth(DesignTokens.Layout.inspectorWidth)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            StatusStripView(notice: model.notice, profile: profile, stopAction: actions.stop)
        }
        .frame(
            minWidth: DesignTokens.Layout.minimumWindowWidth,
            minHeight: DesignTokens.Layout.minimumWindowHeight
        )
        .accessibilityIdentifier("app.shell")
    }
}
