import SwiftUI

struct SidebarView: View {
    @Environment(ExplorerViewModel.self) private var viewModel

    private var research: ROMResearchService { viewModel.research }

    var body: some View {
        List {
            Section {
                sidebarRow(
                    title: "All ROMs",
                    symbol: "square.grid.2x2",
                    count: viewModel.catalog.items.count,
                    isSelected: viewModel.selectedCategory == nil && viewModel.selectedHardwareModel == nil
                ) {
                    viewModel.selectAllROMs()
                }
            } header: {
                header
            }

            Section("Collections") {
                ForEach(ROMCategory.allCases.filter { $0 != .other }) { category in
                    sidebarRow(
                        title: category.title,
                        symbol: category.symbolName,
                        count: viewModel.categoryCounts[category, default: 0],
                        isSelected: viewModel.selectedCategory == category && viewModel.selectedHardwareModel == nil
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }

            Section("Amiga Models") {
                ForEach(viewModel.hardwareModelCounts, id: \.model.id) { entry in
                    sidebarRow(
                        title: entry.model.name,
                        symbol: entry.model.symbolName,
                        count: entry.count,
                        isSelected: viewModel.selectedHardwareModel?.id == entry.model.id
                    ) {
                        viewModel.selectHardwareModel(entry.model)
                    }
                }
            }

            Section("Mode") {
                Label(
                    viewModel.isReferenceOnlyMode ? "Reference catalog" : "Local library",
                    systemImage: viewModel.isReferenceOnlyMode ? "books.vertical" : "externaldrive"
                )
                if !viewModel.isReferenceOnlyMode {
                    Label("\(viewModel.catalog.installedCount) ROMs on disk", systemImage: "checkmark.circle")
                }
            }

            Section("Research") {
                Label("\(research.completedCount) cached profiles", systemImage: "checkmark.seal.fill")
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(research.completedCount) cached profiles")
                    .accessibilityIdentifier(UITestingSupport.AccessibilityID.Research.cachedProfiles)
                    .accessibilityValue("\(research.completedCount)")

                if research.isCacheReady {
                    Text("Cache ready")
                        .font(.system(size: 1))
                        .opacity(0.01)
                        .accessibilityIdentifier(UITestingSupport.AccessibilityID.Research.cacheReady)
                        .accessibilityLabel("Cache ready")
                }
                Label("\(research.activeAgentCount) active agents", systemImage: "antenna.radiowaves.left.and.right")

                if research.activeAgentCount > 0 || research.queuedResearchCount > 0 {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Research in progress…")
                            .font(.caption)
                            .foregroundStyle(AmigaTheme.accentOrange)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier(UITestingSupport.AccessibilityID.Research.researchInProgress)
                }

                if let message = viewModel.bulkResearchFeedback ?? research.bulkResearchMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier(UITestingSupport.AccessibilityID.Research.bulkMessageSidebar)
                }

                Button("Refresh Missing Research") {
                    viewModel.researchAll(forceRefresh: false)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(AmigaTheme.accentOrange)
                .disabled(research.activeAgentCount > 0)
                .accessibilityIdentifier(UITestingSupport.AccessibilityID.Research.refreshMissing)

                if viewModel.enableSubAgents {
                    Button("Re-research All with Ollama") {
                        viewModel.researchAll(forceRefresh: true)
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(AmigaTheme.accentCyan)
                    .disabled(research.activeAgentCount > 0)
                    .accessibilityIdentifier(UITestingSupport.AccessibilityID.Research.reresearchAll)
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(AmigaTheme.backgroundTop.opacity(0.35))
        .navigationTitle("Explorer")
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: AmigaTheme.accentOrange.opacity(0.35), radius: 8, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Amiga ROM")
                    .font(.title2.weight(.bold))
                Text("Ultimate firmware atlas")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func sidebarRow(
        title: String,
        symbol: String,
        count: Int,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: symbol)
                Spacer()
                Text("\(count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(rowBackground(isSelected: isSelected))
    }

    @ViewBuilder
    private func rowBackground(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.accentColor.opacity(0.22))
        } else {
            Color.clear
        }
    }
}