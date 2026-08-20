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
                        if let previewLayer = appModel.livePreview.previewLayer {
                            ZStack {
                                CameraPreviewSurface(previewLayer: previewLayer)
                                    .accessibilityIdentifier("camera.preview")
                                DetectionOverlayView(
                                    observations: appModel.livePreview.observations,
                                    sourceFormat: appModel.livePreview.negotiatedFormat,
                                    modelSize: appModel.livePreview.detectorInputSize
                                )
                            }
                        } else {
                            VStack(spacing: DesignTokens.Spacing.standard) {
                                Image(systemName: "viewfinder")
                                    .font(.largeTitle)
                                    .foregroundStyle(DesignTokens.Colors.canvasPrimary)
                                    .accessibilityHidden(true)
                                Text("Camera preview is preparing")
                                    .font(DesignTokens.Typography.body)
                                    .foregroundStyle(DesignTokens.Colors.canvasPrimary)
                            }
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
