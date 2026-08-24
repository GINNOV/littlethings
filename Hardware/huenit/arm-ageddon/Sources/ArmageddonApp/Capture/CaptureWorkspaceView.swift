import ArmageddonCore
import AppKit
import SwiftUI

struct CaptureWorkspaceView: View {
    @Environment(AppModel.self) private var appModel
    @State private var searchText = ""
    @State private var selectedCaptureID: String?
    @State private var captureName = "Captured frame"

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
            header
            if let error = appModel.captureError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .padding(.horizontal, DesignTokens.Spacing.standard)
                    .accessibilityIdentifier("captures.error")
            }
            if appModel.captures.isEmpty {
                EmptyStateView(
                    title: searchText.isEmpty ? "No captures yet" : "No matching captures",
                    symbol: "photo.on.rectangle.angled",
                    description: searchText.isEmpty
                        ? "Capture a frame from Live to build a reviewable, provenance-rich dataset."
                        : "Try a different name or clear the search."
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                captureGrid
            }
        }
        .padding(DesignTokens.Spacing.roomy)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.workspace)
        .accessibilityIdentifier("workspace.capture")
        .task { await appModel.refreshCaptures(search: searchText) }
    }

    private var header: some View {
        HStack(alignment: .bottom, spacing: DesignTokens.Spacing.standard) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                Text("Capture library")
                    .font(DesignTokens.Typography.workspaceTitle)
                    .bold()
                Text("Review frames with their model, source, and timing provenance attached.")
                    .font(DesignTokens.Typography.supporting)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            TextField("Capture name", text: $captureName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 170)
                .accessibilityLabel("New capture name")
            Button("Capture from Live", systemImage: "camera.viewfinder") {
                Task { await appModel.captureCurrentFrame(name: captureName) }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("captures.capture")
            TextField("Search captures", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 190)
                .accessibilityLabel("Search captures")
                .accessibilityIdentifier("captures.search")
                .onChange(of: searchText) { _, value in
                    Task { await appModel.refreshCaptures(search: value) }
                }
        }
    }

    private var captureGrid: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.standard) {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 220), spacing: DesignTokens.Spacing.standard)],
                    spacing: DesignTokens.Spacing.standard
                ) {
                    ForEach(appModel.captures) { capture in
                        captureCard(capture, isSelected: selectedCaptureID == capture.id)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            detailPanel
                .frame(width: 280)
        }
    }

    private func captureCard(_ capture: CaptureRecord, isSelected: Bool) -> some View {
        Button {
            selectedCaptureID = capture.id
        } label: {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                ZStack {
                    DesignTokens.Colors.canvas
                    Image(systemName: capture.isTrashed ? "trash" : "photo")
                        .font(.largeTitle)
                        .foregroundStyle(capture.isTrashed ? .secondary : Color.accentColor)
                }
                .frame(height: 115)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(capture.name)
                    .font(DesignTokens.Typography.sectionTitle)
                    .lineLimit(1)
                HStack {
                    Label(capture.review.rawValue.capitalized, systemImage: reviewSymbol(capture.review))
                    Spacer()
                    Text("\(capture.provenance.observations.count) detections")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(DesignTokens.Spacing.standard)
            .frame(maxWidth: .infinity, alignment: .leading)
            .canvasCard()
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Capture \(capture.name), \(capture.review.rawValue)")
        .accessibilityIdentifier("capture.\(capture.id)")
    }

    @ViewBuilder
    private var detailPanel: some View {
        if let id = selectedCaptureID,
           let capture = appModel.captures.first(where: { $0.id == id }) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.standard) {
                Text("Capture details")
                    .font(DesignTokens.Typography.sectionTitle)
                LabeledContent("Name", value: capture.name)
                LabeledContent("Source", value: capture.provenance.sourceID)
                LabeledContent("Model", value: capture.provenance.modelID)
                LabeledContent("Frame", value: String(capture.provenance.frameID))
                LabeledContent("Created", value: capture.createdAt.formatted(date: .abbreviated, time: .shortened))
                Divider()
                Button("Accept", systemImage: "checkmark.circle") {
                    Task { await appModel.reviewCapture(id: id, as: .accepted) }
                }
                .buttonStyle(.borderedProminent)
                Button("Reject", systemImage: "xmark.circle") {
                    Task { await appModel.reviewCapture(id: id, as: .rejected) }
                }
                .buttonStyle(.bordered)
                Button("Move to Trash", systemImage: "trash") {
                    Task { await appModel.trashCapture(id: id) }
                }
                .buttonStyle(.bordered)
                Button("Export capture", systemImage: "square.and.arrow.up") {
                    export(captureID: id)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("capture.export")
                Spacer()
            }
            .padding(DesignTokens.Spacing.standard)
            .canvasCard()
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("capture.details")
        } else {
            EmptyStateView(
                title: "Select a capture",
                symbol: "sidebar.right",
                description: "Review provenance and export a verified bundle."
            )
            .padding(DesignTokens.Spacing.standard)
        }
    }

    private func reviewSymbol(_ review: CaptureReview) -> String {
        switch review {
        case .pending: "circle.dashed"
        case .accepted: "checkmark.circle.fill"
        case .rejected: "xmark.circle.fill"
        }
    }

    private func export(captureID: String) {
        let exports = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Armageddon", isDirectory: true)
            .appendingPathComponent("Exports", isDirectory: true)
        try? FileManager.default.createDirectory(at: exports, withIntermediateDirectories: true)
        let panel = NSOpenPanel()
        panel.title = "Export Capture"
        panel.message = "Choose a destination folder for the verified capture bundle."
        panel.prompt = "Export"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = exports
        guard panel.runModal() == .OK, let directory = panel.url else { return }
        let destination = directory.appendingPathComponent("capture-\(captureID.prefix(8))", isDirectory: true)
        Task { _ = await appModel.exportCapture(id: captureID, to: destination) }
    }
}
