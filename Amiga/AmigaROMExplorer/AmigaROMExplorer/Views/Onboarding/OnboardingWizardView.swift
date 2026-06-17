import AppKit
import SwiftUI

struct OnboardingWizardView: View {
    @Environment(ExplorerViewModel.self) private var viewModel
    @State private var step = 0
    @State private var wantsReferenceOnly = true
    @State private var wantsOllama = false

    private let steps = ["Welcome", "Reference", "ROMs", "Scan", "Ollama", "Ready"]

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            AmigaBackground()

            VStack(spacing: 0) {
                progressHeader

                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    referenceStep.tag(1)
                    getROMsStep.tag(2)
                    scanStep.tag(3)
                    ollamaStep.tag(4)
                    readyStep.tag(5)
                }
                .tabViewStyle(.automatic)
                .frame(maxHeight: .infinity)

                footer
            }
            .padding(28)
        }
        .frame(minWidth: 760, minHeight: 620)
    }

    private var progressHeader: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Amiga ROM Explorer")
                        .font(.title.weight(.bold))
                    Text("Setup wizard")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack(spacing: 8) {
                ForEach(steps.indices, id: \.self) { index in
                    Capsule()
                        .fill(index <= step ? AnyShapeStyle(AmigaTheme.heroGradient) : AnyShapeStyle(Color.white.opacity(0.15)))
                        .frame(height: 4)
                }
            }
        }
        .padding(.bottom, 20)
    }

    private var welcomeStep: some View {
        OnboardingCard(
            title: "Welcome to the ultimate ROM atlas",
            subtitle: "Identify Kickstart revisions, hardware targets, and firmware history — with or without local ROM files.",
            symbol: "sparkles"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                featureRow("folder.fill", "Browse a shipped reference catalog of Amiga firmware")
                featureRow("desktopcomputer", "See which machines each ROM belongs to")
                featureRow("doc.text.magnifyingglass", "Scan your own legally obtained ROM folder later")
                featureRow("antenna.radiowaves.left.and.right", "Optionally enrich research with local Ollama")
            }
        }
    }

    private var referenceStep: some View {
        OnboardingCard(
            title: "Start without downloading ROMs",
            subtitle: "The app ships a folder-agnostic reference catalog and pre-researched profiles so you can learn which ROM is which immediately.",
            symbol: "books.vertical"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                Toggle("Use reference catalog only for now", isOn: $wantsReferenceOnly)
                    .toggleStyle(.switch)

                Text("Reference mode shows manifest entries, hardware mapping, history, and technical notes. It does not require Kickstart files on disk.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                StatPill(title: "Bundled entries", value: "\(viewModel.catalog.items.count)", symbol: "number")
            }
        }
    }

    private var getROMsStep: some View {
        OnboardingCard(
            title: "Getting ROMs legally",
            subtitle: "Amiga ROMs are copyrighted. The app never ships Kickstart or cartridge images.",
            symbol: "checkmark.shield"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                bullet("Purchase ROMs from legal sources such as Amiga Forever or hardware you own.")
                bullet("Extract firmware into the suggested folder layout from the reference readme.")
                bullet("Keep a local manifest.tsv mapping source archives to normalized paths.")
                bullet("Do not redistribute ROM files with this app.")

                Text("Suggested layout: kickstart/<version>/<machine>/<variant>/<name>.rom")
                    .font(.caption.monospaced())
                    .foregroundStyle(AmigaTheme.accentCyan)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AmigaTheme.cardFill, in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var scanStep: some View {
        OnboardingCard(
            title: "Scan your ROM folder",
            subtitle: "Optional. Point the app at a local library to mark which reference entries are installed and compute checksums.",
            symbol: "folder.badge.gearshape"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.firmwareDirectoryPath.isEmpty {
                    Text("No folder selected yet.")
                        .foregroundStyle(.secondary)
                } else {
                    Text(viewModel.firmwareDirectoryPath)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                    Text("\(viewModel.catalog.installedCount) of \(viewModel.catalog.items.count) reference entries found on disk")
                        .font(.subheadline)
                        .foregroundStyle(AmigaTheme.accentOrange)
                }

                HStack {
                    Button("Choose ROM Folder…") {
                        chooseFolder()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AmigaTheme.accentOrange)

                    if !viewModel.firmwareDirectoryPath.isEmpty {
                        Button("Clear Selection") {
                            viewModel.setLocalFirmwareDirectory(nil)
                            wantsReferenceOnly = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }

    private var ollamaStep: some View {
        OnboardingCard(
            title: "Optional: Ollama sub-agents",
            subtitle: "Deep LLM research runs locally. The shipped reference cache already works offline.",
            symbol: "brain"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                Toggle("Enable Ollama sub-agents", isOn: $wantsOllama)
                    .toggleStyle(.switch)
                    .onChange(of: wantsOllama) { _, enabled in
                        viewModel.enableSubAgents = enabled
                    }

                if wantsOllama {
                    TextField("Ollama base URL", text: ollamaURLBinding)
                    TextField("Model name", text: ollamaModelBinding)

                    HStack {
                        Button("Test Connection") {
                            viewModel.testOllamaConnection()
                        }
                        .disabled(viewModel.isTestingOllama)

                        if viewModel.isTestingOllama {
                            ProgressView().controlSize(.small)
                        } else {
                            Text(viewModel.ollamaStatusMessage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text("Install from https://ollama.com, run `ollama pull \(viewModel.ollamaModel)`, then test the connection.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var readyStep: some View {
        OnboardingCard(
            title: "You're ready to explore",
            subtitle: summaryText,
            symbol: "flag.checkered"
        ) {
            VStack(alignment: .leading, spacing: 10) {
                featureRow("books.vertical", "\(viewModel.catalog.items.count) reference ROM profiles available")
                featureRow("sparkles", "\(viewModel.research.completedCount) research profiles loaded from cache")
                if !viewModel.firmwareDirectoryPath.isEmpty {
                    featureRow("externaldrive", "\(viewModel.catalog.installedCount) ROM files detected locally")
                }
            }
        }
    }

    private var summaryText: String {
        if wantsReferenceOnly || viewModel.firmwareDirectoryPath.isEmpty {
            "Reference catalog mode — explore firmware identities without local ROM files."
        } else {
            "Local library mode — reference catalog enriched with your scanned ROM folder."
        }
    }

    private var footer: some View {
        HStack {
            if step > 0 {
                Button("Back") { step -= 1 }
                    .buttonStyle(.bordered)
            }

            Spacer()

            if step < steps.count - 1 {
                Button("Continue") { step += 1 }
                    .buttonStyle(.borderedProminent)
                    .tint(AmigaTheme.accentOrange)
            } else {
                Button("Start Exploring") {
                    viewModel.completeOnboarding(referenceOnly: wantsReferenceOnly && viewModel.firmwareDirectoryPath.isEmpty)
                }
                .buttonStyle(.borderedProminent)
                .tint(AmigaTheme.accentOrange)
            }
        }
        .padding(.top, 18)
    }

    private func featureRow(_ symbol: String, _ text: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.subheadline)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
                .font(.subheadline)
        }
    }

    private var ollamaURLBinding: Binding<String> {
        Binding(
            get: { viewModel.ollamaBaseURL },
            set: { viewModel.ollamaBaseURL = $0 }
        )
    }

    private var ollamaModelBinding: Binding<String> {
        Binding(
            get: { viewModel.ollamaModel },
            set: { viewModel.ollamaModel = $0 }
        )
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Select your local Amiga firmware folder"

        if panel.runModal() == .OK, let url = panel.url {
            wantsReferenceOnly = false
            viewModel.setLocalFirmwareDirectory(url.path)
        }
    }
}

struct OnboardingCard<Content: View>: View {
    let title: String
    let subtitle: String
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                Label(title, systemImage: symbol)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AmigaTheme.heroGradient)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}