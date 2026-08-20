import ArmageddonCore
import Foundation
import SwiftUI

struct LiveWorkspaceView: View {
    @Environment(AppModel.self) private var appModel
    @State private var manualControlsPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    Text("Live workspace")
                        .font(DesignTokens.Typography.workspaceTitle)
                        .bold()
                        .accessibilityIdentifier("workspace.live")
                    Text("Inspect, select, and capture locally. Motion stays supervised.")
                        .font(DesignTokens.Typography.supporting)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(
                    appModel.livePreview.isPaused ? "Resume preview" : "Pause preview",
                    systemImage: appModel.livePreview.isPaused ? "play.fill" : "pause.fill"
                ) {
                    appModel.livePreview.setPaused(!appModel.livePreview.isPaused)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("live.pause-resume")
                Button("Capture frame", systemImage: "camera.viewfinder") {
                    appModel.livePreview.captureCurrentFrame()
                }
                .buttonStyle(.borderedProminent)
                .disabled(appModel.livePreview.isPaused || appModel.livePreview.observations.isEmpty)
                .accessibilityIdentifier("live.capture")
            }

            performanceHealth

            HStack(alignment: .top, spacing: DesignTokens.Spacing.standard) {
                previewPanel
                controlPanel
            }
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.Colors.workspace)
    }

    private var previewPanel: some View {
        ZStack(alignment: .bottomLeading) {
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
                                selectedObservationID: appModel.livePreview.selectedObservationID,
                                sourceFormat: appModel.livePreview.negotiatedFormat,
                                modelSize: appModel.livePreview.detectorInputSize,
                                selectObservation: { appModel.livePreview.selectObservation(id: $0) }
                            )
                        }
                    } else {
                        previewPreparing
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

            if appModel.livePreview.isPaused {
                Label("Preview paused", systemImage: "pause.circle.fill")
                    .font(DesignTokens.Typography.supporting.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, DesignTokens.Spacing.standard)
                    .padding(.vertical, DesignTokens.Spacing.compact)
                    .background(.black.opacity(0.72), in: Capsule())
                    .padding(DesignTokens.Spacing.standard)
                    .accessibilityIdentifier("live.paused")
            } else if let lastCaptureMessage = appModel.livePreview.lastCaptureMessage {
                Text(lastCaptureMessage)
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.white)
                    .padding(.horizontal, DesignTokens.Spacing.standard)
                    .padding(.vertical, DesignTokens.Spacing.compact)
                    .background(.black.opacity(0.72), in: Capsule())
                    .padding(DesignTokens.Spacing.standard)
                    .accessibilityIdentifier("live.capture.message")
            }
        }
        .frame(minWidth: 560, maxWidth: .infinity, minHeight: 410, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Spacing.standard))
        .accessibilityLabel("Live camera canvas")
        .accessibilityIdentifier("live.canvas")
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            Text("Live controls")
                .font(DesignTokens.Typography.sectionTitle)

            sourceMenu
            modelMenu

            Divider()

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                Text("Recent performance")
                    .font(DesignTokens.Typography.supporting.weight(.semibold))
                metricRow("Capture FPS", value: fpsText)
                metricRow("Inference p95", value: millisecondsText(appModel.livePreview.performanceSnapshot.inferenceP95Milliseconds))
                metricRow("Overlay p95", value: millisecondsText(appModel.livePreview.performanceSnapshot.endToOverlayP95Milliseconds))
                metricRow("Detections", value: "\(appModel.livePreview.observations.count)")
            }

            if appModel.cameraLifecycleSnapshot.connection != .connected {
                Label("Targeting stale until the camera source recovers.", systemImage: "clock.badge.exclamationmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("live.source-stale")
            }

            Divider()

            LabeledContent("Camera") {
                Text(cameraStatus)
                    .foregroundStyle(.secondary)
            }
            LabeledContent("Model") {
                Text(appModel.modelRegistrySnapshot.activeModelID ?? "Fixture detector")
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            LabeledContent("Safety") {
                Label(
                    appModel.livePreview.targetingAvailable ? "Targeting available" : "Detection only",
                    systemImage: appModel.livePreview.targetingAvailable ? "checkmark.shield" : "shield.lefthalf.filled"
                )
                .foregroundStyle(.secondary)
            }

            DisclosureGroup(isExpanded: $manualControlsPresented) {
                manualControls
            } label: {
                Label("Manual arm controls", systemImage: "slider.horizontal.3")
                    .font(DesignTokens.Typography.supporting.weight(.semibold))
            }
            .accessibilityIdentifier("live.manual-controls")

            Text("STOP remains available in the bottom bar.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(width: 282, alignment: .leading)
        .background(DesignTokens.Colors.canvas, in: RoundedRectangle(cornerRadius: DesignTokens.Spacing.standard))
        .accessibilityIdentifier("live.control-panel")
    }

    private var sourceMenu: some View {
        Menu {
            Button("Native camera", systemImage: "camera.fill") {
                Task { await appModel.livePreview.selectSource(.nativeCamera) }
            }
            Button("Recorded fixture", systemImage: "rectangle.inset.filled") {
                Task { await appModel.livePreview.selectSource(.recordedFixture) }
            }
            Button("Rescan cameras", systemImage: "arrow.clockwise") {
                Task { await appModel.rescanCameras() }
            }
            Divider()
            Button("HUENIT telemetry · detection only", systemImage: "cable.connector") {}
                .disabled(true)
        } label: {
            Label("Source · \(appModel.livePreview.selectedSource.label)", systemImage: "camera.fill")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("live.source-picker")
    }

    private var modelMenu: some View {
        Menu {
            Button("Fixture detector", systemImage: "cube") {
                Task {
                    await appModel.livePreview.selectFixtureModel(
                        id: "fixture.constant.detector",
                        label: "Fixture detector"
                    )
                }
            }
            Button("Recorded fixture detector", systemImage: "rectangle.inset.filled") {
                Task {
                    await appModel.livePreview.selectFixtureModel(
                        id: "fixture.recorded.detector",
                        label: "Recorded fixture detector"
                    )
                }
            }
            ForEach(appModel.modelRegistrySnapshot.models) { model in
                Button {
                    Task { await appModel.activateModel(id: model.id) }
                } label: {
                    Label(
                        model.displayName,
                        systemImage: model.id == appModel.modelRegistrySnapshot.activeModelID
                            ? "checkmark.circle.fill"
                            : "cube"
                    )
                }
            }
            if appModel.modelRegistrySnapshot.models.isEmpty {
                Text("No imported model is active")
                    .foregroundStyle(.secondary)
            }
        } label: {
            Label("Model · \(appModel.livePreview.activeModelLabel)", systemImage: "cube")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("live.model-picker")
    }

    private var performanceHealth: some View {
        let snapshot = appModel.livePreview.performanceSnapshot
        let targetingText = snapshot.targetingAvailable ? "Targeting available" : "Targeting inhibited"
        return HStack(alignment: .top, spacing: DesignTokens.Spacing.standard) {
            Image(systemName: snapshot.health.symbolName)
                .font(.title3)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                Text(snapshot.health.label)
                    .font(DesignTokens.Typography.sectionTitle)
                Text(snapshot.healthReason)
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.secondary)
                if snapshot.health != .ready,
                   snapshot.health != .insufficientData {
                    Button("Retry detection", systemImage: "arrow.clockwise") {
                        Task { await appModel.retryLiveDetection() }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("live.retry-detection")
                }
            }
            Spacer(minLength: DesignTokens.Spacing.standard)
            Text(targetingText)
                .font(DesignTokens.Typography.supporting)
                .multilineTextAlignment(.trailing)
        }
        .padding(DesignTokens.Spacing.standard)
        .background(DesignTokens.Colors.status, in: RoundedRectangle(cornerRadius: DesignTokens.Spacing.compact))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Performance health")
        .accessibilityValue(snapshot.health.label)
        .accessibilityHint(snapshot.healthReason + " " + targetingText)
        .accessibilityIdentifier("live.performance-health")
    }

    private var manualControls: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
            Text("Hardware motion is locked until calibration and a safety profile are loaded.")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Button("− X") {}
                Button("+ X") {}
                Button("+ Y") {}
            }
            .buttonStyle(.bordered)
            .disabled(true)
            .accessibilityIdentifier("live.manual-motion-buttons")
        }
        .padding(.top, DesignTokens.Spacing.compact)
    }

    private var previewPreparing: some View {
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

    private var cameraStatus: String {
        switch appModel.cameraLifecycleSnapshot.connection {
        case .connected: "Connected"
        case .available: "Available"
        case .connecting: "Connecting"
        case .disconnected: "Disconnected"
        case .interrupted: "Interrupted"
        case .failed: "Needs attention"
        case .unavailable: "Unavailable"
        }
    }

    private var fpsText: String {
        guard let fps = appModel.livePreview.performanceSnapshot.observedFPS else { return "—" }
        return "\(fps.formatted(.number.precision(.fractionLength(1)))) fps"
    }

    private func millisecondsText(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "\(value.formatted(.number.precision(.fractionLength(0)))) ms"
    }

    private func metricRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.monospacedDigit())
        }
    }
}
