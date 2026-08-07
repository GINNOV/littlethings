import SwiftUI

struct ROMDetailView: View {
    @Environment(ExplorerViewModel.self) private var viewModel

    private var research: ROMResearchService { viewModel.research }

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
                viewModel.researchAll(forceRefresh: viewModel.enableSubAgents)
            }
            .buttonStyle(.borderedProminent)
            .tint(AmigaTheme.accentOrange)
            .accessibilityIdentifier(UITestingSupport.AccessibilityID.Research.researchAll)

            if let message = viewModel.bulkResearchFeedback ?? research.bulkResearchMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(UITestingSupport.AccessibilityID.Research.bulkMessageWelcome)
            }
        }
    }

    @ViewBuilder
    private func detailContent(for item: ROMCatalogItem) -> some View {
        let state = research.state(for: item)

        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ROMHeroHeader(item: item, state: state)

                    if !item.isOnDisk && viewModel.isReferenceOnlyMode {
                        referenceModeBanner
                    }

                    switch state {
                    case .idle, .queued:
                        if research.isCacheReady {
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
                .padding(.bottom, 8)
            }

            hardwareModelFooter(for: item)
        }
        .task(id: item.id) {
            research.requestResearch(for: item)
        }
    }

    @ViewBuilder
    private func hardwareModelFooter(for item: ROMCatalogItem) -> some View {
        HStack(alignment: .center, spacing: 14) {
            if let primary = item.machines.first {
                Image(systemName: primary.symbolName)
                    .font(.title2)
                    .foregroundStyle(AmigaTheme.accentOrange)
                    .frame(width: 28)
            } else {
                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 28)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Compatible Amiga")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                if item.machines.isEmpty {
                    Text("No specific model mapped")
                        .font(.subheadline.weight(.semibold))
                } else {
                    Text(item.machines.map(\.name).joined(separator: " · "))
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 12)

            if !item.machines.isEmpty {
                VStack(alignment: .trailing, spacing: 3) {
                    Text("Chipset")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(uniqueChipsets(for: item.machines))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AmigaTheme.accentCyan)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AmigaTheme.cardStroke)
                .frame(height: 1)
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

    private func uniqueChipsets(for models: [HardwareModel]) -> String {
        var seen = Set<String>()
        return models.compactMap { model in
            seen.insert(model.chipset).inserted ? model.chipset : nil
        }.joined(separator: " · ")
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