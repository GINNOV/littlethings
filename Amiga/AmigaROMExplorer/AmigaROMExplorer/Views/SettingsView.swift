import AppKit
import SwiftUI

struct SettingsView: View {
    @Environment(ExplorerViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        Form {
            Section("Catalog Mode") {
                Picker("Mode", selection: $viewModel.catalogMode) {
                    Text("Reference catalog only").tag(CatalogMode.referenceOnly)
                    Text("Local ROM library").tag(CatalogMode.localLibrary)
                }
                .onChange(of: viewModel.catalogMode) { _, mode in
                    if mode == .referenceOnly {
                        viewModel.setLocalFirmwareDirectory(nil)
                    }
                }

                if viewModel.catalogMode == .localLibrary {
                    TextField("ROM folder", text: $viewModel.firmwareDirectoryPath)
                    Button("Choose Folder…") { chooseDirectory() }
                }

                LabeledContent("Reference entries") {
                    Text("\(viewModel.catalog.items.count)")
                }
                LabeledContent("Installed locally") {
                    Text("\(viewModel.catalog.installedCount)")
                }
                LabeledContent("Cached research") {
                    Text("\(viewModel.research.completedCount)")
                }

                Button("Reload Catalog") { viewModel.reloadCatalog() }
                Button("Show Setup Wizard") { viewModel.showOnboarding = true }
            }

            Section("Research Sub-Agents") {
                Toggle("Enable LLM sub-agents (Ollama)", isOn: $viewModel.enableSubAgents)
                Toggle("Prefetch missing research on launch", isOn: $viewModel.prefetchResearch)
                TextField("Ollama base URL", text: $viewModel.ollamaBaseURL)
                TextField("Ollama model", text: $viewModel.ollamaModel)
                Button("Test Ollama Connection") { viewModel.testOllamaConnection() }
                Text(viewModel.ollamaStatusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Save Settings") { viewModel.persistSettings() }
            }
        }
        .formStyle(.grouped)
        .frame(width: 560, height: 480)
        .onDisappear { viewModel.persistSettings() }
    }

    private func chooseDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Select your local Amiga firmware folder"

        if panel.runModal() == .OK, let url = panel.url {
            viewModel.catalogMode = .localLibrary
            viewModel.setLocalFirmwareDirectory(url.path)
        }
    }
}