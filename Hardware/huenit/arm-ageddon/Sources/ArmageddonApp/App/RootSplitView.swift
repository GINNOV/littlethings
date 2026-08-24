import SwiftUI

struct RootSplitView: View {
    @Bindable var model: AppShellModel
    @Environment(AppModel.self) private var appModel
    let actions: AppActions
    let profile: LaunchProfile?

    init(model: AppShellModel, actions: AppActions, profile: LaunchProfile?, preferenceSuite: String? = nil) {
        self.model = model
        self.actions = actions
        self.profile = profile
        _ = preferenceSuite
    }

    var body: some View {
        GoWorkspaceView(stopAction: actions.stop)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                StatusStripView(
                    notice: model.notice ?? appModel.goPlayMessage,
                    profile: profile,
                    armConnected: appModel.armConnected
                )
            }
            .frame(
                minWidth: DesignTokens.Layout.minimumWindowWidth,
                minHeight: DesignTokens.Layout.minimumWindowHeight
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("app.shell")
    }
}
