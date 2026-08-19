import SwiftUI

struct LiveWorkspaceView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            Text("Live workspace")
                .font(DesignTokens.Typography.workspaceTitle)
                .bold()
                .accessibilityIdentifier("workspace.live")
            ZStack {
                DesignTokens.Colors.canvas
                Group {
                    if appModel.cameraLifecycleSnapshot.authorization == .authorized,
                       appModel.cameraLifecycleSnapshot.connection == .connected {
                        VStack(spacing: DesignTokens.Spacing.standard) {
                            Image(systemName: "viewfinder")
                                .font(.largeTitle)
                                .foregroundStyle(DesignTokens.Colors.canvasPrimary)
                                .accessibilityHidden(true)
                            Text("Camera preview will appear here")
                                .font(DesignTokens.Typography.body)
                                .foregroundStyle(DesignTokens.Colors.canvasPrimary)
                            Text("Connect a supported source to begin local inspection.")
                                .font(DesignTokens.Typography.supporting)
                                .foregroundStyle(DesignTokens.Colors.canvasSecondary)
                        }
                    } else {
                        CameraAuthorizationView(
                            snapshot: appModel.cameraLifecycleSnapshot,
                            requestPermission: {
                                Task { await appModel.requestCameraPermission() }
                            },
                            openSystemSettings: appModel.openCameraSettings,
                            rescan: {
                                Task { await appModel.rescanCameras() }
                            }
                        )
                    }
                }
                .multilineTextAlignment(.center)
                .padding(DesignTokens.Spacing.roomy)
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Spacing.standard))
            .accessibilityLabel("Live camera canvas")
            .accessibilityIdentifier("live.canvas")
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.Colors.workspace)
    }
}
