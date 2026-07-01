import SwiftUI

struct ROMListView: View {
    @Environment(ExplorerViewModel.self) private var viewModel

    var body: some View {
        Group {
            if viewModel.catalog.isLoading {
                ProgressView("Loading manifest…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.catalog.lastError {
                ContentUnavailableView("Manifest Error", systemImage: "exclamationmark.triangle", description: Text(error))
            } else if viewModel.filteredItems.isEmpty {
                ContentUnavailableView("No ROMs", systemImage: "opticaldisc", description: Text("Try another category, Amiga model, or search term."))
            } else {
                List(viewModel.filteredItems, selection: Binding(
                    get: { viewModel.selectedItemID },
                    set: { id in
                        viewModel.selectedItemID = id
                        if let id, let item = viewModel.catalog.item(withID: id) {
                            viewModel.select(item)
                        }
                    }
                )) { item in
                    ROMListRow(item: item, researchState: viewModel.research.state(for: item))
                        .tag(item.id)
                }
                .listStyle(.inset)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AmigaTheme.backgroundBottom.opacity(0.25))
        .navigationTitle(viewModel.listTitle)
        .navigationSubtitle(viewModel.listSubtitle)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Reload", systemImage: "arrow.clockwise") {
                    viewModel.reloadCatalog()
                }
            }
        }
    }
}

struct ROMListRow: View {
    let item: ROMCatalogItem
    let researchState: ResearchState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                CategoryBadge(category: item.category)
                DumpQualityBadge(quality: item.parsed.dumpQuality)
                Spacer()
                researchIndicator
            }

            Text(item.displayTitle)
                .font(.headline)
                .lineLimit(2)

            if let subtitle = item.displaySubtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AmigaTheme.accentCyan)
                    .lineLimit(1)
            } else if !item.machines.isEmpty {
                Text(item.machines.map(\.name).joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(AmigaTheme.accentCyan)
                    .lineLimit(1)
            }

            Text(item.manifest.destination)
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var researchIndicator: some View {
        switch researchState {
        case .completed:
            Image(systemName: "sparkles")
                .foregroundStyle(AmigaTheme.accentOrange)
                .help("Research ready")
        case .researching:
            ProgressView()
                .controlSize(.small)
        case .queued:
            Image(systemName: "hourglass")
                .foregroundStyle(.yellow)
        case .failed:
            Image(systemName: "xmark.circle")
                .foregroundStyle(.red)
        case .idle:
            Image(systemName: "circle.dashed")
                .foregroundStyle(.secondary)
        }
    }
}