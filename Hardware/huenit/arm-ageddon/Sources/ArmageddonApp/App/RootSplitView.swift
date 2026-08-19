import SwiftUI

struct RootSplitView: View {
    @Bindable var model: AppShellModel
    let actions: AppActions
    let profile: LaunchProfile?
    @AppStorage private var showInspectorOnLaunch: Bool

    init(model: AppShellModel, actions: AppActions, profile: LaunchProfile?, preferenceSuite: String? = nil) {
        self.model = model
        self.actions = actions
        self.profile = profile
        _showInspectorOnLaunch = AppStorage(
            wrappedValue: true,
            "showInspectorOnLaunch",
            store: preferenceSuite.flatMap { UserDefaults(suiteName: $0) }
        )
    }

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
        .inspector(isPresented: $showInspectorOnLaunch) {
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
