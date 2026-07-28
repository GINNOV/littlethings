import AppKit

struct BatchConversionProgressPresentation {
    let completedCount: Int
    let totalCount: Int
    let currentFilename: String
}

struct BatchConversionFailurePresentation {
    let filename: String
    let reason: String
}

struct BatchConversionSummaryPresentation {
    let successfulURLs: [URL]
    let failures: [BatchConversionFailurePresentation]
    let outputDirectory: URL
    let wasCancelled: Bool
}

@MainActor
final class BatchConversionProgressDialog: NSObject {
    private let panel: NSPanel
    private let titleLabel = NSTextField(labelWithString: "Converting Images")
    private let filenameLabel = NSTextField(labelWithString: "")
    private let countLabel = NSTextField(labelWithString: "")
    private let progressIndicator = NSProgressIndicator()
    private let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)
    private var onCancel: (() -> Void)?

    init(totalCount: Int, onCancel: @escaping () -> Void) {
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 164),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        self.onCancel = onCancel
        super.init()

        panel.title = "Convert to IFF"
        panel.isReleasedWhenClosed = false
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.delegate = self

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        filenameLabel.lineBreakMode = .byTruncatingMiddle
        filenameLabel.textColor = .secondaryLabelColor
        countLabel.stringValue = "0 of \(totalCount)"
        countLabel.alignment = .right
        countLabel.textColor = .secondaryLabelColor

        progressIndicator.isIndeterminate = false
        progressIndicator.minValue = 0
        progressIndicator.maxValue = Double(totalCount)
        progressIndicator.doubleValue = 0

        cancelButton.target = self
        cancelButton.action = #selector(cancel)
        cancelButton.keyEquivalent = "\u{1b}"

        let contentView = NSView()
        panel.contentView = contentView

        for view in [titleLabel, filenameLabel, countLabel, progressIndicator, cancelButton] {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            filenameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            filenameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            filenameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            progressIndicator.topAnchor.constraint(equalTo: filenameLabel.bottomAnchor, constant: 12),
            progressIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            countLabel.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 10),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            countLabel.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -12),
            countLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),

            cancelButton.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18)
        ])
    }

    func show() {
        panel.center()
        panel.makeKeyAndOrderFront(nil)
    }

    func update(_ progress: BatchConversionProgressPresentation) {
        filenameLabel.stringValue = progress.currentFilename
        countLabel.stringValue = "\(progress.completedCount) of \(progress.totalCount)"
        progressIndicator.maxValue = Double(progress.totalCount)
        progressIndicator.doubleValue = Double(progress.completedCount)
    }

    func close() {
        onCancel = nil
        panel.delegate = nil
        panel.orderOut(nil)
    }

    func showSummary(_ summary: BatchConversionSummaryPresentation) {
        close()

        let alert = NSAlert()
        alert.messageText = summary.wasCancelled ? "Conversion Cancelled" : "Conversion Complete"
        alert.informativeText = summaryText(for: summary)
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Show in Finder")

        if alert.runModal() == .alertSecondButtonReturn {
            NSWorkspace.shared.activateFileViewerSelecting([summary.outputDirectory])
        }
    }

    @objc
    private func cancel() {
        cancelButton.isEnabled = false
        cancelButton.title = "Cancelling…"
        onCancel?()
    }

    private func summaryText(for summary: BatchConversionSummaryPresentation) -> String {
        var lines = [
            "\(summary.successfulURLs.count) succeeded, \(summary.failures.count) failed.",
            "Output: \(summary.outputDirectory.path)"
        ]

        if !summary.successfulURLs.isEmpty {
            lines.append("")
            lines.append("Succeeded:")
            lines.append(contentsOf: summary.successfulURLs.map { "• \($0.lastPathComponent)" })
        }

        if !summary.failures.isEmpty {
            lines.append("")
            lines.append("Failed:")
            lines.append(contentsOf: summary.failures.map { "• \($0.filename): \($0.reason)" })
        }

        return lines.joined(separator: "\n")
    }
}

extension BatchConversionProgressDialog: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        cancel()
        return false
    }
}
