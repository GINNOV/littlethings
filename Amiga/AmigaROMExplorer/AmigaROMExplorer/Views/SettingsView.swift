import AppKit
import SwiftUI

struct SettingsView: View {
    @Environment(ExplorerViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            AmigaBackground()

            ScrollView {
                VStack(spacing: 20) {
                    header

                    OnboardingCard(
                        title: "Catalog Mode",
                        subtitle: "Browse the shipped reference atlas on its own, or enrich it by scanning a local ROM folder. Flat folders and TOSEC-style names are matched by checksum.",
                        symbol: "books.vertical"
                    ) {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(spacing: 12) {
                                modeOption(
                                    title: "Reference catalog",
                                    subtitle: "No local ROMs required",
                                    symbol: "books.vertical",
                                    isSelected: viewModel.catalogMode == .referenceOnly
                                ) {
                                    viewModel.catalogMode = .referenceOnly
                                    viewModel.setLocalFirmwareDirectory(nil)
                                }

                                modeOption(
                                    title: "Local library",
                                    subtitle: "Match files on disk",
                                    symbol: "externaldrive",
                                    isSelected: viewModel.catalogMode == .localLibrary
                                ) {
                                    viewModel.catalogMode = .localLibrary
                                }
                            }

                            if viewModel.catalogMode == .localLibrary {
                                localLibraryControls
                            }

                            HStack(spacing: 10) {
                                StatPill(
                                    title: "Reference entries",
                                    value: "\(viewModel.catalog.items.count)",
                                    symbol: "number"
                                )
                                StatPill(
                                    title: "Installed locally",
                                    value: "\(viewModel.catalog.installedCount)",
                                    symbol: "checkmark.circle"
                                )
                                StatPill(
                                    title: "Cached research",
                                    value: "\(viewModel.research.completedCount)",
                                    symbol: "checkmark.seal"
                                )
                            }

                            HStack(spacing: 12) {
                                Button("Reload Catalog") { viewModel.reloadCatalog() }
                                    .buttonStyle(.bordered)

                                Button("Show Setup Wizard") { viewModel.showOnboarding = true }
                                    .buttonStyle(.bordered)
                            }
                        }
                    }

                    OnboardingCard(
                        title: "Research Sub-Agents",
                        subtitle: "Optional local Ollama enrichment for ROM profiles that are not already in the bundled cache.",
                        symbol: "brain"
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle("Enable LLM sub-agents (Ollama)", isOn: $viewModel.enableSubAgents)
                                .toggleStyle(.switch)

                            Toggle("Prefetch missing research on launch", isOn: $viewModel.prefetchResearch)
                                .toggleStyle(.switch)

                            if viewModel.enableSubAgents {
                                VStack(alignment: .leading, spacing: 12) {
                                    settingsField("Ollama base URL", text: $viewModel.ollamaBaseURL)
                                    settingsField("Ollama model", text: $viewModel.ollamaModel)

                                    Button("Use recommended model (llama3.2)") {
                                        viewModel.ollamaBaseURL = AppSettings.defaultOllamaBaseURL
                                        viewModel.ollamaModel = AppSettings.defaultOllamaModel
                                    }
                                    .buttonStyle(.borderless)
                                    .foregroundStyle(AmigaTheme.accentCyan)

                                    HStack(alignment: .center, spacing: 12) {
                                        Button("Test Ollama Connection") {
                                            viewModel.testOllamaConnection()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(AmigaTheme.accentOrange)
                                        .disabled(viewModel.isTestingOllama)

                                        if viewModel.isTestingOllama {
                                            ProgressView()
                                                .controlSize(.small)
                                        } else {
                                            Text(viewModel.ollamaStatusMessage)
                                                .font(.caption)
                                                .foregroundStyle(ollamaStatusColor)
                                        }
                                    }
                                }
                            } else {
                                Text("The bundled reference cache works fully offline. Enable Ollama when you want deeper LLM research for uncached entries.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    HStack {
                        Spacer()
                        Button("Save Settings") { viewModel.persistSettings() }
                            .buttonStyle(.borderedProminent)
                            .tint(AmigaTheme.accentOrange)
                    }
                }
                .padding(24)
            }
        }
        .frame(minWidth: 600, minHeight: 560)
        .onDisappear { viewModel.persistSettings() }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(AmigaTheme.heroGradient)
                .frame(width: 48, height: 48)
                .background(AmigaTheme.cardFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AmigaTheme.cardStroke, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Settings")
                    .font(.title.weight(.bold))
                Text("Catalog, library, and research preferences")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var localLibraryControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.firmwareDirectoryPath.isEmpty {
                Text("No ROM folder selected yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text(viewModel.firmwareDirectoryPath)
                    .font(.caption.monospaced())
                    .textSelection(.enabled)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AmigaTheme.cardFill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                if let report = viewModel.catalog.localScanReport {
                    LocalROMScanSummaryView(report: report)
                } else if viewModel.catalog.isLoading {
                    Text("Scanning ROM folder…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(viewModel.catalog.installedCount) of \(viewModel.catalog.items.count) reference entries found on disk")
                        .font(.subheadline)
                        .foregroundStyle(AmigaTheme.accentOrange)
                }
            }

            HStack(spacing: 12) {
                Button("Choose Folder…") { chooseDirectory() }
                    .buttonStyle(.borderedProminent)
                    .tint(AmigaTheme.accentOrange)

                if !viewModel.firmwareDirectoryPath.isEmpty {
                    Button("Clear Selection") {
                        viewModel.setLocalFirmwareDirectory(nil)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var ollamaStatusColor: Color {
        let message = viewModel.ollamaStatusMessage.lowercased()
        if message.contains("reachable") {
            return .green
        }
        if message.contains("could not") || message.contains("fail") {
            return .orange
        }
        return .secondary
    }

    private func settingsField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(title, text: text)
                .textFieldStyle(.plain)
                .font(.body.monospaced())
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AmigaTheme.cardFill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AmigaTheme.cardStroke, lineWidth: 1)
                )
        }
    }

    private func modeOption(
        title: String,
        subtitle: String,
        symbol: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(isSelected ? AmigaTheme.accentOrange : .secondary)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                isSelected ? AmigaTheme.accentOrange.opacity(0.14) : AmigaTheme.cardFill,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? AmigaTheme.accentOrange.opacity(0.55) : AmigaTheme.cardStroke,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
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