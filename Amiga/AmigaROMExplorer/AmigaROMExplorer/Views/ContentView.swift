import SwiftUI

struct ContentView: View {
    @Environment(ExplorerViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 240, ideal: 270, max: 320)
        } content: {
            ROMListView()
                .navigationSplitViewColumnWidth(min: 300, ideal: 360, max: 420)
        } detail: {
            ROMDetailView()
        }
        .background {
            AmigaBackground()
        }
        .searchable(text: $viewModel.searchText, prompt: "Search ROMs, machines, versions…")
        .task {
            if viewModel.catalog.items.isEmpty {
                viewModel.reloadCatalog()
            }
        }
        .accessibilityIdentifier(UITestingSupport.AccessibilityID.explorerRoot)
    }
}