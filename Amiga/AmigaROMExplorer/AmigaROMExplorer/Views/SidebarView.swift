import SwiftUI

struct SidebarView: View {
    @Environment(ExplorerViewModel.self) private var viewModel

    var body: some View {
        List(selection: Binding(
            get: { viewModel.selectedCategory },
            set: { viewModel.selectedCategory = $0; viewModel.selectedItemID = nil }
        )) {
            Section {
                sidebarRow(category: nil, count: viewModel.catalog.items.count)
            } header: {
                header
            }

            Section("Collections") {
                ForEach(ROMCategory.allCases.filter { $0 != .other }) { category in
                    sidebarRow(category: category, count: viewModel.categoryCounts[category, default: 0])
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
                Label("\(viewModel.research.completedCount) cached profiles", systemImage: "checkmark.seal.fill")
                Label("\(viewModel.research.activeAgentCount) active agents", systemImage: "antenna.radiowaves.left.and.right")
                Button("Refresh Missing Research") {
                    viewModel.researchAll()
                }
                .buttonStyle(.borderless)
                .foregroundStyle(AmigaTheme.accentOrange)
            }

            Section {
                Button("Setup Wizard…") {
                    viewModel.showOnboarding = true
                }
                .buttonStyle(.borderless)
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
    private func sidebarRow(category: ROMCategory?, count: Int) -> some View {
        let title = category?.title ?? "All ROMs"
        let symbol = category?.symbolName ?? "square.grid.2x2"

        HStack {
            Label(title, systemImage: symbol)
            Spacer()
            Text("\(count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .tag(category)
    }
}