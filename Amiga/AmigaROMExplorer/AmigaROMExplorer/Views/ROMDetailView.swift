import SwiftUI

struct ROMDetailView: View {
    @Environment(ExplorerViewModel.self) private var viewModel

    var body: some View {
        Group {
            if let item = viewModel.selectedItem {
                detailContent(for: item)
            } else {
                welcome
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AmigaTheme.backgroundBottom.opacity(0.2))
    }

    private var welcome: some View {
        ContentUnavailableView {
            Label("Select a ROM", systemImage: "cpu")
        } description: {
            Text("Browse your manifest-backed firmware collection. Sub-agents will deep-research each ROM for hardware context, history, and technical insights.")
        } actions: {
            Button("Research All") {
                viewModel.researchAll()
            }
            .buttonStyle(.borderedProminent)
            .tint(AmigaTheme.accentOrange)
        }
    }

    @ViewBuilder
    private func detailContent(for item: ROMCatalogItem) -> some View {
        let state = viewModel.research.state(for: item)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ROMHeroHeader(item: item, state: state)

                if !item.machines.isEmpty {
                    sectionHeader("Compatible Hardware", symbol: "desktopcomputer")
                    HardwareGrid(models: item.machines)
                }

                if !item.isOnDisk && viewModel.isReferenceOnlyMode {
                    referenceModeBanner
                }

                switch state {
                case .idle, .queued:
                    if viewModel.research.isCacheReady {
                        quickFacts(for: item)
                    } else {
                        ResearchLoadingView(progress: "Loading reference cache…")
                    }
                case .researching(let progress):
                    ResearchLoadingView(progress: progress)
                    quickFacts(for: item)
                case .failed(let message):
                    ResearchSectionView(title: "Research Error", symbol: "exclamationmark.triangle", content: message)
                    quickFacts(for: item)
                case .completed(let research):
                    researchPanels(research)
                }

                manifestPanel(item)
            }
            .padding(24)
        }
        .task(id: item.id) {
            viewModel.research.requestResearch(for: item)
        }
    }

    private var referenceModeBanner: some View {
        GlassCard {
            Label(
                "Reference profile only — ROM file not required. Scan a local folder in Settings to match this entry to files on disk.",
                systemImage: "books.vertical"
            )
            .font(.subheadline)
            .foregroundStyle(AmigaTheme.accentCyan)
        }
    }

    @ViewBuilder
    private func researchPanels(_ research: ROMResearch) -> some View {
        ResearchSectionView(title: "Overview", symbol: "text.book.closed", content: research.summary)
        ResearchSectionView(title: "What's Inside", symbol: "memorychip", content: research.contentsDescription)
        ResearchSectionView(title: "Purpose", symbol: "bolt.fill", content: research.purpose)
        ResearchSectionView(title: "History", symbol: "clock.arrow.circlepath", content: research.history)

        if !research.hardwareModels.isEmpty {
            sectionHeader("Research Hardware Map", symbol: "map")
            HardwareGrid(models: research.hardwareModels)
        }

        if !research.technicalInsights.isEmpty {
            InsightListView(title: "Technical Insights", items: research.technicalInsights)
        }

        if !research.notableLibraries.isEmpty {
            InsightListView(title: "Notable Libraries", items: research.notableLibraries)
        }

        ResearchSectionView(title: "Compatibility", symbol: "checkmark.shield", content: research.compatibilityNotes)

        HStack {
            Text("Source: \(research.researchSource.rawValue)")
            Spacer()
            Text(research.researchedAt.formatted(date: .abbreviated, time: .shortened))
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private func quickFacts(for item: ROMCatalogItem) -> some View {
        let baseline = ROMKnowledgeBase.baselineResearch(for: item)
        ResearchSectionView(title: "Quick Overview", symbol: "sparkles", content: baseline.summary)
    }

    @ViewBuilder
    private func manifestPanel(_ item: ROMCatalogItem) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("Manifest Provenance", systemImage: "doc.text.magnifyingglass")
                    .font(.headline)
                    .foregroundStyle(AmigaTheme.accentMagenta)

                LabeledContent("Source Archive") {
                    Text(item.manifest.source)
                        .textSelection(.enabled)
                }
                LabeledContent("Destination") {
                    Text(item.manifest.destination)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                }
                LabeledContent("Status") {
                    Text(item.manifest.status.label)
                }
                if let info = item.fileInfo {
                    LabeledContent("Size") {
                        Text(ByteCountFormatter.string(fromByteCount: Int64(info.byteCount), countStyle: .file))
                    }
                    if let md5 = info.md5 {
                        LabeledContent("MD5") {
                            Text(md5)
                                .font(.caption.monospaced())
                                .textSelection(.enabled)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func sectionHeader(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.title3.weight(.semibold))
            .foregroundStyle(AmigaTheme.heroGradient)
    }
}

struct ROMHeroHeader: View {
    let item: ROMCatalogItem
    let state: ResearchState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        CategoryBadge(category: item.category)
                        DumpQualityBadge(quality: item.parsed.dumpQuality)
                    }
                    Text(item.displayTitle)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle = item.displaySubtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.72))
                    }
                }
                Spacer()
                statusChip
            }

            HStack(spacing: 10) {
                if !item.versionLabel.isEmpty {
                    StatPill(title: "Version", value: item.versionLabel, symbol: "number")
                }
                StatPill(title: "Variant", value: item.humanizedVariant, symbol: "slider.horizontal.3")
                StatPill(title: "On Disk", value: item.isOnDisk ? "Yes" : "No", symbol: item.isOnDisk ? "checkmark.circle" : "xmark.circle")
                if let year = item.parsed.year {
                    StatPill(title: "Year", value: String(year), symbol: "calendar")
                }
                if let publisher = item.parsed.publisher {
                    StatPill(title: "Publisher", value: publisher, symbol: "building.2")
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AmigaTheme.heroGradient.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AmigaTheme.heroGradient, lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    private var statusChip: some View {
        switch state {
        case .completed:
            Label("Researched", systemImage: "sparkles")
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.green.opacity(0.25), in: Capsule())
        case .researching:
            Label("Researching", systemImage: "antenna.radiowaves.left.and.right")
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.orange.opacity(0.25), in: Capsule())
        default:
            Label("Pending", systemImage: "hourglass")
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.gray.opacity(0.25), in: Capsule())
        }
    }
}