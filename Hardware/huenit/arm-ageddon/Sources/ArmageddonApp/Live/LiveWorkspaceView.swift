import ArmageddonCore
import Foundation
import SwiftUI

struct LiveWorkspaceView: View {
    @Environment(AppModel.self) private var appModel
    @State private var manualControlsPresented = true

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
                sourceMenu
                    .frame(maxWidth: 220)
                modelMenu
                    .frame(maxWidth: 240)
                Button(
                    appModel.livePreview.isPaused ? "Resume preview" : "Pause preview",
                    systemImage: appModel.livePreview.isPaused ? "play.fill" : "pause.fill"
                ) {
                    appModel.livePreview.setPaused(!appModel.livePreview.isPaused)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("live.pause-resume")
                Button("Capture frame", systemImage: "camera.viewfinder") {
                    Task {
                        await appModel.captureCurrentFrame(name: "Live frame")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(appModel.livePreview.isPaused || !appModel.livePreview.canCaptureCurrentFrame)
                .accessibilityIdentifier("live.capture")
            }

            performanceHealth

            HStack(alignment: .top, spacing: DesignTokens.Spacing.standard) {
                previewPanel
                    .layoutPriority(0)
                controlPanel
                    .layoutPriority(1)
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
                   appModel.cameraLifecycleSnapshot.connection == .connected,
                   let previewLayer = appModel.livePreview.previewLayer {
                    CameraPreviewSurface(previewLayer: previewLayer)
                        .accessibilityIdentifier("camera.preview")
                } else if appModel.livePreview.observations.isEmpty {
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
                    .multilineTextAlignment(.center)
                    .padding(DesignTokens.Spacing.roomy)
                }
            }
            DetectionOverlayView(
                observations: appModel.livePreview.observations,
                selectedObservationID: appModel.livePreview.selectedObservationID,
                sourceFormat: appModel.livePreview.negotiatedFormat,
                modelSize: appModel.livePreview.detectorInputSize,
                selectObservation: { appModel.livePreview.selectObservation(id: $0) }
            )
            .padding(20)

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
        .frame(minWidth: 280, maxWidth: .infinity, minHeight: 280, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Spacing.standard))
        .accessibilityElement(children: .contain)
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
        .canvasCard(cornerRadius: DesignTokens.Spacing.standard)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("live.control-panel")
    }

    private var sourceMenu: some View {
        Picker(
            "Source",
            selection: Binding(
                get: { appModel.livePreview.selectedSource },
                set: { source in
                    Task { await appModel.livePreview.selectSource(source) }
                }
            )
        ) {
            Text("Native camera").tag(LivePreviewSource.nativeCamera)
            Text("Recorded fixture").tag(LivePreviewSource.recordedFixture)
            Text("HUENIT telemetry · detection only").tag(LivePreviewSource.huenitTelemetry)
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .accessibilityLabel("Source · \(appModel.livePreview.selectedSource.label)")
        .accessibilityIdentifier("live.source-picker")
    }

    private var modelMenu: some View {
        Picker(
            "Model",
            selection: Binding(
                get: { appModel.livePreview.activeModelID },
                set: { identifier in
                    Task {
                        if identifier == "fixture.constant.detector" {
                            await appModel.livePreview.selectFixtureModel(
                                id: identifier,
                                label: "Fixture detector"
                            )
                        } else if identifier == "fixture.recorded.detector" {
                            await appModel.livePreview.selectFixtureModel(
                                id: identifier,
                                label: "Recorded fixture detector"
                            )
                        } else {
                            await appModel.activateModel(id: identifier)
                        }
                    }
                }
            )
        ) {
            Text("Fixture detector").tag("fixture.constant.detector")
            Text("Recorded fixture detector").tag("fixture.recorded.detector")
            ForEach(appModel.modelRegistrySnapshot.models) { model in
                Text(model.displayName).tag(model.id)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .accessibilityLabel("Model · \(appModel.livePreview.activeModelLabel)")
        .accessibilityIdentifier("live.model-picker")
    }

    private var performanceHealthSummary: some View {
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

    private var performanceHealth: some View {
        let snapshot = appModel.livePreview.performanceSnapshot
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
            performanceHealthSummary
            if snapshot.health != .ready,
               snapshot.health != .insufficientData {
                Button("Retry detection", systemImage: "arrow.clockwise") {
                    Task { await appModel.retryLiveDetection() }
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("live.retry-detection")
            }
        }
    }

    private var manualControls: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
            Text("Hardware motion is locked until calibration and a safety profile are loaded.")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Button("− X") {}
                    .accessibilityIdentifier("live.manual.minus-x")
                Button("+ X") {}
                    .accessibilityIdentifier("live.manual.plus-x")
                Button("+ Y") {}
                    .accessibilityIdentifier("live.manual.plus-y")
            }
            .buttonStyle(.bordered)
            .disabled(true)
            .accessibilityElement(children: .contain)
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
