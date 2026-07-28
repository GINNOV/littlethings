//
//  UtilitiesCommands.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI

struct UtilitiesCommands: Commands {
    @FocusedBinding(\.document) var document: PixDeluxeDocument?

    var body: some Commands {
        CommandMenu("Utilities") {
            Button("Generate and Copy Hexdump") {
                document?.generateHexdump()
            }
            .disabled(document?.chunkyData == nil)
            .keyboardShortcut("h", modifiers: [.command, .shift])

            Button("Convert to IFF...") {
                beginIFFConversion()
            }

            Divider()
            
            Button("Export as PNG...") {
                document?.exportToPNG()
            }
            .disabled(document?.image == nil)
            
            Button("Export as JPG...") {
                document?.exportToJPEG()
            }
            .disabled(document?.image == nil)
        }
    }

    @MainActor
    private func beginIFFConversion() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.png, .jpeg]
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = true

        guard openPanel.runModal() == .OK, !openPanel.urls.isEmpty else {
            return
        }

        let inputURLs = openPanel.urls
        guard let outputDirectory = outputDirectory(for: inputURLs) else {
            return
        }

        let colorDepthDialog = ColorDepthDialog()
        guard let nPlanes = colorDepthDialog.runModal() else {
            return
        }

        let converter = BatchImageConverter()
        var conversionTask: Task<Void, Never>?
        let progressDialog = BatchConversionProgressDialog(totalCount: inputURLs.count) {
            conversionTask?.cancel()
        }

        progressDialog.show()
        conversionTask = Task {
            let result = await converter.convert(
                inputURLs: inputURLs,
                outputDirectory: outputDirectory,
                nPlanes: nPlanes
            ) { progress in
                progressDialog.update(
                    BatchConversionProgressPresentation(
                        completedCount: progress.completedCount,
                        totalCount: progress.totalCount,
                        currentFilename: progress.currentInputURL.lastPathComponent
                    )
                )
            }

            if inputURLs.count == 1, let outputURL = result.successes.first?.outputURL {
                progressDialog.close()
                openConvertedDocument(at: outputURL)
                return
            }

            progressDialog.showSummary(
                BatchConversionSummaryPresentation(
                    successfulURLs: result.successes.map(\.outputURL),
                    failures: result.failures.map {
                        BatchConversionFailurePresentation(
                            filename: $0.inputURL.lastPathComponent,
                            reason: $0.message
                        )
                    },
                    outputDirectory: outputDirectory,
                    wasCancelled: result.wasCancelled
                )
            )
        }
    }

    @MainActor
    private func outputDirectory(for inputURLs: [URL]) -> URL? {
        guard inputURLs.count > 1 else {
            return FileManager.default.temporaryDirectory
        }

        let panel = NSOpenPanel()
        panel.title = "Choose an Output Folder"
        panel.prompt = "Choose"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK else {
            return nil
        }
        return panel.url
    }

    @MainActor
    private func openConvertedDocument(at url: URL) {
        NSDocumentController.shared.openDocument(withContentsOf: url, display: true) { _, _, error in
            if let error {
                let alert = NSAlert(error: error)
                alert.messageText = "Couldn’t Open Converted Image"
                alert.runModal()
            }
        }
    }
}
